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

const productSchema = {
   "$schema" : "https://json-schema.org/draft/2020-12/schema",
   "$id" : "http://wso2.com/schemas/product.json",
   "type": "object",
   "properties": {
     "product_id" : {
       "type" : "string",
       "maxLength": 15,
       "pattern": "^\\d{4}$"
     },
     "product_name" : {
       "type" : "string",
       "maxLength": 50
     },
     "tags" : {
       "type" : "array",
       "items" : {
         "type" : "string",
         "enum": ["apim", "iam", "integration", "enterprise"]
       }
     }
   },
   "required": [ "product_id", "product_name", "tags" ]
};

const subscriptionSchema = {
   "$schema": "https://json-schema.org/draft/2020-12/schema",
   "$id": "http://wso2.com/schemas/common/subscription.json",
   "type": "object",
   "properties": {
     "plan": {
       "type": "string",
       "enum": ["free", "basic", "premium", "enterprise"]
     },
     "start_date": {
       "type": "string",
       "format": "date"
     },
     "end_date": {
       "type": "string",
       "format": "date"
     },
     "auto_renew": {
       "type": "boolean"
     },
     "features": {
       "type": "array",
       "items": {
         "type": "string",
         "enum": ["api_access", "advanced_analytics", "priority_support", "custom_integrations"]
       }
     }
   },
   "required": ["plan", "start_date"]
};

const userSchema = {
   "$schema": "https://json-schema.org/draft/2020-12/schema",
   "$id": "http://wso2.com/schemas/user.json",
   "type": "object",
   "properties": {
     "username": {
       "type": "string",
       "minLength": 3,
       "maxLength": 30,
       "pattern": "^[a-zA-Z0-9_]+$"
     },
     "nickname": {
       "type": "string",
       "maxLength": 50
     },
     "email": {
       "type": "string",
       "format": "email"
     },
     "role": {
       "type": "string",
       "enum": ["admin", "moderator", "user", "guest"]
     },
     "created_at": {
       "type": "string",
       "format": "date-time"
     },
     "is_active": {
       "type": "boolean"
     },
     "preferences": {
       "type": "object",
       "properties": {
         "theme": {
           "type": "string",
           "enum": ["light", "dark", "system"]
         },
         "language": {
           "type": "string",
           "pattern": "^[a-z]{2}(-[A-Z]{2})?$"
         },
         "notifications": {
           "type": "boolean"
         }
       }
     }
   },
    "required": ["username", "email", "role"]
};

const personSchemaFull = {
  "$id": "https://example.com/person.schema.json",
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "Person",
  "type": "object",
  "properties": {
    "firstName": {
      "type": "string",
      "description": "The person's first name."
    },
    "lastName": {
      "type": "string",
      "description": "The person's last name."
    },
    "age": {
      "description": "Age in years which must be equal to or greater than zero.",
      "type": "integer",
      "minimum": 0
    }
  },
  "required" : ["firstName", "lastName", "age"]
};

const addressSchema = {
  "$id": "https://example.com/address.schema.json",
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "object",
  "properties": {
    "street": {
      "type": "string"
    },
    "city": {
      "type": "string"
    },
    "zipCode": {
      "type": "string",
      "pattern": "^\\d{5}$"
    }
  }
};

const personSchemaRef = {
  "$id": "https://example.com/person-ref.schema.json",
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "object",
  "properties": {
    "firstName": {
      "type": "string"
    },
    "lastName": {
      "type": "string"
    },
    "age": {
      "type": "integer",
      "minimum": 0
    },
    "address": {
      "$ref": "https://example.com/address.schema.json"
    }
  }
};

const schemaWithoutIdForMulti = {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "type": "object"
};

const schemaWithRelativeIdForMulti = {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "./schemas/relative.json",
    "type": "object"
};

const schemaANoRefs = {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://example.com/schema-a.json",
    "type": "object",
    "properties": {
        "name": {"type": "string"}
    }
};

const schemaBNoRefs = {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://example.com/schema-b.json",
    "type": "object",
    "properties": {
        "value": {"type": "number"}
    }
};

const schemaUrnA = {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "urn:example:schema-a",
    "type": "object"
};

const schemaUrnB = {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "urn:example:schema-b",
    "type": "object"
};

function dataProviderForSchemaJsonValidation() returns [json, map<json>, boolean][] {
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

    json validSubscription1 = {
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
        [validProduct1, productSchema, true],
        [validProduct2, productSchema, true],
        [invalidProduct1, productSchema, false],
        [invalidProduct2, productSchema, false],
        [validSubscription1, subscriptionSchema, true],
        [validSubscription2, subscriptionSchema, true],
        [invalidSubscription1, subscriptionSchema, false],
        [invalidSubscription2, subscriptionSchema, false],
        [validUser1, userSchema, true],
        [validUser2, userSchema, true],
        [invalidUser1, userSchema, false],
        [invalidUser2, userSchema, false]
    ];
}

@test:Config {
    dataProvider: dataProviderForSchemaJsonValidation
}
isolated function testSchemaJsonValidation(json inputData, map<json> schema, boolean shouldPass) {
    Error? result = validate(inputData, schema);
    if shouldPass {
        test:assertTrue(result is (),  "Valid data should pass schema validation");
    } else {
        test:assertTrue(result is Error, "Invalid data should fail schema validation");
    }
}

