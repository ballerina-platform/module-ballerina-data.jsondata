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

import ballerina/test;

@test:Config {
    dataProvider: dataProviderForBasicTypeForParseAsType
}
isolated function testJsonToBasicTypes(json sourceData, typedesc<anydata> expType, anydata expResult) returns Error? {
    anydata result = check parseAsType(sourceData, {}, expType);
    test:assertEquals(result, expResult);
}

function dataProviderForBasicTypeForParseAsType() returns [json, typedesc<anydata>, anydata][] {
    return [
        [5, int, 5],
        [5.5, float, 5.5],
        [5.5, decimal, 5.5d],
        ["hello", string, "hello"],
        [true, boolean, true],
        [1.5, decimal, 1.5d],
        ["", string, ""],
        [1.5, decimal, 1.5d],
        [1.5, float, 1.5f],
        [1.5, decimal, 1.5d],
        [1.5, float, 1.5f],
        [1.5, int, 2]
    ];
}

@test:Config
isolated function testNilAsExpectedTypeWithParseAsType() returns error? {
    () val1 = check parseAsType(null);
    test:assertEquals(val1, ());

    () val2 = check parseAsType(());
    test:assertEquals(val2, ());
}

@test:Config
isolated function testSimpleJsonToRecord() returns Error? {
    json j = {"a": "hello", "b": 1};

    SimpleRec1 recA = check parseAsType(j);
    test:assertEquals(recA.a, "hello");
    test:assertEquals(recA.b, 1);

    SimpleRec2 recB = check parseAsType(j);
    test:assertEquals(recB.a, "hello");
    test:assertEquals(recB.b, 1);

    OpenRecord recC = check parseAsType(j);
    test:assertEquals(recC.get("a"), "hello");
    test:assertEquals(recC.get("b"), 1);
}

@test:Config
isolated function testSimpleJsonToRecordWithProjection() returns Error? {
    json j = {"a": "hello", "b": 1};

    record {|string a;|} recA = check parseAsType(j);
    test:assertEquals(recA.a, "hello");
    test:assertEquals(recA, {"a": "hello"});
}

@test:Config
isolated function testNestedJsonToRecord() returns Error? {
    json j = {
        "a": "hello",
        "b": 1,
        "c": {
            "d": "world",
            "e": 2
        }
    };

    NestedRecord1 recA = check parseAsType(j);
    test:assertEquals(recA.a, "hello");
    test:assertEquals(recA.b, 1);
    test:assertEquals(recA.c.d, "world");
    test:assertEquals(recA.c.e, 2);

    NestedRecord2 recB = check parseAsType(j);
    test:assertEquals(recB.a, "hello");
    test:assertEquals(recB.b, 1);
    test:assertEquals(recB.c.d, "world");
    test:assertEquals(recB.c.e, 2);

    OpenRecord recC = check parseAsType(j);
    test:assertEquals(recC.get("a"), "hello");
    test:assertEquals(recC.get("b"), 1);
    test:assertEquals(recC.get("c"), {d: "world", e: 2});
}

@test:Config
isolated function testNestedJsonToRecordWithProjection() returns Error? {
    json j = {
        "a": "hello",
        "b": 1,
        "c": {
            "d": "world",
            "e": 2
        }
    };

    record {|string a; record {|string d;|} c;|} recA = check parseAsType(j);
    test:assertEquals(recA.a, "hello");
    test:assertEquals(recA.c.d, "world");
    test:assertEquals(recA, {"a": "hello", "c": {"d": "world"}});
}

@test:Config
isolated function testJsonToRecordWithOptionalFields() returns Error? {
    json j = {"a": "hello"};

    record {|string a; int b?;|} recA = check parseAsType(j);
    test:assertEquals(recA.a, "hello");
    test:assertEquals(recA.b, null);
}

@test:Config
isolated function testJsonToRecordWithOptionalFieldsWithProjection() returns Error? {
    json j = {
        "a": "hello",
        "b": 1,
        "c": {
            "d": "world",
            "e": 2
        }
    };

    record {|string a; record {|string d; int f?;|} c;|} recA = check parseAsType(j);
    test:assertEquals(recA.a, "hello");
    test:assertEquals(recA.c.d, "world");
    test:assertEquals(recA, {"a": "hello", "c": {"d": "world"}});
}

@test:Config
isolated function testParseAsType1() returns Error? {
    json jsonContent = {
        "id": 2,
        "name": "Anne",
        "address": {
            "street": "Main",
            "city": "94"
        }
    };

    R x = check parseAsType(jsonContent);
    test:assertEquals(x.id, 2);
    test:assertEquals(x.name, "Anne");
    test:assertEquals(x.address.street, "Main");
    test:assertEquals(x.address.city, "94");
}

@test:Config
isolated function testMapTypeAsFieldTypeInRecord() returns Error? {
    json jsonContent = {
        "employees": {
            "John": "Manager",
            "Anne": "Developer"
        }
    };

    Company x = check parseAsType(jsonContent);
    test:assertEquals(x.employees["John"], "Manager");
    test:assertEquals(x.employees["Anne"], "Developer");
}

@test:Config
isolated function testParseAsType2() returns Error? {
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

    Person x = check parseAsType(jsonContent);
    test:assertEquals(x.name, "John");
    test:assertEquals(x.age, 30);
    test:assertEquals(x.address.street, "123 Main St");
    test:assertEquals(x.address.zipcode, 10001);
    test:assertEquals(x.address.coordinates.latitude, 40.7128);
    test:assertEquals(x.address.coordinates.longitude, -74.0060);
}

