import ballerina/data.jsondata;

type Union int|record {| int a;|}|record {| int b;|};

public function main() returns error? {
    Union val = check jsondata:fromJsonStringWithType("1");
}
