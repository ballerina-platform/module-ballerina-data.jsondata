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

type intArrayReadonly int[] & readonly;

type intArray2dReadonly int[][] & readonly;

type booleanArrayReadonly boolean[] & readonly;

type type1Readonly [int, boolean, decimal, string] & readonly;

type type2Readonly map<int|string> & readonly;

type type3Readonly map<boolean> & readonly;

type type4Readonly map<map<int>> & readonly;

type type5Readonly map<int>[] & readonly;

type mapIntArrayReadonly map<int[]> & readonly;

type jsonTypeReadonly json & readonly;

type int2ArrayReadonly int[2] & readonly;

type char2ArrayReadonly string:Char[2] & readonly;

type char2DFixedArrayReadonly string:Char[3][4] & readonly;

type int2DFixedArrayReadonly int[2][1] & readonly;

type intTupleReadonly [[int], [int]] & readonly;

type intTupleRestReadonly [[int], [int]...] & readonly;

type intStringTupleReadonly [[int], [string]] & readonly;

type intStringTupleRestReadonly [[int], [string]...] & readonly;

type NilTypeReadonly () & readonly;

type BooleanTypeReadonly boolean & readonly;

type intTypeReadonly int & readonly;

type floatTypeReadonly float & readonly;

type decimalTypeReadonly decimal & readonly;

type stringTypeReadonly string & readonly;

type charTypeReadonly string:Char & readonly;

type ByteTypeReadonly byte & readonly;

type intUnsigned8Readonly int:Unsigned8 & readonly;

type intSigned8Readonly int:Signed8 & readonly;

type intUnsigned16Readonly int:Unsigned16 & readonly;

type intSigned16Readonly int:Signed16 & readonly;

type intUnsigned32Readonly int:Unsigned32 & readonly;

type intSigned32Readonly int:Signed32 & readonly;

type strinttupleReadonly [int, int] & readonly;

type stringArrReadonly string[] & readonly;

type tuple1Readonly [[int, string], [boolean, float]] & readonly;

type tuple2Readonly [[float, string], [boolean, decimal]...] & readonly;

type stringArrayTypeReadonly string[] & readonly;

type Rec1ReadOnly Rec1 & readonly;

type Rec2ReadOnly Rec2 & readonly;

type Rec3ReadOnly Rec3 & readonly;

type Rec1 record {|
    string name;
    int age;
    boolean isMarried = true;
    float...;
|};

type Rec2 record {|
    Rec1 student;
    string address;
    int count;
    float weight = 18.3;
    boolean...;
|};

type Rec3 record {|
    Rec1 student;
|};

type Rec4 record {|
    readonly string department;
    intTypeReadonly studentCount;
    Rec1ReadOnly[] student;
|};

type Rec5 record {|
    readonly & int id;
    Rec2 & readonly health;
|};

type ExpectedTuple [
    intArrayReadonly,
    type1Readonly,
    intArrayReadonly,
    intArray2dReadonly,
    type3Readonly,
    type4Readonly,
    type5Readonly,
    mapIntArrayReadonly,
    int2ArrayReadonly,
    int2DFixedArrayReadonly,
    intTupleReadonly,
    intTupleRestReadonly,
    intTupleRestReadonly,
    intStringTupleRestReadonly,
    intStringTupleRestReadonly,
    intTupleReadonly,
    int2DFixedArrayReadonly,
    BooleanTypeReadonly,
    BooleanTypeReadonly,
    intTypeReadonly,
    floatTypeReadonly,
    decimalTypeReadonly,
    stringTypeReadonly,
    charTypeReadonly,
    ByteTypeReadonly,
    intUnsigned8Readonly,
    intSigned8Readonly,
    intUnsigned16Readonly,
    intSigned16Readonly,
    intUnsigned32Readonly,
    intSigned32Readonly,
    NilTypeReadonly,
    Rec1ReadOnly,
    Rec3ReadOnly,
    Rec2ReadOnly,
    Rec4,
    Rec5
];

