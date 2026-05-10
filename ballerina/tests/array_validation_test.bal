// Copyright (c) 2026, WSO2 LLC. (https://www.wso2.com).
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

// ============================================================
// Type Definitions from Schema Files
// ============================================================

public type Schema19 [json...];

public type Schema20_noRecord string;

@StringConstraints {
 minLength: 5
}
public type SchemaRestItemString string;

@NumberConstraints {
 minimum: 20.0
}
public type SchemaRestItemNumber int|float|decimal;

public type Schema21 [(SchemaRestItemString|SchemaRestItemNumber)...];

public type Schema22 [string...];

@ArrayConstraints {
    prefixItems: [int, boolean]
}
public type Schema23 [(int|boolean|string)...];

@NumberConstraints {
    minimum: 4.0
}
public type SchemaItem0_24 int;

@ArrayConstraints {
    prefixItems: [SchemaItem0_24]
}
public type Schema24 [(SchemaItem0_24|string)...];

@ArrayConstraints {
    prefixItems: [int],
    minItems: 3
}
public type Schema25 [int, string, string, string...];

@ArrayConstraints {
 minItems: 10
}
public type Schema26 [int, string...];

public type Schema27 never;

public const SCHEMA_CONST_MAP = {"foo": "bar"};

public type SchemaConstTuple [SCHEMA_CONST_MAP];

public type SchemaItem0_28 int|float|decimal;

public type SchemaRestItem_28 string|int;

@ArrayConstraints {
    prefixItems: [SchemaItem0_28]
}
public type Schema28 [(SchemaItem0_28|SchemaRestItem_28)...];

@ArrayConstraints {
    prefixItems: [int],
    maxItems: 4
}
public type Schema29 [(int|string)...];

@ArrayConstraints {
    prefixItems: [int],
    maxItems: 100
}
public type Schema30 [(int|string)...];

@ArrayConstraints {
 uniqueItems: true
}
public type Schema31 [string...];

@ArrayConstraints {
 uniqueItems: true,
 contains: {value: SchemaContains, minContains: 0}
}
public type Schema32 [string...];

@NumberConstraints {
 multipleOf: 2.0
}
public type SchemaContains int;

public type Schema44 [(int|float|decimal)...];

@NumberConstraints {
 multipleOf: 2.0
}
public type SchemaContains44Number int|float|decimal;

public type SchemaContains44 SchemaContains44Number|boolean|string|[json...]|record {| json...; |}|();

public type SchemaUnevaluatedItems int|float|decimal;

@ArrayConstraints {
    prefixItems: [string]
}
public type Schema54 [(string|Schema54)...];

@ArrayConstraints {
    prefixItems: [SchemaItem0_59, SchemaItem1_59]
}
public type Schema59 [(SchemaItem0_59|SchemaItem1_59|SchemaRestItem_59)...];

public type SchemaItem0_59 string;

@NumberConstraints {
    minimum: 0.0
}
public type SchemaItem1_59 int;

public type SchemaRestItem_59 boolean;

@MetaData {
 title: "User Roles List"
}
@ArrayConstraints {
 minItems: 2
}
public type Schema61 [SchemaItem0_61, SchemaItem1_61, SchemaRestItem_61...];

@MetaData {
 title: "Primary Role"
}
public type SchemaItem0_61 string;

@MetaData {
 title: "Secondary Role"
}
public type SchemaItem1_61 string;

@MetaData {
 title: "Additional Role"
}
public type SchemaRestItem_61 string;

@ArrayConstraints {
    contains: {value: string}
}
public type Schema62 [json...];

@ArrayConstraints {
    contains: {value: 5}
}
public type SchemaContainsConst [json...];

public type SchemaPrefixAliasItem int;

@ArrayConstraints {
    prefixItems: [SchemaPrefixAliasItem, SchemaPrefixAliasItem]
}
public type SchemaPrefixAliasOnly [(SchemaPrefixAliasItem|SchemaPrefixAliasItem|never)...];

public type SchemaPrefixRemainingA string;

public type SchemaPrefixRemainingB boolean;

@ArrayConstraints {
    prefixItems: [SchemaPrefixRemainingA]
}
public type SchemaPrefixRemaining [(SchemaPrefixRemainingA|SchemaPrefixRemainingB)...];

@ArrayConstraints {
    prefixItems: [SchemaNestedPrefixItem, SchemaNestedPrefixItem, SchemaNestedPrefixItem]
}
public type SchemaNestedPrefix [(SchemaNestedPrefixItem|SchemaNestedPrefixItem|SchemaNestedPrefixItem)...];

