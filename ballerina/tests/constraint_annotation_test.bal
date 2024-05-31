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
// under the License

import ballerina/constraint;
import ballerina/test;
import ballerina/time;

public type ValidationPerson record {|
    @constraint:String {
        maxLength: 5,
        minLength: 2
    }
    string name;
    @constraint:Int {
        minValueExclusive: 5
    }
    int age;
    @constraint:Float {
        minValue: 150,
        maxValue: 185.20,
        maxFractionDigits: 2
    }
    float height;
    @constraint:Date {
        option: {
            value: "PAST",
            message: "Date of birth should be past value"
        },
        message: "Invalid date found for date of birth"
    }
    time:Date dob;
|};

@test:Config {
    groups: ["constraint-validation"]
}
function testValidConstraintAnnotationForParseString() returns error? {
    string jsonStr = string `{
        "name": "John",
        "age": 6,
        "height": 180.20,
        "dob": {
            "year": 1990,
            "month": 12,
            "day": 31
        }
    }`;

    ValidationPerson person = check parseString(jsonStr);
    test:assertEquals(person.name, "John");
    test:assertEquals(person.age, 6);
    test:assertEquals(person.height, 180.20);
    test:assertEquals(person.dob.year, 1990);
    test:assertEquals(person.dob.month, 12);
    test:assertEquals(person.dob.day, 31);
}

@constraint:Array {
    length: 2
}
public type Weight decimal[];

public type ValidationItem record {|
    Weight weight;
|};

@test:Config {
    groups: ["constraint-validation"],
    dataProvider: invalidConstraintAnnotation
}
function testInvalidConstraintAnnotationForParseString(string sourceData, typedesc<record {}> expType, string expectedError) {
    anydata|Error err = parseString(sourceData, {}, expType);
    test:assertEquals(err is Error, true);
    test:assertEquals((<error>err).message(), expectedError);
}

function invalidConstraintAnnotation() returns [string, typedesc<record {}>, string][] {
    return [
        [
            string `
                {
                    "name": "John Doe",
                    "age": 6,
                    "height": 180.20,
                    "dob": {
                        "year": 1990,
                        "month": 12,
                        "day": 31
                    }
                }`,
            ValidationPerson,
            "Validation failed for '$.name:maxLength' constraint(s)."
        ],
        [
            string `
                {
                    "name": "John",
                    "age": 4,
                    "height": 180.20,
                    "dob": {
                        "year": 1990,
                        "month": 12,
                        "day": 31
                    }
                }`,
            ValidationPerson,
            "Validation failed for '$.age:minValueExclusive' constraint(s)."
        ],
        [
            string `
                {
                    "name": "John",
                    "age": 6,
                    "height": 185.21,
                    "dob": {
                        "year": 1990,
                        "month": 12,
                        "day": 31
                    }
                }`,
            ValidationPerson,
            "Validation failed for '$.height:maxValue' constraint(s)."
        ],
        [
            string `
                {
                    "name": "John",
                    "age": 6,
                    "height": 167.252,
                    "dob": {
                        "year": 1990,
                        "month": 12,
                        "day": 31
                    }
                }`,
            ValidationPerson,
            "Validation failed for '$.height:maxFractionDigits' constraint(s)."
        ],
        [
            string `
                {
                    "name": "John",
                    "age": 6,
                    "height": 180.20,
                    "dob": {
                        "year": 5000,
                        "month": 12,
                        "day": 31
                    }
                }`,
            ValidationPerson,
            "Date of birth should be past value."
        ],
        [
            string `
                {
                    "weight": [1.2, 2.3, 3.4]
                }
                `,
            ValidationItem,
            "Validation failed for '$.weight:length' constraint(s)."
        ]
    ];
}

@test:Config {
    groups: ["constraint-validation"]
}
function testValidConstraintAnnotationForParseAsType() returns error? {
    json jsonVal = {
        name: "John",
        age: 6,
        height: 180.20,
        dob: {
            year: 1990,
            month: 12,
            day: 31
        }
    };

    ValidationPerson person = check parseAsType(jsonVal);
    test:assertEquals(person.name, "John");
    test:assertEquals(person.age, 6);
    test:assertEquals(person.height, 180.20);
    test:assertEquals(person.dob.year, 1990);
    test:assertEquals(person.dob.month, 12);
    test:assertEquals(person.dob.day, 31);
}

@test:Config {
    groups: ["constraint-validation"],
    dataProvider: invalidConstraintAnnotationForParseAsType
}
function testInvalidConstraintAnnotationForParseAsType(json sourceData, typedesc<record {}> expType, string expectedError) {
    anydata|Error err = parseAsType(sourceData, {}, expType);
    test:assertEquals(err is Error, true);
    test:assertEquals((<error> err).message(), expectedError);
}

function invalidConstraintAnnotationForParseAsType() returns [json, typedesc<record {}>, string][] {
    return [
        [
            {
                name: "John Doe",
                age: 6,
                height: 180.20,
                dob: {
                    year: 1990,
                    month: 12,
                    day: 31
                }
            },
            ValidationPerson,
            "Validation failed for '$.name:maxLength' constraint(s)."
        ],
        [
            {
                name: "John",
                age: 4,
                height: 180.20,
                dob: {
                    year: 1990,
                    month: 12,
                    day: 31
                }                
            },
            ValidationPerson,
            "Validation failed for '$.age:minValueExclusive' constraint(s)."
        ],
        [
            {
                name: "John",
                age: 6,
                height: 185.21,
                dob: {
                    year: 1990,
                    month: 12,
                    day: 31
                }                
            },
            ValidationPerson,
            "Validation failed for '$.height:maxValue' constraint(s)."
        ],
        [
            {
                name: "John",
                age: 6,
                height: 167.252,
                dob: {
                    year: 1990,
                    month: 12,
                    day: 31
                }                
            },
            ValidationPerson,
            "Validation failed for '$.height:maxFractionDigits' constraint(s)."
        ],
        [
            {
                name: "John",
                age: 6,
                height: 180.20,
                dob: {
                    year: 5000,
                    month: 12,
                    day: 31
                }                
            },
            ValidationPerson,
            "Date of birth should be past value."
        ],
        [
            {
                "weight": [1.2, 2.3, 3.4]
            },
            ValidationItem,
            "Validation failed for '$.weight:length' constraint(s)."
        ]
    ];
}
