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
 // Type Definitions - Fixed to match provided Annotations
 // ============================================================

 // 1. Fixed: propertyNames constraint using StringConstraints
 @StringConstraints {
     pattern: re `^[a-z_][a-z0-9_]*$`
 }
 public type SchemaPropertyNamePattern string;

 @ObjectConstraints {
     propertyNames: SchemaPropertyNamePattern
 }
 public type Schema1 record {| json...; |};

 // 2. Fixed: propertyNames with maxLength
 @StringConstraints {
     maxLength: 10
 }
 public type MaxLenString string;

 @ObjectConstraints {
     propertyNames: MaxLenString
 }
 public type Schema2 record {| json...; |};

 // 3. Fixed: propertyNames with minLength
 @StringConstraints {
     minLength: 2
 }
 public type MinLenString string;

 @ObjectConstraints {
     propertyNames: MinLenString
 }
 public type Schema3 record {| json...; |};

 public type Schema4 record {| json...; |};

 // ============================================================
 // patternProperties Tests - Fixed to match PatternPropertiesElements
 // ============================================================

 // Basic pattern matching
 @PatternProperties {
     value: [
         { pattern: re `^S_.*$`, value: string },
         { pattern: re `^I_.*$`, value: int }
     ]
 }
 public type SchemaPP1 record {| json...; |};

 // Multiple pattern matches
 @PatternProperties {
     value: [
         { pattern: re `.*test.*`, value: string },
         { pattern: re `.*_end$`, value: int }
     ]
 }
 public type SchemaPP2 record {| json...; |};

 // Complex regex patterns
 @PatternProperties {
     value: [
         { pattern: re `^[a-z]+_[0-9]+$`, value: int },
         { pattern: re `^[A-Z]{2,4}$`, value: string }
     ]
 }
 public type SchemaPP3 record {| json...; |};

 // Interaction with properties keyword
 @PatternProperties {
     value: [{ pattern: re `^prefix_.*$`, value: int }]
 }
 public type SchemaPP4 record {|
     string explicit;
     json...;
 |};

 // Interaction with additionalProperties (using never)
 @PatternProperties {
     value: [{ pattern: re `^S_.*$`, value: int }]
 }
 @AdditionalProperties {
     value: never
 }
 public type SchemaPP5 record {|
     string allowed;
     json...;
 |};

 // Interaction with additionalProperties (schema constraint)
 @PatternProperties {
     value: [{ pattern: re `^S_.*$`, value: string }]
 }
 @AdditionalProperties {
     value: boolean
 }
 public type SchemaPP6 record {| json...; |};

 // Single pattern element
 @PatternProperties {
     value: [{ pattern: re `^[a-z]+$`, value: string }]
 }
 public type SchemaPP7 record {| json...; |};

 // ============================================================
 // minProperties and maxProperties Tests
 // ============================================================

 // minProperties constraint
 @ObjectConstraints {
     minProperties: 2
 }
 public type SchemaMinProps1 record {| json...; |};

 // maxProperties constraint
 @ObjectConstraints {
     maxProperties: 3
 }
 public type SchemaMaxProps1 record {| json...; |};

 // Both minProperties and maxProperties constraints
 @ObjectConstraints {
     minProperties: 2,
     maxProperties: 3
 }
 public type SchemaMinMaxProps1 record {| json...; |};

 // ============================================================
 // required Tests
 // ============================================================

 // Mix of required and optional fields
 public type RequiredSchema1 record {|
     string name;
     int age?;
     string email;
     string phone?;
 |};

 // All required fields
 public type RequiredSchema2 record {|
     string name;
     int age;
     string email;
 |};

 // Only optional fields (no required constraint generated)
public type RequiredSchema3 record {|
    string name?;
    int age?;
    string email?;
|};

@Not {
    value: MissingKeywordsObjectNotSchema
}
@MetaData {
    title: "Object Missing Keywords"
}
@UnevaluatedProperties {
    value: boolean
}
public type MissingKeywordsObjectBase record {|
    string id?;
    int value?;
    json...;
|};

public type MissingKeywordsObjectNotSchemaObject record {|
    json forbidden;
    json...;
|};

public type MissingKeywordsObjectNotSchema boolean|string|[json...]|MissingKeywordsObjectNotSchemaObject|()|int|float|decimal;

