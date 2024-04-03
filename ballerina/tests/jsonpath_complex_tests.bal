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

import ballerina/'lang.'int as integer;
import ballerina/lang.'float as fl;
import ballerina/test;

@test:Config {}
function testSelectAllExpression() returns error? {
    JsonPathRawTemplate jsonpath = `$.*`;

    json result = check read(decimalJson, jsonpath);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[2.34, 3.65, (), 4.12, 0.0, 0.0, 2.34]);
    json[] resultsArray = <json[]>result;
    test:assertEquals(resultsArray.length(), 7);
    test:assertTrue(resultsArray[0] is float);
    test:assertTrue(resultsArray[1] is float);
    test:assertTrue(resultsArray[2] is ());
    test:assertTrue(resultsArray[3] is float);
    test:assertTrue(resultsArray[4] is float);
    test:assertTrue(resultsArray[5] is float);
    test:assertTrue(resultsArray[6] is float);

    result = check read(floatJson, jsonpath);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[1.23, 4.32, fl:Infinity, -fl:Infinity, (), 4.12, 0.0, 0.0, 1.23]);
    resultsArray = <json[]>result;
    test:assertEquals(resultsArray.length(), 9);
    test:assertTrue(resultsArray[0] is float);
    test:assertTrue(resultsArray[1] is float);
    test:assertTrue(resultsArray[2] is float);
    test:assertTrue(resultsArray[3] is float);
    test:assertTrue(resultsArray[4] is ());
    test:assertTrue(resultsArray[5] is float);
    test:assertTrue(resultsArray[6] is float);
    test:assertTrue(resultsArray[7] is float);
    test:assertTrue(resultsArray[8] is float);

    result = check read(intJson, jsonpath);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[1, -1, 0, 0, integer:MAX_VALUE, integer:MIN_VALUE, 2, 2, (), 1]);
    resultsArray = <json[]>result;
    test:assertEquals(resultsArray.length(), 10);
    test:assertTrue(resultsArray[0] is int);
    test:assertTrue(resultsArray[1] is int);
    test:assertTrue(resultsArray[2] is int);
    test:assertTrue(resultsArray[3] is int);
    test:assertTrue(resultsArray[4] is int);
    test:assertTrue(resultsArray[5] is int);
    test:assertTrue(resultsArray[6] is int);
    test:assertTrue(resultsArray[7] is int);
    test:assertTrue(resultsArray[8] is ());
    test:assertTrue(resultsArray[9] is int);

    result = check read(booleanJson, jsonpath);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[true, false, true, (), false, true]);
    resultsArray = <json[]>result;
    test:assertEquals(resultsArray.length(), 6);
    test:assertTrue(resultsArray[0] is boolean);
    test:assertTrue(resultsArray[1] is boolean);
    test:assertTrue(resultsArray[2] is boolean);
    test:assertTrue(resultsArray[3] is ());
    test:assertTrue(resultsArray[4] is boolean);
    test:assertTrue(resultsArray[5] is boolean);

    result = check read(stringJson, jsonpath);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>["", "string", "a", "string", (), "string", ""]);
    resultsArray = <json[]>result;
    test:assertEquals(resultsArray.length(), 7);
    test:assertTrue(resultsArray[0] is string);
    test:assertTrue(resultsArray[1] is string);
    test:assertTrue(resultsArray[2] is string);
    test:assertTrue(resultsArray[3] is string);
    test:assertTrue(resultsArray[4] is ());
    test:assertTrue(resultsArray[5] is string);
    test:assertTrue(resultsArray[6] is string);

    result = check read(nilJson, jsonpath);
    test:assertTrue(result is json[]);
    test:assertEquals(result, [(), (), ()]);
    resultsArray = <json[]>result;
    test:assertEquals(resultsArray.length(), 3);
    test:assertTrue(resultsArray[0] is ());
    test:assertTrue(resultsArray[1] is ());
    test:assertTrue(resultsArray[2] is ());

    result = check read(j1, jsonpath);
    test:assertTrue(result is json[]);
    test:assertEquals(result, [decimalJson, floatJson, intJson, booleanJson, stringJson, nilJson, intJson]);

    result = check read(j2, jsonpath);
    test:assertTrue(result is json[]);
    test:assertEquals(result, [jsonMap, jsonMap, {}]);

    result = check read(j3, jsonpath);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[j1, j2, n1, i1, <float>d1, f1, b1, s1]);

    result = check read(j4, jsonpath);
    test:assertTrue(result is json[]);
    test:assertEquals(result, [[decimalJson, intJson, floatJson], [nilJson, stringJson, booleanJson], []]);
}

