// Copyright (c) 2024, WSO2 LLC. (https://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
import ballerina/test;

final readonly & json value = {
    event: {
        name: "Bond Movies",
        movies: [
            {
                name: "Licence to Kill",
                star: "Timothy Dalton",
                rating: 6.6
            },
            {
                name: "GoldenEye",
                star: "Pierce Brosnan",
                rating: 7.2
            },
            {
                name: "Tomorrow Never Dies",
                star: "Pierce Brosnan",
                rating: 6.5
            },
            {
                name: "Skyfall",
                star: "Daniel Craig",
                rating: 7.8
            }
        ]
    }
};

final readonly & json value2 = {
    store: {
        book: [
            {
                category: "reference",
                author: "Nigel Rees",
                title: "Sayings of the Century",
                price: 8.95
            },
            {
                category: "fiction",
                author: "Evelyn Waugh",
                title: "Sword of Honour",
                price: 12.99
            },
            {
                category: "fiction",
                author: "Herman Melville",
                title: "Moby Dick",
                isbn: "0-553-21311-3",
                price: 8.99
            },
            {
                category: "fiction",
                author: "J. R. R. Tolkien",
                title: "The Lord of the Rings",
                isbn: "0-395-19395-8",
                price: 22.99
            }
        ],
        bicycle: {
            color: "red",
            price: 19.95
        }
    },
    expensive: 10
};

@test:Config {}
isolated function testQuery() returns error? {
    json result = check read(value, `$.event.movies`);
    test:assertTrue(result is json[]);
    test:assertEquals(result, (<json[]>[
        {
            name: "Licence to Kill",
            star: "Timothy Dalton",
            rating: 6.6
        },
        {
            name: "GoldenEye",
            star: "Pierce Brosnan",
            rating: 7.2
        },
        {
            name: "Tomorrow Never Dies",
            star: "Pierce Brosnan",
            rating: 6.5
        },
        {
            name: "Skyfall",
            star: "Daniel Craig",
            rating: 7.8
        }
    ]));
}

@test:Config {}
isolated function testQuery2() returns error? {
    json result = check read(value, `$.event.name`);
    test:assertEquals(result, "Bond Movies");
}

@test:Config {}
isolated function testQuery3() returns error? {
    json result = check read(value, `$.event.${"name"}`);
    test:assertEquals(result, "Bond Movies");
}

@test:Config {}
isolated function testQuery4() returns error? {
    json result = check read(value, `$.event.movies[?(@.rating>7)]`);
    test:assertEquals(result, <json[]>[
        {
            name: "GoldenEye",
            star: "Pierce Brosnan",
            rating: 7.2
        },
        {
            name: "Skyfall",
            star: "Daniel Craig",
            rating: 7.8
        }
    ]);
}

@test:Config {}
isolated function testQuery5() returns error? {
    int a = 7;
    json result = check read(value, `$.event.movies[?(@.rating>${a})]`);
    test:assertEquals(result, <json[]>[
        {
            name: "GoldenEye",
            star: "Pierce Brosnan",
            rating: 7.2
        },
        {
            name: "Skyfall",
            star: "Daniel Craig",
            rating: 7.8
        }
    ]);
}

@test:Config {}
function testQuery6() returns error? {
    json result = check read(value, `$..movies.length()`);
    test:assertEquals(result, 4);
}

@test:Config {}
function testQuery7() returns error? {
    json result = check read(value, `$.max($.event.movies..rating)`);
    test:assertEquals(result, 7.8);
}

@test:Config {}
function testQuery8() returns error? {
    json result = check read(value, `$..rating.avg()`);
    test:assertEquals(result, 28.1 / 4);
}