@test:Config
isolated function testParseAsType3() returns Error? {
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
            "month": "April"
        }
    };

    Book x = check parseAsType(jsonContent);
    test:assertEquals(x.title, "To Kill a Mockingbird");
    test:assertEquals(x.author.name, "Harper Lee");
    test:assertEquals(x.author.birthdate, "1926-04-28");
    test:assertEquals(x.author.hometown, "Monroeville, Alabama");
    test:assertEquals(x.publisher.name, "J. B. Lippincott & Co.");
    test:assertEquals(x.publisher.year, 1960);
    test:assertEquals(x.publisher["month"], "April");
    test:assertEquals(x.publisher["location"], "Philadelphia");
    test:assertEquals(x["price"], 10.5);
    test:assertEquals(x.author["local"], false);
}

@test:Config
isolated function testParseAsType4() returns Error? {
    json jsonContent = {
        "name": "School Twelve",
        "city": 23,
        "number": 12,
        "section": 2,
        "flag": true,
        "tp": 12345
    };

    School x = check parseAsType(jsonContent);
    test:assertEquals(x.name, "School Twelve");
    test:assertEquals(x.number, 12);
    test:assertEquals(x.flag, true);
    test:assertEquals(x["section"], 2);
    test:assertEquals(x["tp"], 12345);
}

@test:Config
isolated function testParseAsType5() returns Error? {
    json jsonContent = {
        "intValue": 10,
        "floatValue": 10.5,
        "stringValue": "test",
        "decimalValue": 10.50,
        "doNotParse": "abc"
    };

    TestRecord x = check parseAsType(jsonContent);
    test:assertEquals(x.intValue, 10);
    test:assertEquals(x.floatValue, 10.5f);
    test:assertEquals(x.stringValue, "test");
    test:assertEquals(x.decimalValue, 10.50d);
    test:assertEquals(x["doNotParse"], "abc");
}

@test:Config
isolated function testParseAsType6() returns Error? {
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

    Class x = check parseAsType(jsonContent);
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
isolated function testParseAsType7() returns Error? {
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

    TestRecord2 x = check parseAsType(jsonContent);
    test:assertEquals(x.intValue, 10);
    test:assertEquals(x.nested1.intValue, 5);
}

@test:Config
isolated function testParseAsType8() returns Error? {
    json jsonContent = {
        "street": "Main",
        "city": "Mahar",
        "house": 94
    };

    TestR x = check parseAsType(jsonContent);
    test:assertEquals(x.street, "Main");
    test:assertEquals(x.city, "Mahar");
}

@test:Config
isolated function testParseAsType9() returns Error? {
    json jsonContent = {
        "street": "Main",
        "city": "Mahar",
        "houses": [94, 95, 96]
    };

    TestArr1 x = check parseAsType(jsonContent);
    test:assertEquals(x.street, "Main");
    test:assertEquals(x.city, "Mahar");
    test:assertEquals(x.houses, [94, 95, 96]);
}

@test:Config
isolated function testParseAsType10() returns Error? {
    json jsonContent = {
        "street": "Main",
        "city": 11,
        "house": [94, "Gedara"]
    };

    TestArr2 x = check parseAsType(jsonContent);
    test:assertEquals(x.street, "Main");
    test:assertEquals(x.city, 11);
    test:assertEquals(x.house, [94, "Gedara"]);
}

@test:Config
isolated function testParseAsType11() returns Error? {
    json jsonContent = {
        "street": "Main",
        "city": "Mahar",
        "house": [94, [1, 2, 3]]
    };

    TestArr3 x = check parseAsType(jsonContent);
    test:assertEquals(x.street, "Main");
    test:assertEquals(x.city, "Mahar");
    test:assertEquals(x.house, [94, [1, 2, 3]]);
}

@test:Config
isolated function testParseAsType12() returns Error? {
    json jsonContent = {
        "street": "Main",
        "city": {
            "name": "Mahar",
            "code": 94
        },
        "flag": true
    };

    TestJson x = check parseAsType(jsonContent);
    test:assertEquals(x.street, "Main");
    test:assertEquals(x.city, {"name": "Mahar", "code": 94});
}

@test:Config
isolated function testParseAsType14() {
    json jsonContent = {
        "id": 12,
        "name": "Anne",
        "address": {
            "id": 34,
            "city": "94"
        }
    };

    RN|Error x = parseAsType(jsonContent);
    test:assertTrue(x is Error);
    test:assertEquals((<Error>x).message(), "required field 'street' not present in JSON");
}

@test:Config
isolated function testParseAsType15() returns Error? {
    json jsonContent = [1, 2, 3];

    IntArr x = check parseAsType(jsonContent);
    test:assertEquals(x, [1, 2, 3]);
}

@test:Config
isolated function testParseAsType16() returns Error? {
    json jsonContent = [1, "abc", [3, 4.0]];

    Tuple|Error x = check parseAsType(jsonContent);
    test:assertEquals(x, [1, "abc", [3, 4.0]]);
}

@test:Config
isolated function testParseAsType17() returns Error? {
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

    TestJson x = check parseAsType(jsonContent);
    test:assertEquals(x.street, "Main");
    test:assertEquals(x.city, {"name": "Mahar", "code": 94, "internal": {"id": 12, "agent": "Anne"}});
}

@test:Config
isolated function testParseAsType18() returns Error? {
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

    Library x = check parseAsType(jsonContent);
    test:assertEquals(x.books.length(), 2);
    test:assertEquals(x.books[0].title, "The Great Gatsby");
    test:assertEquals(x.books[0].author, "F. Scott Fitzgerald");
    test:assertEquals(x.books[1].title, "The Grapes of Wrath");
    test:assertEquals(x.books[1].author, "John Steinbeck");
}

@test:Config
isolated function testParseAsType19() returns Error? {
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

    LibraryB x = check parseAsType(jsonContent);
    test:assertEquals(x.books.length(), 2);
    test:assertEquals(x.books[0].title, "The Great Gatsby");
    test:assertEquals(x.books[0].author, "F. Scott Fitzgerald");
    test:assertEquals(x.books[1].title, "The Grapes of Wrath");
    test:assertEquals(x.books[1].author, "John Steinbeck");

    LibraryC y = check parseAsType(jsonContent);
    test:assertEquals(y.books.length(), 3);
    test:assertEquals(y.books[0].title, "The Great Gatsby");
    test:assertEquals(y.books[0].author, "F. Scott Fitzgerald");
    test:assertEquals(y.books[1].title, "The Grapes of Wrath");
    test:assertEquals(y.books[1].author, "John Steinbeck");
    test:assertEquals(y.books[2].title, "Binary Echoes: Unraveling the Digital Web");
    test:assertEquals(y.books[2].author, "Alexandra Quinn");
}

@test:Config
isolated function testParseAsType20() returns Error? {
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
    |} val1 = check parseAsType(jsonVal1);
    test:assertEquals(val1.length(), 2);
    test:assertEquals(val1["a"]["c"], "world");
    test:assertEquals(val1["a"]["d"], "2");
    test:assertEquals(val1["b"]["c"], "world");
    test:assertEquals(val1["b"]["d"], "2");

    record {|
        map<string>...;
    |} val2 = check parseAsType(jsonVal1);
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
    |} val3 = check parseAsType(jsonVal3);
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
isolated function testUnionTypeAsExpTypeForParseAsType() returns Error? {
    decimal|float val1 = check parseAsType(1.0);
    test:assertEquals(val1, 1.0d);

    json jsonVal2 =  {
        "a": "hello",
        "b": 1.0
    };

    record {|
        decimal|float b;
    |} val2 = check parseAsType(jsonVal2);
    test:assertEquals(val2.length(), 1);
    test:assertEquals(val2.b, 1.0d);

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
        record {| int|decimal b; record {| string|boolean e; |} d; |} a;
        decimal|float c;
    |} val3 = check parseAsType(jsonVal3);
    test:assertEquals(val3.length(), 2);
    test:assertEquals(val3.a.length(), 2);
    test:assertEquals(val3.a.b, 1);
    test:assertEquals(val3.a.d.e, false);
    test:assertEquals(val3.c, 2.0d);
}

