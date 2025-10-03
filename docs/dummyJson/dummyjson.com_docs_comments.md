---
url: "https://dummyjson.com/docs/comments"
title: "Comments - DummyJSON - Free Fake REST API for Placeholder JSON Data"
---

# ![svg icon](https://dummyjson.com/public/img/icons/chat.svg) Comments - Docs

The **comments** endpoint provides a dataset of sample user comments, including details like usernames, post IDs, and comment texts, ideal for testing and prototyping social interactions and feedback features in web applications.


[Get all comments](https://dummyjson.com/docs/comments#comments-all)

By default you will get 30 items, use [Limit and skip](https://dummyjson.com/docs/comments#comments-limit_skip) to paginate through all items.


```js
fetch('https://dummyjson.com/comments')
.then(res => res.json())
.then(console.log);

```

Show Output

```json
{
  "comments": [\
    {\
      "id": 1,\
      "body": "This is some awesome thinking!",\
      "postId": 242,\
      "likes": 3,\
      "user": {\
        "id": 105,\
        "username": "emmac",\
        "fullName": "Emma Wilson"\
      }\
    },\
    {\
      "id": 2,\
      "body": "What terrific math skills you're showing!",\
      "postId": 46,\
      "likes": 4,\
      "user": {\
        "id": 183,\
        "username": "cameronp",\
        "fullName": "Cameron Perez"\
      }\
    },\
    {...},\
    {...}\
    // 30 items\
  ],
  "total": 340,
  "skip": 0,
  "limit": 30
}

```

[Get a single comment](https://dummyjson.com/docs/comments#comments-single)

```js
fetch('https://dummyjson.com/comments/1')
.then(res => res.json())
.then(console.log);

```

Show Output

```json
{
  "id": 1,
  "body": "This is some awesome thinking!",
  "postId": 242,
  "likes": 3,
  "user": {
    "id": 105,
    "username": "emmac",
    "fullName": "Emma Wilson"
  }
}

```

[Limit and skip comments](https://dummyjson.com/docs/comments#comments-limit_skip)

You can pass limit and skip params to limit and skip the
results for pagination, and use limit=0 to get all items.


You can pass select as query params with comma-separated values
to select specific data


```js
fetch('https://dummyjson.com/comments?limit=10&skip=10&select=body,postId')
.then(res => res.json())
.then(console.log);

```

Show Output

```json
{
  "comments": [\
    {\
      "id": 11,\
      "body": "It was a pleasure to grade this!",\
      "postId": 156,\
      "likes": 8,\
      "user": {\
        "id": 162,\
        "username": "mateob",\
        "fullName": "Mateo Bennett"\
      }\
    },\
    {...},\
    {...},\
    {...}\
    // 10 items\
  ],
  "total": 340,
  "skip": 10,
  "limit": 10
}

```

[Get all comments by post id](https://dummyjson.com/docs/comments#comments-post)

```js
fetch('https://dummyjson.com/comments/post/6')
.then(res => res.json())
.then(console.log);

```

Show Output

```json
{
  "comments": [\
    {\
      "id": 15,\
      "body": "You've shown so much growth!",\
      "postId": 6, // post id is 6\
      "likes": 2,\
      "user": {\
        "id": 17,\
        "username": "evelyns",\
        "fullName": "Evelyn Sanchez"\
      }\
    }\
  ],
  "total": 1,
  "skip": 0,
  "limit": 1
}

```

[Add a new comment](https://dummyjson.com/docs/comments#comments-add)

Adding a new comment will not add it into the server.


It will simulate a POST request and will return the new created comment with a new id


```js
fetch('https://dummyjson.com/comments/add', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    body: 'This makes all sense to me!',
    postId: 3,
    userId: 5,
  })
})
.then(res => res.json())
.then(console.log);

```

Show Output

```json
{
  "id": 341,
  "body": "This makes all sense to me!",
  "postId": 3,
  "user": {
    "id": 5,
    "username": "emmaj",
    fullName: "Emma Miller"
  }
}

```

[Update a comment](https://dummyjson.com/docs/comments#comments-update)

Updating a comment will not update it into the server.


It will simulate a PUT/PATCH request and will return updated comment with modified data


```js
/* updating body of comment with id 1 */
fetch('https://dummyjson.com/comments/1', {
  method: 'PUT', /* or PATCH */
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    body: 'I think I should shift to the moon',
  })
})
.then(res => res.json())
.then(console.log);

```

Show Output

```json
{
  "id": 1,
  "body": "I think I should shift to the moon", // only body was updated
  "postId": 242,
  "likes": 3,
  "user": {
    "id": 105,
    "username": "emmac",
    "fullName": "Emma Wilson"
  }
}

```

[Delete a comment](https://dummyjson.com/docs/comments#comments-delete)

Deleting a comment will not delete it into the server.


It will simulate a DELETE request and will return deleted comment with isDeleted & deletedOn keys


```js
fetch('https://dummyjson.com/comments/1', {
  method: 'DELETE',
})
.then(res => res.json())
.then(console.log);

```

Show Output

```json
{
  "id": 1,
  "body": "This is some awesome thinking!",
  "postId": 242,
  "likes": 3,
  "user": {
    "id": 105,
    "username": "emmac",
    "fullName": "Emma Wilson"
  },
  "isDeleted": true,
  "deletedOn": /* ISOTime */
}

```

[Buy me a coffee ![Coffee Icon](https://dummyjson.com/public/img/icons/coffee.svg)](https://buymeacoffee.com/muhammadovi)

[![Github](https://dummyjson.com/public/img/icons/github.svg)](https://github.com/Ovi/DummyJSON)[![Github](https://dummyjson.com/public/img/icons/twitter_x.svg)](https://x.com/DummyJSON)[![Github](https://dummyjson.com/public/img/icons/linkedin.svg)](https://linkedin.com/company/DummyJSON)