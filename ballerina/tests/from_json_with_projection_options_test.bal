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
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/io;
import ballerina/test;
import ballerina/lang.value;

const PATH = "tests/resources/";

const options1 = {nilAsOptionalField: true, absentAsNilableType: false};
const options2 = {nilAsOptionalField: false, absentAsNilableType: true};
const options3 = {nilAsOptionalField: true, absentAsNilableType: true};
const options4 = {nilAsOptionalField: false, absentAsNilableType: false};

type Sales record {|
    @Name {
        value: "sales_data"
    }
    SalesData[] salesData;
    @Name {
        value: "total_sales"
    }
    record {|
        @Name {
            value: "date_range"
        }
        string dataRange?;
        @Name {
            value: "total_revenue"
        }
        string totalRevenue;
    |} totalSales;
|};

type SalesData record {|
    @Name {
        value: "transaction_id"
    }
    string transactionId;
    string date;
    @Name {
        value: "customer_name"
    }
    string customerName;
    string product;
    @Name {
        value: "unit_price"
    }
    string unitPrice;
    @Name {
        value: "total_price"
    }
    string totalPrice?;
|};

@test:Config {
    groups: ["options"]
}
isolated function testNilAsOptionalFieldForParseString() returns error? {
    string jsonData = check io:fileReadString(PATH + "sales.json");
    Sales sales = check parseString(jsonData, options1);
    test:assertEquals(sales.salesData[0].length(), 5);
    test:assertEquals(sales.salesData[0].transactionId, "TXN001");
    test:assertEquals(sales.salesData[0].date, "2024-03-25");
    test:assertEquals(sales.salesData[0].customerName, "ABC Corporation");
    test:assertEquals(sales.salesData[0].product, "InnovateX");
    test:assertEquals(sales.salesData[0].unitPrice, "$499");

    test:assertEquals(sales.salesData[1].length(), 6);
    test:assertEquals(sales.salesData[1].transactionId, "TXN002");
    test:assertEquals(sales.salesData[1].date, "2024-03-25");
    test:assertEquals(sales.salesData[1].customerName, "XYZ Enterprises");
    test:assertEquals(sales.salesData[1].product, "SecureTech");
    test:assertEquals(sales.salesData[1].unitPrice, "$999");
    test:assertEquals(sales.salesData[1].totalPrice, "$4995");

    test:assertEquals(sales.salesData[2].length(), 5);
    test:assertEquals(sales.salesData[2].transactionId, "TXN003");
    test:assertEquals(sales.salesData[2].date, "2024-03-26");
    test:assertEquals(sales.salesData[2].customerName, "123 Inc.");
    test:assertEquals(sales.salesData[2].product, "InnovateX");
    test:assertEquals(sales.salesData[2].unitPrice, "$499");

    test:assertEquals(sales.totalSales.length(), 1);
    test:assertEquals(sales.totalSales.totalRevenue, "$21462");
}

@test:Config {
    groups: ["options"]
}
isolated function testNilAsOptionalFieldForParseStringNegative() returns error? {
    string jsonData = check io:fileReadString(PATH + "sales.json");
    Sales|Error err = parseString(jsonData, options4);
    test:assertTrue(err is Error);
    test:assertEquals((<Error>err).message(), "incompatible value 'null' for type 'string' in field 'salesData.totalPrice'");
}

@test:Config {
    groups: ["options"]
}
isolated function testNilAsOptionalFieldForParseAsType() returns error? {
    string jsonData = check io:fileReadString(PATH + "sales.json");
    json salesJson = check value:fromJsonString(jsonData);
    Sales sales = check parseAsType(salesJson, options1);

    test:assertEquals(sales.salesData[0].length(), 5);
    test:assertEquals(sales.salesData[0].transactionId, "TXN001");
    test:assertEquals(sales.salesData[0].date, "2024-03-25");
    test:assertEquals(sales.salesData[0].customerName, "ABC Corporation");
    test:assertEquals(sales.salesData[0].product, "InnovateX");
    test:assertEquals(sales.salesData[0].unitPrice, "$499");

    test:assertEquals(sales.salesData[1].length(), 6);
    test:assertEquals(sales.salesData[1].transactionId, "TXN002");
    test:assertEquals(sales.salesData[1].date, "2024-03-25");
    test:assertEquals(sales.salesData[1].customerName, "XYZ Enterprises");
    test:assertEquals(sales.salesData[1].product, "SecureTech");
    test:assertEquals(sales.salesData[1].unitPrice, "$999");
    test:assertEquals(sales.salesData[1].totalPrice, "$4995");

    test:assertEquals(sales.salesData[2].length(), 5);
    test:assertEquals(sales.salesData[2].transactionId, "TXN003");
    test:assertEquals(sales.salesData[2].date, "2024-03-26");
    test:assertEquals(sales.salesData[2].customerName, "123 Inc.");
    test:assertEquals(sales.salesData[2].product, "InnovateX");
    test:assertEquals(sales.salesData[2].unitPrice, "$499");

    test:assertEquals(sales.totalSales.length(), 1);
    test:assertEquals(sales.totalSales.totalRevenue, "$21462");
}

