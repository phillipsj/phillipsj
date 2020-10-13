---
title: "Creating an Express API using SQL Server"
date: 2020-10-12T21:32:48-04:00
tags:
- ExpressJS
- Node
- Open Source
- SQL Server
- Microsoft And Linux
---

The majority of my experience with JavaScript started in 2008 and slowly dwindled in 2015. I have tinkered with Node in the past but never tried building anything that retrieved data from a relational database. I am now working on an example application that is going to be written using [Express](https://expressjs.com/) to create an API against an SQL Server using the [Adventure Works 2019](https://docs.microsoft.com/en-us/sql/samples/adventureworks-install-configure?view=sql-server-ver15&tabs=ssms) database. I couldn't find many examples to lean upon, and that is why I created this post. I initially thought I needed to use [tedious](https://github.com/tediousjs/tedious), which turned out to feel tedious to me, and then I discovered [mssql](https://github.com/tediousjs/node-mssql#readme), which has a better feel to me. There is support for [Connection Pooling](https://github.com/tediousjs/node-mssql#pool-management), and I leverage that in this example. I am using the global connection pool technique, so all queries will share the pool. I am still catching up on modern JavaScript and Node, so please send me any improvement you think I could make. Let's jump into the code.

## Prerequisites

You will need Node installed for your platform, and a SQL Server database with Adventure Works installed. I have created an Adventure Works container that has the database preinstalled. If you choose to use it, then you will need Docker or container tool installed.  You can find out more about the container [here](https://github.com/phillipsj/adventureworks-container).

## Setting up the project

Okay, we are now ready to create a new project.

```Bash
$ mkdir sqlapp && cd sqlapp
``` 

Now create our Node project and skip the questions.

```Bash
$ npm init --yes
Wrote to ~/sqlapp/package.json
```

Finally, let's install the packages that we need with Express first.

```Bash
$ npm install express
npm notice created a lockfile as package-lock.json. You should commit this file.
npm WARN sqlapp@1.0.0 No description
npm WARN sqlapp@1.0.0 No repository field.
  
+ express@4.17.1
added 50 packages from 37 contributors and audited 50 packages in 2.253s
found 0 vulnerabilities
```

And mssql next.

```Bash
$ npm install mssql
npm WARN deprecated request@2.88.2: request has been deprecated, see https://github.com/request/request/issues/3142
npm WARN deprecated har-validator@5.1.5: this library is no longer supported
npm WARN sqlapp@1.0.0 No description
npm WARN sqlapp@1.0.0 No repository field.

+ mssql@6.2.3
added 84 packages from 187 contributors and audited 134 packages in 4.607s

2 packages are looking for funding
  run `npm fund` for details

found 0 vulnerabilities
```

## Creating our application

The default entry point is currently set to server.js, so we can just create a *server.js* file and then open it in your favorite editor.

```Bash
$ touch server.js
```

In the *server.js* file, we can load Express and mssql.

```JavaScript
const express = require('express');
const sql = require('mssql');
```

Now we can create our Express server and configure the port we want to use.

```JavaScript
const app = express();
const port = process.env.PORT || 3200;
```

The mssql library needs configuration, and we will define that as a constant. We will either set the configuration using environment variables or default to the container's configuration mentioned previously.

```JavaScript
const config = {
   user: process.env.DB_USER || 'sa',
   password: process.env.DB_PASSWORD || 'ThisIsNotASecurePassword123',
   server: process.env.DB_SERVER || 'localhost',
   database: process.env.DB_DATABASE || 'AdventureWorks2019',
}
```

Now we can create our first API endpoint to retrieve 20 products from our database.

```JavaScript
app.get('/products', (req, res) => {
   const productQuery = `SELECT TOP 20 pc.Name  as CategoryName,
                                       psc.Name as SubCategoryName,
                                       p.name   as ProductName
                       FROM [Production].[ProductSubCategory] psc
                       JOIN [Production].[Product] p ON psc.ProductSubcategoryID = p.productsubcategoryid
                       JOIN [Production].[ProductCategory] pc on psc.ProductCategoryID = pc.ProductCategoryID`
   const request = new sql.Request();
   request.query(productQuery, (err, result) => {
      if (err) res.status(500).send(err);
      res.send(result);
   });
});
```

Now all this is left is to create our global connection pool and start our Express server. We will call the connect method passing in the configuration above. This will set a global connection pool that all queries can leverage to retrieve their connection object. We also have this configured that if an error occurs, creating a connection will log the error and exit with a non-zero exit code. The non-zero exit code comes into play if you decide to leverage this with Docker or in a Docker Compose file by setting restart to *always*. Docker will restart the app when it gets a non-zero exit code.

```JavaScript
sql.connect(config, err => {
   if (err) {
      console.log('Failed to open a SQL Database connection.', err.stack);
      process.exit(1);
   }
   app.listen(port, () => {
      console.log(`App is listening at http://localhost:${port}`);
   });
});
```

Here it is all together.

```JavaScript
const express = require('express');
const sql = require('mssql');

const app = express();
const port = process.env.PORT || 3200;

const config = {
   user: process.env.DB_USER || 'sa',
   password: process.env.DB_PASSWORD || 'ThisIsNotASecurePassword123',
   server: process.env.DB_SERVER || 'localhost',
   database: process.env.DB_DATABASE || 'AdventureWorks2019',
}

app.get('/products', (req, res) => {
   const productQuery = `SELECT TOP 20 pc.Name  as CategoryName,
                           psc.Name as SubCategoryName,
                          p.name   as ProductName
                       FROM [Production].[ProductSubCategory] psc
                       JOIN [Production].[Product] p ON psc.ProductSubcategoryID = p.productsubcategoryid
                       JOIN [Production].[ProductCategory] pc on psc.ProductCategoryID = pc.ProductCategoryID`
   const request = new sql.Request();
   request.query(productQuery, (err, result) => {
      if (err) res.status(500).send(err);
      res.send(result);
   });
});

sql.connect(config, err => {
   if (err) {
      console.log('Failed to open a SQL Database connection.', err.stack);
      process.exit(1);
   }
   app.listen(port, () => {
      console.log(`App is listening at http://localhost:${port}`);
   });
});
```

## Running the application

Running our application is really just two commands: starting our Adventure Works Docker container and then running our application.

```Bash
$ docker run -d -p 1433:1433 --name adventureworks --hostname adventureworks phillipsj/adventureworks
c6d13961b161bab431732baf08b50e00d9dcfdd3183f3fbcba5c3acc6596d071
```

Now with our database running, let's execute our Node app.

```Bash
$ node ./server.js
tedious deprecated The default value for `config.options.enableArithAbort` will change from `false` to `true` in the next major version of `tedious`. Set the value to `true` or `false` explicitly to silence this message. node_modules/mssql/lib/tedious/connection-pool.js:61:23
App is listening at http://localhost:3200
```

Now we can make a call to *http://localhost:3200/products* and return a list of 20 products.

```Bash
$ curl http://localhost:3200/products
{"recordsets":[[{"CategoryName":"Bikes"....
```

## Conclusion

I learned a lot from getting this simple example functioning. It was nice to reacquaint myself with JavaScript and Node. 

Thanks for reading,

Jamie
