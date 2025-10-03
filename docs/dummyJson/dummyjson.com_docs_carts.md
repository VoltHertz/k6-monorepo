---
url: "https://dummyjson.com/docs/carts"
title: "Carts - DummyJSON - Free Fake REST API for Placeholder JSON Data"
---

# ![svg icon](https://dummyjson.com/public/img/icons/cart.svg) Carts - Docs

The **carts** endpoint offers a dataset of sample shopping cart data, including details like cart items, quantities, prices, and user IDs, useful for testing and prototyping e-commerce functionalities such as cart management and checkout processes.


[Get all carts](https://dummyjson.com/docs/carts#carts-all)

```js
fetch('https://dummyjson.com/carts')
.then(res => res.json())
.then(console.log);

```

Show Output

```json
{
  "carts": [\
    {\
      "id": 1,\
      "products": [\
        {\
          "id": 144,\
          "title": "Cricket Helmet",\
          "price": 44.99,\
          "quantity": 4,\
          "total": 179.96,\
          "discountPercentage": 11.47,\
          "discountedTotal": 159.32,\
          "thumbnail": "https://cdn.dummyjson.com/products/images/sports-accessories/Cricket%20Helmet/thumbnail.png"\
        },\
        {...}\
        // more products\
      ],\
      "total": 4794.8,\
      "discountedTotal": 4288.95,\
      "userId": 142,\
      "totalProducts": 5,\
      "totalQuantity": 20\
    },\
    {...},\
    {...},\
    {...}\
    // 30 items\
  ],
  "total": 50,
  "skip": 0,
  "limit": 30
}

```

[Get a single cart](https://dummyjson.com/docs/carts#carts-single)

```js
fetch('https://dummyjson.com/carts/1')
.then(res => res.json())
.then(console.log);

```

Show Output

```json
{
  "id": 1,
  "products": [\
    {\
      "id": 144,\
      "title": "Cricket Helmet",\
      "price": 44.99,\
      "quantity": 4,\
      "total": 179.96,\
      "discountPercentage": 11.47,\
      "discountedTotal": 159.32,\
      "thumbnail": "https://cdn.dummyjson.com/products/images/sports-accessories/Cricket%20Helmet/thumbnail.png"\
    },\
    {...}\
    // more products\
  ],
  "total": 4794.8,
  "discountedTotal": 4288.95,
  "userId": 142,
  "totalProducts": 5,
  "totalQuantity": 20
}

```

[Get carts by a user](https://dummyjson.com/docs/carts#carts-user)

```js
// getting carts by user with id 5
fetch('https://dummyjson.com/carts/user/5')
.then(res => res.json())
.then(console.log);

```

Show Output

```json
{
  "carts": [\
    {\
      "id": 19,\
      "products": [\
        {\
          "id": 144,\
          "title": "Cricket Helmet",\
          "price": 44.99,\
          "quantity": 4,\
          "total": 179.96,\
          "discountPercentage": 11.47,\
          "discountedTotal": 159.32,\
          "thumbnail": "https://cdn.dummyjson.com/products/images/sports-accessories/Cricket%20Helmet/thumbnail.png"\
        },\
        {...}\
        // more products\
      ],\
      "total": 2492,\
      "discountedTotal": 2140,\
      "userId": 5, // user id is 5\
      "totalProducts": 5,\
      "totalQuantity": 14\
    }\
  ],
  "total": 1,
  "skip": 0,
  "limit": 1
}

```

[Add a new cart](https://dummyjson.com/docs/carts#carts-add)

Adding a new cart will not add it into the server.


It will simulate a POST request and will return the new created cart with a new id


You can provide a userId and array of products as objects, containing productId & quantity

```js
fetch('https://dummyjson.com/carts/add', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    userId: 1,
    products: [\
      {\
        id: 144,\
        quantity: 4,\
      },\
      {\
        id: 98,\
        quantity: 1,\
      },\
    ]
  })
})
.then(res => res.json())
.then(console.log);

```

Show Output

```json
  {
    "id": 51,
    "products": [ // products were added by id\
      {\
        "id": 98,\
        "title": "Rolex Submariner Watch",\
        "price": 13999.99,\
        "quantity": 4,\
        "total": 55999.96,\
        "discountPercentage": 0.82,\
        "discountedPrice": 55541,\
        "thumbnail": "https://cdn.dummyjson.com/products/images/mens-watches/Rolex%20Submariner%20Watch/thumbnail.png"\
      },\
      {\
        "id": 144,\
        "title": "Cricket Helmet",\
        "price": 44.99,\
        "quantity": 1,\
        "total": 44.99,\
        "discountPercentage": 10.75,\
        "discountedPrice": 40,\
        "thumbnail": "https://cdn.dummyjson.com/products/images/sports-accessories/Cricket%20Helmet/thumbnail.png"\
      }\
    ],
    "total": 56044.95, // total was calculated with quantity
    "discountedTotal": 55581,
    "userId": 1, // user id is 1
    "totalProducts": 2,
    "totalQuantity": 5 // total quantity of items
}

```

[Update a cart](https://dummyjson.com/docs/carts#carts-update)

Updating a cart will not update it into the server.


It will simulate a PUT/PATCH request and will return updated cart with modified data


Pass "merge: true" to include old products when updating


You can provide a userId and array of products as objects, containing productId & quantity

```js
/* adding products in cart with id 1 */
fetch('https://dummyjson.com/carts/1', {
  method: 'PUT', /* or PATCH */
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    merge: true, // this will include existing products in the cart
    products: [\
      {\
        id: 1,\
        quantity: 1,\
      },\
    ]
  })
})
.then(res => res.json())
.then(console.log);

```

Show Output

```json
{
  "id": 1,
  "products": [\
    {\
      "id": 1,\
      "title": "Essence Mascara Lash Princess",\
      "price": 9.99,\
      "quantity": 1,\
      "total": 9.99,\
      "discountPercentage": 7.17,\
      "discountedPrice": 9,\
      "thumbnail": "https://cdn.dummyjson.com/products/images/beauty/Essence%20Mascara%20Lash%20Princess/thumbnail.png"\
    }\
    {...}\
    // other old products\
  ],
  "total": 103784.84, // total was updated
  "discountedTotal": 89695, // discounted total was updated
  "userId": 33,
  "totalProducts": 5, // total products were updated
  "totalQuantity": 16 // total quantity was updated
}

```

[Delete a cart](https://dummyjson.com/docs/carts#carts-delete)

Deleting a cart will not delete it into the server.


It will simulate a DELETE request and will return deleted cart with isDeleted & deletedOn keys


```js
fetch('https://dummyjson.com/carts/1', {
  method: 'DELETE',
})
.then(res => res.json())
.then(console.log);

```

Show Output

```json
{
  "id": 1,
  "products": [\
    {\
      "id": 168,\
      "title": "Charger SXT RWD",\
      "price": 32999.99,\
      "quantity": 3,\
      "total": 98999.97,\
      "discountPercentage": 13.39,\
      "discountedTotal": 85743.87,\
      "thumbnail": "https://cdn.dummyjson.com/products/images/vehicle/Charger%20SXT%20RWD/thumbnail.png"\
    },\
    {...},\
    // more products\
  ],
  "total": 103774.85,
  "discountedTotal": 89686.65,
  "userId": 33,
  "totalProducts": 4,
  "totalQuantity": 15,
  "isDeleted": true,
  "deletedOn": /* ISOTime */
}

```

[Buy me a coffee ![Coffee Icon](https://dummyjson.com/public/img/icons/coffee.svg)](https://buymeacoffee.com/muhammadovi)

[![Github](https://dummyjson.com/public/img/icons/github.svg)](https://github.com/Ovi/DummyJSON)[![Github](https://dummyjson.com/public/img/icons/twitter_x.svg)](https://x.com/DummyJSON)[![Github](https://dummyjson.com/public/img/icons/linkedin.svg)](https://linkedin.com/company/DummyJSON)