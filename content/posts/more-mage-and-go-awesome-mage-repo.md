---
title: "More Mage and Go: Awesome Mage Repo"
date: 2021-10-17T20:50:09-04:00
tags:
- Go
- Golang
- Mage
- Build Tools
---

I got so wrapped up with [Mage](https://www.phillipsj.net/posts/building-go-projects-like-a-mage/) and the [helpers](https://www.phillipsj.net/posts/mage-helpers-for-clean-go-builds/) posts that I didn't realize that an [awesome mage](https://github.com/magefile/awesome-mage) repository already exists with an extensive list of helpers that are already available. It's a pretty robust list that covers most of the common usages that would be needed. Let's see what using the [mage-extras](https://github.com/mcandre/mage-extras) helpers will do to our [mage-example](https://github.com/phillipsj/mage-example) project.

### Installing Mage Extras Helpers

We can install it using `go get` in our project.

```Bash
go get github.com/mcandre/mage-extras

go: downloading github.com/mcandre/mage-extras v0.0.6
go: downloading github.com/mcandre/factorio v0.0.1
go: downloading github.com/mcandre/zipc v0.0.4
go: downloading github.com/jhoonb/archivex v0.0.0-20201016144719-6a343cdae81d
go get: added github.com/mcandre/mage-extras v0.0.6
```

Now we can start using these in our *magefile.go*.

### Using the Mage Extras in our Magefile

Now we can replace our build task to use one of the mage-extras helpers.

```Go
//go:build mage
// +build mage

package main

import (
	"path/filepath"

	"github.com/magefile/mage/mg"
	"github.com/magefile/mage/sh"
	mageextras "github.com/mcandre/mage-extras"
	"github.com/phillipsj/mage-helpers/dl"
)

var Default = Build

func Clean() error {
	return sh.Rm("bin")
}

func Build() error {
	mg.Deps(Clean)
	return mageextras.Compile("-o", "./bin/")
}

func Test() error {
	return mageextras.UnitTest()
}

func Download() error {
	mg.Deps(Build)

	url := "https://gist.githubusercontent.com/phillipsj/07fed8ce06f932c19ab7613d8426d922/raw/13d3fc0ca54d136ad5744fd4448b65dbc87f32dc/random.txt"
	return dl.GetFile(url, filepath.Join("bin", "random.txt"))
}

```

We also added a test execution step that leverages the *UnitTest* helper. 

## Wrapping Up

Like I said above, I didn't realize that many of these helpers already existed, which makes it even nicer that this pattern is already in use. I did stumble across one of the projects that called them *spells*, which I think is neat. I will check out a few other projects like *retool* and *mageproj*, which seem to bring some additional structure to projects. 

Thanks for reading,

Jamie