@test:Config {}
function testSelectElementExpression() returns error? {
    string expression = "$.a1";
    string elementName = "a1";

    json result = check read(decimalJson, `$.a1`);
    test:assertTrue(result is float);
    test:assertEquals(result, 2.34);

    result = check read(floatJson, `$.${elementName}`);
    test:assertTrue(result is float);
    test:assertEquals(result, 1.23);

    result = check read(intJson, `$.a1`);
    test:assertTrue(result is int);
    test:assertEquals(result, 1);

    result = check read(booleanJson, `$.${elementName}`);
    test:assertTrue(result is boolean);
    test:assertEquals(result, true);

    result = check read(stringJson, `$.${elementName}`);
    test:assertTrue(result is string);
    test:assertEquals(result, "");

    result = check read(nilJson, `$.a1`);
    test:assertTrue(result is ());
    test:assertEquals(result, ());

    result = check read(j1, `${expression}`);
    test:assertEquals(result, decimalJson);

    result = check read(j2, `${expression}`);
    test:assertTrue(result is map<json>);
    test:assertEquals(result, jsonMap);

    result = check read(j3, `$.a1`);
    test:assertEquals(result, j1);

    result = check read(j3, `$['a1']`);
    test:assertEquals(result, j1);

    result = check read(j4, `$.a1`);
    test:assertTrue(result is json[]);
    test:assertEquals(result, [decimalJson, intJson, floatJson]);

    result = check read(j4, `$['a1']`);
    test:assertTrue(result is json[]);
    test:assertEquals(result, [decimalJson, intJson, floatJson]);

    result = check read(j4, `$['${"a1"}']`);
    test:assertTrue(result is json[]);
    test:assertEquals(result, [decimalJson, intJson, floatJson]);

    result = check read(check j4.a1, `$[-1]`);
    test:assertEquals(result, floatJson);

    result = check read([check j4.a2], `$[0][-1].a1`);
    test:assertEquals(result, b1);
}

@test:Config {}
function testNestedSelectElementExpression() returns error? {
    string expression = "$.a1.a1";
    string nestedElementName = "a1.a1";

    json result = check read(j1, `$.a1.a1`);
    test:assertTrue(result is float);
    test:assertEquals(result, 2.34);

    result = check read(j2, `$.${nestedElementName}`);
    test:assertEquals(result, decimalJson);

    result = check read(j3, `${expression}`);
    test:assertEquals(result, decimalJson);

    result = check read(j1, `$..a1.a2`);
    test:assertTrue(result is json[]);
    test:assertEquals(result, [3.65]);

    result = check read(j2, `$..a2.a3`);
    test:assertEquals(result, <json[]>[intJson, fl:Infinity, fl:Infinity]);

    result = check read(j2, `$..a2.['a3']`);
    test:assertEquals(result, <json[]>[intJson, fl:Infinity, fl:Infinity]);

    result = check read(j2, `$..a30.a3`);
    test:assertEquals(result, <json[]>[]);

    result = check read(j3, `$..a1.a2`);
    test:assertEquals(result, <json[]>[floatJson, 3.65, floatJson, 3.65, 3.65]);

    result = check read(j3, `$..a1.['a2']`);
    test:assertEquals(result, <json[]>[floatJson, 3.65, floatJson, 3.65, 3.65]);

    result = check read(j4, `$..a2.a2`);
    test:assertEquals(result, []);

    result = check read(j4, `$..a3.a2`);
    test:assertEquals(result, <json[]>[]);

    result = check read(j4, `$..a3.['a2']`);
    test:assertEquals(result, <json[]>[]);
}