public type MissingKeywordsObjectOneOfMain record {|
    json...;
|};

public type MissingKeywordsObjectOneOfA record {|
    "A" mode;
    json...;
|};

public type MissingKeywordsObjectOneOfB record {|
    "B" mode;
    json...;
|};

@OneOf
public type MissingKeywordsObjectOneOfSubTypes MissingKeywordsObjectOneOfA|MissingKeywordsObjectOneOfB;

@AllOf
public type MissingKeywordsObjectOneOf MissingKeywordsObjectOneOfMain|MissingKeywordsObjectOneOfSubTypes;

public type MissingKeywordsObjectAllOfMain record {|
    json...;
|};

public type MissingKeywordsObjectAllOf1 record {|
    string common;
    json...;
|};

public type MissingKeywordsObjectAllOf2 record {|
    int count;
    json...;
|};

@AllOf
public type MissingKeywordsObjectAllOfSubTypes MissingKeywordsObjectAllOf1|MissingKeywordsObjectAllOf2;

@AllOf
public type MissingKeywordsObjectAllOf MissingKeywordsObjectAllOfMain|MissingKeywordsObjectAllOfSubTypes;

@AllOf
public type MissingKeywordsObjectSubTypes MissingKeywordsObjectOneOf|MissingKeywordsObjectAllOf;

@AllOf
public type MissingKeywordsObjectSchema MissingKeywordsObjectBase|MissingKeywordsObjectSubTypes;

 // ============================================================
 // Test Functions (Logical values remain same, types updated)
 // ============================================================

function validObjectSchemasForValidate() returns [json, typedesc<json>][] {
    return [
        [{"first_name": "John", "last_name": "Doe", "age": 30}, Schema1],
        [{"a": 1, "b": 2, "c": 3}, Schema2],
        [{"ab": 1, "cd": 2}, Schema3],
        [{"anyName": 1, "ANOTHER": 2, "123": 3}, Schema4],
        [{"S_field": "test", "I_field": 42}, SchemaPP1],
        [{"test_field": "what"}, SchemaPP2],
        [{"abc_123": 456, "ABC": "test"}, SchemaPP3],
        [{"explicit": "defined", "prefix_1": 10}, SchemaPP4],
        [{"allowed": "yes", "S_1": 100}, SchemaPP5],
        [{"allowed": "test"}, SchemaPP5],
        [{"S_1": 10, "S_2": 20, "allowed": "present"}, SchemaPP5],
        [{"S_field": "test", "other": true}, SchemaPP6],
        [{"S_prop1": "hello", "is_active": true, "is_deleted": false}, SchemaPP6],
        [{"lowercase": "test"}, SchemaPP7],
        // minProperties tests
        [{"a": 1, "b": 2}, SchemaMinProps1],
        [{"x": 1, "y": 2, "z": 3}, SchemaMinProps1],
        // maxProperties tests
        [{"a": 1, "b": 2}, SchemaMaxProps1],
        [{"single": 1}, SchemaMaxProps1],
        // minProperties and maxProperties combined tests
        [{"a": 1, "b": 2}, SchemaMinMaxProps1],
        [{"x": 1, "y": 2, "z": 3}, SchemaMinMaxProps1],
        // required tests
        [{"name": "John", "email": "john@example.com"}, RequiredSchema1],
        [{"name": "John", "age": 30, "email": "john@example.com"}, RequiredSchema1],
        [{"name": "Jane", "age": 25, "email": "jane@example.com", "phone": "123-456-7890"}, RequiredSchema1],
        [{"name": "Alice", "age": 35, "email": "alice@example.com"}, RequiredSchema2],
        [{"name": "Bob", "age": 40, "email": "bob@example.com"}, RequiredSchema2],
        [{}, RequiredSchema3]
        // missing object keywords tests (allOf/not with generated oneOf structure)
//        [{"common": "enabled", "count": 1}, MissingKeywordsObjectSchema],
//        [{"id": "item-1", "value": 42, "common": "active", "count": 2, "isEnabled": true},
//        MissingKeywordsObjectSchema]
    ];
}

