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

import ballerina/test;

// Possitive tests for fromJsonWithType() function.

@test:Config
isolated function testJsonToBasicTypes() returns error? {
    int val1 = check fromJsonWithType(5);
    test:assertEquals(val1, 5);

    float val2 = check fromJsonWithType(5.5);
    test:assertEquals(val2, 5.5);

    decimal val3 = check fromJsonWithType(5.5);
    test:assertEquals(val3, 5.5d);

    string val4 = check fromJsonWithType("hello");
    test:assertEquals(val4, "hello");

    boolean val5 = check fromJsonWithType(true);
    test:assertEquals(val5, true);

    () val6 = check fromJsonWithType(null);
    test:assertEquals(val6, null);
}

@test:Config
isolated function testSimpleJsonToRecord() returns error? {
    json j = {"a": "hello", "b": 1};

    record {|string a; int b;|} recA = check fromJsonWithType(j);
    test:assertEquals(recA.a, "hello");
    test:assertEquals(recA.b, 1);
}

@test:Config
isolated function testSimpleJsonToRecordWithProjection() returns error? {
    json j = {"a": "hello", "b": 1};

    record {|string a;|} recA = check fromJsonWithType(j);
    test:assertEquals(recA.a, "hello");
    test:assertEquals(recA, {"a": "hello"});
}

@test:Config
isolated function testNestedJsonToRecord() returns error? {
    json j = {
        "a": "hello",
        "b": 1,
        "c": {
            "d": "world",
            "e": 2
        }
    };

    record {|string a; int b; record {|string d; int e;|} c;|} recA = check fromJsonWithType(j);
    test:assertEquals(recA.a, "hello");
    test:assertEquals(recA.b, 1);
    test:assertEquals(recA.c.d, "world");
    test:assertEquals(recA.c.e, 2);
}

@test:Config
isolated function testNestedJsonToRecordWithProjection() returns error? {
    json j = {
        "a": "hello",
        "b": 1,
        "c": {
            "d": "world",
            "e": 2
        }
    };

    record {|string a; record {|string d;|} c;|} recA = check fromJsonWithType(j);
    test:assertEquals(recA.a, "hello");
    test:assertEquals(recA.c.d, "world");
    test:assertEquals(recA, {"a": "hello", "c": {"d": "world"}});
}

@test:Config
isolated function testJsonToRecordWithOptionalFields() returns error? {
    json j = {"a": "hello"};

    record {|string a; int b?;|} recA = check fromJsonWithType(j);
    test:assertEquals(recA.a, "hello");
    test:assertEquals(recA.b, null);
}

@test:Config
isolated function testJsonToRecordWithOptionalFieldsWithProjection() returns error? {
    json j = {
        "a": "hello",
        "b": 1,
        "c": {
            "d": "world",
            "e": 2
        }
    };

    record {|string a; record {|string d; int f?;|} c;|} recA = check fromJsonWithType(j);
    test:assertEquals(recA.a, "hello");
    test:assertEquals(recA.c.d, "world");
    test:assertEquals(recA, {"a": "hello", "c": {"d": "world"}});
}

@test:Config
isolated function testFromJsonWithType1() returns error? {
    json jsonContent = {
        "id": 2,
        "name": "Anne",
        "address": {
            "street": "Main",
            "city": "94"
        }
    };

    R x = check fromJsonWithType(jsonContent);
    test:assertEquals(x.id, 2);
    test:assertEquals(x.name, "Anne");
    test:assertEquals(x.address.street, "Main");
    test:assertEquals(x.address.city, "94");
}

@test:Config
isolated function testMapTypeAsFieldTypeInRecord() returns error? {
    json jsonContent = {
        "employees": {
            "John": "Manager",
            "Anne": "Developer"
        }
    };

    Company x = check fromJsonWithType(jsonContent);
    test:assertEquals(x.employees["John"], "Manager");
    test:assertEquals(x.employees["Anne"], "Developer");
}

