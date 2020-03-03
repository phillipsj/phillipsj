---
title: "Hadolint: Linting your Dockerfile"
date: 2020-03-02T21:30:30-05:00
tags:
- Dockerfile
- Docker
- Haskell
- Open Source
- Containers
---

Linters are commonly used in development to help teams detect programmatic and stylistic errors. [Hadolint](https://github.com/hadolint/hadolint) is a linter created for Dockerfiles using [Haskell](https://www.haskell.org/). This tool validates against the [best practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/) outlined by Docker and takes a neat approach to parse the Dockerfile that you should checkout. It supports all major platforms, and this tutorial will be leveraging the container to perform the linting on an example Dockerfile. Let's get started.

## The Dockerfile

```Bash
$ touch Dockerfile
```

Now let's add the following to the file:

```Docker
FROM crystallang/crystal:latest

# Getting Depedencies
RUN apt-get update && apt-get install -y \
  git \
  libc6-dev \
  libevent-dev \
  libpcre2-dev \
  libpng-dev \
  libssl-dev \
  libyaml-dev \
  zlib1g-dev \
  curl \
  wget

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -

RUN apt-get update && apt-get install -y \
  yarn \
  tmux \

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

## Linting with hadolint

Now that we have a Dockerfile created let's run hadolint against it using the container.

```Bash
$ docker run --rm -i hadolint/hadolint < Dockerfile
/dev/stdin:1 DL3007 Using latest is prone to errors if the image will ever update. Pin the version explicitly to a release tag
/dev/stdin:4 DL3008 Pin versions in apt get install. Instead of `apt-get install <package>` use `apt-get install <package>=<version>`
/dev/stdin:4 DL3009 Delete the apt-get lists after installing something
/dev/stdin:4 DL3015 Avoid additional packages by specifying `--no-install-recommends`
/dev/stdin:6 DL4006 Set the SHELL option -o pipefail before RUN with a pipe in it. 
/dev/stdin:7 DL4006 Set the SHELL option -o pipefail before RUN with a pipe in it. 
/dev/stdin:8 DL4006 Set the SHELL option -o pipefail before RUN with a pipe in it. 
/dev/stdin:10 DL3008 Pin versions in apt get install. Instead of `apt-get install <package>` use `apt-get install <package>=<version>`
/dev/stdin:10 DL3009 Delete the apt-get lists after installing something
/dev/stdin:10 DL3015 Avoid additional packages by specifying `--no-install-recommends`
/dev/stdin:12 DL4001 Either use Wget or Curl but not both
/dev/stdin:19 DL3003 Use WORKDIR to switch to a directory
```

Wow, we have 12 issues in our Dockerfile that was found by hadolint. Let's start fixing these issues. The first one to address is [DL3007](https://github.com/hadolint/hadolint/wiki/DL3007), which says to not use the latest tag.

Let's set our image tag in our FROM.

```Dockerfile
FROM crystallang/crystal:0.27.2
```

Now we need to make sure we pin our versions and set *--no-install-recommends* in our apt-get install commands, which will address issues with the [DL3008](https://github.com/hadolint/hadolint/wiki/DL3008) and [DL3015](https://github.com/hadolint/hadolint/wiki/DL3015) codes.

```Dockerfile
FROM crystallang/crystal:0.27.2

# Getting Depedencies
RUN apt-get update && apt-get install -y --no-install-recommends \
  git=1:2.7.4-0ubuntu1.7 \
  libc6-dev=2.23-0ubuntu10 \
  libevent-dev=2.0.21-stable-2ubuntu0.16.04.1 \
  libpcre2-dev=10.21-1 \
  libpng12-dev=1.2.54-1ubuntu1.1 \
  libssl-dev=1.0.2g-1ubuntu4.15 \
  libyaml-dev=0.1.6-3 \
  zlib1g-dev=1:1.2.8.dfsg-2ubuntu4.3 \
  curl=7.47.0-1ubuntu2.14 \
  wget=1.17.1-1ubuntu1.5 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -

RUN apt-get update && apt-get install -y --no-install-recommends\
  yarn=1.21.1-1 \
  tmux=2.1-3build1 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
  
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

Let's run hadolint again and see what issues we have left.

```Bash
docker run --rm -i hadolint/hadolint < Dockerfile
/dev/stdin:18 DL4006 Set the SHELL option -o pipefail before RUN with a pipe in it.
/dev/stdin:19 DL4006 Set the SHELL option -o pipefail before RUN with a pipe in it.
/dev/stdin:20 DL4006 Set the SHELL option -o pipefail before RUN with a pipe in it.
/dev/stdin:28 DL4001 Either use Wget or Curl but not both
/dev/stdin:35 DL3003 Use WORKDIR to switch to a directory
```

Let's address [DL4006](https://github.com/hadolint/hadolint/wiki/DL4006) by adding the following before our *RUN* commands that add the yarn and node repositories.

```Dockerfile
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
```

This change would make the file look like this:

```Dockerfile
FROM crystallang/crystal:0.27.2

# Getting Depedencies
RUN apt-get update && apt-get install -y --no-install-recommends \
  git=1:2.7.4-0ubuntu1.7 \
  libc6-dev=2.23-0ubuntu10 \
  libevent-dev=2.0.21-stable-2ubuntu0.16.04.1 \
  libpcre2-dev=10.21-1 \
  libpng12-dev=1.2.54-1ubuntu1.1 \
  libssl-dev=1.0.2g-1ubuntu4.15 \
  libyaml-dev=0.1.6-3 \
  zlib1g-dev=1:1.2.8.dfsg-2ubuntu4.3 \
  curl=7.47.0-1ubuntu2.14 \
  wget=1.17.1-1ubuntu1.5 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -

RUN apt-get update && apt-get install -y --no-install-recommends\
  yarn=1.21.1-1 \
  tmux=2.1-3build1 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN set -ex \
        && wget -q https://github.com/DarthSim/overmind/releases/download/v2.0.0/overmind-v2.0.0-linux-amd64.gz \
        && gunzip overmind-v2.0.0-linux-amd64.gz \
        && chmod +x overmind-v2.0.0-linux-amd64 \
        && mv overmind-v2.0.0-linux-amd64 /usr/local/bin/overmind

# Cloning the Lucky repo and building Lucky
RUN set -ex \
        && git clone https://github.com/luckyframework/lucky_cli \
        && WORKDIR lucky_cli \
        && git checkout v0.12.0 \
        && shards install \
        && crystal build src/lucky.cr --release --no-debug \
        && mv lucky /usr/local/bin/lucky \
        && WORKDIR .. \
        && rm -r lucky_cli
```

This change now leaves two remaining issues, [DL3003](https://github.com/hadolint/hadolint/wiki/DL3003) and [DL4001](https://github.com/hadolint/hadolint/wiki/DL4001). Let's start with DL3003 by changing our *cd* commands to *WORKDIR* commands. This section begins on line 39, and here it is below.

```Dockerfile
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

We will change this section to be as below.

```Dockerfile
# Cloning the Lucky repo and building Lucky
RUN set -ex \
  && git clone https://github.com/luckyframework/lucky_cli

WORKDIR /lucky_cli

RUN set -ex \
 && git checkout v0.12.0 \
 && shards install \
 && crystal build src/lucky.cr --release --no-debug \
 && mv lucky /usr/local/bin/lucky

WORKDIR /

RUN set -ex \
  && rm -r lucky_cli
```

Let's run hadolint again and see what we have left.

```Bash
docker run --rm -i hadolint/hadolint < Dockerfile
/dev/stdin:29 DL4001 Either use Wget or Curl but not both
```

This issue is related to lines 19, 21, and 30. We use *curl* in 19 and 21 while we are also using *wget* on line 30. We are going to change line 30 to use *curl*. Here is the original line.

```Dockerfile
RUN set -ex \
        && wget -q https://github.com/DarthSim/overmind/releases/download/v2.0.0/overmind-v2.0.0-linux-amd64.gz \
        && gunzip overmind-v2.0.0-linux-amd64.gz \
        && chmod +x overmind-v2.0.0-linux-amd64 \
        && mv overmind-v2.0.0-linux-amd64 /usr/local/bin/overmind
```

Here is our line now converted to using *curl*.

```Dockerfile
RUN set -ex \
        && curl -OL https://github.com/DarthSim/overmind/releases/download/v2.0.0/overmind-v2.0.0-linux-amd64.gz \
        && gunzip overmind-v2.0.0-linux-amd64.gz \
        && chmod +x overmind-v2.0.0-linux-amd64 \
        && mv overmind-v2.0.0-linux-amd64 /usr/local/bin/overmind
```

Once again, let's execute hadolint, and we should now have a clean run. While it passed, let's not forget to remove it from the apt install line.

```Bash
$ docker run --rm -i hadolint/hadolint < Dockerfile
```

Yay! We have a clean linting run. Here is what our file looks like in its entirety.

```Dockerfile
FROM crystallang/crystal:0.27.2

# Getting Depedencies
RUN apt-get update && apt-get install -y --no-install-recommends \
  git=1:2.7.4-0ubuntu1.7 \
  libc6-dev=2.23-0ubuntu10 \
  libevent-dev=2.0.21-stable-2ubuntu0.16.04.1 \
  libpcre2-dev=10.21-1 \
  libpng12-dev=1.2.54-1ubuntu1.1 \
  libssl-dev=1.0.2g-1ubuntu4.15 \
  libyaml-dev=0.1.6-3 \
  zlib1g-dev=1:1.2.8.dfsg-2ubuntu4.3 \
  curl=7.47.0-1ubuntu2.14 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -

RUN apt-get update && apt-get install -y --no-install-recommends\
  yarn=1.21.1-1 \
  tmux=2.1-3build1 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN set -ex \
        && curl -OL https://github.com/DarthSim/overmind/releases/download/v2.0.0/overmind-v2.0.0-linux-amd64.gz \
        && gunzip overmind-v2.0.0-linux-amd64.gz \
        && chmod +x overmind-v2.0.0-linux-amd64 \
        && mv overmind-v2.0.0-linux-amd64 /usr/local/bin/overmind

# Cloning the Lucky repo and building Lucky
RUN set -ex \
  && git clone https://github.com/luckyframework/lucky_cli

WORKDIR /lucky_cli

RUN set -ex \
 && git checkout v0.12.0 \
 && shards install \
 && crystal build src/lucky.cr --release --no-debug \
 && mv lucky /usr/local/bin/lucky

WORKDIR /

RUN set -ex \
  && rm -r lucky_cli
```

## Conclusion

I hope you enjoyed learning about hadolint. It is a helpful tool that you can easily incorporate into your development process and CI/CD pipelines. Linting is useful for ensuring that code quality is maintained, and your Dockerfiles can now enjoy the same treatment as any other code you write.

Thanks for reading,

Jamie
