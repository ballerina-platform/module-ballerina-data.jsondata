/*
 * Copyright (c) 2024, WSO2 LLC. (https://www.wso2.com).
 *
 * WSO2 LLC. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package io.ballerina.stdlib.data.jsondata.compiler;

import io.ballerina.compiler.api.SemanticModel;
import io.ballerina.compiler.api.symbols.ArrayTypeSymbol;
import io.ballerina.compiler.api.symbols.RecordFieldSymbol;
import io.ballerina.compiler.api.symbols.RecordTypeSymbol;
import io.ballerina.compiler.api.symbols.Symbol;
import io.ballerina.compiler.api.symbols.TupleTypeSymbol;
import io.ballerina.compiler.api.symbols.TypeDescKind;
import io.ballerina.compiler.api.symbols.TypeReferenceTypeSymbol;
import io.ballerina.compiler.api.symbols.TypeSymbol;
import io.ballerina.compiler.api.symbols.UnionTypeSymbol;
import io.ballerina.compiler.api.symbols.VariableSymbol;
import io.ballerina.compiler.syntax.tree.CheckExpressionNode;
import io.ballerina.compiler.syntax.tree.ChildNodeList;
import io.ballerina.compiler.syntax.tree.ExpressionNode;
import io.ballerina.compiler.syntax.tree.FunctionCallExpressionNode;
import io.ballerina.compiler.syntax.tree.FunctionDefinitionNode;
import io.ballerina.compiler.syntax.tree.ModuleMemberDeclarationNode;
import io.ballerina.compiler.syntax.tree.ModulePartNode;
import io.ballerina.compiler.syntax.tree.ModuleVariableDeclarationNode;
import io.ballerina.compiler.syntax.tree.Node;
import io.ballerina.compiler.syntax.tree.SyntaxKind;
import io.ballerina.compiler.syntax.tree.VariableDeclarationNode;
import io.ballerina.projects.plugins.AnalysisTask;
import io.ballerina.projects.plugins.SyntaxNodeAnalysisContext;
import io.ballerina.tools.diagnostics.Diagnostic;
import io.ballerina.tools.diagnostics.DiagnosticFactory;
import io.ballerina.tools.diagnostics.DiagnosticInfo;
import io.ballerina.tools.diagnostics.DiagnosticSeverity;
import io.ballerina.tools.diagnostics.Location;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * Jsondata Record Field Validator.
 */
public class JsondataRecordFieldValidator implements AnalysisTask<SyntaxNodeAnalysisContext> {

    private SemanticModel semanticModel;
    private final HashMap<Location, DiagnosticInfo> allDiagnosticInfo = new HashMap<>();
    Location currentLocation;

    @Override
    public void perform(SyntaxNodeAnalysisContext ctx) {
        semanticModel = ctx.semanticModel();
        List<Diagnostic> diagnostics = semanticModel.diagnostics();
        boolean erroneousCompilation = diagnostics.stream()
                .anyMatch(d -> d.diagnosticInfo().severity().equals(DiagnosticSeverity.ERROR));
        if (erroneousCompilation) {
            return;
        }

        ModulePartNode rootNode = (ModulePartNode) ctx.node();
        for (ModuleMemberDeclarationNode member : rootNode.members()) {
            switch (member.kind()) {
                case FUNCTION_DEFINITION -> processFunctionDefinitionNode((FunctionDefinitionNode) member, ctx);
                case MODULE_VAR_DECL ->
                        processModuleVariableDeclarationNode((ModuleVariableDeclarationNode) member, ctx);
            }
        }
    }

    private void processFunctionDefinitionNode(FunctionDefinitionNode functionDefinitionNode,
                                               SyntaxNodeAnalysisContext ctx) {
        ChildNodeList childNodeList = functionDefinitionNode.functionBody().children();
        for (Node node : childNodeList) {
            if (node.kind() != SyntaxKind.LOCAL_VAR_DECL) {
                continue;
            }
            VariableDeclarationNode variableDeclarationNode = (VariableDeclarationNode) node;
            Optional<ExpressionNode> initializer = variableDeclarationNode.initializer();
            if (initializer.isEmpty() || !isFromJsonFunctionFromXmldata(initializer.get())) {
                continue;
            }

            currentLocation = variableDeclarationNode.typedBindingPattern().typeDescriptor().location();
            Optional<Symbol> symbol = semanticModel.symbol(variableDeclarationNode.typedBindingPattern());
            if (symbol.isEmpty()) {
                continue;
            }
            validateExpectedType(((VariableSymbol) symbol.get()).typeDescriptor(), ctx);
        }
    }

    private boolean isFromJsonFunctionFromXmldata(ExpressionNode expressionNode) {
        if (expressionNode.kind() == SyntaxKind.CHECK_EXPRESSION) {
            expressionNode = ((CheckExpressionNode) expressionNode).expression();
        }

        if (expressionNode.kind() != SyntaxKind.FUNCTION_CALL) {
            return false;
        }
        String functionName = ((FunctionCallExpressionNode) expressionNode).functionName().toSourceCode().trim();
        return functionName.contains(Constants.FROM_JSON_STRING_WITH_TYPE);
    }

