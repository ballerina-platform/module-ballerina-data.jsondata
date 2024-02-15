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

// Possitive tests for fromJsonStringWithType() function.

@test:Config
isolated function testJsonStringToBasicTypes() returns error? {
    int val1 = check fromJsonStringWithType("5");
    test:assertEquals(val1, 5);

    float val2 = check fromJsonStringWithType("5.5");
    test:assertEquals(val2, 5.5);

    decimal val3 = check fromJsonStringWithType("5.5");
    test:assertEquals(val3, 5.5d);

    string val4 = check fromJsonStringWithType("hello");
    test:assertEquals(val4, "hello");

    boolean val5 = check fromJsonStringWithType("true");
    test:assertEquals(val5, true);

    () val6 = check fromJsonStringWithType("null");
    test:assertEquals(val6, null);
}

@test:Config
isolated function testSimpleJsonStringToRecord() returns error? {
    string j = string `{"a": "hello", "b": 1}`;

    record {|string a; int b;|} recA = check fromJsonStringWithType(j);
    test:assertEquals(recA.a, "hello");
    test:assertEquals(recA.b, 1);
}

@test:Config
isolated function testSimpleJsonStringToRecordWithProjection() returns error? {
    string str = string `{"a": "hello", "b": 1}`;

    record {|string a;|} recA = check fromJsonStringWithType(str);
    test:assertEquals(recA.length(), 1);
    test:assertEquals(recA.a, "hello");
    test:assertEquals(recA, {"a": "hello"});
}

@test:Config
isolated function testNestedJsonStringToRecord() returns error? {
    string str = string `{
        "a": "hello",
        "b": 1,
        "c": {
            "d": "world",
            "e": 2
        }
    }`;

    record {|string a; int b; record {|string d; int e;|} c;|} recA = check fromJsonStringWithType(str);
    test:assertEquals(recA.length(), 3);
    test:assertEquals(recA.a, "hello");
    test:assertEquals(recA.b, 1);
    test:assertEquals(recA.c.length(), 2);
    test:assertEquals(recA.c.d, "world");
    test:assertEquals(recA.c.e, 2);
}

@test:Config
isolated function testNestedJsonStringToRecordWithProjection() returns error? {
    string str = string `{
        "a": "hello",
        "b": 1,
        "c": {
            "d": "world",
            "e": 2
        }
    }`;

    record {|string a; record {|string d;|} c;|} recA = check fromJsonStringWithType(str);
    test:assertEquals(recA.a, "hello");
    test:assertEquals(recA.c.d, "world");
    test:assertEquals(recA, {"a": "hello", "c": {"d": "world"}});
}

@test:Config
isolated function testJsonStringToRecordWithOptionalFields() returns error? {
    string str = string `{"a": "hello"}`;

    record {|string a; int b?;|} recA = check fromJsonStringWithType(str);
    test:assertEquals(recA.length(), 1);
    test:assertEquals(recA.a, "hello");
    test:assertEquals(recA.b, null);
}

@test:Config
isolated function testJsonStringToRecordWithOptionalFieldsWithProjection() returns error? {
    string str = string `{
        "a": "hello",
        "b": 1,
        "c": {
            "d": "world",
            "e": 2
        }
    }`;

    record {|string a; record {|string d; int f?;|} c;|} recA = check fromJsonStringWithType(str);
    test:assertEquals(recA.a, "hello");
    test:assertEquals(recA.c.d, "world");
    test:assertEquals(recA, {"a": "hello", "c": {"d": "world"}});
}

@test:Config
isolated function testFromJsonStringWithType1() returns error? {
    string str = string `{
        "id": 2,
        "name": "Anne",
        "address": {
            "street": "Main",
            "city": "94"
        }
    }`;

    R x = check fromJsonStringWithType(str);
    test:assertEquals(x.id, 2);
    test:assertEquals(x.name, "Anne");
    test:assertEquals(x.address.street, "Main");
    test:assertEquals(x.address.city, "94");
}

@test:Config
isolated function testMapTypeAsFieldTypeInRecordForJsonString() returns error? {
    string str = string `{
        "employees": {
            "John": "Manager",
            "Anne": "Developer"
        }
    }`;

    Company x = check fromJsonStringWithType(str);
    test:assertEquals(x.employees["John"], "Manager");
    test:assertEquals(x.employees["Anne"], "Developer");
}

