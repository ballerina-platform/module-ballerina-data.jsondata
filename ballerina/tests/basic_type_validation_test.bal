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
// Type Definitions - Basic Types
// ============================================================

// Null type
public type NullType ();

// Plain basic types
public type BasicString string;
public type BasicInt int;
public type BasicFloat float;
public type BasicDecimal decimal;
public type BasicBoolean boolean;

// Constrained string types

@StringConstraints {
    minLength: 2,
    maxLength: 10
}
public type BoundedString string;

@StringConstraints {
    pattern: re `^[a-z]+$`
}
public type PatternString string;

// Constrained number types

@NumberConstraints {
    minimum: 0.0,
    maximum: 100.0
}
public type BoundedInt int;

@NumberConstraints {
    exclusiveMinimum: 0.0,
    exclusiveMaximum: 100.0
}
public type ExclusiveRangeInt int;

@NumberConstraints {
    multipleOf: 5.0
}
public type MultipleOfFiveInt int;

@NumberConstraints {
    minimum: 1.0,
    maximum: 1000.0
}
public type BoundedFloat float;

@NumberConstraints {
    minimum: 0.0,
    maximum: 100.0
}
public type BoundedDecimal decimal;

// Union basic types
public type StringOrInt string|int;
public type BooleanOrInt boolean|int;
public type NullableString string|();
public type NullableInt int|();
public type NumberUnion int|float|decimal;

@NumberConstraints {
    minimum: 2.0
}
public type ReferencedNumberUnion int|float|decimal;

public type ReferencedMixedUnion ReferencedNumberUnion|boolean|string|[json...]|record {|
    json...;
|}|();

public type ReferencedMixedUnionSubTypes int|ReferencedMixedUnion;

@AllOf
public type ReferencedMixedUnionSchema json|ReferencedMixedUnionSubTypes;

public type ReferencedAnyOfNumber int|float|decimal;

public type ReferencedAnyOfSubTypes ReferencedAnyOfNumber|json;

@AllOf
public type ReferencedAnyOfSchema json|ReferencedAnyOfSubTypes;

@StringConstraints {
    minLength: 2
}
public type OneOfStringMin string;

@StringConstraints {
    maxLength: 4
}
public type OneOfStringMax string;

@OneOf
public type OneOfStringSubTypes OneOfStringMin|OneOfStringMax;

@AllOf
public type OneOfStringSchema string|OneOfStringSubTypes;

// Singleton types (const equivalent)
public type SingleInt 1;
public type SingleString "hello";

// Enum-like union of singletons
public type ColorEnum "red"|"green"|"blue";

// Never type (always fails validation)
public type NeverType never;

// ============================================================
// Valid Test Data Provider
// ============================================================

function validBasicTypeSchemasForValidate() returns [json, typedesc<json>][] {
    return [
        // Null type
        [null, NullType],

        // Plain basic types
        ["hello", BasicString],
        ["", BasicString],
        [42, BasicInt],
        [0, BasicInt],
        [-1, BasicInt],
        [3.14, BasicFloat],
        [0.0, BasicFloat],
        [100.5d, BasicDecimal],
        [0d, BasicDecimal],
        [true, BasicBoolean],
        [false, BasicBoolean],

        // BoundedString (minLength: 2, maxLength: 10)
        ["hello", BoundedString],
        ["ab", BoundedString],
        ["0123456789", BoundedString],

        // PatternString (pattern: ^[a-z]+$)
        ["hello", PatternString],
        ["a", PatternString],
        ["abcdefghijklmnopqrstuvwxyz", PatternString],

        // BoundedInt (minimum: 0, maximum: 100)
        [50, BoundedInt],
        [0, BoundedInt],
        [100, BoundedInt],

        // ExclusiveRangeInt (exclusiveMinimum: 0, exclusiveMaximum: 100)
        [50, ExclusiveRangeInt],
        [1, ExclusiveRangeInt],
        [99, ExclusiveRangeInt],

        // MultipleOfFiveInt (multipleOf: 5)
        [25, MultipleOfFiveInt],
        [0, MultipleOfFiveInt],
        [100, MultipleOfFiveInt],
        [-10, MultipleOfFiveInt],

        // BoundedFloat (minimum: 1.0, maximum: 1000.0)
        [500.0, BoundedFloat],
        [1.0, BoundedFloat],
        [1000.0, BoundedFloat],

        // BoundedDecimal (minimum: 0.0, maximum: 100.0)
        [50.0d, BoundedDecimal],
        [0.0d, BoundedDecimal],
        [100.0d, BoundedDecimal],

        // Union types - StringOrInt (string|int)
        ["hello", StringOrInt],
        [42, StringOrInt],
        [0, StringOrInt],
        ["", StringOrInt],

        // Union types - BooleanOrInt (boolean|int)
        [true, BooleanOrInt],
        [false, BooleanOrInt],
        [42, BooleanOrInt],

        // Nullable types - NullableString (string|())
        ["hello", NullableString],
        ["", NullableString],
        [null, NullableString],

        // Nullable types - NullableInt (int|())
        [42, NullableInt],
        [0, NullableInt],
        [null, NullableInt],

        // NumberUnion (int|float|decimal)
        [42, NumberUnion],
        [3.14, NumberUnion],
        [100.5d, NumberUnion],

        // ReferencedMixedUnionSchema validates nested referenced union members
        [2.5, ReferencedMixedUnionSchema],

        // ReferencedAnyOfSchema preserves json in nested referenced unions
        ["foo", ReferencedAnyOfSchema],

        // OneOfStringSchema allows values matching exactly one string branch
        ["a", OneOfStringSchema],
        ["abcde", OneOfStringSchema],

        // Singleton types
        [1, SingleInt],
        ["hello", SingleString],

        // Enum-like union of singletons
        ["red", ColorEnum],
        ["green", ColorEnum],
        ["blue", ColorEnum]
    ];
}

