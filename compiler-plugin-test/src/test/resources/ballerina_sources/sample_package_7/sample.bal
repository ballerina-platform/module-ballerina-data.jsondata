import ballerina/data.jsondata;

type T1 (map<anydata>|int|xml)[];
type T2 record {|
    string p1;
    table<record {|string a;|}>|int p2;
|};

public function main() returns error? {
    string str1 = string `[
            {
                "p1":"v1",
                "p2":1
            },
            {
                "p1":"v2",
                "p2":true
            }
        ]`;
    T1 _ = check jsondata:parseString(str1);

    string str2 = string `
        {
            "p1":"v1",
            "p2": {
                "a": 1,
                "b": 2
            }
        }`;
    T2 _ = check jsondata:parseString(str2);
}