@test:Config {}
function testSelectElementWithWildcardExpression() returns error? {
    JsonPathRawTemplate jsonpath = `$..*`;
    json[] assertResult = [
        decimalJson,
        floatJson,
        intJson,
        booleanJson,
        stringJson,
        nilJson,
        intJson,
        2.34,
        3.65,
        (),
        4.12,
        0.0,
        -0.0,
        2.34,
        1.23,
        4.32,
        fl:Infinity,
        -fl:Infinity,
        (),
        4.12,
        0.0,
        -0.0,
        1.23,
        1,
        -1,
        0,
        -0,
        integer:MAX_VALUE,
        integer:MIN_VALUE,
        2,
        2,
        (),
        1,
        true,
        false,
        true,
        (),
        false,
        true,
        "",
        "string",
        "a",
        "string",
        (),
        "string",
        "",
        (),
        (),
        (),
        1,
        -1,
        0,
        -0,
        integer:MAX_VALUE,
        integer:MIN_VALUE,
        2,
        2,
        (),
        1
    ];

    json result = check read(j1, jsonpath);
    test:assertEquals(result, assertResult);

    result = check read(j2, jsonpath);
    test:assertEquals(result, <json[]>[jsonMap, jsonMap, {}, ...assertResult, ...assertResult]);
}

@test:Config {}
function testSelectElementByIndexExpression() returns error? {
    string expression = "$[0]";
    JsonPathRawTemplate jsonpath = `$[0]`;

    int index = 5;

    json result = check read([d1, d2, f1, f2], jsonpath);
    test:assertTrue(result is decimal);
    test:assertEquals(result, <decimal>2.34);

    result = check read([d1, s1, n2, b6], `$[${3}]`);
    test:assertTrue(result is boolean);
    test:assertEquals(result, true);

    result = check read([n1, d3, f3, b4, s1, s5], `$[${index}]`);
    test:assertTrue(result is ());
    test:assertEquals(result, ());

    result = check read([(), (), ()], `${expression}`);
    test:assertTrue(result is ());
    test:assertEquals(result, ());

    result = check read([jsonMap], `$${"["}0${"]"}`);
    test:assertTrue(result is map<json>);
    test:assertEquals(result, jsonMap);

    result = check read([j4], `$[0]`);
    test:assertEquals(result, j4);

    result = check read(j4, `$.a1[0]`);
    test:assertEquals(result, decimalJson);

    result = check read(check j4?.a1, jsonpath);
    test:assertEquals(result, decimalJson);
}

@test:Config {}
function testSelectElementByIndexRangeExpression() returns error? {
    JsonPathRawTemplate jsonpath = `$[0:2]`;

    int index = 0;

    json result = check read([j1, j2, j3, j4], jsonpath);
    test:assertTrue(result is json[]);
    test:assertEquals(result, [j1, j2]);

    result = check read([j1, j2, j3, j4], `$[3].a1[${index}:${index + 3}]`);
    test:assertTrue(result is json[]);
    test:assertEquals(result, [decimalJson, intJson, floatJson]);

    result = check read(j4, `$.a1[0:]`);
    test:assertTrue(result is json[]);
    test:assertEquals(result, [decimalJson, intJson, floatJson]);

    result = check read(j4, `$.a1[:2]`);
    test:assertTrue(result is json[]);
    test:assertEquals(result, [decimalJson, intJson]);

    result = check read(j4, `$.a1[10:3]`);
    test:assertTrue(result is json[]);
    test:assertEquals(result, []);

    result = check read(j4, `$.a1[-1:-2]`);
    test:assertTrue(result is json[]);
    test:assertEquals(result, []);

    result = check read(j4, `$.a1[-1:-100]`);
    test:assertTrue(result is json[]);
    test:assertEquals(result, []);

    result = check read(j4, `$.a1[-1:10]`);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[floatJson, decimalJson, intJson, floatJson]);

    result = check read(j4, `$.a1[-1:1]`);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[floatJson, decimalJson]);

    result = check read(j4, `$.a1[-3:-1]`);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[decimalJson, intJson]);

    result = check read(j4, `$.a1[2:10]`);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[floatJson]);

    result = check read(j4, `$.a1[-2:]`);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[intJson, floatJson]);

    result = check read(j4, `$.a1[:-2]`);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[decimalJson]);
}

