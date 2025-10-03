---
url: "https://dummyjson.com/docs/image"
title: "Image - DummyJSON - Free Fake REST API for Placeholder JSON Data"
---

# ![svg icon](https://dummyjson.com/public/img/icons/image.svg) Image - Docs

The **image** endpoint provides customizable placeholder images by specifying size in the URL, with options for background color, text color, and display text, ideal for use in websites and wireframes.


The base URL is: **[dummyjson.com/image](https://dummyjson.com/image)**

[Generate square image](https://dummyjson.com/docs/image#image-square)

```js
// https://dummyjson.com/image/SIZE
fetch('https://dummyjson.com/image/150')
.then(response => response.blob()) // Convert response to blob
.then(blob => {
  console.log('Fetched image blob:', blob);
})
// Blob {size: SIZE, type: 'image/png'}

```

### Output:

![150x150](https://dummyjson.com/image/150)

[Generate custom size image](https://dummyjson.com/docs/image#image-custom-size)

```js
// https://dummyjson.com/image/WIDTHxHEIGHT
fetch('https://dummyjson.com/image/200x100')
.then(response => response.blob()) // Convert response to blob
.then(blob => {
  console.log('Fetched image blob:', blob);
})
// Blob {size: SIZE, type: 'image/png'}

```

### Output:

![200x100](https://dummyjson.com/image/200x100)

[Generate image with custom text](https://dummyjson.com/docs/image#image-custom-text)

```js
// https://dummyjson.com/image/SIZE/?text=TEXT
fetch('https://dummyjson.com/image/400x200/008080/ffffff?text=Hello+Peter')
.then(response => response.blob()) // Convert response to blob
.then(blob => {
  console.log('Fetched image blob:', blob);
})
// Blob {size: SIZE, type: 'image/png'}

```

### Output:

![400x200](https://dummyjson.com/image/400x200/008080/ffffff?text=Hello+Peter)

[Generate image with custom colors](https://dummyjson.com/docs/image#image-custom-color)

```js
// https://dummyjson.com/image/SIZE/BACKGROUND/COLOR
fetch('https://dummyjson.com/image/400x200/282828')
.then(response => response.blob()) // Convert response to blob
.then(blob => {
  console.log('Fetched image blob:', blob);
})
// Blob {size: SIZE, type: 'image/png'}

```

### Output:

![400x200](https://dummyjson.com/image/400x200/282828)

[Generate image with different formats](https://dummyjson.com/docs/image#image-format)

Supported Formats:
**[png](https://dummyjson.com/image/400x200?type=png),**
**[jpeg](https://dummyjson.com/image/400x200?type=jpg),**
**[webp](https://dummyjson.com/image/400x200?type=webp)**

```js
// https://dummyjson.com/image/SIZE/BACKGROUND/COLOR
fetch('https://dummyjson.com/image/400x200?type=webp&text=I+am+a+webp+image')
.then(response => response.blob()) // Convert response to blob
.then(blob => {
  console.log('Fetched image blob:', blob);
})
// Blob {size: SIZE, type: 'image/webp'}

```

### Output:

![400x200](https://dummyjson.com/image/400x200?type=webp&text=I+am+a+webp+image)

[Generate image with custom font family](https://dummyjson.com/docs/image#image-font-family)

Supported Fonts:


**[bitter](https://dummyjson.com/image/250?text=Hello+Peter!&fontFamily=bitter),**
**[cairo](https://dummyjson.com/image/250?text=Hello+Peter!&fontFamily=cairo),**
**[comfortaa](https://dummyjson.com/image/250?text=Hello+Peter!&fontFamily=comfortaa),**
**[cookie](https://dummyjson.com/image/250?text=Hello+Peter!&fontFamily=cookie),**
**[dosis](https://dummyjson.com/image/250?text=Hello+Peter!&fontFamily=dosis),**
**[gotham](https://dummyjson.com/image/250?text=Hello+Peter!&fontFamily=gotham),**
**[lobster](https://dummyjson.com/image/250?text=Hello+Peter!&fontFamily=lobster),**
**[marhey](https://dummyjson.com/image/250?text=Hello+Peter!&fontFamily=marhey),**
**[pacifico](https://dummyjson.com/image/250?text=Hello+Peter!&fontFamily=pacifico),**
**[poppins](https://dummyjson.com/image/250?text=Hello+Peter!&fontFamily=poppins),**
**[quicksand](https://dummyjson.com/image/250?text=Hello+Peter!&fontFamily=quicksand),**
**[qwigley](https://dummyjson.com/image/250?text=Hello+Peter!&fontFamily=qwigley),**
**[satisfy](https://dummyjson.com/image/250?text=Hello+Peter!&fontFamily=satisfy),**
**[ubuntu](https://dummyjson.com/image/250?text=Hello+Peter!&fontFamily=ubuntu)**

```js
// https://dummyjson.com/image/SIZE/BACKGROUND/COLOR
fetch('https://dummyjson.com/image/400x200/282828?fontFamily=pacifico&text=I+am+a+pacifico+font')
.then(response => response.blob()) // Convert response to blob
.then(blob => {
  console.log('Fetched image blob:', blob);
})
// Blob {size: SIZE, type: 'image/png'}

```

### Output:

![400x200](https://dummyjson.com/image/400x200/282828?fontFamily=pacifico&text=I+am+a+pacifico+font)

[Generate image with custom font size](https://dummyjson.com/docs/image#image-font-size)

```js
// https://dummyjson.com/image/SIZE/?text=TEXT&fontSize=FONT_SIZE
fetch('https://dummyjson.com/image/400x200/008080/ffffff?text=Hello+Peter!&fontSize=16')
.then(response => response.blob()) // Convert response to blob
.then(blob => {
  console.log('Fetched image blob:', blob);
})
// Blob {size: SIZE, type: 'image/png'}

```

### Output:

![400x200](https://dummyjson.com/image/400x200/008080/ffffff?text=Hello+Peter!&fontSize=16)

[Generate identicon](https://dummyjson.com/docs/image#image-identicon)

```js
// https://dummyjson.com/icon/HASH/SIZE/?type=png (or svg)
fetch('https://dummyjson.com/icon/abc123/150') // png is default
.then(response => response.blob()) // Convert response to blob
.then(blob => {
  console.log('Fetched image blob:', blob);
})
// Blob {size: SIZE, type: 'image/png'}

```

### Output:

![identicon](https://dummyjson.com/icon/abc123/150)

[Buy me a coffee ![Coffee Icon](https://dummyjson.com/public/img/icons/coffee.svg)](https://buymeacoffee.com/muhammadovi)

[![Github](https://dummyjson.com/public/img/icons/github.svg)](https://github.com/Ovi/DummyJSON)[![Github](https://dummyjson.com/public/img/icons/twitter_x.svg)](https://x.com/DummyJSON)[![Github](https://dummyjson.com/public/img/icons/linkedin.svg)](https://linkedin.com/company/DummyJSON)