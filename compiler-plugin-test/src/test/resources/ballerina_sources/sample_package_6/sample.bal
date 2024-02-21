import ballerina/data.jsondata;

public function main() returns error? {
    record {
        @jsondata:Name {
            value: "B"
        }
        string A;
        string B;
    } _ = check jsondata:fromJsonWithType({
        "A": "Hello",
        "B": "World"
    });

    record {
        @jsondata:Name {
            value: "B"
        }
        string A;
        string B;
    } _ = {A: "Hello", B: "World"};
}
