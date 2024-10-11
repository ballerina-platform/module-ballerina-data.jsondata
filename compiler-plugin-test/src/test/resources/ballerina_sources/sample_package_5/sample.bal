import ballerina/data.jsondata;

type Data record {
    @jsondata:Name {
        value: "B"
    }
    string A;
    string B;
};

type Data2 record {
    @jsondata:Name {
        value: "C"
    }
    string A;
    @jsondata:Name {
        value: "C"
    }
    string B;
};