type Response record {|
    string status;
    record {|
        User user;
        Post[] posts;
    |} data;
|};

type User record {|
    int id;
    string username;
    string? email;
|};

type Post record {|
    int id;
    string title;
    string? content;
|};

@test:Config {
    groups: ["options"]
}
isolated function testAbsentAsNilableTypeForParseString() returns error? {
    string jsonData = check io:fileReadString(PATH + "response.json");
    Response response = check parseString(jsonData, options2);
    test:assertEquals(response.status, "success");

    test:assertEquals(response.data.user.length(), 3);
    test:assertEquals(response.data.user.id, 123);
    test:assertEquals(response.data.user.username, "example_user");
    test:assertEquals(response.data.user.email, null);

    test:assertEquals(response.data.user.length(), 3);
    test:assertEquals(response.data.posts[0].id, 1);
    test:assertEquals(response.data.posts[0].title, "First Post");
    test:assertEquals(response.data.posts[0].content, "This is the content of the first post.");

    test:assertEquals(response.data.user.length(), 3);
    test:assertEquals(response.data.posts[1].id, 2);
    test:assertEquals(response.data.posts[1].title, "Second Post");
    test:assertEquals(response.data.posts[1].content, null);
}

@test:Config {
    groups: ["options"]
}
isolated function testAbsentAsNilableTypeForParseAsType() returns error? {
    string jsonData = check io:fileReadString(PATH + "response.json");
    json salesJson = check value:fromJsonString(jsonData);
    Response response = check parseAsType(salesJson, options2);
    test:assertEquals(response.status, "success");

    test:assertEquals(response.data.user.length(), 3);
    test:assertEquals(response.data.user.id, 123);
    test:assertEquals(response.data.user.username, "example_user");
    test:assertEquals(response.data.user.email, null);

    test:assertEquals(response.data.user.length(), 3);
    test:assertEquals(response.data.posts[0].id, 1);
    test:assertEquals(response.data.posts[0].title, "First Post");
    test:assertEquals(response.data.posts[0].content, "This is the content of the first post.");

    test:assertEquals(response.data.user.length(), 3);
    test:assertEquals(response.data.posts[1].id, 2);
    test:assertEquals(response.data.posts[1].title, "Second Post");
    test:assertEquals(response.data.posts[1].content, null);
}

type Specifications record {
    string storage?;
    string display?;
    string? processor;
    string? ram;
    string? graphics;
    string? camera;
    string? battery;
    string os?;
    string 'type?;
    boolean wireless?;
    string battery_life?;
    boolean noise_cancellation?;
    string? color;
};

type ProductsItem record {
    int id;
    string name;
    string brand?;
    decimal price;
    string? description;
    Specifications specifications?;
};

type Data record {
    ProductsItem[] products;
};

type ResponseEcom record {
    string status;
    Data data;
};