@test:Config {
 groups: ["object-validation"],
 dataProvider: validObjectSchemasForValidate
}
function testValidObjectSchemasForValidate(json sourceData, typedesc<json> expType) returns error? {
 check validate(sourceData, expType);
}

function invalidObjectSchemasForValidate() returns [json, typedesc<json>][] {
 return [
     [{"FirstName": "John"}, Schema1], // Fails pattern (Upper case)
     [{"veryLongPropertyName": 1}, Schema2], // Fails maxLength
     [{"a": 1}, Schema3], // Fails minLength
     [{"S_field": 42}, SchemaPP1], // Matches S_ (string) but is int
     [{"extra": "not allowed"}, SchemaPP5], // Fails AdditionalProperties
     [{"allowed": "yes", "S_1": "not an int"}, SchemaPP5], // Matches pattern property but wrong type (expected int)
     [{"allowed": "yes", "S_1": 10, "unmatched": "bad"}, SchemaPP5], // Valid pattern property, but has an unallowed additional property
     [{"S_1": true}, SchemaPP6], // Matches pattern property but wrong type (expected string, got boolean)
     [{"random_field": "not a boolean"}, SchemaPP6], // Fails additional property constraint (expected boolean, got string)
     [{"S_valid": "string", "invalid_additional": 123}, SchemaPP6], // Valid pattern property, but invalid additional property
     // minProperties tests
     [{"single":1}, SchemaMinProps1], // Only 1 property, minimum is 2
     [{}, SchemaMinProps1], // 0 properties, minimum is 2
     // maxProperties tests
     [{"a": 1, "b": 2, "c": 3, "d": 4}, SchemaMaxProps1], // 4 properties, maximum is 3
     [{"x": 1, "y": 2, "z": 3, "w": 4, "v": 5}, SchemaMaxProps1], // 5 properties, maximum is 3
     // minProperties and maxProperties combined tests
     [{"only": 1}, SchemaMinMaxProps1], // 1 property, below minimum of 2
     [{"a": 1, "b": 2, "c": 3, "d": 4}, SchemaMinMaxProps1], // 4 properties, above maximum of 3
     [{}, SchemaMinMaxProps1], // 0 properties, below minimum of 2
     // required tests
     [{}, RequiredSchema1], // Missing all required fields (name, email)
     [{"name": "John"}, RequiredSchema1], // Missing required field (email)
     [{"email": "john@example.com"}, RequiredSchema1], // Missing required field (name)
     [{"name": "Jane", "age": 30}, RequiredSchema1], // Missing required field (email)
     [{}, RequiredSchema2], // Missing all required fields (name, age, email)
     [{"name": "Alice"}, RequiredSchema2], // Missing required fields (age, email)
     [{"age": 25}, RequiredSchema2], // Missing required fields (name, email)
    [{"email": "alice@example.com"}, RequiredSchema2], // Missing required fields (name, age)
    [{"name": "Bob", "age": 40}, RequiredSchema2] // Missing required field (email)
    // missing object keywords tests (allOf/oneOf/not)
//    [{"mode": "A", "common": "enabled", "count": 1}, MissingKeywordsObjectSchema],
//    [{"mode": "B", "common": "enabled", "count": 1}, MissingKeywordsObjectSchema],
//    [{"common": "enabled"}, MissingKeywordsObjectSchema],
//    [{"common": "enabled", "count": 1, "forbidden": "x"}, MissingKeywordsObjectSchema]
];
}

@test:Config {
 groups: ["object-validation"],
 dataProvider: invalidObjectSchemasForValidate
}
function testInvalidObjectSchemasForValidate(json sourceData, typedesc<json> expType) {
 Error? err = validate(sourceData, expType);
 test:assertTrue(err is Error, msg = "Expected validation to fail but it succeeded");
}

// ============================================================
// DependentRequired Tests
// ============================================================

public type DependentRequiredType record {|
 string occupation?;
 @DependentRequired {
     value: ["age"]
 }
 string name?;
 @DependentRequired {
     value: ["name"]
 }
 int id?;
 @DependentRequired {
     value: ["id"]
 }
 int|float|decimal age?;
 int...;
|};

// ============================================================
// DependentSchema Tests
// ============================================================

public type AgeDependentSchema record {|
 string name?;
 json...;
|};