@test:Config
isolated function testAnydataAsExpTypeForParseAsType() returns Error? {
    anydata val1 = check parseAsType(1);
    test:assertEquals(val1, 1);

    json jsonVal2 = {
        "a": "hello",
        "b": 1
    };

    anydata val2 = check parseAsType(jsonVal2);
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

    anydata val3 = check parseAsType(jsonVal3);
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

    anydata val4 = check parseAsType(jsonVal4);
    test:assertEquals(val4, {"a": [{"b": 1, "d": {"e": "hello"}}], "c": 2});

    [[int], int] str5 = [[1], 2];
    anydata val5 = check parseAsType(str5);
    test:assertEquals(val5, [[1], 2]);
}

@test:Config
isolated function testJsonAsExpTypeForParseAsType() returns Error? {
    json val1 = check parseAsType(1);
    test:assertEquals(val1, 1);

    record {|
        string a;
        int b;
    |} jsonVal2 = {
        "a": "hello",
        "b": 1
    };

    json val2 = check parseAsType(jsonVal2);
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

    json val3 = check parseAsType(jsonVal3);
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

    json val4 = check parseAsType(jsonVal4);
    test:assertEquals(val4, {"a": [{"b": 1, "d": {"e": "hello"}}], "c": 2});

    [[int], float] jsonVal5 = [[1], 2];
    json val5 = check parseAsType(jsonVal5);
    test:assertEquals(val5, [[1], 2.0]);
}

@test:Config
isolated function testMapAsExpTypeForParseAsType() returns Error? {
    record {|
        string a;
        string b;
    |} jsonVal1 = {
        "a": "hello",
        "b": "1"
    };

    map<string> val1 = check parseAsType(jsonVal1);
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
    |} val2 = check parseAsType(jsonVal2);
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

    map<map<string>> val3 = check parseAsType(jsonVal3);
    test:assertEquals(val3, {"a": {"c": "world", "d": "2"}, "b": {"c": "war", "d": "3"}});

    record {|
        map<string> a;
    |} val4 = check parseAsType(jsonVal3);
    test:assertEquals(val4.a, {"c": "world", "d": "2"});

    map<record {|
        string c;
        string d;
    |}> val5 = check parseAsType(jsonVal3);
    test:assertEquals(val5, {"a": {"c": "world", "d": "2"}, "b": {"c": "war", "d": "3"}});

    json jsonVal6 = {
        a: "Kanth",
        b: {
            g: {
                c: "hello",
                d: "1"
            },
            h: {
                c: "world",
                d: "2"
            }
        }
    };
    record {|
        string a;
        map<map<string>> b;
    |} val6 = check parseAsType(jsonVal6);
    test:assertEquals(val6.a, "Kanth");
    test:assertEquals(val6.b, {g: {c: "hello", d: "1"}, h: {c: "world", d: "2"}});
}

@test:Config
isolated function testProjectionInTupleForParseAsType() returns Error? {
    float[] jsonVal1 = [1, 2, 3, 4, 5, 8];
    [float, float] val1 = check parseAsType(jsonVal1);
    test:assertEquals(val1, [1.0, 2.0]);

    record {|
        float[] a;
    |} jsonVal2 = {
        "a": [1, 2, 3, 4, 5, 8]
    };
    record {| [float, float] a; |} val2 = check parseAsType(jsonVal2);
    test:assertEquals(val2.a, [1.0, 2.0]);

    [int, string] str3 = [1, "4"];
    [int] val3 = check parseAsType(str3); 
    test:assertEquals(val3, [1]);

    [string, record {|json...;|}] jsonVal4 = ["1", {}];
    [string] val4 = check parseAsType(jsonVal4); 
    test:assertEquals(val4, ["1"]);

    [string, int[], map<int>] jsonVal5 = ["1", [], {"name": 1}];
    [string] val5 = check parseAsType(jsonVal5); 
    test:assertEquals(val5, ["1"]);
}