@test:Config
isolated function testFromJsonWithType2() returns error? {
    json jsonContent = {
        "name": "John",
        "age": 30,
        "address": {
            "street": "123 Main St",
            "zipcode": 10001,
            "coordinates": {
                "latitude": 40.7128,
                "longitude": -74.0060
            }
        }
    };

    Person x = check fromJsonWithType(jsonContent);
    test:assertEquals(x.name, "John");
    test:assertEquals(x.age, 30);
    test:assertEquals(x.address.street, "123 Main St");
    test:assertEquals(x.address.zipcode, 10001);
    test:assertEquals(x.address.coordinates.latitude, 40.7128);
    test:assertEquals(x.address.coordinates.longitude, -74.0060);
}

@test:Config
isolated function testFromJsonWithType3() returns error? {
    json jsonContent = {
        "title": "To Kill a Mockingbird",
        "author": {
            "name": "Harper Lee",
            "birthdate": "1926-04-28",
            "hometown": "Monroeville, Alabama",
            "local": false
        },
        "price": 10.5,
        "publisher": {
            "name": "J. B. Lippincott & Co.",
            "year": 1960,
            "location": "Philadelphia",
            "month": 4
        }
    };

    Book x = check fromJsonWithType(jsonContent);
    test:assertEquals(x.title, "To Kill a Mockingbird");
    test:assertEquals(x.author.name, "Harper Lee");
    test:assertEquals(x.author.birthdate, "1926-04-28");
    test:assertEquals(x.author.hometown, "Monroeville, Alabama");
    test:assertEquals(x.publisher.name, "J. B. Lippincott & Co.");
    test:assertEquals(x.publisher.year, 1960);
    test:assertEquals(x.publisher["location"], "Philadelphia");
    test:assertEquals(x["price"], 10.5);
    test:assertEquals(x.author["local"], false);
}

@test:Config
isolated function testFromJsonWithType4() returns error? {
    json jsonContent = {
        "name": "School Twelve",
        "city": 23,
        "number": 12,
        "section": 2,
        "flag": true,
        "tp": 12345
    };

    School x = check fromJsonWithType(jsonContent);
    test:assertEquals(x.name, "School Twelve");
    test:assertEquals(x.number, 12);
    test:assertEquals(x.flag, true);
    test:assertEquals(x["section"], 2);
    test:assertEquals(x["tp"], 12345);
}

@test:Config
isolated function testFromJsonWithType5() returns error? {
    json jsonContent = {
        "intValue": 10,
        "floatValue": 10.5,
        "stringValue": "test",
        "decimalValue": 10.50,
        "doNotParse": "abc"
    };

    TestRecord x = check fromJsonWithType(jsonContent);
    test:assertEquals(x.intValue, 10);
    test:assertEquals(x.floatValue, 10.5f);
    test:assertEquals(x.stringValue, "test");
    test:assertEquals(x.decimalValue, 10.50d);
    test:assertEquals(x["doNotParse"], "abc");
}

@test:Config
isolated function testFromJsonWithType6() returns error? {
    json jsonContent = {
        "id": 1,
        "name": "Class A",
        "student": {
            "id": 2,
            "name": "John Doe",
            "school": {
                "name": "ABC School",
                "address": {
                    "street": "Main St",
                    "city": "New York"
                }
            }
        },
        "teacher": {
            "id": 3,
            "name": "Jane Smith"
        },
        "monitor": null
    };

    Class x = check fromJsonWithType(jsonContent);
    test:assertEquals(x.id, 1);
    test:assertEquals(x.name, "Class A");
    test:assertEquals(x.student.id, 2);
    test:assertEquals(x.student.name, "John Doe");
    test:assertEquals(x.student.school.name, "ABC School");
    test:assertEquals(x.student.school.address.street, "Main St");
    test:assertEquals(x.student.school.address.city, "New York");
    test:assertEquals(x.teacher.id, 3);
    test:assertEquals(x.teacher.name, "Jane Smith");
    test:assertEquals(x.monitor, null);
}