ExpectedTuple expectedResults = [
    [1, 2, 3],
    [12, true, 123.4, "hello"],
    [12, 13],
    [[12], [13]],
    {id: false, age: true},
    {key1: {id: 12, age: 24}, key2: {id: 12, age: 24}},
    [{id: 12, age: 24}, {id: 12, age: 24}],
    {key1: [12, 13], key2: [132, 133]},
    [12],
    [[1], [2]],
    [[1], [2]],
    [[1], [2], [3]],
    [[1]],
    [[1], ["2"], ["3"]],
    [[1]],
    [[1], [2]],
    [[1], [2]],
    true,
    false,
    12,
    12.3,
    12.3,
    "hello",
    "h",
    12,
    13,
    14,
    15,
    16,
    17,
    18,
    null,
    {name: "John", age: 30, "height": 1.8},
    {student: {name: "John", age: 30, "height": 1.8}},
    {"isSingle": true, address: "this is address", count: 14, student: {name: "John", age: 30, "height": 1.8}},
    {department: "CSE", studentCount: 3, student: [{name: "John", age: 30, "height": 1.8}]},
    {id: 12, health: {student: {name: "John", age: 30, "height": 1.8}, address: "this is address", count: 14}}
];

@test:Config {
    dataProvider: readonlyIntersectionTestDataForFromJsonStringWithType
}
isolated function testReadOnlyIntersectionTypeAsExpTypForFromJsonStringWithType(string sourceData,
        typedesc<anydata> expType, anydata expectedData) returns error? {
    anydata result = check fromJsonStringWithType(sourceData, {}, expType);
    test:assertEquals(result, expectedData);
}

function readonlyIntersectionTestDataForFromJsonStringWithType() returns [string, typedesc<anydata>, anydata][] {
    return [
        [string `[1, 2, 3]`, intArrayReadonly, expectedResults[0]],
        ["[12, true, 123.4, \"hello\"]", type1Readonly, expectedResults[1]],
        ["[12, 13]", intArrayReadonly, expectedResults[2]],
        ["[[12], [13]]", intArray2dReadonly, expectedResults[3]],
        ["{\"id\": false, \"age\": true}", type3Readonly, expectedResults[4]],
        ["{\"key1\": {\"id\": 12, \"age\": 24}, \"key2\": {\"id\": 12, \"age\": 24}}", type4Readonly, expectedResults[5]],
        ["[{\"id\": 12, \"age\": 24}, {\"id\": 12, \"age\": 24}]", type5Readonly, expectedResults[6]],
        ["{\"key1\": [12, 13], \"key2\": [132, 133]}", mapIntArrayReadonly, expectedResults[7]],
        ["[12]", int2ArrayReadonly, expectedResults[8]],
        ["[[1],[2]]", int2DFixedArrayReadonly, expectedResults[9]],
        ["[[1],[2]]", intTupleReadonly, expectedResults[10]],
        ["[[1],[2],[3]]", intTupleRestReadonly, expectedResults[11]],
        ["[[1]]", intTupleRestReadonly, expectedResults[12]],
        ["[[1],[\"2\"],[\"3\"]]", intStringTupleRestReadonly, expectedResults[13]],
        ["[[1]]", intStringTupleRestReadonly, expectedResults[14]],
        ["[[1],[2]]", intTupleReadonly, expectedResults[15]],
        ["[[1],[2]]", int2DFixedArrayReadonly, expectedResults[16]],
        ["true", BooleanTypeReadonly, expectedResults[17]],
        ["false", BooleanTypeReadonly, expectedResults[18]],
        ["12", intTypeReadonly, expectedResults[19]],
        ["12.3", floatTypeReadonly, expectedResults[20]],
        ["12.3", decimalTypeReadonly, expectedResults[21]],
        ["\"hello\"", stringTypeReadonly, expectedResults[22]],
        ["\"h\"", charTypeReadonly, expectedResults[23]],
        ["12", ByteTypeReadonly, expectedResults[24]],
        ["13", intUnsigned8Readonly, expectedResults[25]],
        ["14", intSigned8Readonly, expectedResults[26]],
        ["15", intUnsigned16Readonly, expectedResults[27]],
        ["16", intSigned16Readonly, expectedResults[28]],
        ["17", intUnsigned32Readonly, expectedResults[29]],
        ["18", intSigned32Readonly, expectedResults[30]],
        ["null", NilTypeReadonly, expectedResults[31]],
        [string `{"name": "John", "age": 30, "height": 1.8}`, Rec1ReadOnly, expectedResults[32]],
        [string `{"student": {"name": "John", "age": 30, "height": 1.8}}`, Rec3ReadOnly, expectedResults[33]],
        [string `{"isSingle": true, "address": "this is address", "count": 14,"student": {"name": "John", "age": 30, "height": 1.8}}`, Rec2ReadOnly, expectedResults[34]],
        [string `{"department": "CSE", "studentCount": 3, "student": [{"name": "John", "age": 30, "height": 1.8}]}`, Rec4, expectedResults[35]],
        [string `{"id": 12, "health": {"student": {"name": "John", "age": 30, "height": 1.8}, "address": "this is address", "count": 14}}`, Rec5, expectedResults[36]]
    ];
}

