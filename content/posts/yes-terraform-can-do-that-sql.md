---
title: "Yes, Terraform can do that: SQL"
date: 2020-03-14T22:19:04-04:00
draft: true
tags:
- Open Source
- Terraform
- HashiCorp
---

This post is going to be the first in a new collection of posts about what you can do with Terraform. I am continually learning about new things to use Terraform to accomplish. Most of these have naturally been things that I have needed to do that have helped me discover these options, and the others will be things that I just found interesting.  Let's start diving into Terraforming SQL.

Terraform has two databases listed on their [providers](https://www.terraform.io/docs/providers/index.html), the two are [PostgreSQL](https://www.terraform.io/docs/providers/postgresql/index.html) and [MySQL](https://www.terraform.io/docs/providers/mysql/index.html). Both of these providers focus on more administration tasks, which makes sense given how you typically use Terraform. I am going to be grabbing a Docker image for MySQL to use to execute the Terraform.

```bash
$ docker run --name mysql -e MYSQL_ROOT_PASSWORD=6Fg4GBVcdI6U -e MYSQL_ROOT_HOST=% -p 3306:3306 -d mysql
....
....
2020-03-15T00:39:44.847890Z 0 [System] [MY-010931] [Server] /usr/sbin/mysqld: ready for connections. Version: '8.0.19'  socket: '/var/run/mysqld/mysqld.sock'  port: 3306  MySQL Community Server - GPL.
2020-03-15T00:39:45.006311Z 0 [System] [MY-011323] [Server] X Plugin ready for connections. Socket: '/var/run/mysqld/mysqlx.sock' bind-address: '::' port: 33060
```

Now create your **main.tf** and add the following.

```hcl
provider "mysql" {
  endpoint = "172.17.0.1:3306"
  username = "root"
  password = "6Fg4GBVcdI6U"
}

resource "mysql_database" "petdb" {
  name = "petdb"
}
```

Now we can execute this to create our database.

```bash
$ terraform init
$ terraform apply
mysql_database.petdb: Creating...
mysql_database.petdb: Creation complete after 0s [id=petdb]
```

That's it, and now you can combine this with a cloud provider to bootstrap your databases in your templates.

Thanks for reading,

Jamie