@test:Config
isolated function testFromJsonWithType7() returns error? {
    json nestedJson = {
        "intValue": 5,
        "floatValue": 2.5,
        "stringValue": "nested",
        "decimalValue": 5.00
    };

    json jsonContent = {
        "intValue": 10,
        "nested1": nestedJson
    };

    TestRecord2 x = check fromJsonWithType(jsonContent);
    test:assertEquals(x.intValue, 10);
    test:assertEquals(x.nested1.intValue, 5);
}

@test:Config
isolated function testFromJsonWithType8() returns error? {
    json jsonContent = {
        "street": "Main",
        "city": "Mahar",
        "house": 94
    };

    TestR x = check fromJsonWithType(jsonContent);
    test:assertEquals(x.street, "Main");
    test:assertEquals(x.city, "Mahar");
}

@test:Config
isolated function testFromJsonWithType9() returns error? {
    json jsonContent = {
        "street": "Main",
        "city": "Mahar",
        "houses": [94, 95, 96]
    };

    TestArr1 x = check fromJsonWithType(jsonContent);
    test:assertEquals(x.street, "Main");
    test:assertEquals(x.city, "Mahar");
    test:assertEquals(x.houses, [94, 95, 96]);
}

@test:Config
isolated function testFromJsonWithType10() returns error? {
    json jsonContent = {
        "street": "Main",
        "city": 11,
        "house": [94, "Gedara"]
    };

    TestArr2 x = check fromJsonWithType(jsonContent);
    test:assertEquals(x.street, "Main");
    test:assertEquals(x.city, 11);
    test:assertEquals(x.house, [94, "Gedara"]);
}

@test:Config
isolated function testFromJsonWithType11() returns error? {
    json jsonContent = {
        "street": "Main",
        "city": "Mahar",
        "house": [94, [1, 2, 3]]
    };

    TestArr3 x = check fromJsonWithType(jsonContent);
    test:assertEquals(x.street, "Main");
    test:assertEquals(x.city, "Mahar");
    test:assertEquals(x.house, [94, [1, 2, 3]]);
}

@test:Config
isolated function testFromJsonWithType12() returns error? {
    json jsonContent = {
        "street": "Main",
        "city": {
            "name": "Mahar",
            "code": 94
        },
        "flag": true
    };

    TestJson x = check fromJsonWithType(jsonContent);
    test:assertEquals(x.street, "Main");
    test:assertEquals(x.city, {"name": "Mahar", "code": 94});
}

@test:Config
isolated function testFromJsonWithType14() returns error? {
    json jsonContent = {
        "id": 12,
        "name": "Anne",
        "address": {
            "id": 34,
            "city": "94"
        }
    };

    RN|Error x = fromJsonWithType(jsonContent);
    test:assertTrue(x is error);
    test:assertEquals((<error>x).message(), "required field 'street' not present in JSON");
}

@test:Config
isolated function testFromJsonWithType15() returns error? {
    json jsonContent = [1, 2, 3];

    IntArr x = check fromJsonWithType(jsonContent);
    test:assertEquals(x, [1, 2, 3]);
}

@test:Config
isolated function testFromJsonWithType16() returns error? {
    json jsonContent = [1, "abc", [3, 4.0]];

    TUPLE|Error x = check fromJsonWithType(jsonContent);
    test:assertEquals(x, [1, "abc", [3, 4.0]]);
}

@test:Config
isolated function testFromJsonWithType17() returns error? {
    json jsonContent = {
        "street": "Main",
        "city": {
            "name": "Mahar",
            "code": 94,
            "internal": {
                "id": 12,
                "agent": "Anne"
            }
        },
        "flag": true
    };

    TestJson x = check fromJsonWithType(jsonContent);
    test:assertEquals(x.street, "Main");
    test:assertEquals(x.city, {"name": "Mahar", "code": 94, "internal": {"id": 12, "agent": "Anne"}});
}

