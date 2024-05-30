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

import io.ballerina.projects.DiagnosticResult;
import io.ballerina.tools.diagnostics.Diagnostic;
import io.ballerina.tools.diagnostics.DiagnosticSeverity;
import org.testng.Assert;
import org.testng.annotations.Test;

import java.util.List;
import java.util.stream.Collectors;

/**
 * This class includes tests for Ballerina Jsondata compiler plugin.
 */
public class CompilerPluginTest {

    static final String UNSUPPORTED_UNION_TYPE =
            "unsupported union type: union type does not support multiple complex types";

    @Test
    public void testInvalidExpectedUnionType1() {
        DiagnosticResult diagnosticResult =
                CompilerPluginTestUtils.loadPackage("sample_package_1").getCompilation().diagnosticResult();
        List<Diagnostic> errorDiagnosticsList = diagnosticResult.diagnostics().stream()
                .filter(r -> r.diagnosticInfo().severity().equals(DiagnosticSeverity.ERROR))
                .collect(Collectors.toList());
        Assert.assertEquals(errorDiagnosticsList.size(), 1);
        Assert.assertEquals(errorDiagnosticsList.get(0).diagnosticInfo().messageFormat(), UNSUPPORTED_UNION_TYPE);
    }

    @Test
    public void testInvalidExpectedUnionType2() {
        DiagnosticResult diagnosticResult =
                CompilerPluginTestUtils.loadPackage("sample_package_2").getCompilation().diagnosticResult();
        List<Diagnostic> errorDiagnosticsList = diagnosticResult.diagnostics().stream()
                .filter(r -> r.diagnosticInfo().severity().equals(DiagnosticSeverity.ERROR))
                .collect(Collectors.toList());
        Assert.assertEquals(errorDiagnosticsList.size(), 1);
        Assert.assertEquals(errorDiagnosticsList.get(0).diagnosticInfo().messageFormat(), UNSUPPORTED_UNION_TYPE);
    }

    @Test
    public void testInvalidRecordFieldType1() {
        DiagnosticResult diagnosticResult =
                CompilerPluginTestUtils.loadPackage("sample_package_3").getCompilation().diagnosticResult();
        List<Diagnostic> errorDiagnosticsList = diagnosticResult.diagnostics().stream()
                .filter(r -> r.diagnosticInfo().severity().equals(DiagnosticSeverity.ERROR))
                .collect(Collectors.toList());
        Assert.assertEquals(errorDiagnosticsList.size(), 2);
        Assert.assertEquals(errorDiagnosticsList.get(0).diagnosticInfo().messageFormat(), UNSUPPORTED_UNION_TYPE);
        Assert.assertEquals(errorDiagnosticsList.get(0).diagnosticInfo().messageFormat(), UNSUPPORTED_UNION_TYPE);
    }

    @Test
    public void testInvalidRecordFieldType2() {
        DiagnosticResult diagnosticResult =
                CompilerPluginTestUtils.loadPackage("sample_package_4").getCompilation().diagnosticResult();
        List<Diagnostic> errorDiagnosticsList = diagnosticResult.diagnostics().stream()
                .filter(r -> r.diagnosticInfo().severity().equals(DiagnosticSeverity.ERROR))
                .collect(Collectors.toList());
        Assert.assertEquals(errorDiagnosticsList.size(), 2);
        Assert.assertEquals(errorDiagnosticsList.get(0).diagnosticInfo().messageFormat(), UNSUPPORTED_UNION_TYPE);
        Assert.assertEquals(errorDiagnosticsList.get(0).diagnosticInfo().messageFormat(), UNSUPPORTED_UNION_TYPE);
    }

    @Test
    public void testDuplicateField1() {
        DiagnosticResult diagnosticResult =
                CompilerPluginTestUtils.loadPackage("sample_package_5").getCompilation().diagnosticResult();
        List<Diagnostic> errorDiagnosticsList = diagnosticResult.diagnostics().stream()
                .filter(r -> r.diagnosticInfo().severity().equals(DiagnosticSeverity.ERROR))
                .collect(Collectors.toList());
        Assert.assertEquals(errorDiagnosticsList.size(), 1);
        Assert.assertEquals(errorDiagnosticsList.get(0).diagnosticInfo().messageFormat(),
                "invalid field: duplicate field found");
    }

