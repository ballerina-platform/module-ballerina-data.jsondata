import ballerina/data.jsondata as jd2;

public function testFunc2() returns error? {
    string str = string `{"a": 1, "b": "str"}`;
    UnionType _ = check jd2:parseString(str);
}
