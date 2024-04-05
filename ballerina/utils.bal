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

isolated function prettifyJson(json value, string indentation, int level, boolean isMapField = false) returns string {
    if value == () {
        return " null";
    } else if value is map<json> {
        return prettifyJsonMap(value, indentation, level, isMapField);
    } else if value is json[] {
        return prettifyJsonArray(value, indentation, level, isMapField);
    } else {
        return prettifyJsonField(value, indentation, level, isMapField);
    }
}

isolated function prettifyJsonMap(map<json> value, string indentation, int level, boolean isMapField) returns string {
    string initialIndentation = getInitialIndentation(indentation, level, isMapField);
    string result = string `${initialIndentation}{`;
    boolean isEmptyMap = value.keys().length() == 0;
    if !isEmptyMap {
        result += "\n";
    }

    int fieldLevel = level + 1;
    string fieldIndentation = getIndentationForLevel(indentation, fieldLevel);
    int length = value.length();
    int i = 1;
    foreach string key in value.keys() {
        string fieldValue = prettifyJson(value.get(key), indentation, fieldLevel, true);
        string line = string `${fieldIndentation}"${key}":${fieldValue}`;
        result += line;
        if i != length {
            result += ",";
        }
        result += "\n";
        i += 1;
    }

    if !isEmptyMap {
        result += getIndentationForLevel(indentation, level);
    }
    result += "}";
    return result;
}

isolated function prettifyJsonArray(json[] array, string indentation, int level, boolean isMapField) returns string {
    string initialIndentation = getInitialIndentation(indentation, level, isMapField);
    string result = string `${initialIndentation}[`;

    boolean isEmptyArray = array.length() == 0;
    if !isEmptyArray {
        result += "\n";
    }

    int elementLevel = level + 1;
    string[] elements = [];
    foreach json value in array {
        elements.push(prettifyJson(value, indentation, elementLevel));
    }
    string separator = ",\n";
    result += 'string:'join(separator, ...elements);

    if !isEmptyArray {
        result += "\n" + getIndentationForLevel(indentation, level);
    }
    return string `${result}]`;
}

isolated function getIndentation(int indentation) returns string {
    string result = "";
    foreach int i in 0 ..< indentation {
        result += " ";
    }
    return result;
}

isolated function getIndentationForLevel(string indentation, int level) returns string {
    string result = "";
    foreach int i in 0 ..< level {
        result += indentation;
    }
    return result;
}

isolated function getInitialIndentation(string indentation, int level, boolean isMapField) returns string {
    return isMapField ? " " : getIndentationForLevel(indentation, level);
}

isolated function prettifyJsonField(json value, string indentation, int level, boolean isMapField) returns string {
    string initialIndentation = getInitialIndentation(indentation, level, isMapField);
    return string `${initialIndentation}${value.toJsonString()}`;
}
