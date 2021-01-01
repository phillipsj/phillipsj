---
title: "Installing Go on openSUSE"
date: 2021-01-01T13:52:58-05:00
tags:
- Open Source
- Linux
- openSUSE
- Go
---

I have been using Go a lot lately. There are several open source projects that I want to be more involved with, and they all use Go. Since I have been using openSUSE, both Leap and Tumbleweed, I thought I would share how to get Go installed. The nice thing about the openSUSE packages for Go is that they include a script that will configure all the environment variables for you after a reboot. You can read more here on the [wiki](https://en.opensuse.org/SDB:Go). Let's add the Go repository so we can install the packages.

#### Leap 15.2

```Bash
$ sudo zypper addrepo https://download.opensuse.org/repositories/devel:languages:go/openSUSE_Leap_15.2/devel:languages:go.repo
$ sudo zypper refresh
```

#### Tumbleweed

```Bash
$ sudo zypper addrepo https://download.opensuse.org/repositories/openSUSE:Factory/standard/openSUSE:Factory.repo
$ sudo zypper refresh
```

Now we can search to see what is available for Go.

```Bash
$ sudo zypper search go
 | go                  | A compiled, garbage-collected, concurrent progra-> | srcpackage
 | go                  | A compiled, garbage-collected, concurrent progra-> | package
 | go-doc              | Go documentation                                   | package
 | go-for-it           | A to-do list with built-in productivity timer      | package
 | go-for-it-lang      | Translations for package go-for-it                 | package
 | go-md2man           | Tool to converts markdown into man pages           | package
 | go-modiff           | Command line tool for diffing Go module dependen-> | srcpackage
 | go-modiff           | Command line tool for diffing Go module dependen-> | package
 | go-race             | Go runtime race detector                           | package
 | go-swagger          | Swagger implementation in golang                   | srcpackage
 | go-swagger          | Swagger implementation in golang                   | package
 | go-swagger-debuginfo| Debug information for package go-swagger           | package
 | go-toml             | Go library for the TOML language                   | package
 | go-tools            | Additional toolsgraphy libraries                   | package
 | go1.10              | A compiled, garbage-collected, concurrent progra-> | srcpackage
 | go1.10              | A compiled, garbage-collected, concurrent progra-> | package
 | go1.10-doc          | Go documentation                                   | package
 | go1.10-race         | Go runtime race detector                           | package
 | go1.11              | A compiled, garbage-collected, concurrent progra-> | srcpackage
 | go1.11              | A compiled, garbage-collected, concurrent progra-> | package
 | go1.11-doc          | Go documentation                                   | package
 | go1.11-race         | Go runtime race detector                           | package
 | go1.12              | A compiled, garbage-collected, concurrent progra-> | srcpackage
 | go1.12              | A compiled, garbage-collected, concurrent progra-> | package
 | go1.12-doc          | Go documentation                                   | package
 | go1.12-race         | Go runtime race detector                           | package
 | go1.13              | A compiled, garbage-collected, concurrent progra-> | srcpackage
 | go1.13              | A compiled, garbage-collected, concurrent progra-> | package
 | go1.13-doc          | Go documentation                                   | package
 | go1.13-race         | Go runtime race detector                           | package   
 | go1.14  | A compiled, garbage-collected, concurrent progra-> | srcpackage
 | go1.14              | A compiled, garbage-collected, concurrent progra-> | package
 | go1.14-doc          | Go documentation                                   | package
 | go1.14-race         | Go runtime race detector                           | package
 | go1.15              | A compiled, garbage-collected, concurrent progra-> | srcpackage
 | go1.15              | A compiled, garbage-collected, concurrent progra-> | package
 | go1.15-doc          | Go documentation                                   | package
 | go1.15-race         | Go runtime race detector                           | package
 | go1.4               | A compiled, garbage-collected, concurrent progra-> | srcpackage
 | go1.4               | A compiled, garbage-collected, concurrent progra-> | package
 | go1.4-debuginfo     | Debug information for package go1.4                | package
 | go1.4-debugsource   | Debug sources for package go1.4                    | package
 | go1.4-doc           | Go documentation                                   | package
 | go1.4-race          | Go runtime race detector                           | package
 | go1.7               | A compiled, garbage-collected, concurrent progra-> | package
 | go1.7-doc           | Go documentation                                   | package
 | go1.7-race          | Go runtime race detector                           | package
 | go1.8               | A compiled, garbage-collected, concurrent progra-> | package
 | go1.8-doc           | Go documentation                                   | package
 | go1.8-race          | Go runtime race detector                           | package
 | go1.9               | A compiled, garbage-collected, concurrent progra-> | srcpackage
 | go1.9               | A compiled, garbage-collected, concurrent progra-> | package
 | go1.9-doc           | Go documentation                                   | package
 | go1.9-race          | Go runtime race detector                           | package
```

There are a lot more packages that are Go related than what I am showing. I know that for my purposes, I need version 1.15, so I will install it.

```Bash
$ sudo zypper install go1.15
Reading installed packages...
Resolving package dependencies...

The following 3 NEW packages are going to be installed:
  go1.15 go1.15-doc go1.15-race

The following recommended package was automatically selected:
  go1.15-doc

3 new packages to install.
```

Once that finishes, let's verify that we have it installed.

```Bash
$ go version
go version go1.15.6 linux/amd64
```

That's it. There are many other Go-related packages in there like [Hugo](https://gohugo.io/) and even Go packages from GitHub. I believe some packages are available in the standard repos. I just know I wanted some of the other packages offered in the extra repo.

Thanks for reading,

Jamie
