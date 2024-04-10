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

const FILE_PATH = "tests/resources/";

type LibraryS1 record {
    BookS1[] book;
};

type BookS1 record {|
    string title;
    string author;
    string genre;
    int publication_year;
|};

type MoviesS2 record {|
    MovieS2[] movie;
|};

type MovieS2 record {|
    string id;
    string title;
    string genre;
    @Name {
        value: "release_year"
    }
    int year;
|};

type OrdersS4 record {|
    OrderS4[] 'order;
|};

type OrderS4 record {|
    @Name {
        value: "order_id"
    }
    int id;
    record {|
        ProductS4[1] product;
    |} products;
|};

type ProductS4 record {|
    @Name {
        value: "product_id"
    }
    int id;
    string name;
|};

@test:Config {
    dataProvider: dataProviderForFileReadTest
}
function testParseString(string filePath, typedesc<record {}> expectedType, record {} expectedData) returns error? {
    string content = check io:fileReadString(FILE_PATH + filePath);
    record {} data = check parseString(content, {}, expectedType);
    test:assertEquals(data, expectedData, "Data mismatched");
}

@test:Config {
    dataProvider: dataProviderForFileReadTest
}
function testParseBytes(string filePath, typedesc<record {}> expectedType, record {} expectedData) returns error? {
    byte[] content = check io:fileReadBytes(FILE_PATH + filePath);
    record {} data = check parseBytes(content, {}, expectedType);
    test:assertEquals(data, expectedData, "Data mismatched");
}

@test:Config {
    dataProvider: dataProviderForFileReadTest
}
function testParseStrema(string filePath, typedesc<record {}> expectedType, record {} expectedData) returns error? {
    stream<byte[], error?> content = check io:fileReadBlocksAsStream(FILE_PATH + filePath);
    record {} data = check parseStream(content, {}, expectedType);
    test:assertEquals(data, expectedData, "Data mismatched");
}

function dataProviderForFileReadTest() returns [string, typedesc<record {}>, record {}][] {
    return [
        [
            "source_1.json",
            LibraryS1,
            {
                "book": [
                    {
                        title: "Harry Potter and the Philosopher's Stone",
                        author: "J.K. Rowling",
                        genre: "Fantasy",
                        publication_year: 1997
                    },
                    {
                        title: "The Great Gatsby",
                        author: "F. Scott Fitzgerald",
                        genre: "Classic",
                        publication_year: 1925
                    },
                    {
                        title: "To Kill a Mockingbird",
                        author: "Harper Lee",
                        genre: "Fiction",
                        publication_year: 1960
                    }
                ]
            }
        ],
        [
            "source_2.json",
            MoviesS2,
            {
                "movie": [
                    {
                        id: "1",
                        title: "American Beauty",
                        genre: "Drama",
                        "year": 1999
                    },
                    {
                        id: "2",
                        title: "The Shawshank Redemption",
                        genre: "Drama",
                        year: 1994
                    },
                    {
                        id: "3",
                        title: "Forrest Gump",
                        genre: "Drama",
                        year: 1994
                    }
                ]
            }
        ],
        [
            "source_3.json",
            OpenRecord,
            {
                "book": [
                    {
                        "id": 1,
                        "title": "The Catcher in the Rye",
                        "author": {
                            "id": 101,
                            "nationality": "American",
                            "first_name": "J.D.",
                            "last_name": "Salinger"
                        },
                        "genre": "Fiction",
                        "publication_year": 1951
                    },
                    {
                        "id": 2,
                        "title": 1984,
                        "author": {
                            "id": 102,
                            "nationality": "British",
                            "first_name": "George",
                            "last_name": "Orwell"
                        },
                        "genre": "Dystopian",
                        "publication_year": 1949
                    },
                    {
                        "id": 3,
                        "title": "The Lord of the Rings",
                        "author": {
                            "id": 103,
                            "nationality": "British",
                            "first_name": "J.R.R.",
                            "last_name": "Tolkien"
                        },
                        "genre": "Fantasy",
                        "publication_year": 1954
                    }
                ]
            }
        ],
        [
            "source_4.json",
            OpenRecord,
            {
                "order": [
                    {
                        "order_id": 123456,
                        "date": "2024-03-22T10:30:00",
                        "customer_id": 987654,
                        "customer_info": {
                            "name": "John Doe",
                            "email": "john.doe@example.com",
                            "address": {
                                "street": "123 Main St",
                                "city": "Anytown",
                                "state": "CA",
                                "zip": 12345,
                                "country": "USA"
                            }
                        },
                        "products": {
                            "product": [
                                {
                                    "product_id": 789,
                                    "quantity": 2,
                                    "name": "Laptop",
                                    "price":
                                {"currency": "USD", "#content": 999.99}
                                },
                                {
                                    "product_id": 456,
                                    "quantity": 1,
                                    "name": "Printer",
                                    "price":
                                {"currency": "USD", "#content": 199.99}
                                }
                            ]
                        },
                        "payment": {
                            "method": "credit_card",
                            "amount": {"currency": "USD", "#content": 2199.97},
                            "card": {
                                "card_type": "VISA",
                                "card_number": "1234 5678 9012 3456",
                                "expiration_date": "2026-12"
                            }
                        },
                        "status": "completed"
                    },
                    {
                        "order_id": 789012,
                        "date": "2024-03-22T11:45:00",
                        "customer_id": 543210,
                        "customer_info": {
                            "name": "Jane Smith",
                            "email": "jane.smith@example.com",
                            "address": {
                                "street": "456 Oak Ave",
                                "city": "Smalltown",
                                "state": "NY",
                                "zip": 54321,
                                "country": "USA"
                            }
                        },
                        "products": {
                            "product": [
                                {
                                    "product_id": 123,
                                    "quantity": 3,
                                    "name": "Smartphone",
                                    "price":
                                {"currency": "USD", "#content": 799.99}
                                },
                                {
                                    "product_id": 234,
                                    "quantity": 2,
                                    "name": "Tablet",
                                    "price":
                                {"currency": "USD", "#content": 499.99}
                                },
                                {
                                    "product_id": 345,
                                    "quantity": 1,
                                    "name": "Smart Watch",
                                    "price":
                                {"currency": "USD", "#content": 299.99}
                                }
                            ]
                        },
                        "payment": {
                            "method": "paypal",
                            "amount": {"currency": "USD", "#content": 3499.94},
                            "paypal": {"email": "jane.smith@example.com"}
                        },
                        "status": "pending"
                    }
                ]
            }
        ],
        [
            "source_4.json",
            OrdersS4,
            {
                "order": [
                    {
                        "id": 123456,
                        "products": {
                            "product": [{"id": 789, "name": "Laptop"}]
                        }
                    },
                    {
                        "id": 789012,
                        "products": {
                            "product": [{"id": 123, "name": "Smartphone"}]
                        }
                    }
                ]
            }
        ]
    ];
}
