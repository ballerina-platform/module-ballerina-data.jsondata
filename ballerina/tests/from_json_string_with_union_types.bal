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
    test:assertTrue(val.field1 is json);
    test:assertEquals(val.field1, {a: "1", b: 2});
    test:assertTrue(val.field2 is RecA);
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
    test:assertTrue(val.field1[0] is RecA);
    test:assertTrue(val.field1[1] is RecA);
    test:assertEquals(val.field1, [{a: "1", b: 2}, {a: "3", b: 4}]);
    test:assertTrue(val.field2 is float[]);
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
    test:assertTrue(val.l is RecB);
    test:assertTrue(val.l.field1 is json);
    test:assertEquals(val.l.field1, {a: "1", b: 2});
    test:assertTrue(val.l.field2 is RecA);
    test:assertEquals(val.l.field2, {a: "3", b: 4});
    test:assertTrue(val.p.m is string);
    test:assertEquals(val.p.m, "5");
    test:assertTrue(val.p.n is int);
    test:assertEquals(val.p.n, 6);
    test:assertEquals(val.q, "test");
}

type UnionList1 [int, int, int]|int[]|float[];

type UnionList2 int[]|[int, int, int]|float[];

@test:Config {
    groups: ["Union"]
}
isolated function testUnionTypeAsExpectedTypeForParseString5() returns error? {
    string jsonStr = string `[1, 2, 3]`;
    UnionList1 val = check parseString(jsonStr);
    test:assertTrue(val is [int, int, int]);
    test:assertEquals(val, [1, 2, 3]);

    string jsonStr2 = string `[1, 2, 3, 4]`;
    UnionList1 val2 = check parseString(jsonStr2);
    test:assertTrue(val2 is [int, int, int]);
    test:assertEquals(val2, [1, 2, 3]);

    UnionList1 val3 = check parseString(jsonStr2, {allowDataProjection: false});
    test:assertTrue(val2 is int[]);
    test:assertEquals(val3, [1, 2, 3, 4]);

    UnionList2 val4 = check parseString(jsonStr2);
    test:assertTrue(val4 is int[]);
    test:assertEquals(val4, [1, 2, 3, 4]);
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
        "l": [12, 22, 13, 44, 51, 26, 100],
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
    test:assertTrue(val.l is [int, int, int]);
    test:assertEquals(val.l, [12, 22, 13]);
    test:assertTrue(val.m is RecB);
    test:assertTrue(val.m.field1 is json);
    test:assertEquals(val.m.field1, {a: "1", b: 2});
    test:assertTrue(val.m.field2 is RecA);
    test:assertEquals(val.m.field2, {a: "3", b: 4});
    test:assertEquals(val.n, [1.0, 2.0]);
}

type UnionReadOnly1 Union1 & readonly;

type UnionReadOnly2 Union2 & readonly;

type UnionReadOnly3 UnionList1 & readonly;

type UnionReadOnly4 UnionList2 & readonly;

type ReadonlyRecB RecB & readonly;

type ReadonlyRecC RecC & readonly;

type ReadonlyRecD RecD & readonly;

type ReadonlyRecE RecE & readonly;

@test:Config {
    groups: ["Union"]
}
isolated function testUnionTypeAsExpectedTypeForParseString7() returns error? {
    string jsonStr = string `{
        "a": "1",
        "b": 2
    }`;
    UnionReadOnly1 val = check parseString(jsonStr);
    test:assertTrue(val is json & readonly);
    test:assertEquals(val, {a: "1", b: 2});

    UnionReadOnly2 val2 = check parseString(jsonStr);
    test:assertTrue(val2 is RecA & readonly);
    test:assertEquals(val2, {a: "1", b: 2});

    string jsonStr2 = string `[1, 2, 3, 4]`;
    UnionReadOnly3 val3 = check parseString(jsonStr2);
    test:assertTrue(val3 is ([int, int, int] & readonly));
    test:assertEquals(val3, [1, 2, 3]);

    UnionReadOnly4 val4 = check parseString(jsonStr2);
    test:assertTrue(val4 is (int[] & readonly));
    test:assertEquals(val4, [1, 2, 3, 4]);
    
    string jsonStr3 = string `{
        "field1": {
            "a": "1",
            "b": 2
        },
        "field2": {
            "a": "3",
            "b": 4
        }
    }`; 
    ReadonlyRecB val5 = check parseString(jsonStr3);
    test:assertTrue(val5.field1 is json & readonly);
    test:assertEquals(val5.field1, {a: "1", b: 2});
    test:assertTrue(val5.field2 is RecA & readonly);
    test:assertEquals(val5.field2, {a: "3", b: 4});

    string jsonStr4 = string `{
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
    ReadonlyRecC val6 = check parseString(jsonStr4);
    test:assertTrue(val6.field1[0] is RecA & readonly);
    test:assertTrue(val6.field1[1] is RecA & readonly);
    test:assertEquals(val6.field1, [{a: "1", b: 2}, {a: "3", b: 4}]);
    test:assertTrue(val6.field2 is (float[] & readonly));
    test:assertEquals(val6.field2, [1.0, 2.0]);
    test:assertEquals(val6.field3, "test");

    string jsonStr5 = string `{
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
    ReadonlyRecD val7 = check parseString(jsonStr5);
    test:assertTrue(val7.l is RecB & readonly);
    test:assertTrue(val7.l.field1 is json & readonly);
    test:assertEquals(val7.l.field1, {a: "1", b: 2});
    test:assertTrue(val7.l.field2 is RecA & readonly);
    test:assertEquals(val7.l.field2, {a: "3", b: 4});
    test:assertTrue(val7.p.m is string); 
    test:assertEquals(val7.p.m, "5");
    test:assertTrue(val7.p.n is int);
    test:assertEquals(val7.p.n, 6);
    test:assertEquals(val7.q, "test");

    string jsonStr6 = string `{
        "l": [12, 22, 13, 44, 51, 26, 100],
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
    ReadonlyRecE val8 = check parseString(jsonStr6);
    test:assertTrue(val8.l is ([int, int, int] & readonly));
    test:assertEquals(val8.l, [12, 22, 13]);
    test:assertTrue(val8.m is RecB & readonly);
    test:assertEquals(val8.m.field1, {a: "1", b: 2});
    test:assertTrue(val8.m.field2 is RecA & readonly);
    test:assertEquals(val8.m.field2, {a: "3", b: 4});
    test:assertEquals(val8.n, [1.0, 2.0]);
}

@test:Config {
    groups: ["Union"]
}
isolated function testUnionAsExpectedTypeForParseStringNegative() {
    string jsonStr = string `"1"`;
    int|RecA|Error err = parseString(jsonStr);
    test:assertTrue(err is error);
    test:assertEquals((<Error>err).message(), "incompatible expected type '(int|data.jsondata:RecA)' for value '1'");
    
    string jsonStr2 = string `{
        "field1": {
            "a": "1",
            "b": 2
        },
        "field2": {
            "a": "3",
            "b": 4
        }
    }`;
    record {|
        int|RecC field1;
        record {
            string|RecA a;
            int|float b;
        } field2;
    |}|Error err2 = parseString(jsonStr2);
    test:assertTrue(err2 is Error);
    test:assertEquals((<Error>err2).message(), "incompatible expected type '(int|data.jsondata:RecC)' for value '{\"a\":\"1\",\"b\":2}'");
}
