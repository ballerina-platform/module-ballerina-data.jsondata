import ballerina/data.jsondata;

type Person record {|
    string? name;
    record {|string street; string country;|}|map<string> address;
    record {|string street; string country;|}|json company;
|};

string str = string `{
        "name": "John",
        "address": {
            "street": "Main Street",
            "country": "USA"
        },
        "company": {
            "street": "Main Street",
            "country": "USA"
        }
    }`;
Person _ = check jsondata:parseString(str);
