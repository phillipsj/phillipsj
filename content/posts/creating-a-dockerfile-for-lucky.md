---
Title: "Creating a Dockerfile for Lucky"
date: 2019-02-14T20:43:43
Tags: 
- Azure
- Cloud
- Crystal
- Open Source
- Lucky
---
# Creating a Dockerfile for Lucky

I've been learning both [Lucky](https://luckyframework.org/) and [Crystal](https://crystal-lang.org/). One item that I always want to understand is what is the build and deployment process for a framework and language. That always ends up being the sticking point for me. If I can't create a build pipeline with a little effort, then I am just not interested in working with it. While Lucky may seem a little complex, it isn't actually too many steps.

In this post, we are going to create a Dockerfile for doing Lucky development. This post will be the first of a few posts covering this topic. Let's get started. I am assuming you have Docker installed and are running on Linux. I don't foresee why this wouldn't work on other OSes but wanted to put this in here.

The first step is to create our Dockerfile.

```Bash
$ mkdir lucky-docker
$ cd lucky-docker
$ touch Dockerfile
```

Now let's open the Dockerfile and starting adding info. Crystal produces a Docker image so we will start with that and currently Lucky requires version 0.27. We will need to get the dependencies installed and pull down the Lucky repo and create our Lucky CLI.

```Dockerfile
FROM crystallang/crystal:0.27.2

# Getting Depedencies
RUN apt-get update \
        && apt-get install -y git libc6-dev libevent-dev libpcre2-dev libpng-dev libssl-dev libyaml-dev zlib1g-dev curl wget
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -

RUN apt-get update && apt-get install -y yarn tmux

RUN set -ex \
        && wget -q https://github.com/DarthSim/overmind/releases/download/v2.0.0/overmind-v2.0.0-linux-amd64.gz \
        && gunzip overmind-v2.0.0-linux-amd64.gz \
        && chmod +x overmind-v2.0.0-linux-amd64 \
        && mv overmind-v2.0.0-linux-amd64 /usr/local/bin/overmind

# Cloning the Lucky repo and building Lucky
RUN set -ex \
        && git clone https://github.com/luckyframework/lucky_cli \
        && cd lucky_cli \
        && git checkout v0.12.0 \
        && shards install \
        && crystal build src/lucky.cr --release --no-debug \
        && mv lucky /usr/local/bin/lucky \
        && cd .. \
        && rm -r lucky_cli
```

Now that we have our container built let's make sure that Lucky works as expected.

```Bash
$ docker run -it lucky
> lucky --version
0.12.0
```

Excellent, we can build a container that we can use with Lucky source code for doing builds or local development. Additional posts will follow with how we are going to use it.

Thanks for reading,

Jamie

**If you enjoy the content then consider [buying me a coffee](https://www.buymeacoffee.com/aQPnJ73O8).**