@ArrayConstraints {
    prefixItems: [SchemaNestedSubItem, SchemaNestedSubItem]
}
public type SchemaNestedPrefixItem [(SchemaNestedSubItem|SchemaNestedSubItem)...];

public type SchemaNestedSubItem record {|
    json foo;
    json...;
|};

@MetaData {
    title: "Array Missing Keywords"
}
@ArrayConstraints {
    contains: {value: MissingArrayKeywordsContains, minContains: 2, maxContains: 3},
    unevaluatedItems: boolean
}
public type MissingArrayKeywordsSchema [json...];

@NumberConstraints {
    minimum: 5.0
}
public type MissingArrayKeywordsContains int;


// ============================================================
// Test Functions
// ============================================================

function validArraySchemasForValidate() returns [json, typedesc<json>][] {
    return [
        [[1, "string", true, null, {"key": "value"}, [1, 2, 3]], Schema19],
        [["hello", "world", "ballerina"], Schema21],
        [["apple", "banana", "cherry", "date"], Schema22],
        [[1, true, "hello", "world", "test"], Schema23],
        [[5, "hello"], Schema24],
        [[42, "hello", "world"], Schema25],
        [[1, "a", "b", "c", "d", "e", "f", "g", "h", "i"], Schema26],
        [[42, "hello", "world"], Schema29],
        [[100, "a", "b", "c"], Schema30],
        [["apple", "banana", "cherry", "date"], Schema31],
        [["apple", "banana", "cherry"], Schema32],
        [[{"foo": "bar"}], SchemaConstTuple],
        [[2, 4, 6, 8, 10], Schema44],
        [["outer", ["inner1"]], Schema54],
        [["alice", 30, true, false, true], Schema59],
        [["admin", "user"], Schema61],
        [["s", 2, 3], Schema62],
        [[5], SchemaContainsConst],
        [[1, 5, "x"], SchemaContainsConst],
        [[1, 1], SchemaPrefixAliasOnly],
        [["tag", true], SchemaPrefixRemaining],
        [[[{"foo": null}, {"foo": null}], [{"foo": null}, {"foo": null}], [{"foo": null}, {"foo": null}]], SchemaNestedPrefix],
        // missing array keywords tests (minContains/maxContains/unevaluatedItems)
        [[5, 6], MissingArrayKeywordsSchema],
        [[5, 7, true, false], MissingArrayKeywordsSchema],
        [[5, 6, 8, false], MissingArrayKeywordsSchema]
    ];
}

@test:Config {
    groups: ["array-validation"],
    dataProvider: validArraySchemasForValidate
}
function testValidArraySchemasForValidate(json sourceData, typedesc<json> expType) returns error? {
    check validate(sourceData, expType);
}

@test:Config {
    groups: ["array-validation"],
    dataProvider: invalidArraySchemasForValidate
}
function testInvalidArraySchemasForValidate(json sourceData, typedesc<json> expType) {
    Error? err = validate(sourceData, expType);
    test:assertTrue(err is Error, msg = "Expected validation to fail but it succeeded");
}

function invalidArraySchemasForValidate() returns [json, typedesc<json>][] {
    return [
        ["not an array", Schema19],
        [["hi", "test", "valid"], Schema21],
        [["string", 123, "another"], Schema22],
        [[1, "not boolean", "string"], Schema23],
        [[3, "hello"], Schema24],
        [[42, "hello"], Schema25],
        [[1, "a", "b", "c", "d", "e", "f", "g", "h"], Schema26],
        [[], Schema27],
        [[42, "a", "b", "c", "d"], Schema29],
        [[42, 123], Schema30],
        [["apple", "banana", "apple"], Schema31],
        [["apple", 3, "banana"], Schema32],
        [[{"foo": "baz"}], SchemaConstTuple],
        [[{"foo": "bar"}, {"foo": "bar"}], SchemaConstTuple],
        [["wrong type"], Schema44],
        [[123, ["array"]], Schema54],
        [["alice", -5], Schema59],
        [["admin"], Schema61],
        [[1, 2, 3], Schema62],
        [[], SchemaContainsConst],
        [[6], SchemaContainsConst],
        [[1, 1, 1], SchemaPrefixAliasOnly],
        [["tag", "extra"], SchemaPrefixRemaining],
        [[[{"foo": null}, {"foo": null}, {"foo": null}], [{"foo": null}, {"foo": null}], [{"foo": null}, {"foo": null}]], SchemaNestedPrefix],
        // missing array keywords tests (minContains/maxContains/unevaluatedItems)
        [[5], MissingArrayKeywordsSchema],
        [[5, 6, 7, 8], MissingArrayKeywordsSchema],
        [[4, 6], MissingArrayKeywordsSchema],
        [[true, false], MissingArrayKeywordsSchema]
    ];
}