@test:Config
isolated function testFromJsonWithType18() returns error? {
    json jsonContent = {
        "books": [
            {
                "title": "The Great Gatsby",
                "author": "F. Scott Fitzgerald"
            },
            {
                "title": "The Grapes of Wrath",
                "author": "John Steinbeck"
            },
            {
                "title": "Binary Echoes: Unraveling the Digital Web",
                "author": "Alexandra Quinn"
            }
        ]
    };

    Library x = check fromJsonWithType(jsonContent);
    test:assertEquals(x.books.length(), 2);
    test:assertEquals(x.books[0].title, "The Great Gatsby");
    test:assertEquals(x.books[0].author, "F. Scott Fitzgerald");
    test:assertEquals(x.books[1].title, "The Grapes of Wrath");
    test:assertEquals(x.books[1].author, "John Steinbeck");
}

@test:Config
isolated function testFromJsonWithType19() returns error? {
    json jsonContent = {
        "books": [
            {
                "title": "The Great Gatsby",
                "author": "F. Scott Fitzgerald"
            },
            {
                "title": "The Grapes of Wrath",
                "author": "John Steinbeck"
            },
            {
                "title": "Binary Echoes: Unraveling the Digital Web",
                "author": "Alexandra Quinn"
            }
        ]
    };

    LibraryB x = check fromJsonWithType(jsonContent);
    test:assertEquals(x.books.length(), 2);
    test:assertEquals(x.books[0].title, "The Great Gatsby");
    test:assertEquals(x.books[0].author, "F. Scott Fitzgerald");
    test:assertEquals(x.books[1].title, "The Grapes of Wrath");
    test:assertEquals(x.books[1].author, "John Steinbeck");

    LibraryC y = check fromJsonWithType(jsonContent);
    test:assertEquals(y.books.length(), 3);
    test:assertEquals(y.books[0].title, "The Great Gatsby");
    test:assertEquals(y.books[0].author, "F. Scott Fitzgerald");
    test:assertEquals(y.books[1].title, "The Grapes of Wrath");
    test:assertEquals(y.books[1].author, "John Steinbeck");
    test:assertEquals(y.books[2].title, "Binary Echoes: Unraveling the Digital Web");
    test:assertEquals(y.books[2].author, "Alexandra Quinn");
}

@test:Config
isolated function testFromJsonWithType20() returns error? {
    // TODO: Fix these bugs and enable the tests.
    json jsonVal1 = {
        "a": {
            "c": "world",
            "d": "2"
        },
        "b": {
            "c": "world",
            "d": "2"
        }
    };

    record {|
        record {|
            string c;
            string d;
        |}...;
    |} val1 = check fromJsonWithType(jsonVal1);
    test:assertEquals(val1.length(), 2);
    test:assertEquals(val1["a"]["c"], "world");
    test:assertEquals(val1["a"]["d"], "2");
    test:assertEquals(val1["b"]["c"], "world");
    test:assertEquals(val1["b"]["d"], "2");

    record {|
        map<string>...;
    |} val2 = check fromJsonWithType(jsonVal1);
    test:assertEquals(val2.length(), 2);
    test:assertEquals(val2["a"]["c"], "world");
    test:assertEquals(val2["a"]["d"], "2");
    test:assertEquals(val2["b"]["c"], "world");
    test:assertEquals(val2["b"]["d"], "2");
    
    json jsonVal3 = {
        "a": [{
            "c": "world",
            "d": "2"
        }],
        "b": [{
            "c": "war",
            "d": "3"
        }]
    };

    record {|
        record {|
            string c;
            string d;
        |}[]...;
    |} val3 = check fromJsonWithType(jsonVal3);
    test:assertEquals(val3.length(), 2);
    test:assertEquals(val3["a"], [{
            "c": "world",
            "d": "2"
        }]);
    test:assertEquals(val3["b"], [{
            "c": "war",
            "d": "3"
        }]);
}

