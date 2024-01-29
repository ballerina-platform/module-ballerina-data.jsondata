// Copyright (c) 2024 WSO2 LLC (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
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

import ballerina/test;

@test:Config {}
function errorTest() {
    json|Error result = read(j4, `$.a1[:]`);
    test:assertTrue(result is Error);
    test:assertEquals((<Error> result).message(), "Failed to parse SliceOperation: :");

    result = read(j4, `#`);
    test:assertTrue(result is Error);
    test:assertEquals((<Error> result).message(), "Unable to execute query '#' on the provided JSON value");

    result = read({name: ""}, `$.id`);
    test:assertTrue(result is Error);
    test:assertEquals((<Error> result).message(), "Unable to execute query '$.id' on the provided JSON value");

    result = read("test", `$.id`);
    test:assertTrue(result is Error);
    test:assertEquals((<Error> result).message(), "Unable to execute query '$.id' on the provided JSON value");

    result = read(1, `$.a1[:]`);
    test:assertTrue(result is Error);
    test:assertEquals((<Error> result).message(), "Failed to parse SliceOperation: :");

    result = read([j4], `$.a3[-1]`);
    test:assertTrue(result is Error);
    test:assertEquals((<Error> result).message(), "Unable to execute query '$.a3[-1]' on the provided JSON value");

    result = read(j4, `$.a1[-1].a12`);
    test:assertTrue(result is Error);
    test:assertEquals((<Error> result).message(), "Unable to execute query '$.a1[-1].a12' on the provided JSON value");

    result = read(j4, `$.a40.sum()`);
    test:assertTrue(result is Error);
    test:assertEquals((<Error> result).message(), "Unable to execute query '$.a40.sum()' on the provided JSON value");

    result = read(j1, `$.a1[1]`);
    test:assertTrue(result is Error);
    test:assertEquals((<Error> result).message(), "Unable to execute query '$.a1[1]' on the provided JSON value");
}