@test:Config {}
function testSelectElementBySpecificNameExpression() returns error? {
    string attributeName = "a2";
    JsonPathRawTemplate exp1 = `$..a1`;
    JsonPathRawTemplate exp2 = `$..['a1']`;
    JsonPathRawTemplate exp3 = `$..['${attributeName}']`;

    json result = check read(decimalJson, exp1);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[2.34]);

    result = check read(nilJson, exp2);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[n1]);

    result = check read(j1, exp3);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[floatJson, 3.65, f2, i2, b2, s2, n2, i2]);

    result = check read(j2, exp1);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[jsonMap, decimalJson, 2.34, f1, i1, b1, s1, n1, i1, decimalJson, 2.34, f1, i1,
                                    b1, s1, n1, i1]);

    result = check read(j3, exp2);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[j1, decimalJson, 2.34, f1, i1, b1, s1, n1, i1, jsonMap, decimalJson, 2.34, f1,
                                    i1, b1, s1, n1, i1, decimalJson, 2.34, f1, i1, b1, s1, n1, i1]);

    result = check read(j4, exp3);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[[nilJson, stringJson, booleanJson], 3.65, i2, f2, n2, s2, b2]);
}

@test:Config {}
function testSelectElementByConditionalExpression() returns error? {
    JsonPathRawTemplate condition1 = `$[?(@.a2)]`;
    JsonPathRawTemplate condition2 = `$[?(@.a9)]`;
    JsonPathRawTemplate condition3 = `$[?(@.a2 && @.a9)]`;
    JsonPathRawTemplate condition4 = `$[?(@.a2 || @.a9)]`;
    JsonPathRawTemplate condition5 = `$[?(@.a9 && @.a100)]`;
    JsonPathRawTemplate condition6 = `$[?(@.a9 || @.a100)]`;
    JsonPathRawTemplate condition7 = `$[?(@.a101 && @.a100)]`;
    JsonPathRawTemplate condition8 = `$[?(@.a101 || @.a100)]`;

    json result = check read(decimalJson, condition1);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[decimalJson]);

    result = check read(decimalJson, condition2);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[]);

    result = check read(decimalJson, condition3);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[]);

    result = check read(decimalJson, condition4);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[decimalJson]);

    result = check read(decimalJson, condition5);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[]);

    result = check read(decimalJson, condition6);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[]);

    result = check read(decimalJson, condition7);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[]);

    result = check read(decimalJson, condition8);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[]);

    result = check read(check j4.a1, condition1);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[decimalJson, intJson, floatJson]);

    result = check read(check j4.a1, condition2);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[intJson, floatJson]);

    result = check read(check j4.a1, condition3);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[intJson, floatJson]);

    result = check read(check j4.a1, condition4);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[decimalJson, intJson, floatJson]);

    result = check read(check j4.a1, condition5);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[]);

    result = check read(check j4.a1, condition6);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[intJson, floatJson]);

    result = check read(check j4.a1, condition7);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[]);

    result = check read(check j4.a1, condition8);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[]);
}