@test:Config
isolated function testUnionTypeAsExpTypeForFromJsonWithType() returns error? {
    decimal|float val1 = check fromJsonWithType(1.0);
    test:assertEquals(val1, 1.0);

    json jsonVal2 =  {
        "a": "hello",
        "b": 1.0
    };

    record {|
        decimal|float b;
    |} val2 = check fromJsonWithType(jsonVal2);
    test:assertEquals(val2.length(), 1);
    test:assertEquals(val2.b, 1.0);

    json jsonVal3 = {
        "a": {
            "b": 1,
            "d": {
                "e": false
            }
        },
        "c": 2.0
    };

    record {|
        record {| decimal|int b; record {| string|boolean e; |} d; |} a;
        decimal|float c;
    |} val3 = check fromJsonWithType(jsonVal3);
    test:assertEquals(val3.length(), 2);
    test:assertEquals(val3.a.length(), 2);
    test:assertEquals(val3.a.b, 1);
    test:assertEquals(val3.a.d.e, false);
    test:assertEquals(val3.c, 2.0);
}

@test:Config
isolated function testAnydataAsExpTypeForFromJsonWithType() returns error? {
    anydata val1 = check fromJsonWithType(1);
    test:assertEquals(val1, 1);

    json jsonVal2 = {
        "a": "hello",
        "b": 1
    };

    anydata val2 = check fromJsonWithType(jsonVal2);
    test:assertEquals(val2, {"a": "hello", "b": 1});

    record {|
        record {|
            int b;
            record {|
                string e;
            |} d;
        |} a;
        int c;
    |} jsonVal3 = {
        "a": {
            "b": 1,
            "d": {
                "e": "hello"
            }
        },
        "c": 2
    };

    anydata val3 = check fromJsonWithType(jsonVal3);
    test:assertEquals(val3, {"a": {"b": 1, "d": {"e": "hello"}}, "c": 2});

    record {|
        record {|
            int b;
            record {|
                string e;
            |} d;
        |}[] a;
        int c;
    |} jsonVal4 = {
        "a": [{
            "b": 1,
            "d": {
                "e": "hello"
            }
        }],
        "c": 2
    };

    anydata val4 = check fromJsonWithType(jsonVal4);
    test:assertEquals(val4, {"a": [{"b": 1, "d": {"e": "hello"}}], "c": 2});

    [[int], int] str5 = [[1], 2];
    anydata val5 = check fromJsonWithType(str5);
    test:assertEquals(val5, [[1], 2]);
}

@test:Config
isolated function testJsonAsExpTypeForFromJsonWithType() returns error? {
    json val1 = check fromJsonWithType(1);
    test:assertEquals(val1, 1);

    record {|
        string a;
        int b;
    |} jsonVal2 = {
        "a": "hello",
        "b": 1
    };

    json val2 = check fromJsonWithType(jsonVal2);
    test:assertEquals(val2, {"a": "hello", "b": 1});

    record {|
        record {|
            int b;
            record {|
                string e;
            |} d;
        |} a;
        int c;
    |} jsonVal3 = {
        "a": {
            "b": 1,
            "d": {
                "e": "hello"
            }
        },
        "c": 2
    };

    json val3 = check fromJsonWithType(jsonVal3);
    test:assertEquals(val3, {"a": {"b": 1, "d": {"e": "hello"}}, "c": 2});

    record {|
        record {|
            int b;
            record {|
                string e;
            |} d;
        |}[] a;
        int c;
    |} jsonVal4 = {
        "a": [{
            "b": 1,
            "d": {
                "e": "hello"
            }
        }],
        "c": 2
    };

    json val4 = check fromJsonWithType(jsonVal4);
    test:assertEquals(val4, {"a": [{"b": 1, "d": {"e": "hello"}}], "c": 2});

    [[int], float] jsonVal5 = [[1], 2];
    json val5 = check fromJsonWithType(jsonVal5);
    test:assertEquals(val5, [[1], 2.0]);
}

