import ballerina/data.jsondata as jd;

type UnionType table<record {|int a;|}>|record {|string b;|};

public function main() returns error? {
    string str = string `{"a": 1, "b": "str"}`;
    UnionType _ = check jd:parseString(str);
}