@test:Config {
    groups: ["options"]
}
isolated function testAbsentAsNilableTypeAndAbsentAsNilableTypeForParseString() returns error? {
    string jsonData = check io:fileReadString(PATH + "product_list_response.json");
    ResponseEcom response = check parseString(jsonData, options3);
    
    test:assertEquals(response.status, "success");
    test:assertEquals(response.data.products[0].length(), 6);
    test:assertEquals(response.data.products[0].id, 1);
    test:assertEquals(response.data.products[0].name, "Laptop");
    test:assertEquals(response.data.products[0].brand, "ExampleBrand");
    test:assertEquals(response.data.products[0].price, 999.99d);
    test:assertEquals(response.data.products[0].description, "A powerful laptop for all your computing needs.");
    test:assertEquals(response.data.products[0].specifications?.storage, "512GB SSD");
    test:assertEquals(response.data.products[0].specifications?.display, "15.6-inch FHD");
    test:assertEquals(response.data.products[0].specifications?.processor, "Intel Core i7");
    test:assertEquals(response.data.products[0].specifications?.ram, "16GB DDR4");
    test:assertEquals(response.data.products[0].specifications?.graphics, "NVIDIA GeForce GTX 1650");
    test:assertEquals(response.data.products[0].specifications?.camera, null);
    test:assertEquals(response.data.products[0].specifications?.battery, null);
    test:assertEquals(response.data.products[0].specifications?.color, null);

    test:assertEquals(response.data.products[1].length(), 5);
    test:assertEquals(response.data.products[1].id, 2);
    test:assertEquals(response.data.products[1].name, "Smartphone");
    test:assertEquals(response.data.products[1].price, 699.99d);
    test:assertEquals(response.data.products[1].description, null);
    test:assertEquals(response.data.products[1].specifications?.storage, "256GB");
    test:assertEquals(response.data.products[1].specifications?.display, "6.5-inch AMOLED");
    test:assertEquals(response.data.products[1].specifications?.processor, null);
    test:assertEquals(response.data.products[1].specifications?.ram, null);
    test:assertEquals(response.data.products[1].specifications?.graphics, null);
    test:assertEquals(response.data.products[1].specifications?.camera, "Quad-camera setup");
    test:assertEquals(response.data.products[1].specifications?.battery, "4000mAh");
    test:assertEquals(response.data.products[1].specifications?.color, null);

    test:assertEquals(response.data.products[2].length(), 6);
    test:assertEquals(response.data.products[2].id, 3);
    test:assertEquals(response.data.products[2].name, "Headphones");
    test:assertEquals(response.data.products[2].brand, "AudioTech");
    test:assertEquals(response.data.products[2].price, 149.99d);
    test:assertEquals(response.data.products[2].description, "Immerse yourself in high-quality sound with these headphones.");
    test:assertEquals(response.data.products[2].specifications?.processor, null);
    test:assertEquals(response.data.products[2].specifications?.ram, null);
    test:assertEquals(response.data.products[2].specifications?.graphics, null);
    test:assertEquals(response.data.products[2].specifications?.camera, null);
    test:assertEquals(response.data.products[2].specifications?.battery, null);
    test:assertEquals(response.data.products[2].specifications?.'type, "Over-ear");
    test:assertEquals(response.data.products[2].specifications?.wireless, true);
    test:assertEquals(response.data.products[2].specifications?.noise_cancellation, true);
    test:assertEquals(response.data.products[2].specifications?.color, "Black");

    test:assertEquals(response.data.products[3].length(), 5);
    test:assertEquals(response.data.products[3].id, 4);
    test:assertEquals(response.data.products[3].name, "Wireless Earbuds");
    test:assertEquals(response.data.products[3].brand, "SoundMaster");
    test:assertEquals(response.data.products[3].price, 99.99d);
    test:assertEquals(response.data.products[3].description, "Enjoy freedom of movement with these wireless earbuds.");
}

@test:Config {
    groups: ["options"]
}
isolated function testAbsentAsNilableTypeAndAbsentAsNilableTypeForParseAsString() returns error? {
    string jsonData = check io:fileReadString(PATH + "product_list_response.json");
    json productJson = check value:fromJsonString(jsonData);
    ResponseEcom response = check parseAsType(productJson, options3);
    
    test:assertEquals(response.status, "success");
    test:assertEquals(response.data.products[0].length(), 6);
    test:assertEquals(response.data.products[0].id, 1);
    test:assertEquals(response.data.products[0].name, "Laptop");
    test:assertEquals(response.data.products[0].brand, "ExampleBrand");
    test:assertEquals(response.data.products[0].price, 999.99d);
    test:assertEquals(response.data.products[0].description, "A powerful laptop for all your computing needs.");
    test:assertEquals(response.data.products[0].specifications?.storage, "512GB SSD");
    test:assertEquals(response.data.products[0].specifications?.display, "15.6-inch FHD");
    test:assertEquals(response.data.products[0].specifications?.processor, "Intel Core i7");
    test:assertEquals(response.data.products[0].specifications?.ram, "16GB DDR4");
    test:assertEquals(response.data.products[0].specifications?.graphics, "NVIDIA GeForce GTX 1650");
    test:assertEquals(response.data.products[0].specifications?.camera, null);
    test:assertEquals(response.data.products[0].specifications?.battery, null);
    test:assertEquals(response.data.products[0].specifications?.color, null);

    test:assertEquals(response.data.products[1].length(), 5);
    test:assertEquals(response.data.products[1].id, 2);
    test:assertEquals(response.data.products[1].name, "Smartphone");
    test:assertEquals(response.data.products[1].price, 699.99d);
    test:assertEquals(response.data.products[1].description, null);
    test:assertEquals(response.data.products[1].specifications?.storage, "256GB");
    test:assertEquals(response.data.products[1].specifications?.display, "6.5-inch AMOLED");
    test:assertEquals(response.data.products[1].specifications?.processor, null);
    test:assertEquals(response.data.products[1].specifications?.ram, null);
    test:assertEquals(response.data.products[1].specifications?.graphics, null);
    test:assertEquals(response.data.products[1].specifications?.camera, "Quad-camera setup");
    test:assertEquals(response.data.products[1].specifications?.battery, "4000mAh");
    test:assertEquals(response.data.products[1].specifications?.color, null);

    test:assertEquals(response.data.products[2].length(), 6);
    test:assertEquals(response.data.products[2].id, 3);
    test:assertEquals(response.data.products[2].name, "Headphones");
    test:assertEquals(response.data.products[2].brand, "AudioTech");
    test:assertEquals(response.data.products[2].price, 149.99d);
    test:assertEquals(response.data.products[2].description, "Immerse yourself in high-quality sound with these headphones.");
    test:assertEquals(response.data.products[2].specifications?.processor, null);
    test:assertEquals(response.data.products[2].specifications?.ram, null);
    test:assertEquals(response.data.products[2].specifications?.graphics, null);
    test:assertEquals(response.data.products[2].specifications?.camera, null);
    test:assertEquals(response.data.products[2].specifications?.battery, null);
    test:assertEquals(response.data.products[2].specifications?.'type, "Over-ear");
    test:assertEquals(response.data.products[2].specifications?.wireless, true);
    test:assertEquals(response.data.products[2].specifications?.noise_cancellation, true);
    test:assertEquals(response.data.products[2].specifications?.color, "Black");

    test:assertEquals(response.data.products[3].length(), 5);
    test:assertEquals(response.data.products[3].id, 4);
    test:assertEquals(response.data.products[3].name, "Wireless Earbuds");
    test:assertEquals(response.data.products[3].brand, "SoundMaster");
    test:assertEquals(response.data.products[3].price, 99.99d);
    test:assertEquals(response.data.products[3].description, "Enjoy freedom of movement with these wireless earbuds.");
}

@test:Config {
    groups: ["options"]
}
isolated function testDisableOptionsOfProjectionTypeForParseString1() returns error? {
    string jsonData = check io:fileReadString(PATH + "sales.json");
    Sales|Error err = parseString(jsonData, options4);
    test:assertTrue(err is Error);
    test:assertEquals((<Error>err).message(), "incompatible value 'null' for type 'string' in field 'salesData.totalPrice'");
}

@test:Config {
    groups: ["options"]
}
isolated function testDisableOptionsOfProjectionTypeForParseAsType1() returns error? {
    string jsonData = check io:fileReadString(PATH + "sales.json");
    json salesJson = check value:fromJsonString(jsonData);
    Sales|Error err = parseAsType(salesJson, options4);
    test:assertTrue(err is Error);
    test:assertEquals((<Error>err).message(), "incompatible value 'null' for type 'string' in field 'salesData.totalPrice'");
}

@test:Config {
    groups: ["options"]
}
isolated function testDisableOptionsOfProjectionTypeForParseString2() returns error? {
    string jsonData = check io:fileReadString(PATH + "response.json");

    Response|Error err = parseString(jsonData, options4);
    test:assertTrue(err is Error);
    test:assertEquals((<Error>err).message(), "required field 'email' not present in JSON");
}

@test:Config {
    groups: ["options"]
}
isolated function testDisableOptionsOfProjectionTypeForParseAsType2() returns error? {
    string jsonData = check io:fileReadString(PATH + "response.json");
    json salesJson = check value:fromJsonString(jsonData);
    Response|Error err = parseAsType(salesJson, options4);
    test:assertTrue(err is Error);
    test:assertEquals((<Error>err).message(), "required field 'email' not present in JSON");
}