@test:Config
isolated function testProjectionInArrayForParseAsType() returns Error? {
    int[2] val1 = check parseAsType([1, 2, 3, 4, 5]);
    test:assertEquals(val1, [1, 2]);

    record {|
        int[] a;
    |} jsonVal2 = {
        "a": [1, 2, 3, 4, 5]
    };
    record {| int[2] a; |} val2 = check parseAsType(jsonVal2);
    test:assertEquals(val2, {a: [1, 2]});

    json jsonVal3 = {
        "a": [1, 2, 3, 4, 5],
        "b": [1, 2, 3, 4, 5]
    };
    record {| int[2] a; int[3] b; |} val3 = check parseAsType(jsonVal3);
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
    record {| record {| string name; int age; |}[1] employees; |} val4 = check parseAsType(jsonVal4);
    test:assertEquals(val4, {employees: [{name: "Prakanth", age: 26}]});

    [int, int, int, record {|int a;|}] jsonVal5 = [1, 2, 3, { a : 2 }];
    int[2] val5 = check parseAsType(jsonVal5);
    test:assertEquals(val5, [1, 2]);
}

@test:Config
isolated function testProjectionInRecordForParseAsType() returns Error? {
    json jsonVal1 = {"name": "John", "age": 30, "city": "New York"};
    record {| string name; string city; |} val1 = check parseAsType(jsonVal1);
    test:assertEquals(val1, {name: "John", city: "New York"});

    json jsonVal2 = {"name": "John", "age": "30", "city": "New York"};
    record {| string name; string city; |} val2 = check parseAsType(jsonVal2);
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
    record {| string name; string city; |} val3 = check parseAsType(jsonVal3);
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
    record {| string name; string city; |} val4 = check parseAsType(jsonVal4);
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
    record {| string name; string city; |} val5 = check parseAsType(jsonVal5);
    test:assertEquals(val5, {name: "John", city: "New York"});
}

@test:Config
isolated function testArrayOrTupleCaseForParseAsType() returns Error? {
    json jsonVal1 = [[1], 2.0];
    [[int], float] val1 = check parseAsType(jsonVal1);
    test:assertEquals(val1, [[1], 2.0]);

    json jsonVal2 = [[1, 2], 2.0];
    [[int, int], float] val2 = check parseAsType(jsonVal2);
    test:assertEquals(val2, [[1, 2], 2.0]);
    
    json jsonStr3 = [[1, 2], [2, 3]];
    int[][] val3 = check parseAsType(jsonStr3);
    test:assertEquals(val3, [[1, 2], [2, 3]]);

    json jsonVal4 = {"val" : [[1, 2], "2.0", 3.0, [5, 6]]};
    record {|
        [[int, int], string, float, [int, int]] val;
    |} val4 = check parseAsType(jsonVal4);
    test:assertEquals(val4, {val: [[1, 2], "2.0", 3.0, [5, 6]]});

    json jsonVal41 = {"val1" : [[1, 2], "2.0", 3.0, [5, 6]], "val2" : [[1, 2], "2.0", 3.0, [5, 6]]};
    record {|
        [[int, int], string, float, [int, int]] val1;
        [[int, int], string, float, [int, int]] val2;
    |} val41 = check parseAsType(jsonVal41);
    test:assertEquals(val41, {val1: [[1, 2], "2.0", 3.0, [5, 6]], val2: [[1, 2], "2.0", 3.0, [5, 6]]});

    json jsonVal5 = {"val" : [[1, 2], [2, 3]]};
    record {|
        int[][] val;
    |} val5 = check parseAsType(jsonVal5);
    test:assertEquals(val5, {val: [[1, 2], [2, 3]]});

    json jsonVal6 = [{"val" : [[1, 2], [2, 3]]}];
    [record {|int[][] val;|}] val6 = check parseAsType(jsonVal6);
    test:assertEquals(val6, [{val: [[1, 2], [2, 3]]}]);
}

@test:Config
isolated function testListFillerValuesWithParseAsType() returns Error? {
    int[2] jsonVal1 = check parseAsType([1]);
    test:assertEquals(jsonVal1, [1, 0]);
    
    [int, float, string, boolean] jsonVal2 = check parseAsType([1]);
    test:assertEquals(jsonVal2, [1, 0.0, "", false]);

    record {|
        float[3] A;
        [int, decimal, float, boolean] B;
    |} jsonVal3 = check parseAsType({A: [1], B: [1]});
    test:assertEquals(jsonVal3, {A: [1.0, 0.0, 0.0], B: [1, 0d, 0.0, false]});
}

@test:Config
isolated function testNameAnnotationWithParseAsType() returns Error? {
    json jsonContent =  {
        "id": 1,
        "title-name": "Harry Potter",
        "author-name": "J.K. Rowling"
    };

    Book2 book = check parseAsType(jsonContent);
    test:assertEquals(book.id, 1);
    test:assertEquals(book.title, "Harry Potter");
    test:assertEquals(book.author, "J.K. Rowling");
}

@test:Config {
    dataProvider: dataProviderForSubTypeIntPostiveCasesWithParseAsType
}
isolated function testSubTypeOfIntAsExpectedTypeWithParseAsType(json sourceData, typedesc<anydata> expType, anydata expectedResult) returns Error? {
    anydata val = check parseAsType(sourceData, {}, expType);
    test:assertEquals(val, expectedResult);
}

