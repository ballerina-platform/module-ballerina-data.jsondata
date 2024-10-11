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
    dataProvider: basicTypeDataProviderForParseString
}
isolated function testJsonStringToBasicTypes(string sourceData, typedesc<anydata> expType,
        anydata expectedData) returns Error? {
    anydata val1 = check parseString(sourceData, {}, expType);
    test:assertEquals(val1, expectedData);
}

function basicTypeDataProviderForParseString() returns [string, typedesc<anydata>, anydata][] {
    return [
        ["5", int, 5],
        ["5.5", float, 5.5],
        ["5.5", decimal, 5.5d],
        ["\"hello\"", string, "hello"],
        ["true", boolean, true],
        [string `"a"`, string:Char, "a"],
        [string `"a"`, anydata, "a"],
        [string `"a"`, json, "a"]
    ];
}

@test:Config
isolated function testNilAsExpectedTypeWithParseString() returns error? {
    () val = check parseString("null");
    test:assertEquals(val, ());
}

@test:Config
isolated function testSimpleJsonStringToRecord() returns Error? {
    string j = string `{"a": "hello", "b": 1}`;

    SimpleRec1 recA = check parseString(j);
    test:assertEquals(recA.a, "hello");
    test:assertEquals(recA.b, 1);

    SimpleRec2 recB = check parseString(j);
    test:assertEquals(recB.a, "hello");
    test:assertEquals(recB.b, 1);

    OpenRecord recC = check parseString(j);
    test:assertEquals(recC.get("a"), "hello");
    test:assertEquals(recC.get("b"), 1);
}

type ReadOnlyUser readonly & record {|
    int id;
|};

@test:Config
isolated function testSimpleJsonStringToRecord2() returns Error? {
    string user = string `{"id": 4012}`;
    ReadOnlyUser r = check parseString(user);
    test:assertEquals(r, {id: 4012});
}

public type UserId readonly & int;

public type UserName readonly & record {
    string firstname;
    string lastname;
};

type ReadOnlyUser2 readonly & record {|
    UserId id;
    UserName name;
    int age;
|};

@test:Config
isolated function testSimpleJsonStringToRecord3() returns Error? {
    string user = string `{"id": 4012, "name": {"firstname": "John", "lastname": "Doe"}, "age": 27}`;
    ReadOnlyUserRecord2 r = check parseString(user);
    test:assertEquals(r, {id: 4012, age: 27, name: {firstname: "John", lastname: "Doe"}});
}

@test:Config
isolated function testSimpleJsonStringToRecordWithProjection() returns Error? {
    string str = string `{"a": "hello", "b": 1}`;

    record {|string a;|} recA = check parseString(str);
    test:assertEquals(recA.length(), 1);
    test:assertEquals(recA.a, "hello");
    test:assertEquals(recA, {"a": "hello"});
}

@test:Config
isolated function testNestedJsonStringToRecord() returns Error? {
    string str = string `{
        "a": "hello",
        "b": 1,
        "c": {
            "d": "world",
            "e": 2
        }
    }`;

    NestedRecord1 recA = check parseString(str);
    test:assertEquals(recA.length(), 3);
    test:assertEquals(recA.a, "hello");
    test:assertEquals(recA.b, 1);
    test:assertEquals(recA.c.length(), 2);
    test:assertEquals(recA.c.d, "world");
    test:assertEquals(recA.c.e, 2);

    NestedRecord2 recB = check parseString(str);
    test:assertEquals(recB.length(), 3);
    test:assertEquals(recB.a, "hello");
    test:assertEquals(recB.b, 1);
    test:assertEquals(recB.c.length(), 2);
    test:assertEquals(recB.c.d, "world");
    test:assertEquals(recB.c.e, 2);

    OpenRecord recC = check parseString(str);
    test:assertEquals(recC.get("a"), "hello");
    test:assertEquals(recC.get("b"), 1);
    test:assertEquals(recC.get("c"), {d: "world", e: 2});
}

@test:Config
isolated function testNestedJsonStringToRecordWithProjection() returns Error? {
    string str = string `{
        "a": "hello",
        "b": 1,
        "c": {
            "d": "world",
            "e": 2
        }
    }`;

    record {|string a; record {|string d;|} c;|} recA = check parseString(str);
    test:assertEquals(recA.a, "hello");
    test:assertEquals(recA.c.d, "world");
    test:assertEquals(recA, {"a": "hello", "c": {"d": "world"}});
}

@test:Config
isolated function testJsonStringToRecordWithOptionalFields() returns Error? {
    string str = string `{"a": "hello"}`;

    record {|string a; int b?;|} recA = check parseString(str);
    test:assertEquals(recA.length(), 1);
    test:assertEquals(recA.a, "hello");
    test:assertEquals(recA.b, ());
}

@test:Config
isolated function testJsonStringToRecordWithOptionalFieldsWithProjection() returns Error? {
    string str = string `{
        "a": "hello",
        "b": 1,
        "c": {
            "d": "world",
            "e": 2
        }
    }`;

    record {|string a; record {|string d; int f?;|} c;|} recA = check parseString(str);
    test:assertEquals(recA.a, "hello");
    test:assertEquals(recA.c.d, "world");
    test:assertEquals(recA, {"a": "hello", "c": {"d": "world"}});
}

@test:Config
isolated function testParseString1() returns Error? {
    string str = string `{
        "id": 2,
        "name": "Anne",
        "address": {
            "street": "Main",
            "city": "94"
        }
    }`;

    R x = check parseString(str);
    test:assertEquals(x.id, 2);
    test:assertEquals(x.name, "Anne");
    test:assertEquals(x.address.street, "Main");
    test:assertEquals(x.address.city, "94");
}

@test:Config
isolated function testMapTypeAsFieldTypeInRecordForJsonString() returns Error? {
    string str = string `{
        "employees": {
            "John": "Manager",
            "Anne": "Developer"
        }
    }`;

    Company x = check parseString(str);
    test:assertEquals(x.employees["John"], "Manager");
    test:assertEquals(x.employees["Anne"], "Developer");
}

@test:Config
isolated function testParseString2() returns Error? {
    string str = string `{
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
    }`;

    Person x = check parseString(str);
    test:assertEquals(x.length(), 3);
    test:assertEquals(x.name, "John");
    test:assertEquals(x.age, 30);
    test:assertEquals(x.address.length(), 3);
    test:assertEquals(x.address.street, "123 Main St");
    test:assertEquals(x.address.zipcode, 10001);
    test:assertEquals(x.address.coordinates.length(), 2);
    test:assertEquals(x.address.coordinates.latitude, 40.7128);
    test:assertEquals(x.address.coordinates.longitude, -74.0060);
}

