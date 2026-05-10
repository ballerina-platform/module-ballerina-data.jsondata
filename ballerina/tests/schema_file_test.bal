// Copyright (c) 2026, WSO2 LLC. (https://www.wso2.com).
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

import ballerina/test;

function dataProviderForSchemaFilePaths() returns [json, string, boolean][] {
    json validProduct = {
        "product_id": "1024",
        "product_name": "Devant",
        "tags": ["integration"]
    };

    json validSubscription = {
        "plan": "enterprise",
        "start_date": "2023-01-01",
        "end_date": "2024-01-01",
        "auto_renew": true,
        "features": ["api_access", "advanced_analytics"]
    };

    return [
        [validProduct, "tests/resources/schemas/path_handling/product.json", true],
        [validSubscription, "tests/resources/schemas/path_handling/common/subscription.json", true],
        [validProduct, "tests/resources/schemas/path_handling/nonexistent.json", false],
        [validProduct, "nonexistent/directory/product.json", false],
        [validProduct, "tests/resources/schemas/path_handling/schema.txt", false],
        [validProduct, "tests/resources/schemas/path_handling/schema.yaml", false],
        [validProduct, "tests/resources/schemas/path_handling/common", false]
    ];
}

@test:Config {
    dataProvider: dataProviderForSchemaFilePaths
}
isolated function testSchemaFilePathHandling(json inputData, string schemaPath, boolean shouldPass) {
    Error? result = validate(inputData, schemaPath);

    if shouldPass {
        test:assertTrue(result is (),  "Valid schema path should not throw error");
    } else {
        test:assertTrue(result is Error, "Invalid schema path should throw error");
    }
}

function dataProviderForSchemaFileValidation() returns [json, string, boolean][] {
    json validProduct1 = {
        "product_id": "1024",
        "product_name": "Devant",
        "tags": ["integration"]
    };

    json validProduct2 = {
        "product_id": "2048",
        "product_name": "Choreo",
        "tags": ["integration", "enterprise"]
    };

    json invalidProduct1 = {
        "product_id": 1024,
        "product_name": "Devant",
        "tags": "integration"
    };

    json invalidProduct2 = {
        "product_name": "Devant",
        "tags": ["integration"]
    };

    json validSubscription = {
        "plan": "enterprise",
        "start_date": "2023-01-01",
        "end_date": "2024-01-01",
        "auto_renew": true,
        "features": ["api_access", "advanced_analytics"]
    };

    json validSubscription2 = {
        "plan": "free",
        "start_date": "2023-01-01"
    };

    json invalidSubscription1 = {
        "plan": "enterprise"
    };

    json invalidSubscription2 = {
        "plan": "ultimate",
        "start_date": "2023-01-01"
    };

    json validUser1 = {
        "username": "john_doe",
        "email": "john@example.com",
        "role": "admin",
        "nickname": "Johnny",
        "subscription": {
            "plan": "enterprise",
            "start_date": "2023-01-01",
            "end_date": "2024-01-01",
            "auto_renew": true
        },
        "profile": {
            "avatar": "https://example.com/avatar.jpg",
            "bio": "Software developer",
            "location": "San Francisco"
        },
        "created_at": "2023-01-01T10:00:00Z",
        "is_active": true,
        "preferences": {
            "theme": "dark",
            "language": "en-US",
            "notifications": true
        }
    };

    json validUser2 = {
        "username": "user123",
        "email": "test@domain.com",
        "role": "user"
    };

    json invalidUser1 = {
        "username": "admin_user",
        "role": "admin"
    };

    json invalidUser2 = {
        "username": "test user",
        "email": "test@example.com",
        "role": "user"
    };

    return [
        [validProduct1, "tests/resources/schemas/path_handling/product.json", true],
        [validProduct2, "tests/resources/schemas/path_handling/product.json", true],
        [invalidProduct1, "tests/resources/schemas/path_handling/product.json", false],
        [invalidProduct2, "tests/resources/schemas/path_handling/product.json", false],
        [validSubscription, "tests/resources/schemas/path_handling/common/subscription.json", true],
        [validSubscription2, "tests/resources/schemas/path_handling/common/subscription.json", true],
        [invalidSubscription1, "tests/resources/schemas/path_handling/common/subscription.json", false],
        [invalidSubscription2, "tests/resources/schemas/path_handling/common/subscription.json", false],
        [validUser1, "tests/resources/schemas/path_handling/user.json", true],
        [validUser2, "tests/resources/schemas/path_handling/user.json", true],
        [invalidUser1, "tests/resources/schemas/path_handling/user.json", false],
        [invalidUser2, "tests/resources/schemas/path_handling/user.json", false]
    ];
}

@test:Config {
    dataProvider: dataProviderForSchemaFileValidation
}
isolated function testSchemaFileValidation(json inputData, string schemaPath, boolean shouldPass) {
    Error? result = validate(inputData, schemaPath);
    if shouldPass {
        test:assertTrue(result is (),  "Valid data should pass schema validation");
    } else {
        test:assertTrue(result is Error, "Invalid data should fail schema validation");
    }
}

function dataProviderForSchemaIdHandling() returns [json, string, boolean][] {
    json req = {
        "catagory_id" : "123",
        "page_size" : 2,
        "page_number" : 1
    };

    json res = {
        "products": ["prod1", "prod2"]
    };

    return [
        [req, "tests/resources/schemas/no_id/product_list_request.json", false],
        [res, "tests/resources/schemas/relative_id/product_list_response.json", true]
    ];
}

@test:Config {
    dataProvider: dataProviderForSchemaIdHandling
}
isolated function testSchemaFileIdHandling(json inputData, string schemaPath, boolean shouldPass) {
    Error? result = validate(inputData, schemaPath);
    if shouldPass {
        test:assertTrue(result is (),  "Valid data should pass schema validation");
    } else {
        test:assertTrue(result is Error, "Invalid data should fail schema validation");
    }
}