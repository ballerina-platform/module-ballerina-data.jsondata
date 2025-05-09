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
public type StringConstraintsConfig record {|
    # The maximum number of characters allowed in the string.
    int:Unsigned32 maxLength?;
    # The minimum number of characters required in the string.
    int:Unsigned32 minLength?;
    # A regular expression that the string must match.
    string:RegExp pattern?;
    # The format that the string must adhere to (e.g., email, date-time).
    string format?;
|};

# The annotation is used to specify validation constraints for string type.
public annotation StringConstraintsConfig StringConstraints on type;

# Defines constraints for JSON schema number type.
public type NumberConstraintsConfig record {|
    # The inclusive upper bound of the constrained type.
    int|float|decimal maximum?;
    # The inclusive lower bound of the constrained type.
    int|float|decimal minimum?;
    # The exclusive upper bound of the constrained type.
    int|float|decimal exclusiveMaximum?;
    # The exclusive lower bound of the constrained type.
    int|float|decimal exclusiveMinimum?;
    # The number must be a multiple of this value.
    int|float|decimal multipleOf?;
|};

# The annotation is used to specify validation constraints for number type.
public annotation NumberConstraintsConfig NumberConstraints on type;

# Defines constraints for JSON Schema array type.
public type ArrayConstraintsConfig record {|
    # The minimum number of items required in the array.
    int:Unsigned32 minItems = 0;
    # The maximum number of items allowed in the array.
    int:Unsigned32 maxItems?;
    # Specifies whether all items in the array must be unique.
    boolean uniqueItems?;
    # Specifies a schema that a specific number of items in the array must match.
    record {|
        int:Unsigned32 minContains = 0;
        int:Unsigned32 maxContains?;
        typedesc<json> value;
    |} contains?;
    # Specifies a schema for items that are not evaluated by contains.
    typedesc<json> unevaluatedItems?;
|};

# The annotation is used to specify validation constraints for array type.
public annotation ArrayConstraintsConfig ArrayConstraints on type;

# Defines constraints for JSON Schema object type.
public type ObjectConstraintsConfig record {|
    # The maximum number of properties allowed in the object.
    int:Unsigned32 maxProperties?;
    # The minimum number of properties required in the object.
    int:Unsigned32 minProperties?;
    # The schema to validate the names of properties in the object.
    typedesc<json> propertyNames?;
|};

# The annotation is used to specify validation constraints for object type.
public annotation ObjectConstraintsConfig ObjectConstraints on type;

# Defines a dependent sub Schema in an object field.
public type DependentSchemaConfig record {|
    # The dependent sub Schema
    typedesc<json> value;
|};

# The annotation is used to specify a dependent schema.
public annotation DependentSchemaConfig DependentSchema on record field;

# Defines the fields dependent required on other fields.
public type DepenedentRequiredConfig record {|
    # The dependent required field/fields
    string|string[] value;
|};

# The annotation is used to specify dependent Required fields.
public annotation DepenedentRequiredConfig DependentRequired on record field;

# Represents a single patternProperties rule in a JSON object schema.
public type PatternPropertiesElement record {|
    # A regular expression that the property name must match
    string:RegExp pattern;
    # The type that properties matching the pattern must conform to
    typedesc<json> value;
|};

# A container for multiple patternProperties rules.
public type PatternPropertiesElements record {|
    # The list of patternProperties rules (each with a pattern and type)
    PatternPropertiesElement|PatternPropertiesElement[] value;
|};

# Annotation used to define patternProperties constraints on object types.
public annotation PatternPropertiesElements PatternProperties on type;

# Defines data type of the additional properties.
public type AdditionalPropertiesConfig record {|
    # Data type of the respective field
    typedesc<json> value;
|};

# The annotation is used to specify additionalProperties in an object.
public annotation AdditionalPropertiesConfig AdditionalProperties on type;