@test:Config {}
function testSelectElementByNumericalConditionalExpression() returns error? {
    int v1 = 2;
    decimal v2 = 2.1;
    float v3 = 3.65;
    decimal v4 = 2.34;

    JsonPathRawTemplate condition1 = `$[?(@.a2 > ${v1})]`;
    JsonPathRawTemplate condition2 = `$[?(@.a1 < ${v2})]`;
    JsonPathRawTemplate condition3 = `$[?(@.a2 >= ${v3})]`;
    JsonPathRawTemplate condition4 = `$[?(@.a1 < ${v2} && @.a2 > ${v1})]`;
    JsonPathRawTemplate condition5 = `$[?(@.a1 < ${v2} || @.a2 > ${v1})]`;
    JsonPathRawTemplate condition6 = `$[?(@.a1 == ${v4})]`;
    JsonPathRawTemplate condition7 = `$[?(@.a2 > 1.1)]`;
    JsonPathRawTemplate condition8 = `$[?(@.a1 == 2.34)]`;
    JsonPathRawTemplate condition9 = `$[?(@.a1 == 12.34)]`;
    JsonPathRawTemplate condition10 = `$[?(@.a1 != 12.34)]`;
    JsonPathRawTemplate condition11 = `$[?(@.a1 <= ${d1} && @.a1 > ${i1})]`;

    json result = check read([decimalJson, floatJson, intJson], condition1);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[decimalJson, floatJson]);

    result = check read([decimalJson, floatJson, intJson], condition2);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[floatJson, intJson]);

    result = check read([decimalJson, floatJson, intJson], condition3);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[decimalJson, floatJson]);

    result = check read([decimalJson, floatJson, intJson], condition4);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[floatJson]);

    result = check read([decimalJson, floatJson, intJson], condition5);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[decimalJson, floatJson, intJson]);

    result = check read([decimalJson, floatJson, intJson], condition6);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[decimalJson]);

    result = check read([decimalJson, floatJson, intJson], condition7);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[decimalJson, floatJson]);

    result = check read([decimalJson, floatJson, intJson], condition8);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[decimalJson]);

    result = check read([decimalJson, floatJson, intJson], condition9);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[]);

    result = check read([decimalJson, floatJson, intJson], condition10);
    test:assertTrue(result is json[]);
    test:assertEquals(result, [decimalJson, floatJson, intJson]);

    result = check read([decimalJson, floatJson, intJson], condition11);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[decimalJson, floatJson]);
}

@test:Config {}
function testSelectElementByPatternMatchingExpression() returns error? {
    json result = check read([decimalJson, floatJson, intJson], `$[?(@.a1=='2.34')]`);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[decimalJson]);

    result = check read([decimalJson, floatJson, intJson], `$[?(@.a7=='0.0' || @.a5=='0.0' || @.a4=='0')]`);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[decimalJson, floatJson, intJson]);

    result = check read([decimalJson, floatJson, intJson, nilJson, stringJson, booleanJson],
                             `$[?(@.a2=='string'&&@.a3=='a')]`);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[stringJson]);

    result = check read([decimalJson, floatJson, intJson, nilJson, stringJson, booleanJson],
                             `$[?(@.a21=='string'&&@.a3=='a')]`);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[]);

    result = check read(stringJson, `$[?(@.a2=~/^.*trin.*$/)]`);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[stringJson]);

    result = check read([stringJson, booleanJson, decimalJson, floatJson, stringJson],
                             `$[?(@.a2=~/^.*trin.*$/)]`);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[stringJson, stringJson]);

    result = check read([stringJson, booleanJson, stringJson], `$[?(@.a2=~'')]`);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[]);

    result = check read([stringJson, booleanJson, stringJson], `$[?(@.a2=~123)]`);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[]);

    result = check read(j1, `$..a1[?(@.a4==4.12)].a2`);
    test:assertTrue(result is json[]);
    test:assertEquals(result, [3.65]);

    result = check read(j2, `$..a1.a4[?(@.a1)].a3`);
    test:assertTrue(result is json[]);
    test:assertEquals(result, [true]);

    result = check read(j3, `$.a2.a1.a1[?(@.a1==2.34)].a4`);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[4.12]);

    result = check read(j3, `$.a2.a1.a1[?(@.a1==100)].a4`);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[]);

    result = check read(j3, `$.a2.a1.a1[?(@.a1==2.34)].a100`);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[]);

    result = check read(j4, `$..a1[0].a2[?(@.a3)]`);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[]);

    result = check read(j4, `$..a1[0][?(@.a4)]`);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[decimalJson]);

    result = check read(j4, `$..a1[0,1].a2`);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[3.65, -1]);

    result = check read(j4, `$..a1[0,1,2].a2`);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[3.65, -1, 4.32]);

    result = check read(decimalJson, `$['a1','a2','a3']`);
    test:assertEquals(result, {"a1": 2.34, "a2": 3.65, "a3": null});

    result = check read(j4, `$..a1[0,-1,-2].a2`);
    test:assertTrue(result is json[]);
    test:assertEquals(result, <json[]>[3.65, 4.32, -1]);

    result = check read(decimalJson, `$['a1','a2','a1000']`);
    test:assertEquals(result, {"a1": 2.34, "a2": 3.65});
}