function dataProviderForSubTypeIntPostiveCasesWithParseAsType() returns [json, typedesc<anydata>, anydata][] {
    return [
        [255, byte, 255],
        [255, int:Unsigned8, 255],
        [0, byte, 0],
        [0, int:Unsigned8, 0],
        [127, int:Signed8, 127],
        [-128, int:Signed8, -128],
        [65535, int:Unsigned16, 65535],
        [0, int:Unsigned16, 0],
        [32767, int:Signed16, 32767],
        [-32768, int:Signed16, -32768],
        [4294967295, int:Unsigned32, 4294967295],
        [0, int:Unsigned32, 0],
        [2147483647, int:Signed32, 2147483647],
        [-2147483648, int:Signed32, -2147483648],
        [[255, 127, 32767, 2147483647, 255, 32767, 2147483647], [byte, int:Signed8, int:Signed16, int:Signed32, int:Unsigned8, int:Unsigned16, int:Unsigned32], [255, 127, 32767, 2147483647, 255, 32767, 2147483647]]
    ];
}

@test:Config
isolated function testSubTypeOfIntAsFieldTypeForParseAsType() returns error? {
    json jsonVal4 = {
        "a": 1,
        "b": 127,
        "c": 32767,
        "d": 2147483647,
        "e": 255,
        "f": 32767,
        "g": 2147483647
    };
    record {|
        byte a;
        int:Signed8 b;
        int:Signed16 c;
        int:Signed32 d;
        int:Unsigned8 e;
        int:Unsigned16 f;
        int:Unsigned32 g;
    |} val16 = check parseAsType(jsonVal4);
    test:assertEquals(val16, {a: 1, b: 127, c: 32767, d: 2147483647, e: 255, f: 32767, g: 2147483647});
}

@test:Config
isolated function testSingletonAsExpectedTypeForParseAsType() returns Error? {
    "1" val1 = check parseAsType("1");
    test:assertEquals(val1, "1");

    Singleton1 val2 = check parseAsType(1);
    test:assertEquals(val2, 1);

    SingletonUnion val3 = check parseAsType(2);
    test:assertEquals(val3, 2);

    () val4 = check parseAsType(null);
    test:assertEquals(val4, ());

    json jsonContent = {
        value: 1,
        id: "3"
    };
    SingletonInRecord val5 = check parseAsType(jsonContent);
    test:assertEquals(val5.id, "3");
    test:assertEquals(val5.value, 1);
}

@test:Config
isolated function testAnydataArrayAsExpTypeForParseAsType() returns Error? {
    json jsonVal1 = [[1], 2.0];
    anydata[] val1 = check parseAsType(jsonVal1);
    test:assertEquals(val1, [[1], 2.0]);

    json jsonVal2 = [["1", 2], 2.0];
    anydata[] val2 = check parseAsType(jsonVal2);
    test:assertEquals(val2, [["1", 2], 2.0]);

    json jsonVal3 = [["1", 2], [2, "3"]];
    anydata[] val3 = check parseAsType(jsonVal3);
    test:assertEquals(val3, [["1", 2], [2, "3"]]);

    json jsonVal4 = {val : [[1, 2], "2.0", 3.0, [5, 6]]};
    record {|
        anydata[] val;
    |} val4 = check parseAsType(jsonVal4);
    test:assertEquals(val4, {val: [[1, 2], "2.0", 3.0, [5, 6]]});

    json jsonVal41 = {val1 : [[1, 2], 2.0, 3.0, [5, 6]], val2 : [[1, 2], "2.0", 3.0, [5, 6]]};
    record {|
        anydata[] val1;
        anydata[] val2;
    |} val41 = check parseAsType(jsonVal41);
    test:assertEquals(val41, {val1: [[1, 2], 2.0, 3.0, [5, 6]], val2: [[1, 2], "2.0", 3.0, [5, 6]]});

    json jsonVal5 = {val : [["1", 2], [2, "3"]]};
    record {|
        anydata[] val;
    |} val5 = check parseAsType(jsonVal5);
    test:assertEquals(val5, {val: [["1", 2], [2, "3"]]});

    json jsonVal6 = [{val : [[1, 2], [2, "James"]]}];
    [record {|anydata[][] val;|}] val6 = check parseAsType(jsonVal6);
    test:assertEquals(val6, [{val: [[1, 2], [2, "James"]]}]);
}

@test:Config
isolated function testParseAsTypeNegative1() returns Error? {
    json jsonContent = {
        "id": 12,
        "name": "Anne",
        "address": {
            "street": "Main",
            "city": "94",
            "id": true
        }
    };

    RN|Error x = parseAsType(jsonContent);
    test:assertTrue(x is Error);
    test:assertEquals((<Error>x).message(), "incompatible value 'true' for type 'int' in field 'address.id'");
}

@test:Config
isolated function testParseAsTypeNegative2() returns Error? {
    json jsonContent = {
        "id": 12
    };

    RN2|Error x = parseAsType(jsonContent);
    test:assertTrue(x is Error);
    test:assertEquals((<Error>x).message(), "required field 'name' not present in JSON");
}

@test:Config
isolated function testParseAsTypeNegative3() returns Error? {
    json jsonContent = {
        "id": 12,
        "name": "Anne",
        "address": {
            "street": "Main",
            "city": "94"
        }
    };

    RN|Error x = parseAsType(jsonContent);
    test:assertTrue(x is Error);
    test:assertEquals((<Error>x).message(), "required field 'id' not present in JSON");
}

@test:Config
isolated function testParseAsTypeNegative4() returns Error? {
    json jsonContent = {
        name: "John"
    };

    int|Error x = parseAsType(jsonContent);
    test:assertTrue(x is Error);
    test:assertEquals((<Error>x).message(), "incompatible expected type 'int' for value '{\"name\":\"John\"}'");

    Union|Error y = parseAsType(jsonContent);
    test:assertTrue(y is Error);
    test:assertEquals((<Error>y).message(), "incompatible expected type 'data.jsondata:Union' for value '{\"name\":\"John\"}'");

    table<RN2>|Error z = parseAsType(jsonContent);
    test:assertTrue(z is Error);
    test:assertEquals((<Error>z).message(), "invalid type 'table<data.jsondata:RN2>' expected 'anydata'");

    RN2|Error a = parseAsType("1");
    test:assertTrue(a is Error);
    test:assertEquals((<Error>a).message(), "incompatible expected type 'data.jsondata:RN2' for value '1'");

    string|Error b = parseAsType(1);
    test:assertTrue(b is Error);
    test:assertEquals((<Error>b).message(), "incompatible expected type 'string' for value '1'");
}

