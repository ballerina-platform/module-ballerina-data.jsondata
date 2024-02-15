// Copyright (c) 2024, WSO2 LLC. (https://www.wso2.com).
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

import ballerina/jballerina.java;

# Convert value of type `json` to subtype of `anydata`.
#
# + v - Source JSON value
# + options - Options to be used for filtering in the projection
# + t - Target type
# + return - On success, returns the given target type value, else returns an `jsondata:Error`
public isolated function fromJsonWithType(json v, Options options = {}, typedesc<anydata> t = <>)
        returns t|Error = @java:Method {'class: "io.ballerina.stdlib.data.jsondata.json.Native"} external;

# Converts JSON string, byte[] or byte-block-stream to subtype of anydata.
#
# + s - Source JSON string value or byte[] or byte-block-stream
# + options - Options to be used for filtering in the projection
# + t - Target type
# + return - On success, returns the given target type value, else returns an `jsondata:Error`
public isolated function fromJsonStringWithType(string|byte[]|stream<byte[], error?> s, Options options = {}, typedesc<anydata> t = <>)
        returns t|Error = @java:Method {'class: "io.ballerina.stdlib.data.jsondata.json.Native"} external;

# Converts a value of type `anydata` to `json`.
#
# + v - Source anydata value
# + return - representation of `v` as value of type json
public isolated function toJson(anydata v) 
        returns json|Error = @java:Method {'class: "io.ballerina.stdlib.data.jsondata.json.Native"} external;

# Represent the options that can be used for filtering in the projection.
#
# + numericPreference - field description
public type Options record {
    typedesc<float|decimal> numericPreference = decimal;
};

# Represents the error type of the ballerina/data.jsondata module. This error type represents any error that can occur
# during the execution of jsondata APIs.
public type Error distinct error;

# Defines the name of the JSON Object key.
#
# + value - The name of the JSON Object key.
public type NameConfig record {|
    string value;
|};

# The annotation is used to overwrite the existing record field name.
public const annotation NameConfig Name on record field;
