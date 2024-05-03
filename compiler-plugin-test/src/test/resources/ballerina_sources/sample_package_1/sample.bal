import ballerina/data.jsondata;

public function main() returns error? {
    int|table<record {|string a;|}>|record {| int b;|} val = check jsondata:parseString("1");
}
