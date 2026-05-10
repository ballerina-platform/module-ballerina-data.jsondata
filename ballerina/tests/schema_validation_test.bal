// Copyright (c) 2026, WSO2 LLC. (https://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/test;
import ballerina/io;
import ballerina/file;

type JsonSchemaTest record {|
    string description;
    boolean|map<json> schema;
    JsonSchemaTestItem[] tests;
    json...;
|};

type JsonSchemaTestItem record {|
    string description;
    json data;
    boolean valid;
    json...;
|};

const testFiles = [
    "additionalProperties.json",
    "anchor.json",
    "allOf.json",
    "anyOf.json",
    "boolean_schema.json",
    "const.json",
    "contains.json",
    "content.json",
    "default.json",
    "defs.json",
    "dependentRequired.json",
    "dependentSchemas.json",
    "dynamicRef.json",
    "enum.json",
    "exclusiveMaximum.json",
    "exclusiveMinimum.json",
    "format.json",
    "if-then-else.json",
    "infinite-loop-detection.json",
    "items.json",
    "maxContains.json",
    "maxItems.json",
    "maxLength.json",
    "maxProperties.json",
    "maximum.json",
    "minContains.json",
    "minItems.json",
    "minLength.json",
    "minProperties.json",
    "minimum.json",
    "multipleOf.json",
    "not.json",
    "oneOf.json",
    "pattern.json",
    "patternProperties.json",
    "prefixItems.json",
    "properties.json",
    "propertyNames.json",
    "ref.json",
//    "refRemote.json", // No feature to load schemas to the registry beforehand, possible TODO
    "required.json",
    "type.json",
    "unevaluatedItems.json",
    "unevaluatedProperties.json",
    "uniqueItems.json"
//    ,
//    "vocabulary.json"
//    "optional/format/date-time.json",
//    "optional/format/date.json",
//    "optional/format/duration.json",
//    "optional/format/time.json",
//    "optional/format/email.json",
//    "optional/format/hostname.json",
//    "optional/format/ipv4.json",
//    "optional/format/ipv6.json",
//    "optional/format/json-pointer.json",
//    "optional/format/relative-json-pointer.json",
//    "optional/format/uri-reference.json",
//    "optional/format/uri.json",
//    "optional/format/uri-template.json",
//    "optional/format/uuid.json"
];

// Format: [groupIdx, testIdx]
const ignoredTestCases = {
    "pattern.json": [[2, -1]], // unsupported regex features in ballerina
    "patternProperties.json": [[5, -1]], // unsupported regex features in ballerina
    "dynamicRef.json": [
        [13, -1], // requires remote schema preloading (tree.json)
        [14, -1], // requires remote schema preloading (extendible-dynamic-ref.json)
        [15, -1], // requires remote schema preloading (extendible-dynamic-ref.json)
        [16, -1], // requires remote schema preloading (extendible-dynamic-ref.json)
        [17, -1]  // requires remote schema preloading (detached-dynamicref.json)
    ],
    "optional/format/hostname.json": [
        [0, 19],
        [1, -1]  // Ignore punycode processing
    ]
};

function isTestCaseIgnored(string testFile, int groupIdx, int testIdx) returns boolean {
    int[][]? ignoredEntries = ignoredTestCases[testFile];

    if ignoredEntries is () {
        return false;
    }

    foreach int[] entry in ignoredEntries {
        if entry[0] == groupIdx && (entry[1] == -1 || entry[1] == testIdx) {
            return true;
        }
    }

    return false;
}

function dataProviderForSchemaValidation() returns [json, map<json>|boolean, string, boolean, string][] {
    [json, map<json>|boolean, string, boolean, string][] testData = [];

    foreach string testFile in testFiles {
        json|error testCaseJson = getJsonSchemaTestContentFromFile(testFile);
        if testCaseJson is error {
            panic error(string `Failed to load test file: ${testFile}`, testCaseJson);
        }

        if testCaseJson is json[] {
            int groupIdx = 0;
            foreach json testCaseJsonItem in testCaseJson {
                JsonSchemaTest|error testCase = parseAsType(testCaseJsonItem, {}, JsonSchemaTest);
                if testCase is error {
                    panic error(string `Invalid test case structure in file: ${testFile}`, testCase);
                }

                int testIdx = 0;
                foreach JsonSchemaTestItem testItem in testCase.tests {
                    if !isTestCaseIgnored(testFile, groupIdx, testIdx) {
                        testData.push([
                            testItem.data,
                            testCase.schema,
                            testFile,
                            testItem.valid,
                            string `${testFile}: ${testCase.description} - ${testItem.description}`
                        ]);
                    }
                    testIdx += 1;
                }
                groupIdx += 1;
            }
        }
    } on fail var e {
    	panic error(e.message());
    }

    return testData;
}
@test:Config {
    dataProvider: dataProviderForSchemaValidation
}
isolated function testSchemaAsJsonValidation(json inputData, map<json>|boolean schema, string schemaPath, boolean shouldPass, string testCase) {
    Error? result = validate(inputData, schema);
    if shouldPass {
        test:assertTrue(result is (), testCase + ": Valid data should pass schema validation");
    } else {
        test:assertTrue(result is Error, testCase + ": Invalid data should fail schema validation");
    }
}

@test:Config {
    dataProvider: dataProviderForSchemaValidation
}

isolated function testSchemaAsFilePathValidation(json inputData, map<json>|boolean schema, string schemaPath, boolean shouldPass, string testCase) returns error? {
    string tempDir = check file:createTempDir(prefix = "schema_test_");
    string:RegExp separator = re `/`;
    string safeFileName = separator.replaceAll(schemaPath, "_");
    string tempSchemaPath = check file:joinPath(tempDir, string `temp_${safeFileName}`);

    check io:fileWriteJson(tempSchemaPath, schema);
    string absolutePath = check file:getAbsolutePath(tempSchemaPath);
    var result = validate(inputData, absolutePath);

    error? deleteFileResult = file:remove(tempSchemaPath);
    if deleteFileResult is error {
        io:println("Warning: Failed to delete temp file: ", tempSchemaPath);
    }

    error? deleteDirResult = file:remove(tempDir, file:RECURSIVE);
    if deleteDirResult is error {
        io:println("Warning: Failed to delete temp directory: ", tempDir);
    }

    if shouldPass {
        test:assertTrue(result is (), testCase + ": Valid data should pass");
    } else {
        test:assertTrue(result is error, testCase + ": Invalid data should fail");
    }
}