import ballerina/data.jsondata;

public function testFunc3() returns error? {
    string str = string `{"a": 1, "b": "str"}`;
    UnionType _ = check jsondata:parseString(str);
}
