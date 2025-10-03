---
url: "https://dummyjson.com/docs/auth"
title: "Auth - DummyJSON - Free Fake REST API for Placeholder JSON Data"
---

# ![svg icon](https://dummyjson.com/public/img/icons/lock.svg) Auth - Docs

The **auth** endpoint provides details about the user authentication and authorization and refresh tokens.


[Login user and get tokens](https://dummyjson.com/docs/auth#auth-login)

You can use any user's credentials from [dummyjson.com/users](https://dummyjson.com/users). Tokens are returned in the response and set as cookies.


```js
fetch('https://dummyjson.com/auth/login', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({

    username: 'emilys',
    password: 'emilyspass',
    expiresInMins: 30, // optional, defaults to 60
  }),
  credentials: 'include' // Include cookies (e.g., accessToken) in the request
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

[Get current auth user](https://dummyjson.com/docs/auth#auth-me)

```js
/* providing accessToken in bearer */
fetch('https://dummyjson.com/auth/me', {
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
  "username": "emilys",
  "email": "emily.johnson@x.dummyjson.com",
  "firstName": "Emily",
  "lastName": "Johnson",
  "gender": "female",
  "image": "https://dummyjson.com/icon/emilys/128"
  ... // other user fields
}

```

[Refresh auth session](https://dummyjson.com/docs/auth#auth-refresh)

Extend the session and create a new access token without username and password. Tokens can also be passed using cookies.

```js
fetch('https://dummyjson.com/auth/refresh', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    refreshToken: '/* YOUR_REFRESH_TOKEN_HERE */', // Optional, if not provided, the server will use the cookie
    expiresInMins: 30, // optional (FOR ACCESS TOKEN), defaults to 60
  }),
  credentials: 'include' // Include cookies (e.g., accessToken) in the request
})
.then(res => res.json())
.then(console.log);

```

Show Output

```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...", // new accessToken (returned in both response and cookies)
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." // new refreshToken (returned in both response and cookies)
}

```

[Buy me a coffee ![Coffee Icon](https://dummyjson.com/public/img/icons/coffee.svg)](https://buymeacoffee.com/muhammadovi)

[![Github](https://dummyjson.com/public/img/icons/github.svg)](https://github.com/Ovi/DummyJSON)[![Github](https://dummyjson.com/public/img/icons/twitter_x.svg)](https://x.com/DummyJSON)[![Github](https://dummyjson.com/public/img/icons/linkedin.svg)](https://linkedin.com/company/DummyJSON)