@test:Config
isolated function testMapAsExpTypeForFromJsonWithType() returns error? {
    record {|
        string a;
        string b;
    |} jsonVal1 = {
        "a": "hello",
        "b": "1"
    };

    map<string> val1 = check fromJsonWithType(jsonVal1);
    test:assertEquals(val1, {"a": "hello", "b": "1"});

    json jsonVal2 = {
        "a": "hello",
        "b": 1,
        "c": {
            "d": "world",
            "e": "2"
        }
    };
    record {|
        string a;
        int b;
        map<string> c;
    |} val2 = check fromJsonWithType(jsonVal2);
    test:assertEquals(val2.a, "hello");
    test:assertEquals(val2.b, 1);
    test:assertEquals(val2.c, {"d": "world", "e": "2"});

    json jsonVal3 = {
        "a": {
            "c": "world",
            "d": "2"
        },
        "b": {
            "c": "war",
            "d": "3"
        }
    };

    map<map<string>> val3 = check fromJsonWithType(jsonVal3);
    test:assertEquals(val3, {"a": {"c": "world", "d": "2"}, "b": {"c": "war", "d": "3"}});

    record {|
        map<string> a;
    |} val4 = check fromJsonWithType(jsonVal3);
    test:assertEquals(val4.a, {"c": "world", "d": "2"});

    map<record {|
        string c;
        string d;
    |}> val5 = check fromJsonWithType(jsonVal3);
    test:assertEquals(val5, {"a": {"c": "world", "d": "2"}, "b": {"c": "war", "d": "3"}});
}

@test:Config
isolated function testProjectionInTupleForFromJsonWithType() returns error? {
    float[] jsonVal1 = [1, 2, 3, 4, 5, 8];
    [float, float] val1 = check fromJsonWithType(jsonVal1);
    test:assertEquals(val1, [1.0, 2.0]);

    record {|
        float[] a;
    |} jsonVal2 = {
        "a": [1, 2, 3, 4, 5, 8]
    };
    record {| [float, float] a; |} val2 = check fromJsonWithType(jsonVal2);
    test:assertEquals(val2.a, [1.0, 2.0]);

    [int, string] str3 = [1, "4"];
    [int] val3 = check fromJsonWithType(str3); 
    test:assertEquals(val3, [1]);

    [string, record {|json...;|}] jsonVal4 = ["1", {}];
    [string] val4 = check fromJsonWithType(jsonVal4); 
    test:assertEquals(val4, ["1"]);

    [string, int[], map<int>] jsonVal5 = ["1", [], {"name": 1}];
    [string] val5 = check fromJsonWithType(jsonVal5); 
    test:assertEquals(val5, ["1"]);
}

@test:Config
isolated function testProjectionInArrayForFromJsonWithType() returns error? {
    int[2] val1 = check fromJsonWithType([1, 2, 3, 4, 5]);
    test:assertEquals(val1, [1, 2]);

    record {|
        int[] a;
    |} jsonVal2 = {
        "a": [1, 2, 3, 4, 5]
    };
    record {| int[2] a; |} val2 = check fromJsonWithType(jsonVal2);
    test:assertEquals(val2, {a: [1, 2]});

    json jsonVal3 = {
        "a": [1, 2, 3, 4, 5],
        "b": [1, 2, 3, 4, 5]
    };
    record {| int[2] a; int[3] b; |} val3 = check fromJsonWithType(jsonVal3);
    test:assertEquals(val3, {a: [1, 2], b: [1, 2, 3]});

    json jsonVal4 = {
        "employees": [
            { "name": "Prakanth",
              "age": 26
            },
            { "name": "Kevin",
              "age": 25
            }
        ]
    };
    record {| record {| string name; int age; |}[1] employees; |} val4 = check fromJsonWithType(jsonVal4);
    test:assertEquals(val4, {employees: [{name: "Prakanth", age: 26}]});
}

