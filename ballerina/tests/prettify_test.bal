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
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/test;

@test:Config {
    groups: ["prettify", "string"]
}
function testStringValue() returns error? {
    json value = "Sam";
    string actual = prettify(value);
    string expected = check getStringContentFromFile("string_value.json");
    test:assertEquals(actual, expected);
}

@test:Config {
    groups: ["prettify", "int"]
}
function testIntValue() returns error? {
    json value = 515;
    string actual = prettify(value);
    string expected = check getStringContentFromFile("int_value.json");
    test:assertEquals(actual, expected);
}

@test:Config {
    groups: ["prettify", "boolean"]
}
function testBooleanValue() returns error? {
    json value = false;
    string actual = prettify(value);
    string expected = check getStringContentFromFile("boolean_value.json");
    test:assertEquals(actual, expected);
}

@test:Config {
    groups: ["prettify", "null"]
}
function testNullValue() returns error? {
    json value = null;
    string actual = prettify(value);
    string expected = " null";
    test:assertEquals(actual, expected);
}

@test:Config {
    groups: ["prettify", "null"]
}
isolated function testNullInMap() returns error? {
    json value = {
        name: "Sam",
        age: null,
        address: {
            number: 308,
            street: "Negra Arroyo Lane",
            city: null
        }
    };
    string actual = prettify(value);
    string expected = check getStringContentFromFile("null_in_map.json");
    test:assertEquals(actual, expected);
}

@test:Config {
    groups: ["prettify", "array"]
}
function testStringArray() returns error? {
    json value = ["sam", "bam", "tan"];
    string actual = prettify(value);
    string expected = check getStringContentFromFile("string_array.json");
    test:assertEquals(actual, expected);
}

@test:Config {
    groups: ["prettify", "array"]
}
function testEmptyArray() returns error? {
    json value = [];
    string actual = prettify(value);
    string expected = check getStringContentFromFile("empty_array.json");
    test:assertEquals(actual, expected);
}

@test:Config {
    groups: ["prettify", "map"]
}
function testEmptyMap() returns error? {
    json value = {};
    string actual = prettify(value);
    string expected = check getStringContentFromFile("empty_map.json");
    test:assertEquals(actual, expected);
}

@test:Config {
    groups: ["prettify", "map"]
}
function testArrayOfEmptyMaps() returns error? {
    json value = [
        {},
        {},
        {}
    ];
    string actual = prettify(value);
    string expected = check getStringContentFromFile("array_of_empty_maps.json");
    test:assertEquals(actual, expected);
}

@test:Config {
    groups: ["prettify", "map"]
}
function testMapWithStringField() returns error? {
    json value = {
        name: "Walter White"
    };
    string actual = prettify(value);
    string expected = check getStringContentFromFile("map_with_string_field.json");
    test:assertEquals(actual, expected);
}

@test:Config {
    groups: ["prettify", "map"]
}
function testMapWithMultipleStringFields() returns error? {
    json value = {
        name: "Walter White",
        subject: "Chemistry",
        city: "Albequerque"
    };
    string actual = prettify(value);
    string expected = check getStringContentFromFile("map_with_multiple_string_fields.json");
    test:assertEquals(actual, expected);
}

@test:Config {
    groups: ["prettify", "map"]
}
function testMap() returns error? {
    json value = {
        person: {
            name: "Walter White",
            age: 51,
            address: {
                number: 308,
                street: "Negra Arroyo Lane",
                city: "Albequerque"
            }
        }
    };
    string actual = prettify(value);
    string expected = check getStringContentFromFile("map.json");
    test:assertEquals(actual, expected);
}

@test:Config {
    groups: ["prettify", "map"]
}
function testArrayOfMap() returns error? {
    json value = [
        {
            name: "Walter White",
            age: 51,
            address: {
                number: 308,
                street: "Negra Arroyo Lane",
                city: "Albequerque"
            }
        },
        {
            name: "Jesse Pinkman",
            age: 26,
            address: {
                number: 9809,
                street: "Margo Street",
                city: "Albequerque"
            }
        }
    ];
    string actual = prettify(value);
    string expected = check getStringContentFromFile("array_of_map.json");
    test:assertEquals(actual, expected);
}

@test:Config {
    groups: ["prettify", "array", "map"]
}
function testComplexExample() returns error? {
    json value = check getJsonContentFromFile("complex_example.json");
    string actual = prettify(value);
    string expected = check getStringContentFromFile("complex_example.json");
    test:assertEquals(actual, expected);
}

@test:Config {
    groups: ["prettify", "array", "map"]
}
function testComplexExampleWithCustomIndentation() returns error? {
    json value = check getJsonContentFromFile("complex_example.json");
    string actual = prettify(value, 2);
    string expected = check getStringContentFromFile("complex_example_with_custom_indentation.json");
    test:assertEquals(actual, expected);
}

@test:Config {
    groups: ["prettify", "array", "map"]
}
function testComplexExampleWithCustomIndentationInvalidTest() returns error? {
    json value = check getJsonContentFromFile("complex_example.json");
    string actual = prettify(value, 2);
    string expected = check getStringContentFromFile("complex_example.json");
    test:assertNotEquals(actual, expected);
}
