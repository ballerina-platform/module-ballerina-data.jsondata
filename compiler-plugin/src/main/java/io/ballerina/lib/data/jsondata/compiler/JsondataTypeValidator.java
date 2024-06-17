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

package io.ballerina.lib.data.jsondata.compiler;

import io.ballerina.compiler.api.ModuleID;
import io.ballerina.compiler.api.SemanticModel;
import io.ballerina.compiler.api.symbols.AnnotationAttachmentSymbol;
import io.ballerina.compiler.api.symbols.AnnotationSymbol;
import io.ballerina.compiler.api.symbols.ArrayTypeSymbol;
import io.ballerina.compiler.api.symbols.IntersectionTypeSymbol;
import io.ballerina.compiler.api.symbols.ModuleSymbol;
import io.ballerina.compiler.api.symbols.RecordFieldSymbol;
import io.ballerina.compiler.api.symbols.RecordTypeSymbol;
import io.ballerina.compiler.api.symbols.Symbol;
import io.ballerina.compiler.api.symbols.SymbolKind;
import io.ballerina.compiler.api.symbols.TupleTypeSymbol;
import io.ballerina.compiler.api.symbols.TypeDefinitionSymbol;
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
import io.ballerina.compiler.syntax.tree.ImportDeclarationNode;
import io.ballerina.compiler.syntax.tree.ModuleMemberDeclarationNode;
import io.ballerina.compiler.syntax.tree.ModulePartNode;
import io.ballerina.compiler.syntax.tree.ModuleVariableDeclarationNode;
import io.ballerina.compiler.syntax.tree.NameReferenceNode;
import io.ballerina.compiler.syntax.tree.Node;
import io.ballerina.compiler.syntax.tree.QualifiedNameReferenceNode;
import io.ballerina.compiler.syntax.tree.SyntaxKind;
import io.ballerina.compiler.syntax.tree.TypeDefinitionNode;
import io.ballerina.compiler.syntax.tree.VariableDeclarationNode;
import io.ballerina.projects.plugins.AnalysisTask;
import io.ballerina.projects.plugins.SyntaxNodeAnalysisContext;
import io.ballerina.tools.diagnostics.Diagnostic;
import io.ballerina.tools.diagnostics.DiagnosticFactory;
import io.ballerina.tools.diagnostics.DiagnosticInfo;
import io.ballerina.tools.diagnostics.DiagnosticSeverity;
import io.ballerina.tools.diagnostics.Location;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * Jsondata Record Field Validator.
 *
 * @since 0.1.0
 */
public class JsondataTypeValidator implements AnalysisTask<SyntaxNodeAnalysisContext> {

    private SemanticModel semanticModel;
    private final HashMap<Location, DiagnosticInfo> allDiagnosticInfo = new HashMap<>();
    Location currentLocation;
    private String modulePrefix = Constants.JSONDATA;

    @Override
    public void perform(SyntaxNodeAnalysisContext ctx) {
        semanticModel = ctx.semanticModel();
        List<Diagnostic> diagnostics = semanticModel.diagnostics();
        boolean erroneousCompilation = diagnostics.stream()
                .anyMatch(d -> d.diagnosticInfo().severity().equals(DiagnosticSeverity.ERROR));
        if (erroneousCompilation) {
            reset();
            return;
        }

        ModulePartNode rootNode = (ModulePartNode) ctx.node();
        updateModulePrefix(rootNode);

        for (ModuleMemberDeclarationNode member : rootNode.members()) {
            switch (member.kind()) {
                case FUNCTION_DEFINITION -> processFunctionDefinitionNode((FunctionDefinitionNode) member, ctx);
                case MODULE_VAR_DECL ->
                        processModuleVariableDeclarationNode((ModuleVariableDeclarationNode) member, ctx);
                case TYPE_DEFINITION ->
                        processTypeDefinitionNode((TypeDefinitionNode) member, ctx);
            }
        }

        reset();
    }

    private void reset() {
        semanticModel = null;
        allDiagnosticInfo.clear();
        currentLocation = null;
        modulePrefix = Constants.JSONDATA;
    }