@test:Config
isolated function testProjectionInRecordForFromJsonWithType() returns error? {
    json jsonVal1 = {"name": "John", "age": 30, "city": "New York"};
    record {| string name; string city; |} val1 = check fromJsonWithType(jsonVal1);
    test:assertEquals(val1, {name: "John", city: "New York"});

    json jsonVal2 = {"name": "John", "age": "30", "city": "New York"};
    record {| string name; string city; |} val2 = check fromJsonWithType(jsonVal2);
    test:assertEquals(val2, {name: "John", city: "New York"});

    json jsonVal3 = { "name": "John", 
                                "company": {
                                    "name": "wso2", 
                                    "year": 2024,
                                    "addrees": {
                                        "street": "123",
                                        "city": "Berkeley"
                                        }
                                    },
                                "city": "New York" };
    record {| string name; string city; |} val3 = check fromJsonWithType(jsonVal3);
    test:assertEquals(val3, {name: "John", city: "New York"});
    
    json jsonVal4 = { "name": "John", 
                                "company": [{
                                    "name": "wso2", 
                                    "year": 2024,
                                    "addrees": {
                                        "street": "123",
                                        "city": "Berkeley"
                                        }
                                    }],
                                "city": "New York" };
    record {| string name; string city; |} val4 = check fromJsonWithType(jsonVal4);
    test:assertEquals(val4, {name: "John", city: "New York"});

    json jsonVal5 = { "name": "John", 
                                "company1": [{
                                    "name": "wso2", 
                                    "year": 2024,
                                    "addrees": {
                                        "street": "123",
                                        "city": "Berkeley"
                                        }
                                    }],
                                "city": "New York",
                                "company2": [{
                                    "name": "amzn", 
                                    "year": 2024,
                                    "addrees": {
                                        "street": "123",
                                        "city": "Miami"
                                        }
                                    }]
                                };
    record {| string name; string city; |} val5 = check fromJsonWithType(jsonVal5);
    test:assertEquals(val5, {name: "John", city: "New York"});
}

@test:Config
isolated function testArrayOrTupleCaseForFromJsonWithType() returns error? {
    json jsonVal1 = [[1], 2.0];
    [[int], float] val1 = check fromJsonWithType(jsonVal1);
    test:assertEquals(val1, [[1], 2.0]);

    json jsonVal2 = [[1, 2], 2.0];
    [[int, int], float] val2 = check fromJsonWithType(jsonVal2);
    test:assertEquals(val2, [[1, 2], 2.0]);
    
    json jsonStr3 = [[1, 2], [2, 3]];
    int[][] val3 = check fromJsonWithType(jsonStr3);
    test:assertEquals(val3, [[1, 2], [2, 3]]);

    json jsonVal4 = {"val" : [[1, 2], "2.0", 3.0, [5, 6]]};
    record {|
        [[int, int], string, float, [int, int]] val;
    |} val4 = check fromJsonWithType(jsonVal4);
    test:assertEquals(val4, {val: [[1, 2], "2.0", 3.0, [5, 6]]});

    json jsonVal41 = {"val1" : [[1, 2], "2.0", 3.0, [5, 6]], "val2" : [[1, 2], "2.0", 3.0, [5, 6]]};
    record {|
        [[int, int], string, float, [int, int]] val1;
        [[int, int], string, float, [int, int]] val2;
    |} val41 = check fromJsonWithType(jsonVal41);
    test:assertEquals(val41, {val1: [[1, 2], "2.0", 3.0, [5, 6]], val2: [[1, 2], "2.0", 3.0, [5, 6]]});

    json jsonVal5 = {"val" : [[1, 2], [2, 3]]};
    record {|
        int[][] val;
    |} val5 = check fromJsonWithType(jsonVal5);
    test:assertEquals(val5, {val: [[1, 2], [2, 3]]});

    json jsonVal6 = [{"val" : [[1, 2], [2, 3]]}];
    [record {|int[][] val;|}] val6 = check fromJsonWithType(jsonVal6);
    test:assertEquals(val6, [{val: [[1, 2], [2, 3]]}]);
}