@test:Config
isolated function testParseString3() returns Error? {
    string str = string `{
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
            "month": "4"
        }
    }`;

    Book x = check parseString(str);
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
isolated function testParseString4() returns Error? {
    string str = string `{
        "name": "School Twelve",
        "city": 23,
        "number": 12,
        "section": 2,
        "flag": true,
        "tp": 12345
    }`;

    School x = check parseString(str);
    test:assertEquals(x.length(), 6);
    test:assertEquals(x.name, "School Twelve");
    test:assertEquals(x.number, 12);
    test:assertEquals(x.flag, true);
    test:assertEquals(x["section"], 2);
    test:assertEquals(x["tp"], 12345);
}

@test:Config
isolated function testParseString5() returns Error? {
    string str = string `{
        "intValue": 10,
        "floatValue": 10.5,
        "stringValue": "test",
        "decimalValue": 10.50,
        "doNotParse": "abc"
    }`;

    TestRecord x = check parseString(str);
    test:assertEquals(x.length(), 5);
    test:assertEquals(x.intValue, 10);
    test:assertEquals(x.floatValue, 10.5f);
    test:assertEquals(x.stringValue, "test");
    test:assertEquals(x.decimalValue, 10.50d);
    test:assertEquals(x["doNotParse"], "abc");
}

@test:Config
isolated function testParseString6() returns Error? {
    string str = string `{
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
    }`;

    Class x = check parseString(str);
    test:assertEquals(x.length(), 5);
    test:assertEquals(x.id, 1);
    test:assertEquals(x.name, "Class A");
    test:assertEquals(x.student.length(), 3);
    test:assertEquals(x.student.id, 2);
    test:assertEquals(x.student.name, "John Doe");
    test:assertEquals(x.student.school.length(), 2);
    test:assertEquals(x.student.school.name, "ABC School");
    test:assertEquals(x.student.school.address.length(), 2);
    test:assertEquals(x.student.school.address.street, "Main St");
    test:assertEquals(x.student.school.address.city, "New York");
    test:assertEquals(x.teacher.length(), 2);
    test:assertEquals(x.teacher.id, 3);
    test:assertEquals(x.teacher.name, "Jane Smith");
    test:assertEquals(x.monitor, ());
}

@test:Config
isolated function testParseString7() returns Error? {
    string nestedJsonStr = string `{
        "intValue": 5,
        "floatValue": 2.5,
        "stringValue": "nested",
        "decimalValue": 5.00
    }`;

    string str = string `{
        "intValue": 10,
        "nested1": ${nestedJsonStr}
    }`;

    TestRecord2 x = check parseString(str);
    test:assertEquals(x.length(), 2);
    test:assertEquals(x.intValue, 10);
    test:assertEquals(x.nested1.length(), 4);
    test:assertEquals(x.nested1.intValue, 5);
}

@test:Config
isolated function testParseString8() returns Error? {
    string str = string `{
        "street": "Main",
        "city": "Mahar",
        "house": 94
    }`;

    TestR x = check parseString(str);
    test:assertEquals(x.street, "Main");
    test:assertEquals(x.city, "Mahar");
}

@test:Config
isolated function testParseString9() returns Error? {
    string str = string `{
        "street": "Main",
        "city": "Mahar",
        "houses": [94, 95, 96]
    }`;

    TestArr1 x = check parseString(str);
    test:assertEquals(x.length(), 3);
    test:assertEquals(x.street, "Main");
    test:assertEquals(x.city, "Mahar");
    test:assertEquals(x.houses, [94, 95, 96]);
}

@test:Config
isolated function testParseString10() returns Error? {
    string str = string `{
        "street": "Main",
        "city": 11,
        "house": [94, "Gedara"]
    }`;

    TestArr2 x = check parseString(str);
    test:assertEquals(x.length(), 3);
    test:assertEquals(x.street, "Main");
    test:assertEquals(x.city, 11);
    test:assertEquals(x.house, [94, "Gedara"]);
}

@test:Config
isolated function testParseString11() returns Error? {
    string str = string `{
        "street": "Main",
        "city": "Mahar",
        "house": [94, [1, 2, 3]]
    }`;

    TestArr3 x = check parseString(str);
    test:assertEquals(x.length(), 3);
    test:assertEquals(x.street, "Main");
    test:assertEquals(x.city, "Mahar");
    test:assertEquals(x.house, [94, [1, 2, 3]]);
}

@test:Config
isolated function testParseString12() returns Error? {
    string str = string `{
        "street": "Main",
        "city": {
            "name": "Mahar",
            "code": 94
        },
        "flag": true
    }`;

    TestJson x = check parseString(str);
    test:assertEquals(x.length(), 3);
    test:assertEquals(x.street, "Main");
    test:assertEquals(x.city, {"name": "Mahar", "code": 94});
}

@test:Config
isolated function testParseString13() returns Error? {
    string str = string `{
        "street": "Main",
        "city": "Mahar",
        "house": [94, [1, 3, 4]]
    }`;

    TestArr3 x = check parseString(str);
    test:assertEquals(x.length(), 3);
    test:assertEquals(x.street, "Main");
    test:assertEquals(x.city, "Mahar");
    test:assertEquals(x.house, [94, [1, 3, 4]]);
}

@test:Config
isolated function testParseString14() returns Error? {
    string str = string `{
        "id": 12,
        "name": "Anne",
        "address": {
            "id": 34,
            "city": "94",
            "street": "York road"
        }
    }`;

    RN x = check parseString(str);
    test:assertEquals(x.length(), 3);
    test:assertEquals(x.id, 12);
    test:assertEquals(x.name, "Anne");
    test:assertEquals(x.address.length(), 3);
    test:assertEquals(x.address.id, 34);
    test:assertEquals(x.address.city, "94");
    test:assertEquals(x.address.street, "York road");
}

@test:Config
isolated function testParseString15() returns Error? {
    string str = string `[1, 2, 3]`;

    IntArr x = check parseString(str);
    test:assertEquals(x, [1, 2, 3]);
}

@test:Config
isolated function testParseString16() returns Error? {
    string str = string `[1, "abc", [3, 4.0]]`;

    Tuple x = check parseString(str);
    test:assertEquals(x, [1, "abc", [3, 4.0]]);
}

@test:Config
isolated function testParseString17() returns Error? {
    string str = string `{
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
    }`;

    TestJson x = check parseString(str);
    test:assertEquals(x.length(), 3);
    test:assertEquals(x.street, "Main");
    test:assertEquals(x.city, {"name": "Mahar", "code": 94, "internal": {"id": 12, "agent": "Anne"}});
}

@test:Config
isolated function testParseString18() returns Error? {
    string str = string `{
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
    }`;

    Library x = check parseString(str);
    test:assertEquals(x.books.length(), 2);
    test:assertEquals(x.books[0].title, "The Great Gatsby");
    test:assertEquals(x.books[0].author, "F. Scott Fitzgerald");
    test:assertEquals(x.books[1].title, "The Grapes of Wrath");
    test:assertEquals(x.books[1].author, "John Steinbeck");
}

type LibraryB record {
    [BookA, BookA] books;
};

type LibraryC record {|
    [BookA, BookA...] books;
|};

@test:Config
isolated function testParseString19() returns Error? {
    string str = string `{
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
    }`;

    LibraryB x = check parseString(str);
    test:assertEquals(x.books.length(), 2);
    test:assertEquals(x.books[0].title, "The Great Gatsby");
    test:assertEquals(x.books[0].author, "F. Scott Fitzgerald");
    test:assertEquals(x.books[1].title, "The Grapes of Wrath");
    test:assertEquals(x.books[1].author, "John Steinbeck");

    LibraryC y = check parseString(str);
    test:assertEquals(y.books.length(), 3);
    test:assertEquals(y.books[0].title, "The Great Gatsby");
    test:assertEquals(y.books[0].author, "F. Scott Fitzgerald");
    test:assertEquals(y.books[1].title, "The Grapes of Wrath");
    test:assertEquals(y.books[1].author, "John Steinbeck");
    test:assertEquals(y.books[2].title, "Binary Echoes: Unraveling the Digital Web");
    test:assertEquals(y.books[2].author, "Alexandra Quinn");
}

@test:Config
isolated function testParseString20() returns Error? {
    string str1 = string `{
        "a": {
            "c": "world",
            "d": "2"
        },
        "b": {
            "c": "world",
            "d": "2"
        }
    }`;

    record {|
        record {|
            string c;
            string d;
        |}...;
    |} val1 = check parseString(str1);
    test:assertEquals(val1.length(), 2);
    test:assertEquals(val1["a"]["c"], "world");
    test:assertEquals(val1["a"]["d"], "2");
    test:assertEquals(val1["b"]["c"], "world");
    test:assertEquals(val1["b"]["d"], "2");

    record {|
        map<string>...;
    |} val2 = check parseString(str1);
    test:assertEquals(val2.length(), 2);
    test:assertEquals(val2["a"]["c"], "world");
    test:assertEquals(val2["a"]["d"], "2");
    test:assertEquals(val2["b"]["c"], "world");
    test:assertEquals(val2["b"]["d"], "2");

    string str3 = string `{
        "a": [{
            "c": "world",
            "d": "2"
        }],
        "b": [{
            "c": "world",
            "d": "2"
        }]
    }`;

    record {|
        record {|
            string c;
            string d;
        |}[]...;
    |} val3 = check parseString(str3);
    test:assertEquals(val3.length(), 2);
    test:assertEquals(val3["a"], [
        {
            "c": "world",
            "d": "2"
        }
    ]);
    test:assertEquals(val3["b"], [
        {
            "c": "world",
            "d": "2"
        }
    ]);
}

@test:Config
isolated function testUnionTypeAsExpTypeForParseString() returns Error? {
    decimal|float val1 = check parseString("1.0");
    test:assertEquals(val1, 1.0);

    string str2 = string `{
        "a": "hello",
        "b": 1
    }`;

    record {|
        decimal|float b;
    |} val2 = check parseString(str2);
    test:assertEquals(val2.length(), 1);
    test:assertEquals(val2.b, 1.0);

    string str3 = string `{
        "a": {
            "b": 1,
            "d": {
                "e": false
            }
        },
        "c": 2
    }`;

    record {|
        record {|decimal|int b; record {|string|boolean e;|} d;|} a;
        decimal|float c;
    |} val3 = check parseString(str3);
    test:assertEquals(val3.length(), 2);
    test:assertEquals(val3.a.length(), 2);
    test:assertEquals(val3.a.b, 1);
    test:assertEquals(val3.a.d.e, false);
    test:assertEquals(val3.c, 2.0);
}

@test:Config
isolated function testAnydataAsExpTypeForParseString() returns Error? {
    string jsonStr1 = string `1`;
    anydata val1 = check parseString(jsonStr1);
    test:assertEquals(val1, 1);

    string jsonStr2 = string `{
        "a": "hello",
        "b": 1
    }`;

    anydata val2 = check parseString(jsonStr2);
    test:assertEquals(val2, {"a": "hello", "b": 1});

    string jsonStr3 = string `{
        "a": {
            "b": 1,
            "d": {
                "e": "hello"
            }
        },
        "c": 2
    }`;

    anydata val3 = check parseString(jsonStr3);
    test:assertEquals(val3, {"a": {"b": 1, "d": {"e": "hello"}}, "c": 2});

    string jsonStr4 = string `{
        "a": [{
            "b": 1,
            "d": {
                "e": "hello"
            }
        }],
        "c": 2
    }`;

    anydata val4 = check parseString(jsonStr4);
    test:assertEquals(val4, {"a": [{"b": 1, "d": {"e": "hello"}}], "c": 2});

    string str5 = string `[[1], 2]`;
    anydata val5 = check parseString(str5);
    test:assertEquals(val5, [[1], 2]);
}

@test:Config
isolated function testAnydataArrayAsExpTypeForParseString() returns Error? {
    string jsonStr1 = string `[["1"], 2.0]`;
    anydata[] val1 = check parseString(jsonStr1);
    test:assertEquals(val1, [["1"], 2.0]);

    string jsonStr2 = string `[["1", 2], 2.0]`;
    anydata[] val2 = check parseString(jsonStr2);
    test:assertEquals(val2, [["1", 2], 2.0]);

    string jsonStr3 = string `[["1", 2], [2, "3"]]`;
    anydata[] val3 = check parseString(jsonStr3);
    test:assertEquals(val3, [["1", 2], [2, "3"]]);

    string jsonStr4 = string `{"val" : [[1, 2], "2.0", 3.0, [5, 6]]}`;
    record {|
        anydata[] val;
    |} val4 = check parseString(jsonStr4);
    test:assertEquals(val4, {val: [[1, 2], "2.0", 3.0, [5, 6]]});

    string jsonStr41 = string `{"val1" : [[1, 2], "2.0", 3.0, [5, 6]], "val2" : [[1, 2], "2.0", 3.0, [5, 6]]}`;
    record {|
        anydata[] val1;
        anydata[] val2;
    |} val41 = check parseString(jsonStr41);
    test:assertEquals(val41, {val1: [[1, 2], "2.0", 3.0, [5, 6]], val2: [[1, 2], "2.0", 3.0, [5, 6]]});

    string jsonStr5 = string `{"val" : [["1", 2], [2, "3"]]}`;
    record {|
        anydata[] val;
    |} val5 = check parseString(jsonStr5);
    test:assertEquals(val5, {val: [["1", 2], [2, "3"]]});

    string jsonStr6 = string `[{"val" : [["1", 2], [2, "3"]]}]`;
    [record {|anydata[][] val;|}] val6 = check parseString(jsonStr6);
    test:assertEquals(val6, [{val: [["1", 2], [2, "3"]]}]);
}

@test:Config
isolated function testJsonAsExpTypeForParseString() returns Error? {
    string jsonStr1 = string `1`;
    json val1 = check parseString(jsonStr1);
    test:assertEquals(val1, 1);

    string jsonStr2 = string `{
        "a": "hello",
        "b": 1
    }`;

    json val2 = check parseString(jsonStr2);
    test:assertEquals(val2, {"a": "hello", "b": 1});

    string jsonStr3 = string `{
        "a": {
            "b": 1,
            "d": {
                "e": "hello"
            }
        },
        "c": 2
    }`;

    json val3 = check parseString(jsonStr3);
    test:assertEquals(val3, {"a": {"b": 1, "d": {"e": "hello"}}, "c": 2});

    string jsonStr4 = string `{
        "a": [{
            "b": 1,
            "d": {
                "e": "hello"
            }
        }],
        "c": 2
    }`;

    json val4 = check parseString(jsonStr4);
    test:assertEquals(val4, {"a": [{"b": 1, "d": {"e": "hello"}}], "c": 2});

    string str5 = string `[[1], 2]`;
    json val5 = check parseString(str5);
    test:assertEquals(val5, [[1], 2]);
}

@test:Config
isolated function testMapAsExpTypeForParseString() returns Error? {
    string jsonStr1 = string `{
        "a": "hello",
        "b": "1"
    }`;

    map<string> val1 = check parseString(jsonStr1);
    test:assertEquals(val1, {"a": "hello", "b": "1"});

    string jsonStr2 = string `{
        "a": "hello",
        "b": 1,
        "c": {
            "d": "world",
            "e": "2"
        }
    }`;
    record {|
        string a;
        int b;
        map<string> c;
    |} val2 = check parseString(jsonStr2);
    test:assertEquals(val2.a, "hello");
    test:assertEquals(val2.b, 1);
    test:assertEquals(val2.c, {"d": "world", "e": "2"});

    string jsonStr3 = string `{
        "a": {
            "c": "world",
            "d": "2"
        },
        "b": {
            "c": "world",
            "d": "2"
        }
    }`;

    map<map<string>> val3 = check parseString(jsonStr3);
    test:assertEquals(val3, {"a": {"c": "world", "d": "2"}, "b": {"c": "world", "d": "2"}});

    record {|
        map<string> a;
    |} val4 = check parseString(jsonStr3);
    test:assertEquals(val4.a, {"c": "world", "d": "2"});

    map<record {|
        string c;
        string d;
    |}> val5 = check parseString(jsonStr3);
    test:assertEquals(val5, {"a": {"c": "world", "d": "2"}, "b": {"c": "world", "d": "2"}});

    string jsonStr6 = string `{
        "a": "Kanth",
        "b": {
            "g": {
                "c": "hello",
                "d": "1"
            },
            "h": {
                "c": "world",
                "d": "2"
            }
        }
    }`;
    record {|
        string a;
        map<map<string>> b;
    |} val6 = check parseString(jsonStr6);
    test:assertEquals(val6.a, "Kanth");
    test:assertEquals(val6.b, {"g": {"c": "hello", "d": "1"}, "h": {"c": "world", "d": "2"}});
}

@test:Config
isolated function testProjectionInTupleForParseString() returns Error? {
    string str1 = string `["1", 2, "3", 4, 5, 8]`;
    [string, float] val1 = check parseString(str1);
    test:assertEquals(val1, ["1", 2.0]);

    string str2 = string `{
        "a": ["1", "2", 3, "4", 5, 8]
    }`;
    record {|[string, string] a;|} val2 = check parseString(str2);
    test:assertEquals(val2.a, ["1", "2"]);

    string str3 = string `[1, "4"]`;
    [float] val3 = check parseString(str3);
    test:assertEquals(val3, [1.0]);

    string str4 = string `["1", {}]`;
    [string] val4 = check parseString(str4);
    test:assertEquals(val4, ["1"]);

    string str5 = string `[1, [], {"name": 1}]`;
    [float] val5 = check parseString(str5);
    test:assertEquals(val5, [1.0]);
}

@test:Config
isolated function testProjectionInArrayForParseString() returns Error? {
    string strVal = string `[1, 2, 3, 4, 5]`;
    int[] val = check parseString(strVal);
    test:assertEquals(val, [1, 2, 3, 4, 5]);

    string strVal2 = string `[1, 2, 3, 4, 5]`;
    int[2] val2 = check parseString(strVal2);
    test:assertEquals(val2, [1, 2]);

    string strVal3 = string `{
        "a": [1, 2, 3, 4, 5]
    }`;
    record {|int[2] a;|} val3 = check parseString(strVal3);
    test:assertEquals(val3, {a: [1, 2]});

    string strVal4 = string `{
        "a": [1, 2, 3, 4, 5],
        "b": [1, 2, 3, 4, 5]
    }`;
    record {|int[2] a; int[3] b;|} val4 = check parseString(strVal4);
    test:assertEquals(val4, {a: [1, 2], b: [1, 2, 3]});

    string strVal5 = string `{
        "employees": [
            { "name": "Prakanth",
              "age": 26
            },
            { "name": "Kevin",
              "age": 25
            }
        ]
    }`;
    record {|record {|string name; int age;|}[1] employees;|} val5 = check parseString(strVal5);
    test:assertEquals(val5, {employees: [{name: "Prakanth", age: 26}]});

    string strVal6 = string `[1, 2, 3, { "a" : val_a }]`;
    int[3] val6 = check parseString(strVal6);
    test:assertEquals(val6, [1, 2, 3]);
}

@test:Config
isolated function testProjectionInRecordForParseString() returns Error? {
    string jsonStr1 = string `{"name": "John", "age": 30, "city": "New York"}`;
    record {|string name; string city;|} val1 = check parseString(jsonStr1);
    test:assertEquals(val1, {name: "John", city: "New York"});

    string jsonStr2 = string `{"name": "John", "age": "30", "city": "New York"}`;
    record {|string name; string city;|} val2 = check parseString(jsonStr2);
    test:assertEquals(val2, {name: "John", city: "New York"});

    string jsonStr3 = string `{ "name": "John", 
                                "company": {
                                    "name": "wso2", 
                                    "year": 2024,
                                    "addrees": {
                                        "street": "123",
                                        "city": "Berkeley"
                                        }
                                    },
                                "city": "New York" }`;
    record {|string name; string city;|} val3 = check parseString(jsonStr3);
    test:assertEquals(val3, {name: "John", city: "New York"});

    string jsonStr4 = string `{ "name": "John", 
                                "company": [{
                                    "name": "wso2", 
                                    "year": 2024,
                                    "addrees": {
                                        "street": "123",
                                        "city": "Berkeley"
                                        }
                                    }],
                                "city": "New York" }`;
    record {|string name; string city;|} val4 = check parseString(jsonStr4);
    test:assertEquals(val4, {name: "John", city: "New York"});

    string jsonStr5 = string `{ "name": "John", 
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
                                }`;
    record {|string name; string city;|} val5 = check parseString(jsonStr5);
    test:assertEquals(val5, {name: "John", city: "New York"});
}

@test:Config
isolated function testArrayOrTupleCaseForParseString() returns Error? {
    string jsonStr1 = string `[["1"], 2.0]`;
    [[string], float] val1 = check parseString(jsonStr1);
    test:assertEquals(val1, [["1"], 2.0]);

    string jsonStr2 = string `[["1", 2], "2.0"]`;
    [[string, float], string] val2 = check parseString(jsonStr2);
    test:assertEquals(val2, [["1", 2.0], "2.0"]);

    string jsonStr3 = string `[[1, 2], [2, 3]]`;
    int[][] val3 = check parseString(jsonStr3);
    test:assertEquals(val3, [[1, 2], [2, 3]]);

    string jsonStr4 = string `{"val" : [[1, 2], "2.0", 3.0, ["5", 6]]}`;
    record {|
        [[int, float], string, float, [string, int]] val;
    |} val4 = check parseString(jsonStr4);
    test:assertEquals(val4, {val: [[1, 2.0], "2.0", 3.0, ["5", 6]]});

    string jsonStr41 = string `{"val1" : [[1, 2], "2.0", 3.0, ["5", 6]], "val2" : [[1, 2], "2.0", 3.0, ["5", 6]]}`;
    record {|
        [[int, float], string, float, [string, int]] val1;
        [[float, float], string, float, [string, float]] val2;
    |} val41 = check parseString(jsonStr41);
    test:assertEquals(val41, {val1: [[1, 2.0], "2.0", 3.0, ["5", 6]], val2: [[1.0, 2.0], "2.0", 3.0, ["5", 6.0]]});

    string jsonStr5 = string `{"val" : [[1, 2], [2, 3]]}`;
    record {|
        int[][] val;
    |} val5 = check parseString(jsonStr5);
    test:assertEquals(val5, {val: [[1, 2], [2, 3]]});

    string jsonStr6 = string `[{"val" : [[1, 2], [2, 3]]}]`;
    [record {|int[][] val;|}] val6 = check parseString(jsonStr6);
    test:assertEquals(val6, [{val: [[1, 2], [2, 3]]}]);
}

@test:Config
isolated function testListFillerValuesWithParseString() returns Error? {
    int[2] jsonVal1 = check parseString("[1]");
    test:assertEquals(jsonVal1, [1, 0]);

    [int, float, string, boolean] jsonVal2 = check parseString("[1]");
    test:assertEquals(jsonVal2, [1, 0.0, "", false]);

    record {|
        float[3] A;
        [int, decimal, float, boolean] B;
    |} jsonVal3 = check parseString(string `{"A": [1], "B": [1]}`);
    test:assertEquals(jsonVal3, {A: [1.0, 0.0, 0.0], B: [1, 0d, 0.0, false]});
}

@test:Config
isolated function testSingletonAsExpectedTypeForParseString() returns Error? {
    "1" val1 = check parseString("\"1\"");
    test:assertEquals(val1, "1");

    Singleton1 val2 = check parseString("1");
    test:assertEquals(val2, 1);

    SingletonUnion val3 = check parseString("1");
    test:assertEquals(val3, 1);

    () val4 = check parseString("null");
    test:assertEquals(val4, ());

    string str5 = string `{
        "value": 1,
        "id": "3"
    }`;
    SingletonInRecord val5 = check parseString(str5);
    test:assertEquals(val5.id, "3");
    test:assertEquals(val5.value, 1);
}

@test:Config
function testDuplicateKeyInTheStringSource() returns Error? {
    string str = string `{
        "id": 1,
        "name": "Anne",
        "id": 2
    }`;

    record {
        int id;
        string name;
    } employee = check parseString(str);
    test:assertEquals(employee.length(), 2);
    test:assertEquals(employee.id, 2);
    test:assertEquals(employee.name, "Anne");
}

@test:Config
function testNameAnnotationWithParseString() returns Error? {
    string jsonStr = string `{
        "id": 1,
        "title-name": "Harry Potter",
        "author-name": "J.K. Rowling"
    }`;

    Book2 book = check parseString(jsonStr);
    test:assertEquals(book.id, 1);
    test:assertEquals(book.title, "Harry Potter");
    test:assertEquals(book.author, "J.K. Rowling");
}

@test:Config
isolated function testByteAsExpectedTypeForParseString() returns Error? {
    byte val1 = check parseString("1");
    test:assertEquals(val1, 1);

    [byte, int] val2 = check parseString("[255, 2000]");
    test:assertEquals(val2, [255, 2000]);

    string str4 = string `{
        "id": 1,
        "name": "Anne",
        "address": {
            "street": "Main",
            "city": "94",
            "id": 2
        }
    }`;

    record {
        byte id;
        string name;
        record {
            string street;
            string city;
            byte id;
        } address;
    } val4 = check parseString(str4);
    test:assertEquals(val4.length(), 3);
    test:assertEquals(val4.id, 1);
    test:assertEquals(val4.name, "Anne");
    test:assertEquals(val4.address.length(), 3);
    test:assertEquals(val4.address.street, "Main");
    test:assertEquals(val4.address.city, "94");
    test:assertEquals(val4.address.id, 2);
}

@test:Config
isolated function testSignedInt8AsExpectedTypeForParseString() returns Error? {
    int:Signed8 val1 = check parseString("-128");
    test:assertEquals(val1, -128);

    int:Signed8 val2 = check parseString("127");
    test:assertEquals(val2, 127);

    [int:Signed8, int] val3 = check parseString("[127, 2000]");
    test:assertEquals(val3, [127, 2000]);

    string str4 = string `{
        "id": 100,
        "name": "Anne",
        "address": {
            "street": "Main",
            "city": "94",
            "id": -2
        }
    }`;

    record {
        int:Signed8 id;
        string name;
        record {
            string street;
            string city;
            int:Signed8 id;
        } address;
    } val4 = check parseString(str4);
    test:assertEquals(val4.length(), 3);
    test:assertEquals(val4.id, 100);
    test:assertEquals(val4.name, "Anne");
    test:assertEquals(val4.address.length(), 3);
    test:assertEquals(val4.address.street, "Main");
    test:assertEquals(val4.address.city, "94");
    test:assertEquals(val4.address.id, -2);
}

@test:Config
isolated function testSignedInt16AsExpectedTypeForParseString() returns Error? {
    int:Signed16 val1 = check parseString("-32768");
    test:assertEquals(val1, -32768);

    int:Signed16 val2 = check parseString("32767");
    test:assertEquals(val2, 32767);

    [int:Signed16, int] val3 = check parseString("[32767, -324234]");
    test:assertEquals(val3, [32767, -324234]);

    string str4 = string `{
        "id": 100,
        "name": "Anne",
        "address": {
            "street": "Main",
            "city": "94",
            "id": -2
        }
    }`;

    record {
        int:Signed16 id;
        string name;
        record {
            string street;
            string city;
            int:Signed16 id;
        } address;
    } val4 = check parseString(str4);
    test:assertEquals(val4.length(), 3);
    test:assertEquals(val4.id, 100);
    test:assertEquals(val4.name, "Anne");
    test:assertEquals(val4.address.length(), 3);
    test:assertEquals(val4.address.street, "Main");
    test:assertEquals(val4.address.city, "94");
    test:assertEquals(val4.address.id, -2);
}

@test:Config
isolated function testSignedInt32AsExpectedTypeForParseString() returns Error? {
    int:Signed32 val1 = check parseString("-2147483648");
    test:assertEquals(val1, -2147483648);

    int:Signed32 val2 = check parseString("2147483647");
    test:assertEquals(val2, 2147483647);

    int:Signed32[] val3 = check parseString("[2147483647, -2147483648]");
    test:assertEquals(val3, [2147483647, -2147483648]);

    string str4 = string `{
        "id": 2147483647,
        "name": "Anne",
        "address": {
            "street": "Main",
            "city": "94",
            "id": -2147483648
        }
    }`;

    record {
        int:Signed32 id;
        string name;
        record {
            string street;
            string city;
            int:Signed32 id;
        } address;
    } val4 = check parseString(str4);
    test:assertEquals(val4.length(), 3);
    test:assertEquals(val4.id, 2147483647);
    test:assertEquals(val4.name, "Anne");
    test:assertEquals(val4.address.length(), 3);
    test:assertEquals(val4.address.street, "Main");
    test:assertEquals(val4.address.city, "94");
    test:assertEquals(val4.address.id, -2147483648);
}

@test:Config
isolated function testUnSignedInt8AsExpectedTypeForParseString() returns Error? {
    int:Unsigned8 val1 = check parseString("255");
    test:assertEquals(val1, 255);

    int:Unsigned8 val2 = check parseString("0");
    test:assertEquals(val2, 0);

    int:Unsigned8[] val3 = check parseString("[0, 255]");
    test:assertEquals(val3, [0, 255]);

    string str4 = string `{
        "id": 0,
        "name": "Anne",
        "address": {
            "street": "Main",
            "city": "94",
            "id": 255
        }
    }`;

    record {
        int:Unsigned8 id;
        string name;
        record {
            string street;
            string city;
            int:Unsigned8 id;
        } address;
    } val4 = check parseString(str4);
    test:assertEquals(val4.length(), 3);
    test:assertEquals(val4.id, 0);
    test:assertEquals(val4.name, "Anne");
    test:assertEquals(val4.address.length(), 3);
    test:assertEquals(val4.address.street, "Main");
    test:assertEquals(val4.address.city, "94");
    test:assertEquals(val4.address.id, 255);
}

@test:Config
isolated function testUnSignedInt16AsExpectedTypeForParseString() returns Error? {
    int:Unsigned16 val1 = check parseString("65535");
    test:assertEquals(val1, 65535);

    int:Unsigned16 val2 = check parseString("0");
    test:assertEquals(val2, 0);

    int:Unsigned16[] val3 = check parseString("[0, 65535]");
    test:assertEquals(val3, [0, 65535]);

    string str4 = string `{
        "id": 0,
        "name": "Anne",
        "address": {
            "street": "Main",
            "city": "94",
            "id": 65535
        }
    }`;

    record {
        int:Unsigned16 id;
        string name;
        record {
            string street;
            string city;
            int:Unsigned16 id;
        } address;
    } val4 = check parseString(str4);
    test:assertEquals(val4.length(), 3);
    test:assertEquals(val4.id, 0);
    test:assertEquals(val4.name, "Anne");
    test:assertEquals(val4.address.length(), 3);
    test:assertEquals(val4.address.street, "Main");
    test:assertEquals(val4.address.city, "94");
    test:assertEquals(val4.address.id, 65535);
}

@test:Config
isolated function testUnSignedInt32AsExpectedTypeForParseString() returns Error? {
    int:Unsigned32 val1 = check parseString("4294967295");
    test:assertEquals(val1, 4294967295);

    int:Unsigned32 val2 = check parseString("0");
    test:assertEquals(val2, 0);

    int:Unsigned32[] val3 = check parseString("[0, 4294967295]");
    test:assertEquals(val3, [0, 4294967295]);

    string str4 = string `{
        "id": 0,
        "name": "Anne",
        "address": {
            "street": "Main",
            "city": "94",
            "id": 4294967295
        }
    }`;

    record {
        int:Unsigned32 id;
        string name;
        record {
            string street;
            string city;
            int:Unsigned32 id;
        } address;
    } val4 = check parseString(str4);
    test:assertEquals(val4.length(), 3);
    test:assertEquals(val4.id, 0);
    test:assertEquals(val4.name, "Anne");
    test:assertEquals(val4.address.length(), 3);
    test:assertEquals(val4.address.street, "Main");
    test:assertEquals(val4.address.city, "94");
    test:assertEquals(val4.address.id, 4294967295);
}

@test:Config
isolated function testUnalignedJsonContent() returns error? {
    string jsonStr = string `
{
                            "a"
                    : 
                    "hello",
                            "b": 
                    1
        }`;
    record {|
        string a;
        int b;
    |} val = check parseString(jsonStr);
    test:assertEquals(val.a, "hello");
    test:assertEquals(val.b, 1);
}

@test:Config
isolated function testNilableTypeAsFieldTypeForParseString() returns error? {
    string jsonStr1 = string `
    {
        "id": 0,
        "name": "Anne",
        "address": {
            "street": "Main",
            "city": "94",
            "id": 4294967295
        }
    }
    `;
    record {|
        int? id;
        string? name;
        anydata? address;
    |} val1 = check parseString(jsonStr1);
    test:assertEquals(val1.id, 0);
    test:assertEquals(val1.name, "Anne");
    test:assertEquals(val1.address, {street: "Main", city: "94", id: 4294967295});

    string jsonStr2 = string `{
        "company": "wso2",
        "employees": [
            { 
                "name": "Walter White",
                "age": 55
            },
            { 
                "name": "Jesse Pinkman",
                "age": 25
            }
        ]
    }`;
    record {|
        anydata? company;
        record {|
            string name;
            int age;
        |}?[] employees;
    |} val2 = check parseString(jsonStr2);
    test:assertEquals(val2.company, "wso2");
    test:assertEquals(val2.employees[0]?.name, "Walter White");
    test:assertEquals(val2.employees[0]?.age, 55);
    test:assertEquals(val2.employees[1]?.name, "Jesse Pinkman");
    test:assertEquals(val2.employees[1]?.age, 25);
}

@test:Config
isolated function testNilableTypeAsFieldTypeForParseAsType() returns error? {
    json jsonVal1 = {
        "id": 0,
        "name": "Anne",
        "address": {
            "street": "Main",
            "city": 94,
            "id": 4294967295
        }
    };
    record {|
        int? id;
        string? name;
        anydata? address;
    |} val1 = check parseAsType(jsonVal1);
    test:assertEquals(val1.id, 0);
    test:assertEquals(val1.name, "Anne");
    test:assertEquals(val1.address, {street: "Main", city: 94, id: 4294967295});

    json jsonVal2 = {
        "company": "wso2",
        "employees": [
            { 
                "name": "Walter White",
                "age": 55
            },
            { 
                "name": "Jesse Pinkman",
                "age": 25
            }
        ]
    };
    record {|
        anydata? company;
        record {|
            string name;
            int age;
        |}?[] employees;
    |} val2 = check parseAsType(jsonVal2);
    test:assertEquals(val2.company, "wso2");
    test:assertEquals(val2.employees[0]?.name, "Walter White");
    test:assertEquals(val2.employees[0]?.age, 55);
    test:assertEquals(val2.employees[1]?.name, "Jesse Pinkman");
    test:assertEquals(val2.employees[1]?.age, 25);
}

@test:Config
isolated function testEscapeCharacterCaseForParseString() returns error? {
    string jsonStr1 = string `
    {
        "A": "\\A_Field",
        "B": "\/B_Field",
        "C": "\"C_Field\"",
        "D": "\uD83D\uDE01",
        "E": "FIELD\nE",
        "F": "FIELD\rF",
        "G": "FIELD\tG",
        "H": ["\\A_Field", "\/B_Field", "\"C_Field\"", "\uD83D\uDE01", "FIELD\nE", "FIELD\rF", "FIELD\tG"]
    }
    `;
    OpenRecord val1 = check parseString(jsonStr1);
    test:assertEquals(val1, {
        A: "\\A_Field",
        B: "/B_Field",
        C: string `"C_Field"`,
        D: "😁",
        E: "FIELD\nE",
        F: "FIELD\rF",
        G: "FIELD\tG",
        H: ["\\A_Field", "/B_Field", string `"C_Field"`, "😁", "FIELD\nE", "FIELD\rF", "FIELD\tG"]
    });
}

@test:Config
isolated function testParseStringNegative1() returns Error? {
    string str = string `{
        "id": 12,
        "name": "Anne",
        "address": {
            "street": "Main",
            "city": "94",
            "id": true
        }
    }`;

    RN|Error x = parseString(str);
    test:assertTrue(x is Error);
    test:assertEquals((<Error>x).message(), "incompatible value 'true' for type 'int' in field 'address.id'");
}

@test:Config
isolated function testParseStringNegative2() returns Error? {
    string str = string `{
        "id": 12
    }`;

    RN2|Error x = parseString(str);
    test:assertTrue(x is Error);
    test:assertEquals((<Error>x).message(), "required field 'name' not present in JSON");
}

@test:Config
isolated function testParseStringNegative3() returns Error? {
    string str = string `{
        "id": 12,
        "name": "Anne",
        "address": {
            "street": "Main",
            "city": "94"
        }
    }`;

    RN|Error x = parseString(str);
    test:assertTrue(x is Error);
    test:assertEquals((<Error>x).message(), "required field 'id' not present in JSON");
}

@test:Config
isolated function testParseStringNegative4() returns Error? {
    string str = string `{
        "name": "John"
    }`;

    int|Error x = parseString(str);
    test:assertTrue(x is Error);
    test:assertEquals((<Error>x).message(), "invalid type 'int' expected 'map type'");

    Union|Error y = parseString(str);
    test:assertTrue(y is Error);
    test:assertEquals((<Error>y).message(), "incompatible expected type 'ballerina/data.jsondata:0:Union' for value '{\"name\":\"John\"}'");

    table<RN2>|Error z = parseString(str);
    test:assertTrue(z is Error);
    test:assertEquals((<Error>z).message(), "unsupported type 'table<data.jsondata:RN2>'");

    RN2|Error a = parseString("1");
    test:assertTrue(a is Error);
    test:assertEquals((<Error>a).message(), "incompatible expected type 'data.jsondata:RN2' for value '1'");
}

@test:Config
isolated function testDuplicateFieldInRecordTypeWithParseString() returns Error? {
    string str = string `{
        "title": "Clean Code",
        "author": "Robert C. Martin",
        `;

    BookN|Error x = parseString(str);
    test:assertTrue(x is Error);
    test:assertEquals((<Error>x).message(), "duplicate field 'author'");
}

@test:Config
isolated function testProjectionInArrayNegativeForParseString() {
    string strVal1 = string `[1, 2, 3, { "a" : val_a }]`;
    int[]|Error val1 = parseString(strVal1);
    test:assertTrue(val1 is Error);
    test:assertEquals((<Error>val1).message(), "invalid type 'int' expected 'map type'");
}

@test:Config {
    dataProvider: dataProviderForSubTypeOfIntNegativeTestForParseString
}
isolated function testSubTypeOfIntAsExptypeNegative(string sourceData, typedesc<anydata> expType, string expectedError) {
    anydata|Error err = parseString(sourceData, {}, expType);
    test:assertTrue(err is Error);
    test:assertEquals((<Error>err).message(), expectedError);
}

function dataProviderForSubTypeOfIntNegativeTestForParseString() returns [string, typedesc<anydata>, string][] {
    string incompatibleStr = "incompatible expected type ";
    return [
        ["256", byte, incompatibleStr + "'byte' for value '256'"],
        ["-1", byte, incompatibleStr + "'byte' for value '-1'"],
        ["128", int:Signed8, incompatibleStr + "'lang.int:Signed8' for value '128'"],
        ["-129", int:Signed8, incompatibleStr + "'lang.int:Signed8' for value '-129'"],
        ["256", int:Unsigned8, incompatibleStr + "'lang.int:Unsigned8' for value '256'"],
        ["-1", int:Unsigned8, incompatibleStr + "'lang.int:Unsigned8' for value '-1'"],
        ["32768", int:Signed16, incompatibleStr + "'lang.int:Signed16' for value '32768'"],
        ["-32769", int:Signed16, incompatibleStr + "'lang.int:Signed16' for value '-32769'"],
        ["65536", int:Unsigned16, incompatibleStr + "'lang.int:Unsigned16' for value '65536'"],
        ["-1", int:Unsigned16, incompatibleStr + "'lang.int:Unsigned16' for value '-1'"],
        ["2147483648", int:Signed32, incompatibleStr + "'lang.int:Signed32' for value '2147483648'"],
        ["-2147483649", int:Signed32, incompatibleStr + "'lang.int:Signed32' for value '-2147483649'"],
        ["4294967296", int:Unsigned32, incompatibleStr + "'lang.int:Unsigned32' for value '4294967296'"],
        ["-1", int:Unsigned32, incompatibleStr + "'lang.int:Unsigned32' for value '-1'"]
    ];
}

@test:Config
isolated function testEmptyJsonDocumentNegative() {
    string|Error err = parseString("");
    test:assertTrue(err is Error);
    test:assertEquals((<Error>err).message(), "'empty JSON document' at line: '1' column: '1'");
}

@test:Config
isolated function testRecordWithRestAsExpectedTypeForParseStringNegative() {
    string personStr = string `
    {
        "id": 1,
        "name": "Anne",
        "measurements": {
            "height": 5.5,
            "weight": 60
        }
    }`;

    PersonA|error val = parseString(personStr);
    test:assertTrue(val is error);
    test:assertEquals((<error>val).message(), "incompatible expected type 'int' for value '5.5'");
}

@test:Config
isolated function testConvertNonStringValueNegative() {
    string|Error err1 = parseString("null");
    test:assertTrue(err1 is Error);
    test:assertEquals((<Error>err1).message(), "incompatible expected type 'string' for value 'null'");

    string|Error err2 = parseString("true");
    test:assertTrue(err2 is Error);
    test:assertEquals((<Error>err2).message(), "incompatible expected type 'string' for value 'true'");

    boolean|Error err3 = parseString("True");
    test:assertTrue(err3 is Error);
    test:assertEquals((<Error>err3).message(), "incompatible expected type 'boolean' for value 'True'");

    boolean|Error err4 = parseString("False");
    test:assertTrue(err4 is Error);
    test:assertEquals((<Error>err4).message(), "incompatible expected type 'boolean' for value 'False'");

    ()|Error err5 = parseString("Null");
    test:assertTrue(err5 is Error);
    test:assertEquals((<Error>err5).message(), "incompatible expected type '()' for value 'Null'");

    ()|Error err6 = parseString("()");
    test:assertTrue(err6 is Error);
    test:assertEquals((<Error>err6).message(), "incompatible expected type '()' for value '()'");
}

@test:Config
isolated function testConvertStringValueNegative() {
    string:Char|Error err1 = parseString("\"abc\"");
    test:assertTrue(err1 is Error);
    test:assertEquals((<Error>err1).message(), "incompatible expected type 'lang.string:Char' for value 'abc'");

    ()|Error err2 = parseString("\"abc\"");
    test:assertTrue(err2 is Error);
    test:assertEquals((<Error>err2).message(), "incompatible expected type '()' for value 'abc'");

    "a"|Error err3 = parseString("\"abc\"");
    test:assertTrue(err3 is Error);
    test:assertEquals((<Error>err3).message(), "incompatible expected type '\"a\"' for value 'abc'");

    boolean|Error err4 = parseString("\"abc\"");
    test:assertTrue(err4 is Error);
    test:assertEquals((<Error>err4).message(), "incompatible expected type 'boolean' for value 'abc'");

    int|float|Error err5 = parseString("\"abc\"");
    test:assertTrue(err5 is Error);
    test:assertEquals((<Error>err5).message(), "incompatible expected type '(int|float)' for value 'abc'");

    float|Error err6 = parseString(string `1f`);
    test:assertTrue(err6 is Error);
    test:assertEquals((<Error>err6).message(), "incompatible expected type 'float' for value '1f'");

    float|Error err7 = parseString(string `1F`);
    test:assertTrue(err7 is Error);
    test:assertEquals((<Error>err7).message(), "incompatible expected type 'float' for value '1F'");

    float|Error err8 = parseString(string `1d`);
    test:assertTrue(err8 is Error);
    test:assertEquals((<Error>err8).message(), "incompatible expected type 'float' for value '1d'");

    float|Error err9 = parseString(string `1D`);
    test:assertTrue(err9 is Error);
    test:assertEquals((<Error>err9).message(), "incompatible expected type 'float' for value '1D'");
}