    private void validateExpectedType(TypeSymbol typeSymbol, SyntaxNodeAnalysisContext ctx) {
        typeSymbol.getLocation().ifPresent(location -> currentLocation = location);
        switch (typeSymbol.typeKind()) {
            case UNION -> {
                validateUnionType((UnionTypeSymbol) typeSymbol, typeSymbol.getLocation(), ctx);
            }
            case RECORD -> {
                validateRecordType((RecordTypeSymbol) typeSymbol, ctx);
            }
            case ARRAY -> {
                validateExpectedType(((ArrayTypeSymbol) typeSymbol).memberTypeDescriptor(), ctx);
            }
            case TUPLE -> {
                validateTupleType((TupleTypeSymbol) typeSymbol, ctx);
            }
            case TYPE_REFERENCE -> {
                validateExpectedType(((TypeReferenceTypeSymbol) typeSymbol).typeDescriptor(), ctx);
            }
        }
    }

    private void validateTupleType(TupleTypeSymbol tupleTypeSymbol, SyntaxNodeAnalysisContext ctx) {
        for (TypeSymbol memberType : tupleTypeSymbol.memberTypeDescriptors()) {
            validateExpectedType(memberType, ctx);
        }
    }

    private void validateRecordType(RecordTypeSymbol recordTypeSymbol, SyntaxNodeAnalysisContext ctx) {
        for (Map.Entry<String, RecordFieldSymbol> entry : recordTypeSymbol.fieldDescriptors().entrySet()) {
            RecordFieldSymbol fieldSymbol = entry.getValue();
            TypeSymbol typeSymbol = fieldSymbol.typeDescriptor();
            validateRecordFieldType(typeSymbol, fieldSymbol.getLocation(), ctx);
        }
    }

    private void validateRecordFieldType(TypeSymbol typeSymbol, Optional<Location> location,
                                         SyntaxNodeAnalysisContext ctx) {
        switch (typeSymbol.typeKind()) {
            case UNION -> validateUnionType((UnionTypeSymbol) typeSymbol, location, ctx);
            case ARRAY -> validateRecordFieldType(((ArrayTypeSymbol) typeSymbol).memberTypeDescriptor(), location, ctx);
            case TYPE_REFERENCE ->
                    validateRecordFieldType(((TypeReferenceTypeSymbol) typeSymbol).typeDescriptor(), location, ctx);
        }
    }

    private void validateUnionType(UnionTypeSymbol unionTypeSymbol, Optional<Location> location,
                                   SyntaxNodeAnalysisContext ctx) {
        int nonPrimitiveMemberCount = 0;
        List<TypeSymbol> memberTypeSymbols = unionTypeSymbol.memberTypeDescriptors();
        for (TypeSymbol memberTypeSymbol : memberTypeSymbols) {
            if (isPrimitiveType(memberTypeSymbol)) {
                continue;
            }
            nonPrimitiveMemberCount++;
        }

        if (nonPrimitiveMemberCount > 1) {
            reportDiagnosticInfo(ctx, location, JsondataDiagnosticCodes.UNSUPPORTED_UNION_TYPE);
        }
    }

    private boolean isPrimitiveType(TypeSymbol typeSymbol) {
        TypeDescKind kind = typeSymbol.typeKind();
        if (kind == TypeDescKind.TYPE_REFERENCE) {
            kind = ((TypeReferenceTypeSymbol) typeSymbol).typeDescriptor().typeKind();
        }

        return kind == TypeDescKind.INT || kind == TypeDescKind.FLOAT || kind == TypeDescKind.DECIMAL
                || kind == TypeDescKind.STRING || kind == TypeDescKind.BOOLEAN || kind == TypeDescKind.BYTE
                || kind == TypeDescKind.NIL;
    }

    private void reportDiagnosticInfo(SyntaxNodeAnalysisContext ctx, Optional<Location> location,
                                      JsondataDiagnosticCodes diagnosticsCodes) {
        Location pos = location.orElseGet(() -> currentLocation);
        DiagnosticInfo diagnosticInfo = new DiagnosticInfo(diagnosticsCodes.getCode(),
                diagnosticsCodes.getMessage(), diagnosticsCodes.getSeverity());
        if (allDiagnosticInfo.containsKey(pos) && allDiagnosticInfo.get(pos).equals(diagnosticInfo)) {
            return;
        }
        allDiagnosticInfo.put(pos, diagnosticInfo);
        ctx.reportDiagnostic(DiagnosticFactory.createDiagnostic(diagnosticInfo, pos));
    }

    private void processModuleVariableDeclarationNode(ModuleVariableDeclarationNode moduleVariableDeclarationNode,
                                                      SyntaxNodeAnalysisContext ctx) {
        Optional<ExpressionNode> initializer = moduleVariableDeclarationNode.initializer();
        if (initializer.isEmpty() || !isFromJsonFunctionFromXmldata(initializer.get())) {
            return;
        }

        Optional<Symbol> symbol = semanticModel.symbol(moduleVariableDeclarationNode.typedBindingPattern());
        if (symbol.isEmpty()) {
            return;
        }
        TypeSymbol typeSymbol = ((VariableSymbol) symbol.get()).typeDescriptor();
        validateExpectedType(typeSymbol, ctx);
    }
}
