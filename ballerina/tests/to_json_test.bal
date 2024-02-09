// Copyright (c) 2024, WSO2 LLC. (https://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/test;

@test:Config
function testToJsonWithBasicType() {
    string name = "Kanth";
    json|Error j = toJson(name);
    test:assertTrue(j is json);
    test:assertEquals(j, "Kanth");

    int age = 26;
    json|Error j2 = toJson(age);
    test:assertTrue(j2 is json);
    test:assertEquals(j2, 26);

    float height = 5.6;
    json|Error j3 = toJson(height);
    test:assertTrue(j3 is json);
    test:assertEquals(j3, 5.6);

    boolean isStudent = false;
    json|Error j4 = toJson(isStudent);
    test:assertTrue(j4 is json);
    test:assertEquals(j4, false);

    json|Error j5 = toJson(());
    test:assertTrue(j5 is json);
    test:assertEquals(j5, ());
}

type Student record {
    string name;
    int age;
};

@test:Config
function testToJsonWithRecord1() {
    Student s = {name: "Kanth", age: 26};
    json|Error j = toJson(s);
    test:assertTrue(j is json);
    test:assertEquals(j, {name: "Kanth", age: 26});
}

type Address2 record {|
    string country;
    string city;
    json...;
|};

@test:Config
function testToJsonWithRecord2() {
    Address2 addr1 = {country: "x", city: "y", "street": "z", "no": 3};
    json|Error jsonaddr1 = toJson(addr1);
    test:assertTrue(jsonaddr1 is json);
    test:assertEquals(jsonaddr1, {country: "x", city: "y", "street": "z", "no": 3});
}

@test:Config
function testToJsonWithXML() {
    xml x1 = xml `<movie>
                    <title>Some</title>
                    <writer>Writer</writer>
                  </movie>`;
    json|Error j = toJson(x1);
    test:assertTrue(j is json);
    test:assertEquals(j, x1.toString());
}
