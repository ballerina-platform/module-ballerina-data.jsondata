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

# Defines JSON schema string type constraints.
#
# + maxLength - The maximum length of the string.
# + minLength - The minimum length of the string.
# + pattern - The regular expression pattern to a string pattern.
# + format - Format of the string.
public type StringValidationRec record {
    int:Unsigned32 maxLength?;
    int:Unsigned32 minLength?;
    string:RegExp pattern?;
    string format?;
};

# The annotation is used to overwrite the existing type name.
public annotation StringValidationRec StringValidation on type;
