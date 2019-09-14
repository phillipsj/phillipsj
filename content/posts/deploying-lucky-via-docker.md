---
Title: "Deploying Lucky via Docker"
date: 2019-02-16T19:40:45
Tags: 
- Azure
- Cloud
- Crystal
- Open Source
- Lucky
- Docker
---
# Deploying Lucky via Docker

In my last [post](https://www.phillipsj.net/posts/creating-a-dockerfile-for-lucky) we created a Docker image for building Lucky or using it for doing local development. In this post, we are going to take it to the next step and use the image we created as part of a multi-stage build that will generate us a final container that we can use to deploy our Lucky application.

I have pushed up my container to [Docker Hub](https://hub.docker.com/r/blueghostlabs/lucky), and you can use it if you want. I do plan on maintaining it, and if the project is interested, I would be more than happy to support that effort.

Let's create our own example Lucky app to work use. You will need to have a working Lucky install which you can do using the website [here](https://luckyframework.org/guides/installing/). This project will be an API application without authentication.

```Bash
$ lucky init
Project name? lucky-app
API only or full support for HTML and Webpack? (api/full): api
Generate authentication? (y/n): n
Done generating your Lucky project

  ▸ cd into lucky-app
  ▸ check database settings in config/database.cr
  ▸ run bin/setup
  ▸ run lucky dev to start the server
```

Since we don't need a database, don't worry about doing any database configuration. You may get some errors when running the *bin/setup* command, but everything should work as demonstrated.

```Bash
$ cd lucky-app
$ bin/setup
$ lucky dev
```

Now navigate to the URL displayed and you should see the following.

```JSON
{"hello":"Hello World from Home::Index"}
```

Now that we have a basic app created let's get it in a Docker image.

We will start by declaring the two images that we need to build and deploy our application.

```Dockerfile
FROM blueghostlabs/lucky:0.12.0

FROM crystallang/crystal:0.27.2
```

Now we need to start filling in the steps. Let's get our application in the container and get it building.

```Dockerfile
FROM blueghostlabs/lucky:0.12.0 as build-env

WORKDIR /app

# Copy your project
COPY . ./

# Setup environment and restore shards
RUN bin/setup

# Build your project
RUN lucky build.release

FROM crystallang/crystal:0.27.2

WORKDIR /app
COPY --from=build-env /app/server .
COPY --from=build-env /app/config/watch.yml config/

CMD ./server
```

Now let's build our app image.

```Bash
$ docker build -t lucky-app .
```

And we can test that it works by running it.

```Bash
$ docker run --name lucky-app -p 5000:5000 -rm -it lucky-app:latest
$ wget -nv -O- http://localhost:5000
{"hello":"Hello World from Home::Index"}2019-02-16 19:27:44 URL:http://localhost:5000/ [40/40] -> "-" [1]
```

That's it for today, we have a working build and created a container with just our source in it. I have one final post planned, and anyone that knows me can guess what that will be, until next time. I have full example repo located [here](https://github.com/BlueGhostLabs/lucky-app).

Thanks for reading,

Jamie

**If you enjoy the content then consider [buying me a coffee](https://www.buymeacoffee.com/aQPnJ73O8).**