public type DependentSchemaType record {|
 string occupation?;
 json name?;
 int id?;
 @DependentSchema {
     value: AgeDependentSchema
 }
 int|float|decimal age?;
 int...;
|};

// ============================================================
// DependentRequired Valid Tests
// ============================================================

function validDependentRequiredSchemas() returns [json, typedesc<json>][] {
 return [
     // No dependent fields present — no dependency triggered
     [{}, DependentRequiredType],
     // Only non-dependent field present
     [{"occupation": "dev"}, DependentRequiredType],
     // All three dependent fields present — full cycle satisfied
     [{"name": "John", "id": 123, "age": 30}, DependentRequiredType],
     // All three + optional occupation
     [{"name": "John", "id": 123, "age": 30, "occupation": "dev"}, DependentRequiredType]
 ];
}

@test:Config {
 groups: ["object-validation"],
 dataProvider: validDependentRequiredSchemas
}
function testValidDependentRequiredSchemas(json sourceData, typedesc<json> expType) returns error? {
 check validate(sourceData, expType);
}

// ============================================================
// DependentRequired Invalid Tests
// ============================================================

function invalidDependentRequiredSchemas() returns [json, typedesc<json>][] {
 return [
     // name present but age missing (name requires age)
     [{"name": "John"}, DependentRequiredType],
     // id present but name missing (id requires name)
     [{"id": 123}, DependentRequiredType],
     // age present but id missing (age requires id)
     [{"age": 30}, DependentRequiredType],
     // name + id present but age missing (name requires age)
     [{"name": "John", "id": 123}, DependentRequiredType],
     // name + age present but id missing (age requires id)
     [{"name": "John", "age": 30}, DependentRequiredType],
     // age + id present but name missing (id requires name)
     [{"age": 30, "id": 123}, DependentRequiredType]
 ];
}

@test:Config {
 groups: ["object-validation"],
 dataProvider: invalidDependentRequiredSchemas
}
function testInvalidDependentRequiredSchemas(json sourceData, typedesc<json> expType) {
 Error? err = validate(sourceData, expType);
 test:assertTrue(err is Error, msg = "Expected validation to fail but it succeeded");
}

// ============================================================
// DependentSchema Valid Tests
// ============================================================

function validDependentSchemaSchemas() returns [json, typedesc<json>][] {
 return [
     // age not present — dependent schema not triggered
     [{}, DependentSchemaType],
     // age present, name is string — conforms to AgeDependentSchema
     [{"age": 30, "name": "John"}, DependentSchemaType],
     // age not present, name can be anything (no dependent schema check)
     [{"name": {"title": "Mr"}}, DependentSchemaType],
    // age present, no name field — conforms to AgeDependentSchema (name is optional)
    [{"age": 25}, DependentSchemaType],
    // age not present, nullable name still valid (dependent schema not triggered)
    [{"name": null}, DependentSchemaType],
    // age present with valid name and optional id
    [{"age": 50, "name": "Alex", "id": 100}, DependentSchemaType]
];
}

@test:Config {
 groups: ["object-validation"],
 dataProvider: validDependentSchemaSchemas
}
function testValidDependentSchemaSchemas(json sourceData, typedesc<json> expType) returns error? {
 check validate(sourceData, expType);
}

// ============================================================
// DependentSchema Invalid Tests
// ============================================================

function invalidDependentSchemaSchemas() returns [json, typedesc<json>][] {
 return [
    // age present, name is int — fails AgeDependentSchema (name must be string)
    [{"age": 30, "name": 123}, DependentSchemaType],
    // age present, name is object — fails AgeDependentSchema (name must be string)
    [{"age": 30, "name": {"title": "Mr"}}, DependentSchemaType],
    // age present, name is boolean — fails AgeDependentSchema
    [{"age": 30, "name": true}, DependentSchemaType],
    // age present, name is null — fails AgeDependentSchema
    [{"age": 30, "name": null}, DependentSchemaType]
];
}

@test:Config {
 groups: ["object-validation"],
 dataProvider: invalidDependentSchemaSchemas
}
function testInvalidDependentSchemaSchemas(json sourceData, typedesc<json> expType) {
 Error? err = validate(sourceData, expType);
 test:assertTrue(err is Error, msg = "Expected validation to fail but it succeeded");
}
