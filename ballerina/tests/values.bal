// Copyright (c) 2024 WSO2 LLC (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
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

import ballerina/lang.'float as fl;
import ballerina/'lang.'int as integer;

decimal d1 = 2.34;
decimal? d2 = 3.65;
decimal? d3 = ();
int|decimal d4 = 4.12;
decimal d5 = 0;
decimal d6 = -0;
decimal d7 = getDecimal();

float f1 = 1.23;
float f2 = 4.32;
float f3 = fl:Infinity;
float f4 = -fl:Infinity;
float? f5 = ();
int|float f6 = 4.12;
float f7 = 0;
float f8 = -0;
float f9 = getFloat();

int i1 = 1;
int i2 = -1;
int i3 = -0;
int i4 = 0;
int i5 = integer:MAX_VALUE;
int i6 = integer:MIN_VALUE;
int|string i7 = 2;
int? i8 = 2;
int? i9 = ();
int i10 = getInt();

boolean b1 = true;
boolean b2 = false;
boolean? b3 = b1;
boolean? b4 = ();
boolean|int b5 = false;
boolean b6 = getBoolean();

string s1 = "";
string s2 = "string";
string:Char s3 = "a";
string? s4 = "string";
string? s5 = ();
int|string s6 = "string";
string s7 = getString();

() n1 = ();
()[]|() n2 = ();
() n3 = getNil();

json decimalJson = {
    a1: d1,
    a2: d2,
    a3: d3,
    a4: d4,
    a5: d5,
    a6: d6,
    a7: d7
};

json floatJson = {
    a1: f1,
    a2: f2,
    a3: f3,
    a4: f4,
    a5: f5,
    a6: f6,
    a7: f7,
    a8: f8,
    a9: f9
};

json intJson = {
    a1: i1,
    a2: i2,
    a3: i3,
    a4: i4,
    a5: i5,
    a6: i6,
    a7: i7,
    a8: i8,
    a9: i9,
    a10: i10
};

json booleanJson = {
    a1: b1,
    a2: b2,
    a3: b3,
    a4: b4,
    a5: b5,
    a6: b6
};

json stringJson = {
    a1: s1,
    a2: s2,
    a3: s3,
    a4: s4,
    a5: s5,
    a6: s6,
    a7: s7
};

json nilJson = {
    a1: n1,
    a2: n2,
    a3: n3
};

map<json> jsonMap = <map<json>>{
    a1: decimalJson,
    a2: floatJson,
    a3: intJson,
    a4: booleanJson,
    a5: stringJson,
    a6: nilJson,
    a7: getJson()
};

json j1 = {
    a1: decimalJson,
    a2: floatJson,
    a3: intJson,
    a4: booleanJson,
    a5: stringJson,
    a6: nilJson,
    a7: getJson()
};

json j2 = {
    a1: jsonMap,
    a2: getMap(),
    a3: <map<json>>{}
};

json j3 = {
    a1: j1,
    a2: j2,
    a3: n1,
    a4: i1,
    a5: d1,
    a6: f1,
    a7: b1,
    a8: s1
};

json j4 = {
    a1: [decimalJson, intJson, floatJson],
    a2: [nilJson, stringJson, booleanJson],
    a3: []
};

json j5 = {
    a1: {
        a1: i1
    },
    a2: {
        a1: d1
    },
    a3: {
        a1: f1
    },
    a4: {
        a1: b1
    },
    a5: {
        a1: s1
    },
    a6: {
        a1: n1
    }
};

json j6 = {
    a1: [d1, d2, d3, d4, d5, d6],
    a2: [f1, f2, f3, f4, f5, f6],
    a3: [i1, i2, i3, i4, i5, i6],
    a4: [n1, n2, n3],
    a5: [s1, s2, s3, s4, s5, s6],
    a6: [b1, b2, b3, b4, b5, b6],
    a7: {
        a1: [s2],
        a2: s2
    }
};

function getInt() returns int {
    return i1;
};

function getDecimal() returns decimal {
    return d1;
};

function getFloat() returns float {
    return f1;
};

function getMap() returns map<json> {
    return jsonMap;
};

function getBoolean() returns boolean {
    return b1;
};

function getString() returns string {
    return s1;
};

function getNil() {
    return n1;
};

function getJson() returns json {
    return intJson;
};
