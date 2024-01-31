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

import ballerina/jballerina.java;
import ballerina/lang.'object as obj;

public type JsonPathValue ()|boolean|int|float|decimal|string|json[]|map<json>;

public type JsonPathRawTemplate object {
    *obj:RawTemplate;
    public (string[] & readonly) strings;
    public JsonPathValue[] insertions;
};

# Extract details from the given JSON value using the provided query template expression
# + 'json - JSON value
# + query - JSON path expression
# + return - extracted details as JSON value, a jsonpath:Error otherwise
public isolated function read(json 'json, JsonPathRawTemplate query) returns json|Error {
    return readJson('json, new JsonPathRawTemplateImpl(query));
}

public class JsonPathRawTemplateImpl {
    *object:RawTemplate;
    public string[] & readonly strings;
    public JsonPathValue[] insertions;

    public isolated function init(JsonPathRawTemplate jsonPathRawTemplate) {
        self.strings = jsonPathRawTemplate.strings;
        self.insertions = jsonPathRawTemplate.insertions;
    }
}

# Extract details from the given JSON value using the provided query expression
# + 'json - JSON value
# + query - JSON path expression
# + return - extracted details as JSON value, a jsonpath:Error otherwise
public isolated function readJson(json 'json, JsonPathRawTemplateImpl query) returns json|Error = @java:Method {
    'class: "io.ballerina.xlibb.jsonpath.BJsonPath"
} external;
