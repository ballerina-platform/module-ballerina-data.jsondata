// Copyright (c) 2024, WSO2 LLC. (https://www.wso2.com).
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

const options = {allowDataProjection: false, enableConstraintValidation: true};

@test:Config
isolated function testDisableDataProjectionInArrayTypeForParseString() {
    string jsonStr1 = string `[1, 2, 3, 4]`;
    int[2]|error val1 = parseString(jsonStr1, options);
    test:assertTrue(val1 is error);
    test:assertEquals((<error>val1).message(), "array size is not compatible with the expected size");

    string strVal2 = string `{
        "a": [1, 2, 3, 4, 5]
    }`;
    record {|int[2] a;|}|error val2 = parseString(strVal2, options);
    test:assertTrue(val2 is error);
    test:assertEquals((<error>val2).message(), "array size is not compatible with the expected size");

    string strVal3 = string `{
        "a": [1, 2, 3, 4, 5],
        "b": [1, 2, 3, 4, 5]
    }`;
    record {|int[2] a; int[3] b;|}|error val3 = parseString(strVal3, options);
    test:assertTrue(val3 is error);
    test:assertEquals((<error>val3).message(), "array size is not compatible with the expected size");

    string strVal4 = string `{
        "employees": [
            { "name": "Prakanth",
              "age": 26
            },
            { "name": "Kevin",
              "age": 25
            }
        ]
    }`;
    record {|record {|string name; int age;|}[1] employees;|}|error val4 = parseString(strVal4, options);
    test:assertTrue(val4 is error);
    test:assertEquals((<error>val4).message(), "array size is not compatible with the expected size");

    string strVal5 = string `[1, 2, 3, { "a" : val_a }]`;
    int[3]|error val5 = parseString(strVal5, options);
    test:assertTrue(val5 is error);
    test:assertEquals((<error>val5).message(), "array size is not compatible with the expected size");
}

@test:Config
isolated function testDisableDataProjectionInTupleTypeForParseString() {
    string str1 = string `["1", 2, 3, 4, "5", 8]`;
    [string, float]|error val1 = parseString(str1, options);
    test:assertTrue(val1 is error);
    test:assertEquals((<error>val1).message(), "array size is not compatible with the expected size");

    string str2 = string `{
        "a": ["1", 2, 3, 4, "5", 8]
    }`;
    record {|[string, float] a;|}|error val2 = parseString(str2, options);
    test:assertTrue(val2 is error);
    test:assertEquals((<error>val2).message(), "array size is not compatible with the expected size");

    string str3 = string `[1, "4"]`;
    [float]|error val3 = parseString(str3, options);
    test:assertTrue(val3 is error);
    test:assertEquals((<error>val3).message(), "array size is not compatible with the expected size");

    string str4 = string `[1, {}]`;
    [float]|error val4 = parseString(str4, options);
    test:assertTrue(val4 is error);
    test:assertEquals((<error>val4).message(), "array size is not compatible with the expected size");

    string str5 = string `["1", [], {"name": 1}]`;
    [string]|error val5 = parseString(str5, options);
    test:assertTrue(val5 is error);
    test:assertEquals((<error>val5).message(), "array size is not compatible with the expected size");
}

@test:Config
isolated function testDisableDataProjectionInRecordTypeWithParseString() {
    string jsonStr1 = string `{"name": "John", "age": 30, "city": "New York"}`;
    record {|string name; string city;|}|error val1 = parseString(jsonStr1, options);
    test:assertTrue(val1 is error);
    test:assertEquals((<error>val1).message(), "undefined field 'age'");

    string jsonStr2 = string `{"name": "John", "age": "30", "city": "New York"}`;
    record {|string name; string city;|}|error val2 = parseString(jsonStr2, options);
    test:assertTrue(val2 is error);
    test:assertEquals((<error>val2).message(), "undefined field 'age'");

    string jsonStr3 = string `{ "name": "John", 
                                "company": {
                                    "name": "wso2", 
                                    "year": 2024,
                                    "addrees": {
                                        "street": "123",
                                        "city": "Berkeley"
                                        }
                                    },
                                "city": "New York" }`;
    record {|string name; string city;|}|error val3 = parseString(jsonStr3, options);
    test:assertTrue(val3 is error);
    test:assertEquals((<error>val3).message(), "undefined field 'company'");

    string jsonStr4 = string `{ "name": "John", 
                                "company": [{
                                    "name": "wso2", 
                                    "year": 2024,
                                    "addrees": {
                                        "street": "123",
                                        "city": "Berkeley"
                                        }
                                    }],
                                "city": "New York" }`;
    record {|string name; string city;|}|error val4 = parseString(jsonStr4, options);
    test:assertTrue(val4 is error);
    test:assertEquals((<error>val4).message(), "undefined field 'company'");

    string jsonStr5 = string `{ "name": "John", 
                                "company1": [{
                                    "name": "wso2", 
                                    "year": 2024,
                                    "addrees": {
                                        "street": "123",
                                        "city": "Berkeley"
                                        }
                                    }],
                                "city": "New York",
                                "company2": [{
                                    "name": "amzn", 
                                    "year": 2024,
                                    "addrees": {
                                        "street": "123",
                                        "city": "Miami"
                                        }
                                    }]
                                }`;
    record {|string name; string city;|}|error val5 = parseString(jsonStr5, options);
    test:assertTrue(val5 is error);
    test:assertEquals((<error>val5).message(), "undefined field 'company1'");
}