@test:Config {}
function testFunctionExpression() returns error? {
    json result = check read(j4, `$..a1.sum()`);
    test:assertEquals(result, 4.57);

    result = check read(j4, `$..a2.sum()`);
    test:assertEquals(result, <float><decimal>d2 + f2 + <float>i2);

    result = check read(j4, `$..a10.avg()`);
    test:assertEquals(result, 1.0);

    result = check read(j4, `$..a10.avg()`);
    test:assertEquals(result, 1.0);

    result = check read(j5, `$..a1.sum()`);
    test:assertEquals(result, 4.57);

    result = check read(j5, `$..a1.min()`);
    test:assertEquals(result, 1.0);

    result = check read(j5, `$..a1.max()`);
    test:assertEquals(result, 2.34);

    result = check read(j4, `$['a1'].length()`);
    test:assertEquals(result, 3);

    result = check read(j5, `$..a1.stddev()`);
    test:assertEquals(result, 0.5850546033396269);

    result = check read(j4, `$['a3'].append(3)`);
    test:assertEquals(result, [3]);

    result = check read(j4, `$['a1'].append({})`);
    test:assertEquals(result, [decimalJson, intJson, floatJson, {}]);

    result = check read(j4, `$['a1'].append({"a1":3})`);
    test:assertEquals(result, [decimalJson, intJson, floatJson, {a1: 3}]);

    result = check read(j4, `$['a1'].append()`);
    test:assertEquals(result, [decimalJson, intJson, floatJson]);

    result = check read(j4, `$.append()`);
    test:assertEquals(result, j4);

    result = check read(j4, `$['a3'].keys()`);
    test:assertEquals(result, ());

    result = check read(j3, `$['a1'].keys()`);
    test:assertEquals(result, <json[]>["a1", "a2", "a3", "a4", "a5", "a6", "a7"]);

    result = check read(j2, `$['a2'].keys()`);
    test:assertEquals(result, <json[]>["a1", "a2", "a3", "a4", "a5", "a6", "a7"]);

    result = check read(j4, `$['a1'].keys()`);
    test:assertEquals(result, ());

    result = check read(j4, `$..['a1'].keys()`);
    test:assertEquals(result, <json[]>["a1", "a2", "a3"]);

    result = check read(decimalJson, `$['a1'].keys()`);
    test:assertEquals(result, ());
}

