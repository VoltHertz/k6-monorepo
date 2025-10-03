---
url: "https://dummyjson.com/docs/users"
title: "Users - DummyJSON - Free Fake REST API for Placeholder JSON Data"
---

# ![svg icon](https://dummyjson.com/public/img/icons/user.svg) Users - Docs

The **users** endpoint provides a versatile dataset of sample user information and related data like carts, posts, and todos, making it ideal for testing and prototyping user management functionalities in web applications.

[Get all users](https://dummyjson.com/docs/users#users-all)

By default you will get 30 items, use [Limit and skip](https://dummyjson.com/docs/users#users-limit_skip) to paginate through all items.


```js
fetch('https://dummyjson.com/users')
.then(res => res.json())
.then(console.log);

```

Show Output

```json
{
  "users": [\
    {\
      "id": 1,\
      "firstName": "Emily",\
      "lastName": "Johnson",\
      "maidenName": "Smith",\
      "age": 28,\
      "gender": "female",\
      "email": "emily.johnson@x.dummyjson.com",\
      "phone": "+81 965-431-3024",\
      "username": "emilys",\
      "password": "emilyspass",\
      "birthDate": "1996-5-30",\
      "image": "...",\
      "bloodGroup": "O-",\
      "height": 193.24,\
      "weight": 63.16,\
      "eyeColor": "Green",\
      "hair": {\
        "color": "Brown",\
        "type": "Curly"\
      },\
      "ip": "42.48.100.32",\
      "address": {\
        "address": "626 Main Street",\
        "city": "Phoenix",\
        "state": "Mississippi",\
        "stateCode": "MS",\
        "postalCode": "29112",\
        "coordinates": {\
          "lat": -77.16213,\
          "lng": -92.084824\
        },\
        "country": "United States"\
      },\
      "macAddress": "47:fa:41:18:ec:eb",\
      "university": "University of Wisconsin--Madison",\
      "bank": {\
        "cardExpire": "03/26",\
        "cardNumber": "9289760655481815",\
        "cardType": "Elo",\
        "currency": "CNY",\
        "iban": "YPUXISOBI7TTHPK2BR3HAIXL"\
      },\
      "company": {\
        "department": "Engineering",\
        "name": "Dooley, Kozey and Cronin",\
        "title": "Sales Manager",\
        "address": {\
          "address": "263 Tenth Street",\
          "city": "San Francisco",\
          "state": "Wisconsin",\
          "stateCode": "WI",\
          "postalCode": "37657",\
          "coordinates": {\
            "lat": 71.814525,\
            "lng": -161.150263\
          },\
          "country": "United States"\
        }\
      },\
      "ein": "977-175",\
      "ssn": "900-590-289",\
      "userAgent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.93 Safari/537.36",\
      "crypto": {\
        "coin": "Bitcoin",\
        "wallet": "0xb9fc2fe63b2a6c003f1c324c3bfa53259162181a",\
        "network": "Ethereum (ERC20)"\
      },\
      "role": "admin" // or "moderator", or "user"\
    },\
    {...},\
    {...}\
    // 30 items\
  ],
  "total": 208,
  "skip": 0,
  "limit": 30
}

```

[Login user and get tokens](https://dummyjson.com/docs/users#users-login)

You can use any user's credentials from [dummyjson.com/users](https://dummyjson.com/users). Tokens are returned in the response and set as cookies.


```js
fetch('https://dummyjson.com/user/login', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({

    username: 'emilys',
    password: 'emilyspass',
    expiresInMins: 30, // optional, defaults to 60
  }),
})
.then(res => res.json())
.then(console.log);

```

Show Output

```json
{
  "id": 1,
  "username": "emilys",
  "email": "emily.johnson@x.dummyjson.com",
  "firstName": "Emily",
  "lastName": "Johnson",
  "gender": "female",
  "image": "https://dummyjson.com/icon/emilys/128",
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...", // JWT accessToken (for backward compatibility) in response and cookies
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." // refreshToken in response and cookies
}

```

[Get current authenticated user](https://dummyjson.com/docs/users#users-me)

You can either pass the access token via the Authorization header (JWT) or use cookies for automatic handling.

```js
/* providing access token in bearer */
fetch('https://dummyjson.com/user/me', {
  method: 'GET',
  headers: {
    'Authorization': 'Bearer /* YOUR_ACCESS_TOKEN_HERE */', // Pass JWT via Authorization header
  },
  credentials: 'include' // Include cookies (e.g., accessToken) in the request
})
.then(res => res.json())
.then(console.log);

```

Show Output

```json
{
  "id": 1,
  "firstName": "Emily",
  "lastName": "Johnson",
  "maidenName": "Smith",
  "age": 28,
  "gender": "female",
  "email": "emily.johnson@x.dummyjson.com",
  "image": "...",
  /* rest user data */
}

```

[Get a single user](https://dummyjson.com/docs/users#users-single)

```js
fetch('https://dummyjson.com/users/1')
.then(res => res.json())
.then(console.log);

```

Show Output

```json
{
  "id": 1,
  "firstName": "Emily",
  "lastName": "Johnson",
  "maidenName": "Smith",
  "age": 28,
  "gender": "female",
  "email": "emily.johnson@x.dummyjson.com",
  "phone": "+81 965-431-3024",
  "username": "emilys",
  "password": "emilyspass",
  "birthDate": "1996-5-30",
  "image": "...",
  "bloodGroup": "O-",
  "height": 193.24,
  "weight": 63.16,
  "eyeColor": "Green",
  "hair": {
    "color": "Brown",
    "type": "Curly"
  },
  "ip": "42.48.100.32",
  "address": {
    "address": "626 Main Street",
    "city": "Phoenix",
    "state": "Mississippi",
    "stateCode": "MS",
    "postalCode": "29112",
    "coordinates": {
      "lat": -77.16213,
      "lng": -92.084824
    },
    "country": "United States"
  },
  "macAddress": "47:fa:41:18:ec:eb",
  "university": "University of Wisconsin--Madison",
  "bank": {
    "cardExpire": "03/26",
    "cardNumber": "9289760655481815",
    "cardType": "Elo",
    "currency": "CNY",
    "iban": "YPUXISOBI7TTHPK2BR3HAIXL"
  },
  "company": {
    "department": "Engineering",
    "name": "Dooley, Kozey and Cronin",
    "title": "Sales Manager",
    "address": {
      "address": "263 Tenth Street",
      "city": "San Francisco",
      "state": "Wisconsin",
      "stateCode": "WI",
      "postalCode": "37657",
      "coordinates": {
        "lat": 71.814525,
        "lng": -161.150263
      },
      "country": "United States"
    }
  },
  "ein": "977-175",
  "ssn": "900-590-289",
  "userAgent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.93 Safari/537.36",
  "crypto": {
    "coin": "Bitcoin",
    "wallet": "0xb9fc2fe63b2a6c003f1c324c3bfa53259162181a",
    "network": "Ethereum (ERC20)"
  },
  "role": "admin" // or "moderator", or "user"
}

```

[Search users](https://dummyjson.com/docs/users#users-search)

```js
fetch('https://dummyjson.com/users/search?q=John')
.then(res => res.json())
.then(console.log);

```

Show Output

```json
{
  "users": [\
    {\
      "id": 50,\
      "firstName": "Emily",\
      "lastName": "Johnson", // name matched the search query\
      /* rest user data */\
    },\
    {...},\
    {...}\
    // 3 items\
  ],
  "total": 3,
  "skip": 0,
  "limit": 3
}

```

[Filter users](https://dummyjson.com/docs/users#users-filter)

You can pass key (nested keys with .) and value as params to filter users. (key and value are case-sensitive)


limit, skip and select works too.


```js
fetch('https://dummyjson.com/users/filter?key=hair.color&value=Brown')
.then(res => res.json())
.then(console.log);

```

Show Output

```json
{
  "users": [\
    {\
      "firstName": "Emily",\
      "hair": {\
        "color": "Brown", // filter matched hair color\
        type: "Curly"\
      },\
      "id": 1,\
      "lastName": "Johnson"\
      /* rest user data */\
    },\
    {...},\
    {...}\
    // 23 items\
  ],
  "total": 23,
  "skip": 0,
  "limit": 23
}

```

[Limit and skip users](https://dummyjson.com/docs/users#users-limit_skip)

You can pass limit and skip params to limit and skip the
results for pagination, and use limit=0 to get all items.


You can pass select as query params with comma-separated values
to select specific data


```js
fetch('https://dummyjson.com/users?limit=5&skip=10&select=firstName,age')
.then(res => res.json())
.then(console.log);

```

Show Output

```json
{
  "users": [\
    {\
      "id": 11, // 10 items were skipped\
      "firstName": "Liam",\
      "age": 29\
    },\
    {\
      "id": 12,\
      "firstName": "Mia",\
      "age": 24\
    },\
    {\
      "id": 13,\
      "firstName": "Noah",\
      "age": 40\
    },\
    {\
      "id": 14,\
      "firstName": "Charlotte",\
      "age": 36\
    },\
    {\
      "id": 15,\
      "firstName": "William",\
      "age": 32\
    }\
  ],
  "total": 208,
  "skip": 10, // 10 items were skipped
  "limit": 5 // limit was applied
}

```

[Limit and skip users](https://dummyjson.com/docs/users#users-sort)

You can pass sortBy and order params to sort the results,
sortBy should be field name and order should be "asc" or "desc"


```js
fetch('https://dummyjson.com/users?sortBy=firstName&order=asc')
.then(res => res.json())
.then(console.log);

```

Show Output

```json
{
  "users": [\
    {\
      "id": 84,\
      "firstName": "Aaliyah", // sorted by firstName in ascending order\
      "lastName": "Hanson",\
      "maidenName": ""\
      /* rest user data */\
    },\
    {\
      "id": 176,\
      "firstName": "Aaliyah", // sorted by firstName in ascending order\
      "lastName": "Martinez",\
      "maidenName": "Adams"\
      /* rest user data */\
    },\
    {...}\
    // 30 items\
  ],
  "total": 208,
  "skip": 0,
  "limit": 30
}

```

[Get user's carts by user id](https://dummyjson.com/docs/users#users-carts)

```js
/* getting carts of user with id 6 */
fetch('https://dummyjson.com/users/6/carts')
.then(res => res.json())
.then(console.log);

```

Show Output

```json
{
  "carts": [\
    {\
      "id": 24,\
      "products": [\
        {\
          "id": 108,\
          "title": "iPhone 12 Silicone Case with MagSafe Plum",\
          "price": 29.99,\
          "quantity": 5,\
          "total": 149.95,\
          "discountPercentage": 14.68,\
          "discountedTotal": 127.94,\
          "thumbnail": "..."\
        },\
        {...},\
        {...}\
      ],\
      "total": 1749.9,\
      "discountedTotal": 1594.33,\
      "userId": 6, // user id is 6\
      "totalProducts": 3,\
      "totalQuantity": 10\
    }\
  ],
  "total": 1,
  "skip": 0,
  "limit": 1
}

```

[Get user's posts by user id](https://dummyjson.com/docs/users#users-posts)

```js
/* getting posts of user with id 5 */
fetch('https://dummyjson.com/users/5/posts')
.then(res => res.json())
.then(console.log);

```

Show Output

```json
{
  "posts": [\
    {\
      "id": 61,\
      "title": "I'm going to hire professional help tomorrow.",\
      "body": "I'm going to hire professional help tomorrow. /*... more data */  ",\
      "userId": 5, // user id is 5\
      "tags": [\
      "fiction"\
        "classic"\
        "american"\
      ],\
      "reactions": {\
        "likes": 1127,\
        "dislikes": 40\
      }\
    },\
    {...}\
  ],
  "total": 2,
  "skip": 0,
  "limit": 2
}

```

[Get user's todos by user id](https://dummyjson.com/docs/users#users-todos)

```js
/* getting todos of user with id 5 */
fetch('https://dummyjson.com/users/5/todos')
.then(res => res.json())
.then(console.log);

```

Show Output

```json
{
  "todos": [\
    {\
      "id": 19,\
      "todo": "Create a compost pile",\
      "completed": true,\
      "userId": 5 // user id is 5\
    },\
    {\
      "id": 85,\
      "todo": "Make a budget",\
      "completed": true,\
      "userId": 5\
    },\
    {\
      "id": 103,\
      "todo": "Go to a local thrift shop",\
      "completed": true,\
      "userId": 5\
    }\
  ],
  "total": 3,
  "skip": 0,
  "limit": 3
}

```

[Add a new user](https://dummyjson.com/docs/users#users-add)

Adding a new user will not add it into the server.


It will simulate a POST request and will return the new created user with a new id


```js
fetch('https://dummyjson.com/users/add', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    firstName: 'Muhammad',
    lastName: 'Ovi',
    age: 250,
    /* other user data */
  })
})
.then(res => res.json())
.then(console.log);

```

Show Output

```json
{
  "id": 209,
  "firstName": "Muhammad",
  "lastName": "Ovi",
  "age": 250,
  /* rest user data */
}

```

[Update a user](https://dummyjson.com/docs/users#users-update)

Updating a user will not update it into the server.


It will simulate a PUT/PATCH request and will return updated user with modified data


```js
/* updating lastName of user with id 2 */
fetch('https://dummyjson.com/users/2', {
  method: 'PUT', /* or PATCH */
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    lastName: 'Owais'
  })
})
.then(res => res.json())
.then(console.log);

```

Show Output

```json
{
  "id": "2",
  "firstName": "Michael",
  "lastName": "Owais", // only lastName is updated
  "gender": "male",
  /* other user data */
}

```

[Delete a user](https://dummyjson.com/docs/users#users-delete)

Deleting a user will not delete it into the server.


It will simulate a DELETE request and will return deleted user with isDeleted & deletedOn keys


```js
fetch('https://dummyjson.com/users/1', {
  method: 'DELETE',
})
.then(res => res.json())
.then(console.log);

```

Show Output

```json
{
  "id": 1,
  "firstName": "Emily",
  "lastName": "Johnson",
  "maidenName": "Smith",
  "age": 28,
  "gender": "female",

  /* other user data */

  "isDeleted": true,
  "deletedOn": /* ISOTime */
}

```

[Buy me a coffee ![Coffee Icon](https://dummyjson.com/public/img/icons/coffee.svg)](https://buymeacoffee.com/muhammadovi)

[![Github](https://dummyjson.com/public/img/icons/github.svg)](https://github.com/Ovi/DummyJSON)[![Github](https://dummyjson.com/public/img/icons/twitter_x.svg)](https://x.com/DummyJSON)[![Github](https://dummyjson.com/public/img/icons/linkedin.svg)](https://linkedin.com/company/DummyJSON)