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

type OpenRecord record {};

type SimpleRec1 record {|
    string a;
    int b;
|};

type SimpleRec2 record {
    string a;
    int b;
};

type NestedRecord1 record {|
    string a; 
    int b;
    record {|
        string d; 
        int e;
    |} c;
|};

type NestedRecord2 record {
    string a; 
    int b;
    record {|
        string d; 
        int e;
    |} c;
};

type RestRecord1 record {|
    string a; 
    anydata...;
|};

type RestRecord2 record {|
    string a;
    int...;
|};

type RestRecord3 record {|
    string a;
    int b;
    record {|
        int...;
    |} c;
|};

type RestRecord4 record {|
    string a;
    int b;
    record {|
        decimal|float...;
    |}...;
|};

type Address record {
    string street;
    string city;
};

type R record {|
    int id;
    string name;
    Address address;
|};

type Company record {
    map<string> employees;
};

type Coordinates record {
    float latitude;
    float longitude;
};

type AddressWithCord record {
    string street;
    int zipcode;
    Coordinates coordinates;
};

type Person record {
    string name;
    int age;
    AddressWithCord address;
};

type Author record {|
    string name;
    string birthdate;
    string hometown;
    boolean...;
|};

type Publisher record {|
    string name;
    int year;
    string...;
|};

type Book record {|
    string title;
    Author author;
    Publisher publisher;
    float...;
|};

type Book2 record {
    int id;
    @Name {
        value: "title-name"
    }
    string title;
    @Name {
        value: "author-name"
    }
    string author;
};

type School record {|
    string name;
    int number;
    boolean flag;
    int...;
|};

type TestRecord record {
    int intValue;
    float floatValue;
    string stringValue;
    decimal decimalValue;
};

type SchoolAddress record {
    string street;
    string city;
};

type School1 record {
    string name;
    SchoolAddress address;
};

type Student1 record {
    int id;
    string name;
    School1 school;
};

type Teacher record {
    int id;
    string name;
};

type Class record {
    int id;
    string name;
    Student1 student;
    Teacher teacher;
    Student1? monitor;
};

type TestRecord2 record {
    int intValue;
    TestRecord nested1;
};

type TestR record {|
    string street;
    string city;
|};

type TestArr1 record {
    string street;
    string city;
    int[] houses;
};

type TestArr2 record {
    string street;
    int city;
    [int, string] house;
};

type TestArr3 record {
    string street;
    string city;
    [int, int[3]] house;
};

type TestJson record {
    string street;
    json city;
    boolean flag;
};

type IntArr int[];

type TUPLE [int, string, [int, float]];

type BookA record {|
    string title;
    string author;
|};

type Library record {
    BookA[2] books;
};

//////// Types used for Negative cases /////////

type AddressN record {
    string street;
    string city;
    int id;
};

type RN record {|
    int id;
    string name;
    AddressN address;
|};

type RN2 record {|
    int id;
    string name;
|};

type Union int|float;

type INTARR int[3];
type INTTUPLE [int, int, int, int...];

type BookN record {
    string title;
    @Name {
        value: "author"
    }
    string name;
    string author;
};