@test:Config {}
function testListOperations() returns error? {

    json result = check read(j4, `$.a2[1][?(@.a2 in ['string', 'string2'])]`);
    test:assertEquals(result, <json[]>[stringJson]);

    result = check read(j4, `$.a2[1][?(@.a2 nin ['string', 'string2'])]`);
    test:assertEquals(result, <json[]>[]);

    result = check read(j4, `$.a2[1][?(@.a1 nin ['string', 'string2'])]`);
    test:assertEquals(result, <json[]>[stringJson]);

    result = check read(j4, `$.a2[1][?(@.a1 in ['string', 'string2'])]`);
    test:assertEquals(result, <json[]>[]);

    result = check read(j4, `$.a1[0][?(@.a1 in [${d1}, 3.21])]`);
    test:assertEquals(result, <json[]>[decimalJson]);

    result = check read(j4, `$.a1[0][?(@.a2 in [${d1}, 3.21])]`);
    test:assertEquals(result, <json[]>[]);

    result = check read(j4, `$.a1[0][?(@.a1 nin [${d1}, 3.21])]`);
    test:assertEquals(result, <json[]>[]);

    result = check read(j4, `$.a1[0][?(@.a2 nin [${d1}, 3.21])]`);
    test:assertEquals(result, <json[]>[decimalJson]);

    result = check read(j4, `$.a1[1][?(@.a1 in [${i1}, 3.21])]`);
    test:assertEquals(result, <json[]>[intJson]);

    result = check read(j4, `$.a1[1][?(@.a2 in [${i1}, 3.21])]`);
    test:assertEquals(result, <json[]>[]);

    result = check read(j4, `$.a1[1][?(@.a1 nin [${i1}, 3.21])]`);
    test:assertEquals(result, <json[]>[]);

    result = check read(j4, `$.a1[1][?(@.a2 nin [${i1}, 3.21])]`);
    test:assertEquals(result, <json[]>[intJson]);

    result = check read(j4, `$.a1[2][?(@.a1 in [${f1}, 3.21])]`);
    test:assertEquals(result, <json[]>[floatJson]);

    result = check read(j4, `$.a1[2][?(@.a2 in [${f1}, 3.21])]`);
    test:assertEquals(result, <json[]>[]);

    result = check read(j4, `$.a1[2][?(@.a1 nin [${f1}, 3.21])]`);
    test:assertEquals(result, <json[]>[]);

    result = check read(j4, `$.a1[2][?(@.a2 nin [${f1}, 3.21])]`);
    test:assertEquals(result, <json[]>[floatJson]);

    result = check read(j4, `$.a2[0][?(@.a1 in [1.12, null])]`);
    test:assertEquals(result, <json[]>[nilJson]);

    result = check read(j4, `$.a2[0][?(@.a4 in [12.25, null, 3.21])]`);
    test:assertEquals(result, <json[]>[]);

    result = check read(j4, `$.a2[0][?(@.a1 nin [3.21, null])]`);
    test:assertEquals(result, <json[]>[]);

    result = check read(j4, `$.a2[0][?(@.a2 nin [1.2, 3.21])]`);
    test:assertEquals(result, <json[]>[nilJson]);

    result = check read(j4, `$.a2[0][?(@.a2 nin [])]`);
    test:assertEquals(result, <json[]>[nilJson]);

    result = check read(j4, `$.a2[0][?(@.a2 nin [])]`);
    test:assertEquals(result, <json[]>[nilJson]);

    result = check read(j4, `$.a2[1][?(@.a1 in [1.12, '${s1}'])]`);
    test:assertEquals(result, <json[]>[stringJson]);

    result = check read(j4, `$.a2[1][?(@.a2 in [12.25, ${s1}, 3.21])]`);
    test:assertEquals(result, <json[]>[]);

    result = check read(j4, `$.a2[1][?(@.a1 nin [3.21, '${s1}'])]`);
    test:assertEquals(result, <json[]>[]);

    result = check read(j4, `$.a2[1][?(@.a2 nin ['${s1}', 3.21])]`);
    test:assertEquals(result, <json[]>[stringJson]);

    result = check read(j4, `$.a2[2][?(@.a1 in [1.12, ${b1}])]`);
    test:assertEquals(result, <json[]>[booleanJson]);

    result = check read(j4, `$.a2[2][?(@.a2 in [12.25, ${b1}, 3.21])]`);
    test:assertEquals(result, <json[]>[]);

    result = check read(j4, `$.a2[2][?(@.a1 nin [3.21, ${b1}])]`);
    test:assertEquals(result, <json[]>[]);

    result = check read(j4, `$.a2[2][?(@.a2 nin [${b1}, 3.21])]`);
    test:assertEquals(result, <json[]>[booleanJson]);
}

@test:Config {}
function testGeneralJsonPathExpresions() returns error? {
    json result = check read(j5, `$`);
    test:assertEquals(result, j5);

    result = check read(j5, `@`);
    test:assertEquals(result, j5);
}

type A JsonPathRawTemplate;

@test:Config {}
function testTypeReferencetype() returns error? {
    A path = `$`;

    json result = check read(j5, path);
    test:assertEquals(result, j5);
}
