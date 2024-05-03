import ballerina/data.jsondata;

type Union int|table<record {|string a;|}>|record {| int b;|};

public function main() returns error? {
    Union val = check jsondata:parseString("1");
}
