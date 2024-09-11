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
import ballerina/jballerina.java;

# Convert value of type `json` to subtype of `anydata`.
#
# + v - Source JSON value
# + options - Options to be used for filtering in the projection
# + t - Target type
# + return - On success, returns value belonging to the given target type, else returns an `jsondata:Error` value.
public isolated function parseAsType(json v, Options options = {}, typedesc<anydata> t = <>)
        returns t|Error = @java:Method {'class: "io.ballerina.lib.data.jsondata.json.Native"} external;

# Converts JSON string to subtype of anydata.
#
# + s - Source JSON string value or byte[] or byte-block-stream
# + options - Options to be used for filtering in the projection
# + t - Target type
# + return - On success, value belonging to the given target type, else returns an `jsondata:Error` value.
public isolated function parseString(string s, Options options = {}, typedesc<anydata> t = <>)
        returns t|Error = @java:Method {'class: "io.ballerina.lib.data.jsondata.json.Native"} external;

# Converts JSON byte[] to subtype of anydata.
#
# + s - Source JSON byte[]
# + options - Options to be used for filtering in the projection
# + t - Target type
# + return - On success, value belonging to the given target type, else returns an `jsondata:Error` value.
public isolated function parseBytes(byte[] s, Options options = {}, typedesc<anydata> t = <>)
        returns t|Error = @java:Method {'class: "io.ballerina.lib.data.jsondata.json.Native"} external;

# Converts JSON byte-block-stream to subtype of anydata.
#
# + s - Source JSON byte-block-stream
# + options - Options to be used for filtering in the projection
# + t - Target type
# + return - On success, value belonging to the given target type, else returns an `jsondata:Error` value.
public isolated function parseStream(stream<byte[], error?> s, Options options = {}, typedesc<anydata> t = <>)
        returns t|Error = @java:Method {'class: "io.ballerina.lib.data.jsondata.json.Native"} external;

# Converts a value of type `anydata` to `json`.
#
# + j - Source anydata value
# + return - representation of `j` as value of type json
public isolated function toJson(anydata j) returns json {
    if j is anydata[] {
        json[] arr = from anydata elem in j
            select toJson(elem);
        return arr;
    } else if j is map<anydata> {
        map<json> m = {};
        foreach var [key, v] in j.entries() {
            string newKey = getNameAnnotation(j, key);
            m[newKey] = toJson(v);
        }
        return m;
    } else {
        return j.toJson();
    }
}

isolated function getNameAnnotation(map<anydata> data, string key) returns string = @java:Method {'class: "io.ballerina.lib.data.jsondata.json.Native"} external;

# Prettifies a `json` value to print it.
#
# + value - The `json` value to be prettified
# + indentation - The number of spaces for an indentation
# + return - The prettified `json` as a string
public isolated function prettify(json value, int indentation = 4) returns string {
    string indent = getIndentation(indentation);
    return prettifyJson(value, indent, 0);
}

# Represent the options that can be used to modify the behaviour of the projection.
#
# + allowDataProjection - Enable or disable projection
# + enableConstraintValidation - Enable or disable constraint validation
public type Options record {
    record {
        # If `true`, nil values will be considered as optional fields in the projection.
        boolean nilAsOptionalField = false;
        # If `true`, absent fields will be considered as nilable types in the projection.
        boolean absentAsNilableType = false;
    }|false allowDataProjection = {};
    boolean enableConstraintValidation = true;
};

# Defines the name of the JSON Object key.
#
# + value - The name of the JSON Object key
public type NameConfig record {|
    string value;
|};

# The annotation is used to overwrite the existing record field name.
public const annotation NameConfig Name on record field;
