---
url: "https://dummyjson.com/docs/products"
title: "Products - DummyJSON - Free Fake REST API for Placeholder JSON Data"
---

# ![svg icon](https://dummyjson.com/public/img/icons/headphones.svg) Products - Docs

The **products** endpoint provides a comprehensive dataset of sample product information, including details like names, prices, descriptions, images, and categories, ideal for testing and prototyping e-commerce applications.


[Get all products](https://dummyjson.com/docs/products#products-all)

By default you will get 30 items, use [Limit and skip](https://dummyjson.com/docs/products#products-limit_skip) to paginate through all items.


```js
fetch('https://dummyjson.com/products')
.then(res => res.json())
.then(console.log);

```

Show Output

```json
{
  "products": [\
    {\
      "id": 1,\
      "title": "Essence Mascara Lash Princess",\
      "description": "The Essence Mascara Lash Princess is a popular mascara known for its volumizing and lengthening effects. Achieve dramatic lashes with this long-lasting and cruelty-free formula.",\
      "category": "beauty",\
      "price": 9.99,\
      "discountPercentage": 7.17,\
      "rating": 4.94,\
      "stock": 5,\
      "tags": [\
        "beauty",\
        "mascara"\
      ],\
      "brand": "Essence",\
      "sku": "RCH45Q1A",\
      "weight": 2,\
      "dimensions": {\
        "width": 23.17,\
        "height": 14.43,\
        "depth": 28.01\
      },\
      "warrantyInformation": "1 month warranty",\
      "shippingInformation": "Ships in 1 month",\
      "availabilityStatus": "Low Stock",\
      "reviews": [\
        {\
          "rating": 2,\
          "comment": "Very unhappy with my purchase!",\
          "date": "2024-05-23T08:56:21.618Z",\
          "reviewerName": "John Doe",\
          "reviewerEmail": "john.doe@x.dummyjson.com"\
        },\
        {\
          "rating": 2,\
          "comment": "Not as described!",\
          "date": "2024-05-23T08:56:21.618Z",\
          "reviewerName": "Nolan Gonzalez",\
          "reviewerEmail": "nolan.gonzalez@x.dummyjson.com"\
        },\
        {\
          "rating": 5,\
          "comment": "Very satisfied!",\
          "date": "2024-05-23T08:56:21.618Z",\
          "reviewerName": "Scarlett Wright",\
          "reviewerEmail": "scarlett.wright@x.dummyjson.com"\
        }\
      ],\
      "returnPolicy": "30 days return policy",\
      "minimumOrderQuantity": 24,\
      "meta": {\
        "createdAt": "2024-05-23T08:56:21.618Z",\
        "updatedAt": "2024-05-23T08:56:21.618Z",\
        "barcode": "9164035109868",\
        "qrCode": "..."\
      },\
      "thumbnail": "...",\
      "images": ["...", "...", "..."]\
    },\
    {...},\
    {...},\
    {...}\
    // 30 items\
  ],
  "total": 194,
  "skip": 0,
  "limit": 30
}

```

[Get a single product](https://dummyjson.com/docs/products#products-single)

```js
fetch('https://dummyjson.com/products/1')
.then(res => res.json())
.then(console.log);

```

Show Output

```json
{
  "id": 1,
  "title": "Essence Mascara Lash Princess",
  "description": "The Essence Mascara Lash Princess is a popular mascara known for its volumizing and lengthening effects. Achieve dramatic lashes with this long-lasting and cruelty-free formula.",
  "category": "beauty",
  "price": 9.99,
  "discountPercentage": 7.17,
  "rating": 4.94,
  "stock": 5,
  "tags": [\
    "beauty",\
    "mascara"\
  ],
  "brand": "Essence",
  "sku": "RCH45Q1A",
  "weight": 2,
  "dimensions": {
    "width": 23.17,
    "height": 14.43,
    "depth": 28.01
  },
  "warrantyInformation": "1 month warranty",
  "shippingInformation": "Ships in 1 month",
  "availabilityStatus": "Low Stock",
  "reviews": [\
    {\
      "rating": 2,\
      "comment": "Very unhappy with my purchase!",\
      "date": "2024-05-23T08:56:21.618Z",\
      "reviewerName": "John Doe",\
      "reviewerEmail": "john.doe@x.dummyjson.com"\
    },\
    {\
      "rating": 2,\
      "comment": "Not as described!",\
      "date": "2024-05-23T08:56:21.618Z",\
      "reviewerName": "Nolan Gonzalez",\
      "reviewerEmail": "nolan.gonzalez@x.dummyjson.com"\
    },\
    {\
      "rating": 5,\
      "comment": "Very satisfied!",\
      "date": "2024-05-23T08:56:21.618Z",\
      "reviewerName": "Scarlett Wright",\
      "reviewerEmail": "scarlett.wright@x.dummyjson.com"\
    }\
  ],
  "returnPolicy": "30 days return policy",
  "minimumOrderQuantity": 24,
  "meta": {
    "createdAt": "2024-05-23T08:56:21.618Z",
    "updatedAt": "2024-05-23T08:56:21.618Z",
    "barcode": "9164035109868",
    "qrCode": "..."
  },
  "thumbnail": "...",
  "images": ["...", "...", "..."]
}

```

[Search products](https://dummyjson.com/docs/products#products-search)

```js
fetch('https://dummyjson.com/products/search?q=phone')
.then(res => res.json())
.then(console.log);

```

Show Output

```json
{
  "products": [\
    {\
      "id": 101,\
      "title": "title": "Apple AirPods Max Silver",\
      "category": "mobile-accessories"\
      ...\
    },\
    {...},\
    {...},\
    {...}\
    // 23 results\
  ],
  "total": 23,
  "skip": 0,
  "limit": 23
}

```

[Limit and skip products](https://dummyjson.com/docs/products#products-limit_skip)

You can pass limit and skip params to limit and skip the
results for pagination, and use limit=0 to get all items.


You can pass select as query params with comma-separated values
to select specific data


```js
fetch('https://dummyjson.com/products?limit=10&skip=10&select=title,price')
.then(res => res.json())
.then(console.log);

```

Show Output

```json
{
  "products": [\
    {\
      "id": 11, // first 10 items are skipped\
      "title": "Annibale Colombo Bed",\
      "price": 1899.99\
    },\
    {...},\
    {...},\
    {...}\
    // 10 items\
  ],
  "total": 194,
  "skip": 10,
  "limit": 10
}

```

[Sort products](https://dummyjson.com/docs/products#products-sort)

You can pass sortBy and order params to sort the results,
sortBy should be field name and order should be "asc" or "desc"


```js
fetch('https://dummyjson.com/products?sortBy=title&order=asc')
.then(res => res.json())
.then(console.log);

```

Show Output

```json
{
  "products": [\
    {\
      "id": 167,\
      "title": "300 Touring", // sorted by title in ascending order\
      "price": 28999.99\
      /* rest product data */\
    },\
    {\
      "id": 99,\
      "title": "Amazon Echo Plus", // sorted by title in ascending order\
      "price": 99.99\
      /* rest product data */\
    },\
    {...}\
    // 30 items\
  ],
  "total": 194,
  "skip": 0,
  "limit": 30
}

```

[Get all products categories](https://dummyjson.com/docs/products#products-categories)

```js
fetch('https://dummyjson.com/products/categories')
.then(res => res.json())
.then(console.log);

```

Show Output

```json
[\
  {\
    "slug": "beauty",\
    "name": "Beauty",\
    "url": "https://dummyjson.com/products/category/beauty"\
  },\
  {\
    "slug": "fragrances",\
    "name": "Fragrances",\
    "url": "https://dummyjson.com/products/category/fragrances"\
  },\
  {\
    "slug": "furniture",\
    "name": "Furniture",\
    "url": "https://dummyjson.com/products/category/furniture"\
  },\
  {...},\
  {...},\
  {...}\
  // more items\
]

```

[Get products category list](https://dummyjson.com/docs/products#products-category_list)

```js
fetch('https://dummyjson.com/products/category-list')
.then(res => res.json())
.then(console.log);

```

Show Output

```json
[\
  "beauty",\
  "fragrances",\
  "furniture",\
  "groceries",\
  "home-decoration",\
  "kitchen-accessories",\
  "laptops",\
  "mens-shirts",\
  "mens-shoes",\
  "mens-watches",\
  "mobile-accessories",\
  "motorcycle",\
  "skin-care",\
  "smartphones",\
  "sports-accessories",\
  "sunglasses",\
  "tablets",\
  "tops",\
  "vehicle",\
  "womens-bags",\
  "womens-dresses",\
  "womens-jewellery",\
  "womens-shoes",\
  "womens-watches"\
]

```

[Get products by a category](https://dummyjson.com/docs/products#products-category)

```js
fetch('https://dummyjson.com/products/category/smartphones')
.then(res => res.json())
.then(console.log);

```

Show Output

```json
{
  "products": [\
    {\
      "id": 122,\
      "title": "iPhone 6",\
      "category": "smartphones",\
      ...\
    },\
    {...}\
    // 16 items\
  ],
  "total": 16,
  "skip": 0,
  "limit": 16
}

```

[Add a new product](https://dummyjson.com/docs/products#products-add)

Adding a new product will not add it into the server.


It will simulate a POST request and will return the new created product with a new id


```js
fetch('https://dummyjson.com/products/add', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    title: 'BMW Pencil',
    /* other product data */
  })
})
.then(res => res.json())
.then(console.log);

```

Show Output

```json
{
  "id": 195,
  "title": "BMW Pencil",
  /* other product data */
}

```

[Update a product](https://dummyjson.com/docs/products#products-update)

Updating a product will not update it into the server.


It will simulate a PUT/PATCH request and will return updated product with modified data


```js
/* updating title of product with id 1 */
fetch('https://dummyjson.com/products/1', {
  method: 'PUT', /* or PATCH */
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    title: 'iPhone Galaxy +1'
  })
})
.then(res => res.json())
.then(console.log);

```

Show Output

```json
{
  "id": 1,
  "title": "iPhone Galaxy +1", // only title was updated
  /* other product data */
}

```

[Delete a product](https://dummyjson.com/docs/products#products-delete)

Deleting a product will not delete it into the server.


It will simulate a DELETE request and will return deleted product with isDeleted & deletedOn keys


```js
fetch('https://dummyjson.com/products/1', {
  method: 'DELETE',
})
.then(res => res.json())
.then(console.log);

```

Show Output

```json
{
  "id": 1,
  "title": "Essence Mascara Lash Princess",
  /* other product data */
  "isDeleted": true,
  "deletedOn": /* ISOTime */
}

```

[Buy me a coffee ![Coffee Icon](https://dummyjson.com/public/img/icons/coffee.svg)](https://buymeacoffee.com/muhammadovi)

[![Github](https://dummyjson.com/public/img/icons/github.svg)](https://github.com/Ovi/DummyJSON)[![Github](https://dummyjson.com/public/img/icons/twitter_x.svg)](https://x.com/DummyJSON)[![Github](https://dummyjson.com/public/img/icons/linkedin.svg)](https://linkedin.com/company/DummyJSON)