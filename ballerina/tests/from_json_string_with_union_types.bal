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

type RecA record {
    string a;
    int|float|string b;
};

type Union1 json|RecA|int;

type Union2 RecA|json|int;

@test:Config {
    groups: ["Union"]
}
isolated function testUnionTypeAsExpectedTypeForParseString1() returns error? {
    string jsonStr = string `{
        "a": "1",
        "b": 2
    }`;
    Union1 val = check parseString(jsonStr);
    test:assertTrue(val is json);
    test:assertEquals(val, {a: "1", b: 2});

    Union2 val2 = check parseString(jsonStr);
    test:assertTrue(val2 is RecA);
    test:assertEquals(val2, {a: "1", b: 2});
}

type RecB record {|
    Union1 field1;
    Union2 field2;
|};

@test:Config {
    groups: ["Union"]
}
isolated function testUnionTypeAsExpectedTypeForParseString2() returns error? {
    string jsonStr = string `{
        "field1": {
            "a": "1",
            "b": 2
        },
        "field2": {
            "a": "3",
            "b": 4
        }
    }`;
    RecB val = check parseString(jsonStr);
    test:assertEquals(val.field1, {a: "1", b: 2});
    test:assertEquals(val.field2, {a: "3", b: 4});
}

type RecC record {
    Union2[] field1;
    int|float[] field2;
    string field3;
};

@test:Config {
    groups: ["Union"]
}
isolated function testUnionTypeAsExpectedTypeForParseString3() returns error? {
    string jsonStr = string `{
        "field1": [
            {
                "a": "1",
                "b": 2
            },
            {
                "a": "3",
                "b": 4
            }
        ],
        "field2": [1.0, 2.0],
        "field3": "test"
    }`;
    RecC val = check parseString(jsonStr);
    test:assertEquals(val.field1, [{a: "1", b: 2}, {a: "3", b: 4}]);
    test:assertEquals(val.field2, [1.0, 2.0]);
    test:assertEquals(val.field3, "test");
}

type RecD record {
    RecB|RecC l;
    record {
        string|RecA m;
        int|float n;
    } p;
    string q;
};

@test:Config {
    groups: ["Union"]
}
isolated function testUnionTypeAsExpectedTypeForParseString4() returns error? {
    string jsonStr = string `{
        "l": {
            "field1": {
                "a": "1",
                "b": 2
            },
            "field2": {
                "a": "3",
                "b": 4
            }
        },
        "p": {
            "m": "5",
            "n": 6
        },
        "q": "test"
    }`;
    RecD val = check parseString(jsonStr);
    test:assertEquals(val.l.field1, {a: "1", b: 2});
    test:assertEquals(val.l.field2, {a: "3", b: 4});
    test:assertEquals(val.p.m, "5");
    test:assertEquals(val.p.n, 6);
    test:assertEquals(val.q, "test");
}

type UnionList1 [int, int, int]|int[]|float[];

@test:Config {
    groups: ["Union"]
}
isolated function testUnionTypeAsExpectedTypeForParseString5() returns error? {
    string jsonStr = string `[1, 2, 3]`;
    UnionList1 val = check parseString(jsonStr);
    test:assertEquals(val, [1, 2, 3]);

    string jsonStr2 = string `[1, 2, 3, 4]`;
    UnionList1 val2 = check parseString(jsonStr2);
    test:assertEquals(val2, [1, 2, 3]);

    UnionList1 val3 = check parseString(jsonStr2, {allowDataProjection: false});
    test:assertEquals(val3, [1, 2, 3, 4]);
}

type RecE record {|
    UnionList1 l;
    RecB|RecC m;
    float[] n;
|};

@test:Config {
    groups: ["Union"]
}
isolated function testUnionTypeAsExpectedTypeForParseString6() returns error? {
    string jsonStr = string `{
        "l": [1, 2, 3],
        "m": {
            "field1": {
                "a": "1",
                "b": 2
            },
            "field2": {
                "a": "3",
                "b": 4
            }
        },
        "n": [1.0, 2.0]
    }`;
    RecE val = check parseString(jsonStr);
    test:assertEquals(val.l, [1, 2, 3]);
    test:assertEquals(val.m.field1, {a: "1", b: 2});
    test:assertEquals(val.m.field2, {a: "3", b: 4});
    test:assertEquals(val.n, [1.0, 2.0]);
}