// ============================================================
// Valid Test Functions
// ============================================================

@test:Config {
    groups: ["basic-type-validation"],
    dataProvider: validBasicTypeSchemasForValidate
}
function testValidBasicTypeSchemasForValidate(json sourceData, typedesc<json> expType) returns error? {
    check validate(sourceData, expType);
}

// ============================================================
// Invalid Test Data Provider
// ============================================================

function invalidBasicTypeSchemasForValidate() returns [json, typedesc<json>][] {
    return [
        // Null type - wrong types
        ["hello", NullType],
        [42, NullType],
        [true, NullType],

        // BasicString - type mismatches
        [null, BasicString],
        [42, BasicString],
        [true, BasicString],

        // BasicInt - type mismatches
        [null, BasicInt],
        ["hello", BasicInt],
        [3.14, BasicInt],
        [true, BasicInt],

        // BasicFloat - type mismatches
        [null, BasicFloat],
        ["hello", BasicFloat],
        [true, BasicFloat],

        // BasicDecimal - type mismatches
        [null, BasicDecimal],
        ["hello", BasicDecimal],
        [true, BasicDecimal],

        // BasicBoolean - type mismatches
        [null, BasicBoolean],
        ["hello", BasicBoolean],
        [42, BasicBoolean],

        // BoundedString constraint violations
        ["a", BoundedString],
        ["01234567890", BoundedString],

        // PatternString constraint violations
        ["Hello", PatternString],
        ["hello123", PatternString],
        ["hello world", PatternString],

        // BoundedInt constraint violations
        [-1, BoundedInt],
        [101, BoundedInt],

        // ExclusiveRangeInt constraint violations
        [0, ExclusiveRangeInt],
        [100, ExclusiveRangeInt],
        [-1, ExclusiveRangeInt],
        [101, ExclusiveRangeInt],

        // MultipleOfFiveInt constraint violations
        [3, MultipleOfFiveInt],
        [7, MultipleOfFiveInt],
        [13, MultipleOfFiveInt],

        // BoundedFloat constraint violations
        [0.5, BoundedFloat],
        [1000.5, BoundedFloat],

        // BoundedDecimal constraint violations
        [-1.0d, BoundedDecimal],
        [101.0d, BoundedDecimal],

        // Union types - no matching variant
        [true, StringOrInt],
        [null, StringOrInt],
        [3.14, StringOrInt],

        ["hello", BooleanOrInt],
        [null, BooleanOrInt],

        [42, NullableString],
        [true, NullableString],

        [3.14, NullableInt],
        ["hello", NullableInt],

        // NumberUnion - non-number types
        ["hello", NumberUnion],
        [true, NumberUnion],
        [null, NumberUnion],

        // ReferencedMixedUnionSchema enforces nested numeric constraints
        [1.5, ReferencedMixedUnionSchema],

        // OneOfStringSchema rejects values matching both string branches
        ["ab", OneOfStringSchema],
        ["abcd", OneOfStringSchema],

        // Singleton types - wrong values
        [2, SingleInt],
        [0, SingleInt],
        ["world", SingleString],
        ["Hello", SingleString],

        // Enum-like union - wrong values
        ["yellow", ColorEnum],
        [1, ColorEnum],

        // Never type - everything fails
        [42, NeverType],
        ["hello", NeverType],
        [null, NeverType],
        [true, NeverType],

        // Complex types against basic types
        [[1, 2, 3], BasicString],
        [{"key": "value"}, BasicInt],
        [[1, 2, 3], BasicBoolean]
    ];
}

// ============================================================
// Invalid Test Functions
// ============================================================

@test:Config {
    groups: ["basic-type-validation"],
    dataProvider: invalidBasicTypeSchemasForValidate
}
function testInvalidBasicTypeSchemasForValidate(json sourceData, typedesc<json> expType) {
    Error? err = validate(sourceData, expType);
    test:assertTrue(err is Error, msg = "Expected validation to fail but it succeeded");
}
