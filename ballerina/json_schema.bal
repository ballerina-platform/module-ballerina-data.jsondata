// Copyright (c) 2025, WSO2 LLC. (https://www.wso2.com).
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

# Defines constraints for JSON schema string type.
#
# + maxLength - The maximum number of characters allowed in the string.
# + minLength - The minimum number of characters required in the string.
# + pattern - A regular expression that the string must match.
# + format - The format that the string must adhere to (e.g., email, date-time).
public type StringValidationRec record {|
    int:Unsigned32 maxLength?;
    int:Unsigned32 minLength?;
    string:RegExp pattern?;
    string format?;
|};

# The annotation is used to specify validation constraints for string type.
public annotation StringValidationRec StringValidation on type;

# Defines constraints for JSON schema number type.
#
# + maximum - The maximum value allowed.
# + minimum - The minimum value allowed.
# + exclusiveMaximum - The upper exclusive bound (value must be less than this).
# + exclusiveMinimum - The lower exclusive bound (value must be greater than this).
# + multipleOf - The number must be a multiple of this value.
public type NumberValidationRec record {|
    int|float|decimal maximum?;
    int|float|decimal minimum?;
    int|float|decimal exclusiveMaximum?;
    int|float|decimal exclusiveMinimum?;
    int|float|decimal multipleOf?;
|};

# The annotation is used to specify validation constraints for number type.
public annotation NumberValidationRec NumberValidation on type;

# Defines constraints for JSON Schema array type.
#
# + minItems - The minimum number of items required in the array.
# + maxItems - The maximum number of items allowed in the array.
# + uniqueItems - Specifies whether all items in the array must be unique.
# + unevaluatedItems - Specifies a schema for items that are not evaluated by contains.
# + contains - Specifies a schema that a specific number of items in the array must match.
public type ArrayValidationRec record {|
    int:Unsigned32 minItems = 0;
    int:Unsigned32 maxItems?;
    boolean uniqueItems?;
    record {|
        int:Unsigned32 minContains = 0;
        int:Unsigned32 maxContains?;
        typedesc<json> contains;
    |} contains?;
    typedesc<json> unevaluatedItems?;
|};

# The annotation is used to specify validation constraints for array type.
public annotation ArrayValidationRec ArrayValidation on type;

public type ObjectValidationRec record {|
    int:Unsigned32 maxProperties?;
    int:Unsigned32 minProperties?;
    typedesc<json> propertyNames?;
|};

# The annotation is used to specify validation constraints for object type.
public annotation ObjectValidationRec ObjectValidation on type;

# Defines a dependent schema.
#
# + value - The dependent Sub Schema
public type DependentSchemaRec record {|
    typedesc<json> value;
|};

# The annotation is used to specify a dependent schema.
public annotation DependentSchemaRec DependentSchema on record field;

# Defines the dependent Required fields.
#
# + value - The dependent Required fields
public type DependentRequiredRec record {|
    string[] value;
|};

# The annotation is used to specify dependent Required fields.
public annotation DependentRequiredRec DependentRequired on record field;

# Defines patternProperties in an object.
#
# + pattern - Regular expression for the field name
# + value - Data type of the respective field
public type PatternPropertiesElement record {
    string:RegExp pattern;
    typedesc<json> value;
};

# The annotation is used to specify patternProperties in an object.
public annotation record {PatternPropertiesElement[] value;} PatternProperties on type;

# Defines additionalProperties in an object.
#
# + value - Data type of the respective field
public type AdditionalPropertiesRec record {|
    typedesc<json> value;
|};

# The annotation is used to specify additionalProperties in an object.
public annotation AdditionalPropertiesRec AdditionalProperties on type;