function dataProviderForSchemaJsonIdHandling() returns [json, map<json>, boolean][] {
    json testData = {
        "key": "value"
    };

    map<json> schemaWithoutId = {
        "$schema": "https://json-schema.org/draft/2020-12/schema",
        "type": "object"
    };

    map<json> schemaWithRelativeId = {
        "$schema": "https://json-schema.org/draft/2020-12/schema",
        "$id": "/schemas/test.json",
        "type": "object"
    };

    map<json> schemaWithValidId = {
        "$schema": "https://json-schema.org/draft/2020-12/schema",
        "$id": "http://test.com/schema.json",
        "type": "object"
    };

    map<json> schemaWithValidId2 = {
        "$schema": "https://json-schema.org/draft/2020-12/schema",
        "$id": "urn://schema.json",
        "type": "object"
    };

    return [
        [testData, schemaWithoutId, true],
        [testData, schemaWithRelativeId, true],
        [testData, schemaWithValidId, true],
        [testData, schemaWithValidId2, true]
    ];
}

@test:Config {
    dataProvider: dataProviderForSchemaJsonIdHandling
}
isolated function testSchemaJsonIdHandling(json inputData, map<json> schema, boolean shouldPass) {
    Error? result = validate(inputData, schema);
    if shouldPass {
        test:assertTrue(result is (),  "Valid schema array should pass");
    } else {
        test:assertTrue(result is Error, "Invalid schema array should fail");
    }
}

function dataProviderForSchemaArrayValidation() returns [json, (map<json>[]), boolean][] {
    json validPerson1 = {
        "firstName": "John",
        "lastName": "Doe",
        "age": 30
    };

    json invalidPerson1 = {
        "firstName": "John",
        "lastName": "Doe",
        "age": -5
    };

    json invalidPerson2 = {
        "firstName": "John",
        "age": 30
    };

    return [
        [validPerson1, [personSchemaFull], true],
        [invalidPerson1, [personSchemaFull], false],
        [invalidPerson2, [personSchemaFull], false]
    ];
}

@test:Config {
    dataProvider: dataProviderForSchemaArrayValidation
}
isolated function testSchemaArrayValidation(json inputData, map<json>[] schemas, boolean shouldPass) {
    Error? result = validate(inputData, schemas);
    if shouldPass {
        test:assertTrue(result is (),  "Valid data should pass schema array validation");
    } else {
        test:assertTrue(result is Error, "Invalid data should fail schema array validation");
    }
}

function dataProviderForSchemaArrayWithReferences() returns [json, (map<json>[]), boolean][] {
    json validPersonWithAddress = {
        "firstName": "John",
        "lastName": "Doe",
        "age": 30,
        "address": {
            "street": "123 Main St",
            "city": "San Francisco",
            "zipCode": "94102"
        }
    };

    json validPersonWithoutAddress = {
        "firstName": "Jane",
        "lastName": "Smith",
        "age": 25
    };

    json invalidPersonWithBadZip = {
        "firstName": "Bob",
        "lastName": "Johnson",
        "age": 40,
        "address": {
            "street": "456 Oak Ave",
            "city": "Los Angeles",
            "zipCode": "9"
        }
    };

    return [
        [validPersonWithoutAddress, [addressSchema, personSchemaRef], true],
        [validPersonWithoutAddress, [personSchemaRef, addressSchema], true],
        [validPersonWithAddress, [addressSchema, personSchemaRef], true],
        [invalidPersonWithBadZip, [addressSchema, personSchemaRef], false]
    ];
}

@test:Config {
    dataProvider: dataProviderForSchemaArrayWithReferences
}
isolated function testSchemaArrayWithReferences(json inputData, map<json>[] schemas, boolean shouldPass) {
    Error? result = validate(inputData, schemas);
    if shouldPass {
        test:assertTrue(result is (),  "Valid data with schema references should pass");
    } else {
        test:assertTrue(result is Error, "Invalid data with schema references should fail");
    }
}

function dataProviderForSchemaArrayMultipleIdHandling() returns [json, (map<json>[]), boolean][] {
    json testData = {"key": "value"};

    return [
        [testData, [], false],
        [testData, [schemaWithoutIdForMulti, schemaBNoRefs], false],
        [testData, [schemaANoRefs, schemaWithoutIdForMulti], false],
        [testData, [schemaWithRelativeIdForMulti, schemaBNoRefs], false],
        [testData, [schemaANoRefs, schemaWithRelativeIdForMulti], false],
        [testData, [schemaANoRefs, schemaBNoRefs], false],
        [testData, [addressSchema, personSchemaRef], true],
        [testData, [personSchemaRef, addressSchema], true],
        [testData, [schemaUrnA, schemaUrnB], false]
    ];
}

@test:Config {
    dataProvider: dataProviderForSchemaArrayMultipleIdHandling
}
isolated function testSchemaArrayMultipleIdHandling(json inputData, map<json>[] schemas, boolean shouldPass) {
    Error? result = validate(inputData, schemas);
    if shouldPass {
        test:assertTrue(result is (), "Valid multiple schema array should pass");
    } else {
        test:assertTrue(result is Error, "Invalid multiple schema array should fail with ID error");
    }
}