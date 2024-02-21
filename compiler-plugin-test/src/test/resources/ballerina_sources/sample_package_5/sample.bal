import ballerina/data.jsondata;

type Data record {
    @jsondata:Name {
        value: "B"
    }
    string A;
    string B;
};
