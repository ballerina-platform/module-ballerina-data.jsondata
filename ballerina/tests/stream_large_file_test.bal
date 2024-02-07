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

import ballerina/io;
import ballerina/test;

const LARGE_JSON_FILE = "build//resources//large_data.json";
const POSTIONS = {
    "Associate Tech Lead": 2000,
    "Software Engineer": 1500,
    "Intern": 200,
    "Senior Software Engineer": 1800,
    "Tech Lead": 3000,
    "Architect": 5000
};
const PRODUCTS = ["IAM", "Ballerina", "MI", "APIM", "CHOREO", "ASGADIO"];

type CompanyR1 record {|
    EmployeeR1[] employees;
    CustomerR1[] customers;
|};

type EmployeeR1 record {|
    int id;
    string product;
    string position;
    int salary;
|};

type CustomerR1 record {|
    int id;
    string name;
    string product;
|};

@test:Config
function testLargeFileStream() returns error? {
    stream<byte[], error?> dataStream = check io:fileReadBlocksAsStream(LARGE_JSON_FILE);
    CompanyR1 company = check fromJsonStringWithType(dataStream);
    test:assertEquals(company.employees.length(), 1001);
    test:assertEquals(company.customers.length(), 1001);

    test:assertEquals(company.employees[0].id, 0);
    test:assertEquals(company.employees[0].product, "IAM");
    test:assertEquals(company.employees[0].position, "Associate Tech Lead");
    test:assertEquals(company.employees[0].salary, 2000);
    test:assertEquals(company.customers[0].id, 0);
    test:assertEquals(company.customers[0].name, "Customer0");
    test:assertEquals(company.customers[0].product, "IAM");

    test:assertEquals(company.employees[1000].id, 1000);
    test:assertEquals(company.employees[1000].product, "CHOREO");
    test:assertEquals(company.employees[1000].position, "Tech Lead");
    test:assertEquals(company.employees[1000].salary, 3000);
    test:assertEquals(company.customers[1000].id, 1000);
    test:assertEquals(company.customers[1000].name, "Customer1000");
    test:assertEquals(company.customers[1000].product, "CHOREO");
}

type EmployeeR2 record {|
    int id;
    string position;
|};

type CustomerR2 record {|
    int id;
    string product;
|};

@test:Config
function testLargeFileStreamWithProjection() returns error? {
    stream<byte[], error?> dataStream = check io:fileReadBlocksAsStream(LARGE_JSON_FILE);
    record {|
        EmployeeR2[5] employees;
        CustomerR2[9] customers;
    |} company = check fromJsonStringWithType(dataStream);
    test:assertEquals(company.employees.length(), 5);
    test:assertEquals(company.customers.length(), 9);

    test:assertEquals(company.employees[0].length(), 2);
    test:assertEquals(company.employees[0].id, 0);
    test:assertEquals(company.employees[0].position, "Associate Tech Lead");
    test:assertEquals(company.customers[0].length(), 2);
    test:assertEquals(company.customers[0].id, 0);
    test:assertEquals(company.customers[0].product, "IAM");

    test:assertEquals(company.employees[4].length(), 2);
    test:assertEquals(company.employees[4].id, 4);
    test:assertEquals(company.employees[4].position, "Tech Lead");
    test:assertEquals(company.customers[4].length(), 2);
    test:assertEquals(company.customers[4].id, 4);
    test:assertEquals(company.customers[4].product, "CHOREO");
}

@test:BeforeSuite
function createLargeFile() returns error? {
    io:WritableByteChannel wbc = check io:openWritableFile(LARGE_JSON_FILE);
    string begin = string `{`;
    string end = "}\n";
    _ = check wbc.write(begin.toBytes(), 0);

    _ = check wbc.write(string `"employees": 
    [
        `.toBytes(), 0);
    _ = check wbc.write(createEmployee(0).toString().toBytes(), 0);
    foreach int i in 1 ... 1000 {
        _ = check wbc.write(",\n        ".toBytes(), 0);
        _ = check wbc.write(createEmployee(i).toString().toBytes(), 0);
    }
    _ = check wbc.write("\n    ],\n".toBytes(), 0);

    _ = check wbc.write(string `"customers": 
    [
        `.toBytes(), 0);
    _ = check wbc.write(createCustomer(0).toString().toBytes(), 0);
    foreach int i in 1...1000 {
        _ = check wbc.write(",\n        ".toBytes(), 0);
        _ = check wbc.write(createCustomer(i).toString().toBytes(), 0);
    }
    _ = check wbc.write("\n    ]\n".toBytes(), 0);


    _ = check wbc.write(end.toBytes(), 0);
    _ = check wbc.close();
}

function createEmployee(int id) returns EmployeeR1 {
    string position = POSTIONS.keys()[id % POSTIONS.keys().length()];
    return {
        "id": id,
        "product": PRODUCTS[id % PRODUCTS.length()],
        "position": position,
        "salary": POSTIONS[position] ?: 0
    };
}

function createCustomer(int id) returns CustomerR1 {
    return {
        "id": id,
        "name": "Customer" + id.toString(),
        "product": PRODUCTS[id % PRODUCTS.length()]
    };
}
