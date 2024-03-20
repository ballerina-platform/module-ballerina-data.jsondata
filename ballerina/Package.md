# Ballerina JSON Data Library

The Ballerina JSON Data Library is a comprehensive toolkit designed to facilitate the handling and manipulation of JSON data within Ballerina applications. It streamlines the process of converting JSON data to native Ballerina data types, enabling developers to work with JSON content seamlessly and efficiently.

## Features

- **Versatile JSON Data Input**: Accept JSON data as a ballerina JSON value, a string, byte array, or a stream and convert it into a subtype of anydata.
- **JSON to anydata Value Conversion**: Transform JSON data into expected type which is subtype of anydata.
- **Projection Support**: Perform selective conversion of JSON data subsets into anydata values through projection.

## Usage

### Converting JSON Document value to a record value

To convert an JSON document value to a record value, you can utilize the `parseAsType` function provided by the library. The example below showcases the transformation of an JSON document value into a record value.

```ballerina
import ballerina/data.jsondata;
import ballerina/io;

type Book record {
    string name;
    string author;
    int year;
};

public function main() returns error? {
    json jsonContent = {
        "name": "Clean Code",
        "author": "Robert C. Martin",
        "year": 2008
    };

    Book book = check jsondata:parseAsType(jsonContent);
    io:println(book);
}
```

### Converting external JSON document to a record value

For transforming JSON content from an external source into a record value, the `parseString`, `parseBytes`, `parseStream` functions can be used. This external source can be in the form of a string or a byte array/byte-block-stream that houses the JSON data. This is commonly extracted from files or network sockets. The example below demonstrates the conversion of an JSON value from an external source into a record value.

```ballerina
import ballerina/data.jsondata;
import ballerina/io;

type Book record {
    string name;
    string author;
    int year;
};

public function main() returns error? {
    string jsonContent = check io:fileReadString("path/to/file.json");
    Book book = check jsondata:parseString(jsonContent);
    io:println(book);
}
```

Make sure to handle possible errors that may arise during the file reading or JSON to anydata conversion process. The `check` keyword is utilized to handle these errors, but more sophisticated error handling can be implemented as per your requirements.

## JSON to anydata representation

The conversion of JSON data to subtype of anydata representation is a fundamental feature of the library.

### JSON Object

The JSON Object can be represented as a value of type record/map in Ballerina which facilitates a structured and type-safe approach to handling JSON data.

Take for instance the following JSON Object snippet:

```json
{
    "author": "Robert C. Martin",
    "books": [
        {
            "name": "Clean Code",
            "year": 2008
        },
        {
            "name": "Clean Architecture",
            "year": 2017
        }
    ]
}
```

This JSON Object can be represented as a record value in Ballerina as follows:

```ballerina
type Author record {
    string author;
    Book[] books;
};

type Book record {
    string name;
    int year;
};

public function main() returns error? {
    json jsonContent = {
        "author": "Robert C. Martin",
        "books": [
            {
                "name": "Clean Code",
                "year": 2008
            },
            {
                "name": "Clean Architecture",
                "year": 2017
            }
        ]
    };

    Author author = check jsondata:parseAsType(jsonContent);
    io:println(author);
}
```

### JSON Array

The JSON Array can be represented as an array/tuple values in Ballerina.

```json
[
    {
        "name": "Clean Code",
        "year": 2008
    },
    {
        "name": "Clean Architecture",
        "year": 2017
    }
]
```

This JSON Array can be converted as an array/tuple in Ballerina as follows:

```ballerina
type Book record {
    string name;
    int year;
};

public function main() returns error? {
    json jsonContent = [
        {
            "name": "Clean Code",
            "year": 2008
        },
        {
            "name": "Clean Architecture",
            "year": 2017
        }
    ];

    Book[] bookArr = check jsondata:parseAsType(jsonContent);
    io:println(bookArr);
  
    [Book, Book] bookTuple = check jsondata:parseAsType(jsonContent);
    io:println(bookTuple);
}
```

### Controlling the JSON to record conversion

The library allows for selective conversion of JSON into closed records. This is beneficial when the JSON data contains members that are not necessary to be transformed into record fields.

```json
{
    "name": "Clean Code",
    "author": "Robert C. Martin",
    "year": 2008,
    "publisher": "Prentice Hall"
}
```

The JSON data above contains `publisher` and `year` fields which are not required to be converted into a record field.

```ballerina
type Book record {|
    string name;
    string author;
|};

public function main() returns error? {
    json jsonContent = {
        "name": "Clean Code",
        "author": "Robert C. Martin",
        "year": 2008,
        "publisher": "Prentice Hall"
    };

    Book book = check jsondata:parseAsType(jsonContent);
    io:println(book);
}
```

However, if the rest field is utilized (or if the record type is defined as an open record), all members in the JSON data will be transformed into record fields:

```ballerina
type Book record {
    string name;
    string author;
}
```

In this instance, all other members in the JSON data, such as `year` and `publisher` will be transformed into `anydata-typed` fields with the corresponding JSON object member as the key-value pair.

This behavior extends to arrays as well.

The process of projecting JSON data into a record supports various use cases, including the filtering out of unnecessary members. This functionality is anticipated to be enhanced in the future to accommodate more complex scenarios, such as filtering values based on regular expressions, among others.
