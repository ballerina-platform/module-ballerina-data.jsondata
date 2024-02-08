import ballerina/data.jsondata;

public function main() returns error? {
    int|record {| int a;|}|record {| int b;|} val = check jsondata:fromJsonStringWithType("1");
}
