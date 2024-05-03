import ballerina/data.jsondata;

type Person record {|
    string? name;
    table<record {| int a;|}>|map<string> address;
    xml|json company;
|};

public function main() returns error? {
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
}
