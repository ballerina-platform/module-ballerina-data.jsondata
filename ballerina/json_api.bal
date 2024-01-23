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

public isolated function fromJsonWithType(json v, Options options = {}, typedesc<anydata> t = <>)
        returns t|error = @java:Method {'class: "io.ballerina.stdlib.data.jsondata.json.Native"} external;

public isolated function fromJsonStringWithType(string|byte[]|stream<byte[], error?> s, Options options = {}, typedesc<anydata> t = <>)
        returns t|error = @java:Method {'class: "io.ballerina.stdlib.data.jsondata.json.Native"} external;

# Represent the options that can be used for filtering in the projection.
#
# + numericPreference - field description
public type Options record {
    typedesc<float|decimal> numericPreference = decimal;
};

# Represents the error type of the ballerina/data.jsondata module. This error type represents any error that can occur
# during the execution of jsondata APIs.
public type Error distinct error;
