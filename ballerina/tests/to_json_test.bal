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

type Employee record {|
    readonly int id;
    string name;
    string dept;
|};

@test:Config
function testToJsonWithTables() {
    table<Employee> key (id) tb = table [
        {id: 1001, name: "Mary", dept: "legal"},
        {id: 1002, name: "John", dept: "finance"}
    ];
    json tbJson = toJson(tb);
    test:assertTrue(tbJson is json[]);
    test:assertEquals(tbJson, <json> [
        {id: 1001, name: "Mary", dept: "legal"},
        {id: 1002, name: "John", dept: "finance"}
    ]);
}

type TestRecord3 record {|
    @Name {
        value: "a-o"
    }
    string a;
    @Name {
        value: "b-o"
    }
    string b;
    int c;
|};

type NestedRecord3 record {
    @Name {
        value: "d-o"
    }
    int d\-name;
    @Name {
        value: "e-o"
    }
    string e;
    NestedRecord3 f?;
    record {
        @Name {
            value: "i-o"
        }
        int i;
        @Name {
            value: "k-o"
        }
        NestedRecord3 k?;
    } j;
};

@test:Config
function testToJsonWithNameAnnotation() {
    TestRecord3 r = {
        a: "name",
        b: "b name",
        c: 1
    };
    json out = {
        "a-o": "name",
        "b-o": "b name",
        "c": 1
    };
    json|Error j = toJson(r);
    test:assertTrue(j is json);
    test:assertEquals(j, out);

    NestedRecord3 n = {
        d\-name: 2,
        e: "test-e",
        f: {
            d\-name: 45,
            e: "nested-e",
            j: {
                i: 1000,
                k: {
                    d\-name: 4,
                    e: "nest-nest-e",
                    j: {
                        i: 10000
                    }
                }
            }
        },
        j: { i: 100}
    };
    json out2 = {
        "d-o": 2,
        "e-o": "test-e",
        f: {
            "d-o": 45,
            e\-o: "nested-e",
            j: {
                "i-o": 1000, 
                "k-o": {
                    d\-o: 4,
                    "e-o": "nest-nest-e",
                    j: {
                        "i-o": 10000
                    }
                }
            }
        },
        j: { "i-o": 100}
    };
    json|Error j2 = toJson(n);
    test:assertTrue(j2 is json);
    test:assertEquals(j2, out2);

    table<TestRecord3> tb = table [
        {a: "a value", b: "b value", c: 1001},
        {a: "a value 2", b: "b value 2", c: 1002}
    ];
    json j3 = toJson(tb);
    test:assertTrue(j3 is json[]);
    json[] out3 = [
        {"a-o": "a value", "b-o": "b value", c: 1001},
        {"a-o": "a value 2", "b-o": "b value 2", c: 1002}
    ];
    test:assertEquals(j3, out3);
}

type TestRecord4 record {|
    @Name {
        value: "a-o"
    }
    string a;
    @Name {
        value: "b-o"
    }
    string b;
    int c;
    TestRecord4[] d;
|};

@test:Config
function testToJsonWithCyclicValues() {
    json[] v1 = [];
    v1.push(v1);
    json|error r1 = toJsonWithCyclicValues(v1);
    assertCyclicReferenceError(r1);

    map<json> v2 = {};
    v2["val"] = v2;
    json|error r2 = toJsonWithCyclicValues(v2);
    assertCyclicReferenceError(r2);

    TestRecord4 v3 = {
        a: "a-v",
        b: "b-v",
        c: 1,
        d: []
    };
    v3.d.push(v3);
    json|error r3 = toJsonWithCyclicValues(v3);
    assertCyclicReferenceError(r3);

    table<record {readonly int id; string name; record {} details;}> key (id) v4 =
        table [
            {id: 1023, name: "Joy", details: {}}
        ];
    record {} details = v4.get(1023).details;
    details["tb"] = v4;
    json|error r4 = toJsonWithCyclicValues(v4);
    assertCyclicReferenceError(r4);
}

@test:Config
function testToJsonWithoutCyclicValuesWithRepeatedSimpleValueMembers() {
    byte byteVal = 3;
    json jsonVal = {
        "a": "abc",
        "b": 1,
        "c": true,
        "d": null,
        "e": 1,
        "f": null,
        "g": true,
        "h": byteVal,
        "i": 2f,
        "j": 2f,
        "k": "non-dup",
        "l": 3d,
        "m": byteVal,
        "n": 3d,
        "o": "abc",
        "p": false
    };
    json jsonRes = toJson(jsonVal);
    test:assertEquals(jsonVal, jsonRes);
    test:assertNotExactEquals(jsonVal, jsonRes);
}

type GreetingConf record {|
    readonly int id;
    record {| string message; |} greeting;
    record {| int count; int interval; |} repetition;
|};

@test:Config
function testToJsonWithoutCyclicValuesWithRepeatedStructuredMembers() {
    map<json> greetingConf = {greeting: {message: "hello world"}, repetition: {count: 2, interval: 5}};
    map<json>[] greetingConfs = [greetingConf, greetingConf];
    json arrJson = toJson(greetingConfs);
    test:assertEquals(greetingConfs, arrJson);
    test:assertNotExactEquals(greetingConfs, arrJson);

    GreetingConf gc = {
        id: 1001,
        greeting: {message: "hello world"},
        repetition: {count: 2, interval: 5}
    };
    table<GreetingConf> tab = table [];
    tab.put(gc);
    tab.put({id: 1002, greeting: {message: "hello!"}, repetition: {count: 1, interval: 30}});
    tab.put(gc);
    json tabJson = toJson(tab);
    test:assertEquals(<json[]> [
        gc,
        {id: 1002, greeting: {message: "hello!"}, repetition: {count: 1, interval: 30}},
        gc
    ], tabJson);

    int[] arr = [1, 2, 3];
    map<int[]> mp = {
        a: arr,
        b: [],
        c: [3, 5, 6, 7],
        d: arr
    };
    json mapJson = toJson(mp);
    test:assertEquals(mp, mapJson);
    test:assertNotExactEquals(mp, mapJson);
}

@test:Config
function testToJsonWithCyclicValuesWithOtherSimpleValueMembers() {
    byte byteVal = 3;
    map<json> jsonVal = {
        "a": "abc",
        "b": 1,
        "c": true,
        "d": null,
        "e": 1,
        "f": null,
        "g": true,
        "h": byteVal,
        "i": 2f,
        "j": 2f,
        "k": "non-dup",
        "l": 3d,
        "m": byteVal,
        "n": 3d,
        "o": "abc",
        "p": false
    };
    jsonVal["q"] = jsonVal;
    json|error r1 = toJsonWithCyclicValues(jsonVal);
    assertCyclicReferenceError(r1);
}

function toJsonWithCyclicValues(anydata val) returns json|error {
    return trap toJson(val);
}

function assertCyclicReferenceError(json|error res) {
    test:assertTrue(res is error);
    error err = <error> res;
    test:assertEquals("the value has a cyclic reference", err.message());
}