@test:Config
isolated function testFromJsonStringWithType2() returns error? {
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

    Person x = check fromJsonStringWithType(str);
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
isolated function testFromJsonStringWithType3() returns error? {
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
            "month": 4
        }
    }`;

    Book x = check fromJsonStringWithType(str);
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
isolated function testFromJsonStringWithType4() returns error? {
    string str = string `{
        "name": "School Twelve",
        "city": 23,
        "number": 12,
        "section": 2,
        "flag": true,
        "tp": 12345
    }`;

    School x = check fromJsonStringWithType(str);
    test:assertEquals(x.length(), 6);
    test:assertEquals(x.name, "School Twelve");
    test:assertEquals(x.number, 12);
    test:assertEquals(x.flag, true);
    test:assertEquals(x["section"], 2);
    test:assertEquals(x["tp"], 12345);
}

@test:Config
isolated function testFromJsonStringWithType5() returns error? {
    string str = string `{
        "intValue": 10,
        "floatValue": 10.5,
        "stringValue": "test",
        "decimalValue": 10.50,
        "doNotParse": "abc"
    }`;

    TestRecord x = check fromJsonStringWithType(str);
    test:assertEquals(x.length(), 5);
    test:assertEquals(x.intValue, 10);
    test:assertEquals(x.floatValue, 10.5f);
    test:assertEquals(x.stringValue, "test");
    test:assertEquals(x.decimalValue, 10.50d);
    test:assertEquals(x["doNotParse"], "abc");
}

@test:Config
isolated function testFromJsonStringWithType6() returns error? {
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

    Class x = check fromJsonStringWithType(str);
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
    test:assertEquals(x.monitor, null);
}

@test:Config
isolated function testFromJsonStringWithType7() returns error? {
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

    TestRecord2 x = check fromJsonStringWithType(str);
    test:assertEquals(x.length(), 2);
    test:assertEquals(x.intValue, 10);
    test:assertEquals(x.nested1.length(), 4);
    test:assertEquals(x.nested1.intValue, 5);
}

@test:Config
isolated function testFromJsonStringWithType8() returns error? {
    string str = string `{
        "street": "Main",
        "city": "Mahar",
        "house": 94
    }`;

    TestR x = check fromJsonStringWithType(str);
    test:assertEquals(x.street, "Main");
    test:assertEquals(x.city, "Mahar");
}

@test:Config
isolated function testFromJsonStringWithType9() returns error? {
    string str = string `{
        "street": "Main",
        "city": "Mahar",
        "houses": [94, 95, 96]
    }`;

    TestArr1 x = check fromJsonStringWithType(str);
    test:assertEquals(x.length(), 3);
    test:assertEquals(x.street, "Main");
    test:assertEquals(x.city, "Mahar");
    test:assertEquals(x.houses, [94, 95, 96]);
}

@test:Config
isolated function testFromJsonStringWithType10() returns error? {
    string str = string `{
        "street": "Main",
        "city": 11,
        "house": [94, "Gedara"]
    }`;

    TestArr2 x = check fromJsonStringWithType(str);
    test:assertEquals(x.length(), 3);
    test:assertEquals(x.street, "Main");
    test:assertEquals(x.city, 11);
    test:assertEquals(x.house, [94, "Gedara"]);
}

@test:Config
isolated function testFromJsonStringWithType11() returns error? {
    string str = string `{
        "street": "Main",
        "city": "Mahar",
        "house": [94, [1, 2, 3]]
    }`;

    TestArr3 x = check fromJsonStringWithType(str);
    test:assertEquals(x.length(), 3);
    test:assertEquals(x.street, "Main");
    test:assertEquals(x.city, "Mahar");
    test:assertEquals(x.house, [94, [1, 2, 3]]);
}

@test:Config
isolated function testFromJsonStringWithType12() returns error? {
    string str = string `{
        "street": "Main",
        "city": {
            "name": "Mahar",
            "code": 94
        },
        "flag": true
    }`;

    TestJson x = check fromJsonStringWithType(str);
    test:assertEquals(x.length(), 3);
    test:assertEquals(x.street, "Main");
    test:assertEquals(x.city, {"name": "Mahar", "code": 94});
}

@test:Config
isolated function testFromJsonStringWithType13() returns error? {
    string str = string `{
        "street": "Main",
        "city": "Mahar",
        "house": [94, [1, 3, "4"]]
    }`;

    TestArr3 x = check fromJsonStringWithType(str);
    test:assertEquals(x.length(), 3);
    test:assertEquals(x.street, "Main");
    test:assertEquals(x.city, "Mahar");
    test:assertEquals(x.house, [94, [1, 3, 4]]);
}

@test:Config
isolated function testFromJsoStringWithType14() returns error? {
    string str = string `{
        "id": 12,
        "name": "Anne",
        "address": {
            "id": 34,
            "city": "94",
            "street": "York road"
        }
    }`;

    RN x = check fromJsonStringWithType(str);
    test:assertEquals(x.length(), 3);
    test:assertEquals(x.id, 12);
    test:assertEquals(x.name, "Anne");
    test:assertEquals(x.address.length(), 3);
    test:assertEquals(x.address.id, 34);
    test:assertEquals(x.address.city, "94");
    test:assertEquals(x.address.street, "York road");
}

@test:Config
isolated function testFromJsonStringWithType15() returns error? {
    string str = string `[1, 2, 3]`;

    IntArr x = check fromJsonStringWithType(str);
    test:assertEquals(x, [1, 2, 3]);
}

@test:Config
isolated function testFromJsonStringWithType16() returns error? {
    string str = string `[1, "abc", [3, 4.0]]`;

    TUPLE x = check fromJsonStringWithType(str);
    test:assertEquals(x, [1, "abc", [3, 4.0]]);
}

@test:Config
isolated function testFromJsonStringWithType17() returns error? {
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

    TestJson x = check fromJsonStringWithType(str);
    test:assertEquals(x.length(), 3);
    test:assertEquals(x.street, "Main");
    test:assertEquals(x.city, {"name": "Mahar", "code": 94, "internal": {"id": 12, "agent": "Anne"}});
}

@test:Config
isolated function testFromJsonStringWithType18() returns error? {
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

    Library x = check fromJsonStringWithType(str);
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
isolated function testFromJsonStringWithType19() returns error? {
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

    LibraryB x = check fromJsonStringWithType(str);
    test:assertEquals(x.books.length(), 2);
    test:assertEquals(x.books[0].title, "The Great Gatsby");
    test:assertEquals(x.books[0].author, "F. Scott Fitzgerald");
    test:assertEquals(x.books[1].title, "The Grapes of Wrath");
    test:assertEquals(x.books[1].author, "John Steinbeck");

    LibraryC y = check fromJsonStringWithType(str);
    test:assertEquals(y.books.length(), 3);
    test:assertEquals(y.books[0].title, "The Great Gatsby");
    test:assertEquals(y.books[0].author, "F. Scott Fitzgerald");
    test:assertEquals(y.books[1].title, "The Grapes of Wrath");
    test:assertEquals(y.books[1].author, "John Steinbeck");
    test:assertEquals(y.books[2].title, "Binary Echoes: Unraveling the Digital Web");
    test:assertEquals(y.books[2].author, "Alexandra Quinn");
}

@test:Config
isolated function testFromJsonStringWithType20() returns error? {
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
    |} val1 = check fromJsonStringWithType(str1);
    test:assertEquals(val1.length(), 2);
    test:assertEquals(val1["a"]["c"], "world");
    test:assertEquals(val1["a"]["d"], "2");
    test:assertEquals(val1["b"]["c"], "world");
    test:assertEquals(val1["b"]["d"], "2");

    record {|
        map<string>...;
    |} val2 = check fromJsonStringWithType(str1);
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
    |} val3 = check fromJsonStringWithType(str3);
    test:assertEquals(val3.length(), 2);
    test:assertEquals(val3["a"], [{
            "c": "world",
            "d": "2"
        }]);
    test:assertEquals(val3["b"], [{
            "c": "world",
            "d": "2"
        }]);
}

@test:Config
isolated function testUnionTypeAsExpTypeForFromJsonStringWithType() returns error? {
    decimal|float val1 = check fromJsonStringWithType("1.0");
    test:assertEquals(val1, 1.0);

    string str2 = string `{
        "a": "hello",
        "b": 1
    }`;

    record {|
        decimal|float b;
    |} val2 = check fromJsonStringWithType(str2);
    test:assertEquals(val2.length(), 1);
    test:assertEquals(val2.b, 1.0);

    string str3 = string `{
        "a": {
            "b": 1,
            "d": {
                "e": "false"
            }
        },
        "c": 2
    }`;

    record {|
        record {| decimal|int b; record {| string|boolean e; |} d; |} a;
        decimal|float c;
    |} val3 = check fromJsonStringWithType(str3);
    test:assertEquals(val3.length(), 2);
    test:assertEquals(val3.a.length(), 2);
    test:assertEquals(val3.a.b, 1);
    test:assertEquals(val3.a.d.e, false);
    test:assertEquals(val3.c, 2.0);
}

@test:Config
isolated function testAnydataAsExpTypeForFromJsonStringWithType() returns error? {
    string jsonStr1 = string `1`;
    anydata val1 = check fromJsonStringWithType(jsonStr1);
    test:assertEquals(val1, 1);

    string jsonStr2 = string `{
        "a": "hello",
        "b": 1
    }`;

    anydata val2 = check fromJsonStringWithType(jsonStr2);
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

    anydata val3 = check fromJsonStringWithType(jsonStr3);
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

    anydata val4 = check fromJsonStringWithType(jsonStr4);
    test:assertEquals(val4, {"a": [{"b": 1, "d": {"e": "hello"}}], "c": 2});

    string str5 = string `[[1], 2]`;
    anydata val5 = check fromJsonStringWithType(str5);
    test:assertEquals(val5, [[1], 2]);
}

@test:Config
isolated function testJsonAsExpTypeForFromJsonStringWithType() returns error? {
    string jsonStr1 = string `1`;
    json val1 = check fromJsonStringWithType(jsonStr1);
    test:assertEquals(val1, 1);

    string jsonStr2 = string `{
        "a": "hello",
        "b": 1
    }`;

    json val2 = check fromJsonStringWithType(jsonStr2);
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

    json val3 = check fromJsonStringWithType(jsonStr3);
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

    json val4 = check fromJsonStringWithType(jsonStr4);
    test:assertEquals(val4, {"a": [{"b": 1, "d": {"e": "hello"}}], "c": 2});

    string str5 = string `[[1], 2]`;
    json val5 = check fromJsonStringWithType(str5);
    test:assertEquals(val5, [[1], 2]);
}

@test:Config
isolated function testMapAsExpTypeForFromJsonStringWithType() returns error? {
    string jsonStr1 = string `{
        "a": "hello",
        "b": 1
    }`;

    map<string> val1 = check fromJsonStringWithType(jsonStr1);
    test:assertEquals(val1, {"a": "hello", "b": "1"});

    string jsonStr2 = string `{
        "a": "hello",
        "b": 1,
        "c": {
            "d": "world",
            "e": 2
        }
    }`;
    record {|
        string a;
        int b;
        map<string> c;
    |} val2 = check fromJsonStringWithType(jsonStr2);
    test:assertEquals(val2.a, "hello");
    test:assertEquals(val2.b, 1);
    test:assertEquals(val2.c, {"d": "world", "e": "2"});

    string jsonStr3 = string `{
        "a": {
            "c": "world",
            "d": 2
        },
        "b": {
            "c": "world",
            "d": 2
        }
    }`;

    map<map<string>> val3 = check fromJsonStringWithType(jsonStr3);
    test:assertEquals(val3, {"a": {"c": "world", "d": "2"}, "b": {"c": "world", "d": "2"}});

    record {|
        map<string> a;
    |} val4 = check fromJsonStringWithType(jsonStr3);
    test:assertEquals(val4.a, {"c": "world", "d": "2"});

    map<record {|
        string c;
        int d;
    |}> val5 = check fromJsonStringWithType(jsonStr3);
    test:assertEquals(val5, {"a": {"c": "world", "d": 2}, "b": {"c": "world", "d": 2}});
}

@test:Config
isolated function testProjectionInTupleForFromJsonStringWithType() returns error? {
    string str1 = string `[1, 2, 3, 4, 5, 8]`;
    [string, float] val1 = check fromJsonStringWithType(str1);
    test:assertEquals(val1, ["1", 2.0]);

    string str2 = string `{
        "a": [1, 2, 3, 4, 5, 8]
    }`;
    record {| [string, float] a; |} val2 = check fromJsonStringWithType(str2);
    test:assertEquals(val2.a, ["1", 2.0]);

    string str3 = string `[1, "4"]`;
    [float] val3 = check fromJsonStringWithType(str3); 
    test:assertEquals(val3, [1.0]);

    string str4 = string `["1", {}]`;
    [float] val4 = check fromJsonStringWithType(str4); 
    test:assertEquals(val4, [1.0]);

    string str5 = string `["1", [], {"name": 1}]`;
    [float] val5 = check fromJsonStringWithType(str5); 
    test:assertEquals(val5, [1.0]);
}

@test:Config
isolated function testProjectionInArrayForFromJsonStringWithType() returns error? {
    string strVal = string `[1, 2, 3, 4, 5]`;
    int[] val = check fromJsonStringWithType(strVal);
    test:assertEquals(val, [1, 2, 3, 4, 5]);

    string strVal2 = string `[1, 2, 3, 4, 5]`;
    int[2] val2 = check fromJsonStringWithType(strVal2);
    test:assertEquals(val2, [1, 2]);

    string strVal3 = string `{
        "a": [1, 2, 3, 4, 5]
    }`;
    record {| int[2] a; |} val3 = check fromJsonStringWithType(strVal3);
    test:assertEquals(val3, {a: [1, 2]});

    string strVal4 = string `{
        "a": [1, 2, 3, 4, 5],
        "b": [1, 2, 3, 4, 5]
    }`;
    record {| int[2] a; int[3] b; |} val4 = check fromJsonStringWithType(strVal4);
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
    record {| record {| string name; int age; |}[1] employees; |} val5 = check fromJsonStringWithType(strVal5);
    test:assertEquals(val5, {employees: [{name: "Prakanth", age: 26}]});
}

@test:Config
isolated function testProjectionInRecordForFromJsonStringWithType() returns error? {
    string jsonStr1 = string `{"name": "John", "age": 30, "city": "New York"}`;
    record {| string name; string city; |} val1 = check fromJsonStringWithType(jsonStr1);
    test:assertEquals(val1, {name: "John", city: "New York"});

    string jsonStr2 = string `{"name": John, "age": "30", "city": "New York"}`;
    record {| string name; string city; |} val2 = check fromJsonStringWithType(jsonStr2);
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
    record {| string name; string city; |} val3 = check fromJsonStringWithType(jsonStr3);
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
    record {| string name; string city; |} val4 = check fromJsonStringWithType(jsonStr4);
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
    record {| string name; string city; |} val5 = check fromJsonStringWithType(jsonStr5);
    test:assertEquals(val5, {name: "John", city: "New York"});
}

@test:Config
isolated function testArrayOrTupleCaseForFromJsonStringWithType() returns error? {
    string jsonStr1 = string `[["1"], 2.0]`;
    [[int], float] val1 = check fromJsonStringWithType(jsonStr1);
    test:assertEquals(val1, [[1], 2.0]);

    string jsonStr2 = string `[["1", 2], 2.0]`;
    [[int, float], string] val2 = check fromJsonStringWithType(jsonStr2);
    test:assertEquals(val2, [[1, 2.0], "2.0"]);
    
    string jsonStr3 = string `[["1", 2], [2, "3"]]`;
    int[][] val3 = check fromJsonStringWithType(jsonStr3);
    test:assertEquals(val3, [[1, 2], [2, 3]]);

    string jsonStr4 = string `{"val" : [[1, 2], "2.0", 3.0, [5, 6]]}`;
    record {|
        [[int, float], string, float, [string, int]] val;
    |} val4 = check fromJsonStringWithType(jsonStr4);
    test:assertEquals(val4, {val: [[1, 2.0], "2.0", 3.0, ["5", 6]]});

    string jsonStr41 = string `{"val1" : [[1, 2], "2.0", 3.0, [5, 6]], "val2" : [[1, 2], "2.0", 3.0, [5, 6]]}`;
    record {|
        [[int, float], string, float, [string, int]] val1;
        [[float, float], string, float, [string, float]] val2;
    |} val41 = check fromJsonStringWithType(jsonStr41);
    test:assertEquals(val41, {val1: [[1, 2.0], "2.0", 3.0, ["5", 6]], val2: [[1.0, 2.0], "2.0", 3.0, ["5", 6.0]]});

    string jsonStr5 = string `{"val" : [["1", 2], [2, "3"]]}`;
    record {|
        int[][] val;
    |} val5 = check fromJsonStringWithType(jsonStr5);
    test:assertEquals(val5, {val: [[1, 2], [2, 3]]});

    string jsonStr6 = string `[{"val" : [["1", 2], [2, "3"]]}]`;
    [record {|int[][] val;|}] val6 = check fromJsonStringWithType(jsonStr6);
    test:assertEquals(val6, [{val: [[1, 2], [2, 3]]}]);
}

// Negative tests for fromJsonStringWithType() function.

@test:Config
isolated function testFromJsonStringWithTypeNegative1() returns error? {
    string str = string `{
        "id": 12,
        "name": "Anne",
        "address": {
            "street": "Main",
            "city": "94",
            "id": true
        }
    }`;

    RN|Error x = fromJsonStringWithType(str);
    test:assertTrue(x is error);
    test:assertEquals((<error>x).message(), "incompatible value 'true' for type 'int' in field 'address.id'");
}

@test:Config
isolated function testFromJsonStringWithTypeNegative2() returns error? {
    string str = string `{
        "id": 12
    }`;

    RN2|Error x = fromJsonStringWithType(str);
    test:assertTrue(x is error);
    test:assertEquals((<error>x).message(), "required field 'name' not present in JSON");
}

@test:Config
isolated function testFromJsonStringWithTypeNegative3() returns error? {
    string str = string `{
        "id": 12,
        "name": "Anne",
        "address": {
            "street": "Main",
            "city": "94"
        }
    }`;

    RN|Error x = fromJsonStringWithType(str);
    test:assertTrue(x is error);
    test:assertEquals((<error>x).message(), "required field 'id' not present in JSON");
}

@test:Config
isolated function testFromJsonStringWithTypeNegative4() returns error? {
    string str = string `{
        name: "John"
    }`;

    int|Error x = fromJsonStringWithType(str);
    test:assertTrue(x is error);
    test:assertEquals((<error>x).message(), "invalid type 'int' expected 'map type'");

    Union|Error y = fromJsonStringWithType(str);
    test:assertTrue(y is error);
    test:assertEquals((<error>y).message(), "invalid type 'ballerina/data.jsondata:0:Union' expected 'map type'");

    table<RN2>|Error z = fromJsonStringWithType(str);
    test:assertTrue(z is error);
    test:assertEquals((<error>z).message(), "unsupported type 'table<data.jsondata:RN2>'");

    RN2|Error a = fromJsonStringWithType("1");
    test:assertTrue(a is error);
    test:assertEquals((<error>a).message(), "incompatible expected type 'data.jsondata:RN2' for value '1'");
}

@test:Config
isolated function testFromJsonStringWithTypeNegative5() returns error? {
    string str = string `[1, 2]`;

    INTARR|Error x = fromJsonStringWithType(str);
    test:assertTrue(x is error);
    test:assertEquals((<error>x).message(), "array size is not compatible with the expected size");

    INTTUPLE|Error y = fromJsonStringWithType(str);
    test:assertTrue(y is error);
    test:assertEquals((<error>y).message(), "array size is not compatible with the expected size");
}

@test:Config
isolated function testDuplicateFieldInRecordTypeWithFromJsonStringWithType() returns error? {
    string str = string `{
        "title": "Clean Code",
        "author": "Robert C. Martin",
        `;

    BookN|Error x = fromJsonStringWithType(str);
    test:assertTrue(x is error);
    test:assertEquals((<error>x).message(), "duplicate field 'author'");
}