@test:Config {}
function testQuery9() returns error? {
    json result = check read(value2, `$.store.book[*].author`);
    test:assertEquals(result, [
        "Nigel Rees", "Evelyn Waugh", "Herman Melville", "J. R. R. Tolkien"
    ]);

    result = check read(value2, `$..author`);
    test:assertEquals(result, [
        "Nigel Rees", "Evelyn Waugh", "Herman Melville", "J. R. R. Tolkien"
    ]);

    result = check read(value2, `$.store.*`);
    test:assertEquals(result, [[
    {
        category: "reference",
        author: "Nigel Rees",
        title: "Sayings of the Century",
        price: 8.95
    },
    {
        category: "fiction",
        author: "Evelyn Waugh",
        title: "Sword of Honour",
        price: 12.99
    },
    {
        category: "fiction",
        author: "Herman Melville",
        title: "Moby Dick",
        isbn: "0-553-21311-3",
        price: 8.99
    },
    {
        category: "fiction",
        author: "J. R. R. Tolkien",
        title: "The Lord of the Rings",
        isbn: "0-395-19395-8",
        price: 22.99
    }],
    {
        color: "red",
        price: 19.95
    }
]);

    result = check read(value2, `$.store..price`);
    test:assertEquals(result, [
        8.95, 12.99, 8.99, 22.99, 19.95
    ]);

    result = check read(value2, `$..book[2]`);
    test:assertEquals(result, [{
        category: "fiction",
        author: "Herman Melville",
        title: "Moby Dick",
        isbn: "0-553-21311-3",
        price: 8.99
    }]);

    result = check read(value2, `$..book[-2]`);
    test:assertEquals(result, [{
        category: "fiction",
        author: "Herman Melville",
        title: "Moby Dick",
        "isbn": "0-553-21311-3",
        price: 8.99
    }]);

    result = check read(value2, `$..book[0,1]`);
    test:assertEquals(result, [{
        category: "reference",
        author: "Nigel Rees",
        title: "Sayings of the Century",
        price: 8.95
    },
    {
        category: "fiction",
        author: "Evelyn Waugh",
        title: "Sword of Honour",
        price: 12.99
    }]);

    result = check read(value2, `$..book[:2]`);
    test:assertEquals(result, [{
        category: "reference",
        author: "Nigel Rees",
        title: "Sayings of the Century",
        price: 8.95
    },
    {
        category: "fiction",
        author: "Evelyn Waugh",
        title: "Sword of Honour",
        price: 12.99
    }]);

    result = check read(value2, `$..book[1:2]`);
    test:assertEquals(result, [{
        category: "fiction",
        author: "Evelyn Waugh",
        title: "Sword of Honour",
        price: 12.99
    }]);

    result = check read(value2, `$..book[-2:]`);
    test:assertEquals(result, [{
        category: "fiction",
        author: "Herman Melville",
        title: "Moby Dick",
        isbn: "0-553-21311-3",
        price: 8.99
    },
    {
        category: "fiction",
        author: "J. R. R. Tolkien",
        title: "The Lord of the Rings",
        isbn: "0-395-19395-8",
        price: 22.99
    }]);

    result = check read(value2, `$..book[2:]`);
    test:assertEquals(result, [{
        category: "fiction",
        author: "Herman Melville",
        title: "Moby Dick",
        isbn: "0-553-21311-3",
        price: 8.99
    },
    {
        category: "fiction",
        author: "J. R. R. Tolkien",
        title: "The Lord of the Rings",
        isbn: "0-395-19395-8",
        price: 22.99
    }]);

    result = check read(value2, `$..book[?(@.isbn)]`);
    test:assertEquals(result, [{
        category: "fiction",
        author: "Herman Melville",
        title: "Moby Dick",
        isbn: "0-553-21311-3",
        price: 8.99
    },
    {
        category: "fiction",
        author: "J. R. R. Tolkien",
        title: "The Lord of the Rings",
        isbn: "0-395-19395-8",
        price: 22.99
    }]);

    result = check read(value2, `$.store.book[?(@.price < 10)]`);
    test:assertEquals(result, [{
        category: "reference",
        author: "Nigel Rees",
        title: "Sayings of the Century",
        price: 8.95
    }, 
    {
        category: "fiction",
        author: "Herman Melville",
        title: "Moby Dick",
        isbn: "0-553-21311-3",
        price: 8.99
    }]);

    result = check read(value2, `$..book[?(@.price <= $['expensive'])]`);
    test:assertEquals(result, [{
        category: "reference",
        author: "Nigel Rees",
        title: "Sayings of the Century",
        price: 8.95
    }, 
    {
        category: "fiction",
        author: "Herman Melville",
        title: "Moby Dick",
        isbn: "0-553-21311-3",
        price: 8.99
    }]);

    result = check read(value2, `$..book[?(@.author =~ /.*REES/i)]`);
    test:assertEquals(result, [{
        category: "reference",
        author: "Nigel Rees",
        title: "Sayings of the Century",
        price: 8.95
    }]);

    result = check read(value2, `$..book.length()`);
    test:assertEquals(result, 4);

    result = check read(value2, `$..*`);
    test:assertEquals(result, <json[]>[{
    book: [
      {
        category: "reference",
        author: "Nigel Rees",
        title: "Sayings of the Century",
        price: 8.95
      },
      {
        category: "fiction",
        author: "Evelyn Waugh",
        title: "Sword of Honour",
        price: 12.99
      },
      {
        category: "fiction",
        author: "Herman Melville",
        title: "Moby Dick",
        "isbn": "0-553-21311-3",
        price: 8.99
      },
      {
        category: "fiction",
        author: "J. R. R. Tolkien",
        title: "The Lord of the Rings",
        "isbn": "0-395-19395-8",
        price: 22.99
      }
    ],
    "bicycle": {
      "color": "red",
      price: 19.95
    }
  },
  10,
  [
    {
      category: "reference",
      author: "Nigel Rees",
      title: "Sayings of the Century",
      price: 8.95
    },
    {
      category: "fiction",
      author: "Evelyn Waugh",
      title: "Sword of Honour",
      price: 12.99
    },
    {
      category: "fiction",
      author: "Herman Melville",
      title: "Moby Dick",
      "isbn": "0-553-21311-3",
      price: 8.99
    },
    {
      category: "fiction",
      author: "J. R. R. Tolkien",
      title: "The Lord of the Rings",
      "isbn": "0-395-19395-8",
      price: 22.99
    }
  ],
  {
    "color": "red",
    price: 19.95
  },
  {
    category: "reference",
    author: "Nigel Rees",
    title: "Sayings of the Century",
    price: 8.95
  },
  {
    category: "fiction",
    author: "Evelyn Waugh",
    title: "Sword of Honour",
    price: 12.99
  },
  {
    category: "fiction",
    author: "Herman Melville",
    title: "Moby Dick",
    "isbn": "0-553-21311-3",
    price: 8.99
  },
  {
    category: "fiction",
    author: "J. R. R. Tolkien",
    title: "The Lord of the Rings",
    "isbn": "0-395-19395-8",
    price: 22.99
  },
  "reference",
  "Nigel Rees",
  "Sayings of the Century",
  8.95,
  "fiction",
  "Evelyn Waugh",
  "Sword of Honour",
  12.99,
  "fiction",
  "Herman Melville",
  "Moby Dick",
  "0-553-21311-3",
  8.99,
  "fiction",
  "J. R. R. Tolkien",
  "The Lord of the Rings",
  "0-395-19395-8",
  22.99,
  "red",
  19.95
]);
}

@test:Config {}
function testQuery10() returns error? {
    json result = check read({id: 1, "name": "John Doe"}, `$.name`);
    test:assertEquals(result, "John Doe");
}
