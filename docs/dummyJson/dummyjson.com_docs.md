---
url: "https://dummyjson.com/docs"
title: "Docs - DummyJSON - Free Fake REST API for Placeholder JSON Data"
---

# ![svg icon](https://dummyjson.com/public/img/icons/home.svg) DummyJSON - Docs

DummyJSON can be used with any type of front end project that needs products, carts, users, todos or any dummy
data in JSON format.


You can use examples below to check how DummyJSON works.


Feel free to enjoy it in your awesome projects!


[Test Route](https://dummyjson.com/docs#intro-test)

See if your internet is working 😉

```js
// Could be GET or POST/PUT/PATCH/DELETE
fetch('https://dummyjson.com/test')
.then(res => res.json())
.then(console.log);

/* { status: 'ok', method: 'GET' } */

```

[Limiting Resources](https://dummyjson.com/docs#intro-limit)

All the resources can be used with query params to achieve pagination and get limited data. limit=0 clears
the limit and you get all items


```js
fetch('https://dummyjson.com/RESOURCE/?limit=10&skip=5&select=key1,key2,key3');

```

It can be comma separated, OR, you can use multiple select query params to get multiple keys.


```js
fetch('https://dummyjson.com/RESOURCE/?limit=10&skip=5&select=key1&select=key2&select=key3');

```

[Delay Responses](https://dummyjson.com/docs#intro-delay)

You can simulate a delay in responses using the delay param, delay can be any number between 0 and 5000
milliseconds


```js
fetch('https://dummyjson.com/RESOURCE/?delay=1000');

```

[Authorizing Resources](https://dummyjson.com/docs#intro-auth)

All resources can be accessed via an access token to test as a logged-in user.

Go to auth module and generate an auth access token to get data as an authorized user

```js
/* providing access token in bearer */
fetch('https://dummyjson.com/auth/RESOURCE', {
  method: 'GET', /* or POST/PUT/PATCH/DELETE */
  headers: {
    'Authorization': 'Bearer /* YOUR_ACCESS_TOKEN_HERE */',
    'Content-Type': 'application/json'
  },
})
.then(res => res.json())
.then(console.log);

```

[IP Address](https://dummyjson.com/docs#intro-ip)

Get the IP address of the client

```js
// GET
fetch('https://dummyjson.com/ip')
.then(res => res.json())
.then(console.log);

/* { ip: '127.0.0.1', userAgent: 'Mozilla/5.0 ...' } */

```

[Buy me a coffee ![Coffee Icon](https://dummyjson.com/public/img/icons/coffee.svg)](https://buymeacoffee.com/muhammadovi)

[![Github](https://dummyjson.com/public/img/icons/github.svg)](https://github.com/Ovi/DummyJSON)[![Github](https://dummyjson.com/public/img/icons/twitter_x.svg)](https://x.com/DummyJSON)[![Github](https://dummyjson.com/public/img/icons/linkedin.svg)](https://linkedin.com/company/DummyJSON)