@test:Config
isolated function testDisableDataProjectionInArrayTypeForParseAsType() {
    json jsonVal1 = [1, 2, 3, 4];
    int[2]|error val1 = parseAsType(jsonVal1, options);
    test:assertTrue(val1 is error);
    test:assertEquals((<error>val1).message(), "array size is not compatible with the expected size");

    json jsonVal2 = {
        a: [1, 2, 3, 4, 5]
    };
    record {|int[2] a;|}|error val2 = parseAsType(jsonVal2, options);
    test:assertTrue(val2 is error);
    test:assertEquals((<error>val2).message(), "array size is not compatible with the expected size");

    json jsonVal3 = {
        a: [1, 2, 3, 4, 5],
        b: [1, 2, 3, 4, 5]
    };
    record {|int[2] a; int[3] b;|}|error val3 = parseAsType(jsonVal3, options);
    test:assertTrue(val3 is error);
    test:assertEquals((<error>val3).message(), "array size is not compatible with the expected size");

    json jsonVal4 = {
        employees: [
            {
                name: "Prakanth",
                age: 26
            },
            {
                name: "Kevin",
                age: 25
            }
        ]
    };
    record {|record {|string name; int age;|}[1] employees;|}|error val4 = parseAsType(jsonVal4, options);
    test:assertTrue(val4 is error);
    test:assertEquals((<error>val4).message(), "array size is not compatible with the expected size");

    json jsonVal5 = ["1", 2, 3, {a: "val_a"}];
    int[3]|error val5 = parseAsType(jsonVal5, options);
    test:assertTrue(val5 is error);
    test:assertEquals((<error>val5).message(), "array size is not compatible with the expected size");
}

@test:Config
isolated function testDisableDataProjectionInTupleTypeForParseAsType() {
    json jsonVal1 = [1, 2, 3, 4, 5, 8];
    [int, int]|error val1 = parseAsType(jsonVal1, options);
    test:assertTrue(val1 is error);
    test:assertEquals((<error>val1).message(), "array size is not compatible with the expected size");

    json jsonVal2 = {
        a: [1, 2, 3, 4, 5, 8]
    };
    record {|[int, int] a;|}|error val2 = parseAsType(jsonVal2, options);
    test:assertTrue(val2 is error);
    test:assertEquals((<error>val2).message(), "array size is not compatible with the expected size");

    json jsonVal3 = [1, "4"];
    [int]|error val3 = parseAsType(jsonVal3, options);
    test:assertTrue(val3 is error);
    test:assertEquals((<error>val3).message(), "array size is not compatible with the expected size");

    json jsonVal4 = ["1", {}];
    [string]|error val4 = parseAsType(jsonVal4, options);
    test:assertTrue(val4 is error);
    test:assertEquals((<error>val4).message(), "array size is not compatible with the expected size");

    json jsonVal5 = ["1", [], {"name": 1}];
    [string]|error val5 = parseAsType(jsonVal5, options);
    test:assertTrue(val5 is error);
    test:assertEquals((<error>val5).message(), "array size is not compatible with the expected size");
}

@test:Config
isolated function testDisableDataProjectionInRecordTypeWithParseAsType() {
    json jsonVal1 = {"name": "John", "age": 30, "city": "New York"};
    record {|string name; string city;|}|error val1 = parseAsType(jsonVal1, options);
    test:assertTrue(val1 is error);
    test:assertEquals((<error>val1).message(), "undefined field 'age'");

    json jsonVal2 = {
        "name": "John",
        "company": {
            "name": "wso2",
            "year": 2024,
            "addrees": {
                "street": "123",
                "city": "Berkeley"
            }
        },
        "city": "New York"
    };
    record {|string name; string city;|}|error val2 = parseAsType(jsonVal2, options);
    test:assertTrue(val2 is error);
    test:assertEquals((<error>val2).message(), "undefined field 'company'");

    json jsonVal3 = {
        "name": "John",
        "company": [
            {
                "name": "wso2",
                "year": 2024,
                "addrees": {
                    "street": "123",
                    "city": "Berkeley"
                }
            }
        ],
        "city": "New York"
    };
    record {|string name; string city;|}|error val3 = parseAsType(jsonVal3, options);
    test:assertTrue(val3 is error);
    test:assertEquals((<error>val3).message(), "undefined field 'company'");

    json jsonVal4 = {
        "name": "John",
        "company1": [
            {
                "name": "wso2",
                "year": 2024,
                "addrees": {
                    "street": "123",
                    "city": "Berkeley"
                }
            }
        ],
        "city": "New York",
        "company2": [
            {
                "name": "amzn",
                "year": 2024,
                "addrees": {
                    "street": "123",
                    "city": "Miami"
                }
            }
        ]
    };
    record {|string name; string city;|}|error val4 = parseAsType(jsonVal4, options);
    test:assertTrue(val4 is error);
    test:assertEquals((<error>val4).message(), "undefined field 'company1'");
}

@test:Config
isolated function testDisableProjectionForOpenArray() returns error? {
    string jsonStr = string `[1, 2, 3, 4]`;
    int[] val = check parseString(jsonStr, options);
    test:assertEquals(val, [1, 2, 3, 4]);
}