@test:Config
isolated function testParseAsTypeNegative6() {
    json jsonContent = {
        "street": "Main",
        "city": "Mahar",
        "house": [94, [1, 3, "4"]]
    };

    TestArr3|Error x = parseAsType(jsonContent);
    test:assertTrue(x is Error);
    test:assertEquals((<Error>x).message(), "incompatible value '4' for type 'int' in field 'house'");
}

@test:Config
isolated function testDuplicateFieldInRecordTypeWithParseAsType() returns Error? {
    json jsonContent = string `{
        "title": "Clean Code",
        "author": "Robert C. Martin",
        `;

    BookN|Error x = parseAsType(jsonContent);
    test:assertTrue(x is Error);
    test:assertEquals((<Error>x).message(), "duplicate field 'author'");
}

@test:Config
isolated function testProjectionInArrayNegativeForParseAsType() {
    [int, int, int, record {|int a;|}] jsonVal5 = [1, 2, 3, { a : 2 }];
    int[]|Error val5 = parseAsType(jsonVal5);
    test:assertTrue(val5 is Error);
    test:assertEquals((<Error>val5).message(), "incompatible expected type 'int' for value '{\"a\":2}'");
}

@test:Config {
    dataProvider: dataProviderForSubTypeOfIntNegativeTestForParseAsType
}
isolated function testSubTypeOfIntAsExptypeWithParseAsTypeNegative(json sourceData, typedesc<anydata> expType, string expectedError) {
    anydata|Error result = parseAsType(sourceData, {}, expType);
    test:assertTrue(result is Error);
    test:assertEquals((<Error>result).message(), expectedError);
}

function dataProviderForSubTypeOfIntNegativeTestForParseAsType() returns [json, typedesc<anydata>, string][] {
    string incompatibleStr = "incompatible expected type ";
    return [
        [256, byte, incompatibleStr + "'byte' for value '256'"],
        [-1, byte, incompatibleStr + "'byte' for value '-1'"],
        [128, int:Signed8, incompatibleStr + "'lang.int:Signed8' for value '128'"],
        [-129, int:Signed8, incompatibleStr + "'lang.int:Signed8' for value '-129'"],
        [256, int:Unsigned8, incompatibleStr + "'lang.int:Unsigned8' for value '256'"],
        [-1, int:Unsigned8, incompatibleStr + "'lang.int:Unsigned8' for value '-1'"],
        [32768, int:Signed16, incompatibleStr + "'lang.int:Signed16' for value '32768'"],
        [-32769, int:Signed16, incompatibleStr + "'lang.int:Signed16' for value '-32769'"],
        [65536, int:Unsigned16, incompatibleStr + "'lang.int:Unsigned16' for value '65536'"],
        [-1, int:Unsigned16, incompatibleStr + "'lang.int:Unsigned16' for value '-1'"],
        [2147483648, int:Signed32, incompatibleStr + "'lang.int:Signed32' for value '2147483648'"],
        [-2147483649, int:Signed32, incompatibleStr + "'lang.int:Signed32' for value '-2147483649'"],
        [4294967296, int:Unsigned32, incompatibleStr + "'lang.int:Unsigned32' for value '4294967296'"],
        [-1, int:Unsigned32, incompatibleStr + "'lang.int:Unsigned32' for value '-1'"]
    ];
}

@test:Config
isolated function testRecordWithRestAsExpectedTypeForParseAsTypeNegative() {
    json jsonVal = {
        id: 1,
        name: "Anne",
        measurements: {
            height: 5.5,
            weight: 60,
            shoeSize: "7"
        }
    };

    PersonA|error val = parseAsType(jsonVal);
    test:assertTrue(val is error);
    test:assertEquals((<error>val).message(), "incompatible value '7' for type 'int' in field 'measurements'");
}

type ReadonlyFieldsRec1 record {|
    readonly int id;
|};

type ReadonlyFieldsRec2 record {
    readonly int id;
};

type ReadonlyFieldsRec3 record {|
    readonly int id;
    readonly string name;
|};

type ReadonlyFieldsRec4 record {
    readonly int id;
    readonly string name;
};

type ReadonlyFieldsRec5 record {|
    readonly int id;
    readonly ReadonlyFieldsRec4 userDetails;
|};

type ReadonlyFieldsRec6 record {
    readonly int id;
    readonly ReadonlyFieldsRec4 userDetails;
};

type ReadonlyFieldsRec7 record {|
    readonly int id;
    readonly ReadonlyFieldsRec3 userDetails;
|};

type ReadonlyFieldsRec8 record {
    readonly int id;
    readonly ReadonlyFieldsRec3 userDetails;
};

type ReadonlyFieldsRec9 record {|
    readonly int id;
    string name;
|};

type ReadonlyFieldsRec10 record {
    readonly int id;
    string name;
};