    @Test
    public void testDuplicateField2() {
        DiagnosticResult diagnosticResult =
                CompilerPluginTestUtils.loadPackage("sample_package_6").getCompilation().diagnosticResult();
        List<Diagnostic> errorDiagnosticsList = diagnosticResult.diagnostics().stream()
                .filter(r -> r.diagnosticInfo().severity().equals(DiagnosticSeverity.ERROR))
                .collect(Collectors.toList());
        Assert.assertEquals(errorDiagnosticsList.size(), 2);
        Assert.assertEquals(errorDiagnosticsList.get(0).diagnosticInfo().messageFormat(),
                "invalid field: duplicate field found");
        Assert.assertEquals(errorDiagnosticsList.get(1).diagnosticInfo().messageFormat(),
                "invalid field: duplicate field found");
    }

    @Test
    public void testComplexUnionTypeAsExpectedType() {
        DiagnosticResult diagnosticResult =
                CompilerPluginTestUtils.loadPackage("sample_package_7").getCompilation().diagnosticResult();
        List<Diagnostic> errorDiagnosticsList = diagnosticResult.diagnostics().stream()
                .filter(r -> r.diagnosticInfo().severity().equals(DiagnosticSeverity.ERROR))
                .collect(Collectors.toList());
        Assert.assertEquals(errorDiagnosticsList.size(), 2);
        Assert.assertEquals(errorDiagnosticsList.get(0).diagnosticInfo().messageFormat(),
                "unsupported union type: union type does not support multiple complex types");
        Assert.assertEquals(errorDiagnosticsList.get(1).diagnosticInfo().messageFormat(),
                "unsupported union type: union type does not support multiple complex types");
    }

    @Test
    public void testComplexUnionTypeAsMemberOfIntersection() {
        DiagnosticResult diagnosticResult =
                CompilerPluginTestUtils.loadPackage("sample_package_8").getCompilation().diagnosticResult();
        List<Diagnostic> errorDiagnosticsList = diagnosticResult.diagnostics().stream()
                .filter(r -> r.diagnosticInfo().severity().equals(DiagnosticSeverity.ERROR))
                .collect(Collectors.toList());
        Assert.assertEquals(errorDiagnosticsList.size(), 1);
        Assert.assertEquals(errorDiagnosticsList.get(0).diagnosticInfo().messageFormat(),
                "unsupported union type: union type does not support multiple complex types");
    }

    @Test
    public void testComplexUnionTypeCaseWhenUserDefinedModulePrefix1() {
        DiagnosticResult diagnosticResult =
                CompilerPluginTestUtils.loadPackage("sample_package_9").getCompilation().diagnosticResult();
        List<Diagnostic> errorDiagnosticsList = diagnosticResult.diagnostics().stream()
                .filter(r -> r.diagnosticInfo().severity().equals(DiagnosticSeverity.ERROR))
                .collect(Collectors.toList());
        Assert.assertEquals(errorDiagnosticsList.size(), 1);
        Assert.assertEquals(errorDiagnosticsList.get(0).diagnosticInfo().messageFormat(),
                "unsupported union type: union type does not support multiple complex types");
    }

    @Test
    public void testComplexUnionTypeCaseWhenUserDefinedModulePrefix2() {
        DiagnosticResult diagnosticResult =
                CompilerPluginTestUtils.loadPackage("sample_package_10").getCompilation().diagnosticResult();
        List<Diagnostic> errorDiagnosticsList = diagnosticResult.diagnostics().stream()
                .filter(r -> r.diagnosticInfo().severity().equals(DiagnosticSeverity.ERROR))
                .collect(Collectors.toList());
        Assert.assertEquals(errorDiagnosticsList.size(), 3);
        Assert.assertEquals(errorDiagnosticsList.get(0).diagnosticInfo().messageFormat(),
                "unsupported union type: union type does not support multiple complex types");
        Assert.assertEquals(errorDiagnosticsList.get(1).diagnosticInfo().messageFormat(),
                "unsupported union type: union type does not support multiple complex types");
        Assert.assertEquals(errorDiagnosticsList.get(2).diagnosticInfo().messageFormat(),
                "unsupported union type: union type does not support multiple complex types");
    }
}
