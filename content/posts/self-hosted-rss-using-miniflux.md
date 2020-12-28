---
title: "Self-Hosted RSS Using Miniflux"
date: 2020-12-27T20:07:12-05:00
tags:
- Linux
- Open Source
- RSS
- Self-hosted
- Miniflux
---

I was all set to use TinyTinyRSS for my self-hosted RSS feed when someone messaged me on LinkedIn and suggest that I take a look at [Miniflux](https://github.com/miniflux/v2). I only gave Miniflux a passing glance because I wanted something that had a mobile app. After getting the message, I decided I would look closer at the project. 

Miniflux is in Go with the goal of being minimalistic. The UI is very basic yet is clear and concise. It doesn't have much JavaScript, some ES6, yep no fancy libraries, to handle a few items, and it's progressive, so it works well with mobile. It is backed by PostgreSQL, just like TinyTinyRSS is, and does come with the ability to do migrations. It has a heavy privacy focus by removing tracking pixels, playing YouTube videos directly, and pulling the original URLs instead of proxies like FeedBurner. Those are all cool features that also go along with my idea of self-hosting. 

I like to run applications locally to test them out before I proceed with doing any other work. Given the feature set, I will try, and I now know how I want to host it. Fortunately, Miniflux is a twelve-factor app, ready to be used in a container environment. They publish a container image on both DockerHub and the GitHub container registry, which is cool. Their image is  Alpine based so I can keep the images small. I didn't realize that the *contrib* directory in GitHub has a few Docker Compose examples until I created my own. Here is my compose file.

```YAML
version: "3.3"

services:
  db:
    image: postgres:13-alpine
    environment:
      - POSTGRES_DB=miniflux
      - POSTGRES_USER=miniflux
      - POSTGRES_PASSWORD=m1n1f7ux
  web:
    image: miniflux/miniflux:2.0.26
    restart: always
    ports:
      - "80:8080"
    environment:
      - DATABASE_URL=postgres://miniflux:m1n1f7ux@db/miniflux?sslmode=disable
      - RUN_MIGRATIONS=1
      - CREATE_ADMIN=1
      - ADMIN_USERNAME=miniflux
      - ADMIN_PASSWORD=m1n1f7ux
    depends_on:
      - db
```

I decided to use the PostgreSQL Alpine image, and I configured it by using environment variables. I did a few things different from the examples in the contrib directory. I set up my container to *always* restart to continue to retry until the database is available instead of bringing up the database first with compose. I configured Miniflux to create an admin account and run the database migrations. You may not want it always to run the database migrations. However, I am only planning to use it as a single container, making sense to keep it simple. Now we can run the compose file to checkout Miniflux.

```Bash
$ docker-compose up
Starting miniflux-test_db_1 ... done
Starting miniflux-test_web_1 ... done
Attaching to miniflux-test_db_1, miniflux-test_web_1
db_1   | 
db_1   | PostgreSQL Database directory appears to contain a database; Skipping initialization
db_1   | 
db_1   | 2020-12-28 01:48:56.172 UTC [1] LOG:  starting PostgreSQL 13.1 on x86_64-pc-linux-musl, compiled by gcc (Alpine 9.3.0) 9.3.0, 64-bit
db_1   | 2020-12-28 01:48:56.173 UTC [1] LOG:  listening on IPv4 address "0.0.0.0", port 5432
db_1   | 2020-12-28 01:48:56.173 UTC [1] LOG:  listening on IPv6 address "::", port 5432
db_1   | 2020-12-28 01:48:56.176 UTC [1] LOG:  listening on Unix socket "/var/run/postgresql/.s.PGSQL.5432"
db_1   | 2020-12-28 01:48:56.179 UTC [20] LOG:  database system was shut down at 2020-12-28 01:45:06 UTC
db_1   | 2020-12-28 01:48:56.182 UTC [1] LOG:  database system is ready to accept connections
web_1  | Current schema version: 42
web_1  | Latest schema version: 42
web_1  | [INFO] User "miniflux" already exists, skipping creation
web_1  | [INFO] Starting Miniflux...
web_1  | [INFO] Starting scheduler...
web_1  | [INFO] Listening on "0.0.0.0:8080" without TLS
```

Now, if you navigate to http://localhost:80, you will see the log in. Use the credentials listed in the compose file to log in. I added a feed to see how it looks.

![](/images/miniflux/initial-setup.png)

Now that I can create a compose file that works, I will convert this to a Kubernetes manifest or maybe Terraform and get it deployed to something like k3s while I tweak the configuration that I am wanting. Once I get this all working, I will share the final solution that I developed.

Thanks for reading,

Jamie