@test:Config
function testReadonlyFields() returns error? {
    json user = {"id": 4012, "name": "John Doe"};
    json user2 = {"id": 4012, "userDetails": user, age: 13};

    ReadonlyFieldsRec1 r1 = check parseAsType(user);
    test:assertEquals(r1, {id: 4012});
    test:assertEquals(r1.id, 4012);
    test:assertTrue(r1 is readonly);
    test:assertTrue(r1.id is readonly);
    
    ReadonlyFieldsRec2 r2 = check parseAsType(user);
    test:assertEquals(r2, {id: 4012, name: "John Doe"});
    test:assertEquals(r2.id, 4012);
    test:assertTrue(r2.id is readonly);
    
    ReadonlyFieldsRec3 r3 = check parseAsType(user);
    test:assertEquals(r3, {id: 4012, name: "John Doe"});
    test:assertEquals(r3.id, 4012);
    test:assertTrue(r3 is readonly);
    test:assertTrue(r3.id is readonly);

    ReadonlyFieldsRec4 r4 = check parseAsType(user);
    test:assertEquals(r4, {id: 4012, name: "John Doe"});
    test:assertEquals(r4.id, 4012);
    test:assertTrue(r4.id is readonly);

    ReadonlyFieldsRec5 r5 = check parseAsType(user2);
    test:assertEquals(r5, {id: 4012, userDetails: {id: 4012, name: "John Doe"}});
    test:assertEquals(r5.id, 4012);
    test:assertEquals(r5.userDetails, {id: 4012, name: "John Doe"});
    
    ReadonlyFieldsRec6 r6 = check parseAsType(user2);
    test:assertEquals(r6, {id: 4012, userDetails: {id: 4012, name: "John Doe"}, age: 13});
    test:assertEquals(r6.id, 4012);
    
    ReadonlyFieldsRec7 r7 = check parseAsType(user2);
    test:assertEquals(r7, {id: 4012, userDetails: {id: 4012, name: "John Doe"}});
    test:assertEquals(r7.id, 4012);
    test:assertTrue(r7 is readonly);
    test:assertTrue(r7.userDetails is readonly);

    ReadonlyFieldsRec8 r8 = check parseAsType(user2);
    test:assertEquals(r8, {id: 4012, userDetails: {id: 4012, name: "John Doe"}, age: 13});
    test:assertEquals(r8.id, 4012);

    ReadonlyFieldsRec9 r9 = check parseAsType(user);
    test:assertEquals(r9, {id: 4012, name: "John Doe"});
    test:assertEquals(r9.id, 4012);
    
    ReadonlyFieldsRec10 r10 = check parseAsType(user);
    test:assertEquals(r10, {id: 4012, name: "John Doe"});
    test:assertEquals(r10.id, 4012);
}

type ReadonlyFieldsRec11 record {|
    readonly int id;
    readonly string taxNo = "N/A";
|};

type ReadonlyFieldsRec12 record {
    readonly int id;
    readonly string taxNo = "N/A";
};

type ReadonlyFieldsRec13 record {|
    readonly int id;
    readonly string name;
    readonly string taxNo = "N/A";
|};

type ReadonlyFieldsRec14 record {
    readonly int id;
    readonly string name;
    readonly string taxNo = "N/A";
};

type ReadonlyFieldsRec15 record {|
    readonly int id;
    readonly ReadonlyFieldsRec4 userDetails;
    readonly string address = "N/A";
|};

type ReadonlyFieldsRec16 record {
    readonly int id;
    readonly ReadonlyFieldsRec4 userDetails;
    readonly string address = "N/A";
};

type ReadonlyFieldsRec17 record {|
    readonly int id;
    readonly ReadonlyFieldsRec3 userDetails;
    readonly string address = "N/A";
|};

type ReadonlyFieldsRec18 record {
    readonly int id;
    readonly ReadonlyFieldsRec3 userDetails;
    readonly string address = "N/A";
};

type ReadonlyFieldsRec19 record {|
    string name;
    readonly int id;
    readonly string taxNo = "N/A";
|};

type ReadonlyFieldsRec20 record {
    readonly string taxNo = "N/A";
    readonly int id;
    string name;
};

type ReadonlyFieldsRecWithSelectiveImmutable record {|
    readonly int id;
    readonly int[] ages;
    readonly string address = "N/A";
|};

type ReadonlyFieldsRecWithSelectiveImmutable2 record {|
    readonly int id;
    int[] ages;
    readonly string address = "N/A";
|};

@test:Config
function testReadonlyFieldsWithDefaultValues() returns error? {
    json user = {"id": 4012, "name": "John Doe"};
    json user2 = {"id": 4012, "userDetails": user};
    json user3 = {"id": 4012, "userDetails": user, taxNo: "1234", address: "Colombo", age: 19, name: "John Doe"};

    ReadonlyFieldsRec11 r1 = check parseAsType(user);
    test:assertEquals(r1, {id: 4012, taxNo: "N/A"});
    test:assertEquals(r1.taxNo, "N/A");
    
    ReadonlyFieldsRec12 r2 = check parseAsType(user);
    test:assertEquals(r2, {id: 4012, taxNo: "N/A", name: "John Doe"});
    test:assertEquals(r2.taxNo, "N/A");
    
    ReadonlyFieldsRec13 r3 = check parseAsType(user);
    test:assertEquals(r3, {id: 4012, taxNo: "N/A", name: "John Doe"});
    test:assertEquals(r3.taxNo, "N/A");

    ReadonlyFieldsRec14 r4 = check parseAsType(user);
    test:assertEquals(r4, {id: 4012, taxNo: "N/A", name: "John Doe"});

    ReadonlyFieldsRec15 r5 = check parseAsType(user2);
    test:assertEquals(r5, {id: 4012, userDetails: {id: 4012, name: "John Doe"}, address: "N/A"});
    
    ReadonlyFieldsRec16 r6 = check parseAsType(user2);
    test:assertEquals(r6, {id: 4012, userDetails: {id: 4012, name: "John Doe"}, address: "N/A"});
    
    ReadonlyFieldsRec17 r7 = check parseAsType(user2);
    test:assertEquals(r7, {id: 4012, userDetails: {id: 4012, name: "John Doe"}, address: "N/A"});

    ReadonlyFieldsRec18 r8 = check parseAsType(user2);
    test:assertEquals(r8, {id: 4012, userDetails: {id: 4012, name: "John Doe"}, address: "N/A"});

    ReadonlyFieldsRec19 r9 = check parseAsType(user);
    test:assertEquals(r9, {id: 4012, taxNo: "N/A", name: "John Doe"});
    r9.name = "Updated name";
    test:assertEquals(r9, {id: 4012, taxNo: "N/A", name: "Updated name"});
    
    ReadonlyFieldsRec20 r10 = check parseAsType(user);
    test:assertEquals(r10, {taxNo: "N/A", id: 4012, name: "John Doe"});

    ReadonlyFieldsRec20 r11 = check parseAsType(user3);
    test:assertEquals(r11, {"id": 4012, "userDetails": user, taxNo: "1234", address: "Colombo", age: 19, name: "John Doe"});
    r11.name = "Updated name";
    test:assertEquals(r11, {"id": 4012, "userDetails": user, taxNo: "1234", address: "Colombo", age: 19, name: "Updated name"});

    ReadonlyFieldsRecWithSelectiveImmutable r21 = check parseAsType({id: 1, ages: [21, 24, 27]});
    test:assertEquals(r21, {id: 1, ages: [21, 24, 27], address: "N/A"});
    test:assertTrue(r21.ages is readonly);

    ReadonlyFieldsRecWithSelectiveImmutable2 r22 = check parseAsType({id: 1, ages: [21, 24, 27]});
    test:assertEquals(r22, {id: 1, ages: [21, 24, 27], address: "N/A"});
}