@test:Config {
    dataProvider: readonlyIntersectionTestDataForFromJsonWithType
}
isolated function testReadOnlyIntersectionTypeAsExpTypForFromJsonWithType(json sourceData,
        typedesc<anydata> expType, anydata expectedData) returns error? {
    anydata result = check fromJsonWithType(sourceData, {}, expType);
    test:assertEquals(result, expectedData);
}

function readonlyIntersectionTestDataForFromJsonWithType() returns [json, typedesc<anydata>, anydata][] {
    return [
        [[1, 2, 3], intArrayReadonly, expectedResults[0]],
        [[12, true, 123.4, "hello"], type1Readonly, expectedResults[1]],
        [[12, 13], intArrayReadonly, expectedResults[2]],
        [[[12], [13]], intArray2dReadonly, expectedResults[3]],
        [{id: false, age: true}, type3Readonly, expectedResults[4]],
        [{key1: {id: 12, age: 24}, key2: {id: 12, age: 24}}, type4Readonly, expectedResults[5]],
        [[{id: 12, age: 24}, {id: 12, age: 24}], type5Readonly, expectedResults[6]],
        [{key1: [12, 13], key2: [132, 133]}, mapIntArrayReadonly, expectedResults[7]],
        [[12], int2ArrayReadonly, expectedResults[8]],
        [[[1], [2]], int2DFixedArrayReadonly, expectedResults[9]],
        [[[1], [2]], intTupleReadonly, expectedResults[10]],
        [[[1], [2], [3]], intTupleRestReadonly, expectedResults[11]],
        [[[1]], intTupleRestReadonly, expectedResults[12]],
        [[[1], ["2"], ["3"]], intStringTupleRestReadonly, expectedResults[13]],
        [[[1]], intStringTupleRestReadonly, expectedResults[14]],
        [[[1], [2]], intTupleReadonly, expectedResults[15]],
        [[[1], [2]], int2DFixedArrayReadonly, expectedResults[16]],
        [true, BooleanTypeReadonly, expectedResults[17]],
        [false, BooleanTypeReadonly, expectedResults[18]],
        [12, intTypeReadonly, expectedResults[19]],
        [12.3, floatTypeReadonly, expectedResults[20]],
        [12.3, decimalTypeReadonly, expectedResults[21]],
        ["hello", stringTypeReadonly, expectedResults[22]],
        ["h", charTypeReadonly, expectedResults[23]],
        [12, ByteTypeReadonly, expectedResults[24]],
        [13, intUnsigned8Readonly, expectedResults[25]],
        [14, intSigned8Readonly, expectedResults[26]],
        [15, intUnsigned16Readonly, expectedResults[27]],
        [16, intSigned16Readonly, expectedResults[28]],
        [17, intUnsigned32Readonly, expectedResults[29]],
        [18, intSigned32Readonly, expectedResults[30]],
        [null, NilTypeReadonly, expectedResults[31]],
        [{name: "John", "age": 30, "height": 1.8}, Rec1ReadOnly, expectedResults[32]],
        [{"student": {"name": "John", "age": 30, "height": 1.8}}, Rec3ReadOnly, expectedResults[33]],
        [
            {
                "isSingle": true,
                "address": "this is address",
                "count": 14,
                "student": {"name": "John", "age": 30, "height": 1.8}
            },
            Rec2ReadOnly,
            expectedResults[34]
        ],
        [{"department": "CSE", "studentCount": 3, "student": [{"name": "John", "age": 30, "height": 1.8}]}, Rec4, expectedResults[35]],
        [{"id": 12, "health": {"student": {"name": "John", "age": 30, "height": 1.8}, "address": "this is address", "count": 14}}, Rec5, expectedResults[36]]
    ];
}