    private void updateModulePrefix(ModulePartNode rootNode) {
        for (ImportDeclarationNode importDeclarationNode : rootNode.imports()) {
            Optional<Symbol> symbol = semanticModel.symbol(importDeclarationNode);
            if (symbol.isPresent() && symbol.get().kind() == SymbolKind.MODULE) {
                ModuleSymbol moduleSymbol = (ModuleSymbol) symbol.get();
                if (isJsondataImport(moduleSymbol)) {
                    modulePrefix = moduleSymbol.id().modulePrefix();
                    break;
                }
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
            if (initializer.isEmpty()) {
                continue;
            }

            currentLocation = variableDeclarationNode.typedBindingPattern().typeDescriptor().location();
            Optional<Symbol> symbol = semanticModel.symbol(variableDeclarationNode.typedBindingPattern());
            if (symbol.isEmpty()) {
                continue;
            }

            TypeSymbol typeSymbol = ((VariableSymbol) symbol.get()).typeDescriptor();
            if (!isParseFunctionOfStringSource(initializer.get())) {
                checkTypeAndDetectDuplicateFields(typeSymbol, ctx);
                continue;
            }

            validateExpectedType(typeSymbol, ctx);
        }
    }

    private void checkTypeAndDetectDuplicateFields(TypeSymbol typeSymbol, SyntaxNodeAnalysisContext ctx) {
        switch (typeSymbol.typeKind()) {
            case RECORD -> detectDuplicateFields((RecordTypeSymbol) typeSymbol, ctx);
            case ARRAY -> checkTypeAndDetectDuplicateFields(((ArrayTypeSymbol) typeSymbol).memberTypeDescriptor(), ctx);
            case TUPLE -> {
                for (TypeSymbol memberType : ((TupleTypeSymbol) typeSymbol).memberTypeDescriptors()) {
                    checkTypeAndDetectDuplicateFields(memberType, ctx);
                }
            }
            case UNION -> {
                for (TypeSymbol memberType : ((UnionTypeSymbol) typeSymbol).memberTypeDescriptors()) {
                    checkTypeAndDetectDuplicateFields(memberType, ctx);
                }
            }
            case TYPE_REFERENCE -> checkTypeAndDetectDuplicateFields(
                    ((TypeReferenceTypeSymbol) typeSymbol).typeDescriptor(), ctx);
            case INTERSECTION -> checkTypeAndDetectDuplicateFields(getRawType(typeSymbol), ctx);
        }
    }

    private boolean isParseFunctionOfStringSource(ExpressionNode expressionNode) {
        if (expressionNode.kind() == SyntaxKind.CHECK_EXPRESSION) {
            expressionNode = ((CheckExpressionNode) expressionNode).expression();
        }

        if (expressionNode.kind() != SyntaxKind.FUNCTION_CALL) {
            return false;
        }
        NameReferenceNode nameReferenceNode = ((FunctionCallExpressionNode) expressionNode).functionName();
        if (nameReferenceNode.kind() != SyntaxKind.QUALIFIED_NAME_REFERENCE) {
            return false;
        }
        String prefix = ((QualifiedNameReferenceNode) nameReferenceNode).modulePrefix().text();
        if (!prefix.equals(modulePrefix)) {
            return false;
        }
        String functionName = ((FunctionCallExpressionNode) expressionNode).functionName().toString().trim();
        return functionName.contains(Constants.PARSE_STRING) || functionName.contains(Constants.PARSE_BYTES)
                || functionName.contains(Constants.PARSE_STREAM);
    }

    private void validateExpectedType(TypeSymbol typeSymbol, SyntaxNodeAnalysisContext ctx) {
        typeSymbol.getLocation().ifPresent(location -> currentLocation = location);
        switch (typeSymbol.typeKind()) {
            case UNION -> validateUnionType((UnionTypeSymbol) typeSymbol, typeSymbol.getLocation(), ctx);
            case RECORD -> validateRecordType((RecordTypeSymbol) typeSymbol, ctx);
            case ARRAY -> validateExpectedType(((ArrayTypeSymbol) typeSymbol).memberTypeDescriptor(), ctx);
            case TUPLE -> validateTupleType((TupleTypeSymbol) typeSymbol, ctx);
            case TABLE, XML -> reportDiagnosticInfo(ctx, typeSymbol.getLocation(),
                    JsondataDiagnosticCodes.UNSUPPORTED_TYPE);
            case TYPE_REFERENCE -> validateExpectedType(((TypeReferenceTypeSymbol) typeSymbol).typeDescriptor(), ctx);
            case INTERSECTION -> validateExpectedType(getRawType(typeSymbol), ctx);
        }
    }

    private void validateTupleType(TupleTypeSymbol tupleTypeSymbol, SyntaxNodeAnalysisContext ctx) {
        for (TypeSymbol memberType : tupleTypeSymbol.memberTypeDescriptors()) {
            validateExpectedType(memberType, ctx);
        }
    }

    private void validateRecordType(RecordTypeSymbol recordTypeSymbol, SyntaxNodeAnalysisContext ctx) {
        detectDuplicateFields(recordTypeSymbol, ctx);

        for (Map.Entry<String, RecordFieldSymbol> entry : recordTypeSymbol.fieldDescriptors().entrySet()) {
            RecordFieldSymbol fieldSymbol = entry.getValue();
            currentLocation = fieldSymbol.getLocation().orElseGet(() -> currentLocation);
            validateExpectedType(fieldSymbol.typeDescriptor(), ctx);
        }
    }

    private void validateUnionType(UnionTypeSymbol unionTypeSymbol, Optional<Location> location,
                                   SyntaxNodeAnalysisContext ctx) {
        boolean isHasUnsupportedType = false;
        List<TypeSymbol> memberTypeSymbols = unionTypeSymbol.memberTypeDescriptors();
        for (TypeSymbol memberTypeSymbol : memberTypeSymbols) {
            if (isSupportedUnionMemberType(getRawType(memberTypeSymbol))) {
                continue;
            }
            isHasUnsupportedType = true;
        }

        if (isHasUnsupportedType) {
            reportDiagnosticInfo(ctx, location, JsondataDiagnosticCodes.UNSUPPORTED_TYPE);
        }
    }

    private boolean isSupportedUnionMemberType(TypeSymbol typeSymbol) {
        TypeDescKind kind = typeSymbol.typeKind();
        if (kind == TypeDescKind.TYPE_REFERENCE) {
            kind = ((TypeReferenceTypeSymbol) typeSymbol).typeDescriptor().typeKind();
        }

        switch (kind) {
            case TABLE, XML -> {
                return false;
            }
            default -> {
                return true;
            }
        }
    }

    public static TypeSymbol getRawType(TypeSymbol typeDescriptor) {
        if (typeDescriptor.typeKind() == TypeDescKind.INTERSECTION) {
            return getRawType(((IntersectionTypeSymbol) typeDescriptor).effectiveTypeDescriptor());
        }
        if (typeDescriptor.typeKind() == TypeDescKind.TYPE_REFERENCE) {
            TypeReferenceTypeSymbol typeRef = (TypeReferenceTypeSymbol) typeDescriptor;
            if (typeRef.typeDescriptor().typeKind() == TypeDescKind.INTERSECTION) {
                return getRawType(((IntersectionTypeSymbol) typeRef.typeDescriptor()).effectiveTypeDescriptor());
            }
            TypeSymbol rawType = typeRef.typeDescriptor();
            if (rawType.typeKind() == TypeDescKind.TYPE_REFERENCE) {
                return getRawType(rawType);
            }
            return rawType;
        }
        return typeDescriptor;
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
        if (initializer.isEmpty() || !isParseFunctionOfStringSource(initializer.get())) {
            return;
        }

        Optional<Symbol> symbol = semanticModel.symbol(moduleVariableDeclarationNode.typedBindingPattern());
        if (symbol.isEmpty()) {
            return;
        }
        validateExpectedType(((VariableSymbol) symbol.get()).typeDescriptor(), ctx);
    }

    private void processTypeDefinitionNode(TypeDefinitionNode typeDefinitionNode, SyntaxNodeAnalysisContext ctx) {
        Node typeDescriptor = typeDefinitionNode.typeDescriptor();
        if (typeDescriptor.kind() != SyntaxKind.RECORD_TYPE_DESC) {
            return;
        }
        validateRecordTypeDefinition(typeDefinitionNode, ctx);
    }

    private void validateRecordTypeDefinition(TypeDefinitionNode typeDefinitionNode, SyntaxNodeAnalysisContext ctx) {
        Optional<Symbol> symbol = semanticModel.symbol(typeDefinitionNode);
        if (symbol.isEmpty()) {
            return;
        }
        TypeDefinitionSymbol typeDefinitionSymbol = (TypeDefinitionSymbol) symbol.get();
        detectDuplicateFields((RecordTypeSymbol) typeDefinitionSymbol.typeDescriptor(), ctx);
    }

    private void detectDuplicateFields(RecordTypeSymbol recordTypeSymbol, SyntaxNodeAnalysisContext ctx) {
        List<String> fieldMembers = new ArrayList<>();
        for (Map.Entry<String, RecordFieldSymbol> entry : recordTypeSymbol.fieldDescriptors().entrySet()) {
            RecordFieldSymbol fieldSymbol = entry.getValue();
            String name = getNameFromAnnotation(entry.getKey(), fieldSymbol.annotAttachments());
            if (fieldMembers.contains(name)) {
                reportDiagnosticInfo(ctx, fieldSymbol.getLocation(), JsondataDiagnosticCodes.DUPLICATE_FIELD);
                return;
            }
            fieldMembers.add(name);
        }
    }

    private String getNameFromAnnotation(String fieldName,
                                         List<AnnotationAttachmentSymbol> annotationAttachments) {
        for (AnnotationAttachmentSymbol annotAttSymbol : annotationAttachments) {
            AnnotationSymbol annotation = annotAttSymbol.typeDescriptor();
            if (!getAnnotModuleName(annotation).contains(Constants.JSONDATA)) {
                continue;
            }
            Optional<String> nameAnnot = annotation.getName();
            if (nameAnnot.isEmpty()) {
                continue;
            }
            String value = nameAnnot.get();
            if (value.equals(Constants.NAME)) {
                return ((LinkedHashMap<?, ?>) annotAttSymbol.attachmentValue().orElseThrow().value())
                        .get("value").toString();
            }
        }
        return fieldName;
    }

    private String getAnnotModuleName(AnnotationSymbol annotation) {
        Optional<ModuleSymbol> moduleSymbol = annotation.getModule();
        if (moduleSymbol.isEmpty()) {
            return "";
        }
        Optional<String> moduleName = moduleSymbol.get().getName();
        return moduleName.orElse("");
    }

    private boolean isJsondataImport(ModuleSymbol moduleSymbol) {
        ModuleID moduleId = moduleSymbol.id();
        return Constants.BALLERINA.equals(moduleId.orgName())
                && Constants.DATA_JSONDATA.equals(moduleId.moduleName());
    }
}