@test:Config
function testNegativeReadonlyFields() returns error? {
    json user = {"a": 4012, "b": "John Doe"};
    json user2 = {"a": 4012, "b": user};
    json user3 = {"id": "string", "b": user};

    ReadonlyFieldsRec11|error r1 = parseAsType(user);
    test:assertTrue(r1 is Error);
    test:assertEquals((<error> r1).message(), "required field 'id' not present in JSON");

    ReadonlyFieldsRec11|error r2 = parseAsType(user3);
    test:assertTrue(r2 is Error);
    test:assertEquals((<error> r2).message(), "incompatible value 'string' for type 'int' in field 'id'");

    ReadonlyFieldsRec15|error r3 = parseAsType(user2);
    test:assertTrue(r3 is Error);
    test:assertEquals((<error> r3).message(), "required field 'id' not present in JSON");

    ReadonlyFieldsRec19|error r5 = parseAsType(user);
    test:assertTrue(r5 is Error);
    test:assertEquals((<error> r5).message(), "required field 'name' not present in JSON");
}

type ReadonlyFieldsRec21 record {|
    @Name {
        value: "id"
    }
    readonly int testId;
|};

type ReadonlyFieldsRec22 record {
    @Name {
        value: "id"
    }
    readonly int testId;

    @Name {
        value: "taxNo"
    }
    readonly string testTaxNo = "N/A";
};

type ReadonlyFieldsRec23 record {|
    @Name {
        value: "id"
    }
    readonly int testId;
    @Name {
        value: "name"
    }
    readonly string testName;
    @Name {
        value: "taxNo"
    }
    readonly string testTaxNo = "N/A";
|};

type ReadonlyFieldsRec24 record {|
    @Name {
        value: "id"
    }
    readonly int testId;
    @Name {
        value: "userDetails"
    }
    readonly ReadonlyFieldsRec3 testUserDetails;
    @Name {
        value: "address"
    }
    readonly string testAddress = "N/A";
|};

type ReadonlyFieldsRec25 record {|
    @Name {
        value: "id"
    }
    readonly int testId;
    @Name {
        value: "userDetails"
    }
    readonly ReadonlyFieldsRec23 testUserDetails;

    @Name {
        value: "address"
    }
    readonly string testAddress = "N/A";
|};

type ReadonlyFieldsRec26 record {
    @Name {
        value: "id"
    }
    readonly int testId;
    @Name {
        value: "userDetails"
    }
    readonly ReadonlyFieldsRec4 testUserDetails;

    @Name {
        value: "address"
    }
    readonly string testAddress = "N/A";
};

type ReadonlyFieldsRec27 record {|
    @Name {
        value: "name"
    }
    string testName;
    @Name {
        value: "id"
    }
    readonly int testId;
    @Name {
        value: "taxNo"
    }
    readonly string testTaxNo = "N/A";
|};

@test:Config
function testReadonlyFieldsWithNameAnnotation() returns error? {
    json user = {"id": 4012, "name": "John Doe"};
    json user2 = {"id": 4012, "userDetails": user, taxNo: "1234", address: "Colombo", age: 19, name: "John Doe"};

    ReadonlyFieldsRec21 r1 = check parseAsType(user);
    test:assertEquals(r1, {testId: 4012});

    ReadonlyFieldsRec22 r2 = check parseAsType(user);
    test:assertEquals(r2, {testId: 4012, testTaxNo: "N/A", name: "John Doe"});

    ReadonlyFieldsRec23 r3 = check parseAsType(user);
    test:assertEquals(r3, {testId: 4012, testTaxNo: "N/A", testName: "John Doe"});

    ReadonlyFieldsRec24 r4 = check parseAsType(user2);
    test:assertEquals(r4, {testId: 4012, testUserDetails: user, testAddress: "Colombo"});

    ReadonlyFieldsRec25 r5 = check parseAsType(user2);
    test:assertEquals(r5, {testId: 4012, testUserDetails: {testId: 4012, testName: "John Doe", testTaxNo: "N/A"}, testAddress: "Colombo"});

    ReadonlyFieldsRec26 r6 = check parseAsType(user2);
    test:assertEquals(r6, {testId: 4012, testUserDetails: user, testAddress: "Colombo", "taxNo":"1234","age":19, "name":"John Doe"});

    ReadonlyFieldsRec27 r7 = check parseAsType(user);
    test:assertEquals(r7, {testId: 4012, testTaxNo: "N/A", testName: "John Doe"});
}
