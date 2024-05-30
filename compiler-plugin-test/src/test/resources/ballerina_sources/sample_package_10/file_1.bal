import ballerina/data.jsondata as jd;

public function testFunc1() returns error? {
    string str = string `{"a": 1, "b": "str"}`;
    UnionType _ = check jd:parseString(str);
}