// Negative tests for fromJsonWithType() function.

@test:Config
isolated function testFromJsonWithTypeNegative1() returns error? {
    json jsonContent = {
        "id": 12,
        "name": "Anne",
        "address": {
            "street": "Main",
            "city": "94",
            "id": true
        }
    };

    RN|Error x = fromJsonWithType(jsonContent);
    test:assertTrue(x is error);
    test:assertEquals((<error>x).message(), "incompatible value 'true' for type 'int' in field 'address.id'");
}

@test:Config
isolated function testFromJsonWithTypeNegative2() returns error? {
    json jsonContent = {
        "id": 12
    };

    RN2|Error x = fromJsonWithType(jsonContent);
    test:assertTrue(x is error);
    test:assertEquals((<error>x).message(), "required field 'name' not present in JSON");
}

@test:Config
isolated function testFromJsonWithTypeNegative3() returns error? {
    json jsonContent = {
        "id": 12,
        "name": "Anne",
        "address": {
            "street": "Main",
            "city": "94"
        }
    };

    RN|Error x = fromJsonWithType(jsonContent);
    test:assertTrue(x is Error);
    test:assertEquals((<Error>x).message(), "required field 'id' not present in JSON");
}

@test:Config
isolated function testFromJsonWithTypeNegative4() returns error? {
    json jsonContent = {
        name: "John"
    };

    int|Error x = fromJsonWithType(jsonContent);
    test:assertTrue(x is error);
    test:assertEquals((<error>x).message(), "incompatible expected type 'int' for value '{\"name\":\"John\"}'");

    Union|Error y = fromJsonWithType(jsonContent);
    test:assertTrue(y is error);
    test:assertEquals((<error>y).message(), "invalid type 'data.jsondata:Union' expected 'anydata'");

    table<RN2>|Error z = fromJsonWithType(jsonContent);
    test:assertTrue(z is error);
    test:assertEquals((<error>z).message(), "invalid type 'table<data.jsondata:RN2>' expected 'anydata'");

    RN2|Error a = fromJsonWithType("1");
    test:assertTrue(a is error);
    test:assertEquals((<error>a).message(), "incompatible expected type 'data.jsondata:RN2' for value '1'");

    string|Error b = fromJsonWithType(1);
    test:assertTrue(b is error);
    test:assertEquals((<error>b).message(), "incompatible expected type 'string' for value '1'");
}

@test:Config
isolated function testFromJsonWithTypeNegative5() returns error? {
    json jsonContent = [1, 2];

    INTARR|Error x = fromJsonWithType(jsonContent);
    test:assertTrue(x is error);
    test:assertEquals((<error>x).message(), "array size is not compatible with the expected size");

    INTTUPLE|Error y = fromJsonWithType(jsonContent);
    test:assertTrue(y is error);
    test:assertEquals((<error>y).message(), "array size is not compatible with the expected size");
}

@test:Config
isolated function testFromJsonWithTypeNegative6() {
    json jsonContent = {
        "street": "Main",
        "city": "Mahar",
        "house": [94, [1, 3, "4"]]
    };

    TestArr3|Error x = fromJsonWithType(jsonContent);
    test:assertTrue(x is Error);
    test:assertEquals((<Error>x).message(), "incompatible value '4' for type 'int' in field 'house'");
}
