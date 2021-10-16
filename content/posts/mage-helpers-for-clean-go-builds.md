---
title: "Mage Helpers for Clean Go Builds"
date: 2021-10-16T14:41:23-04:00
tags:
- Go
- Golang
- Mage
- Build Tools
---

In my last [post](https://www.phillipsj.net/posts/building-go-projects-like-a-mage/), I discussed why one would consider using Mage. Those considerations are for cross-platform support and not relying on tools like cURL to be installed on the system. I had also discussed having the ability to wrap functionality up in packages to allow sharing and centralizing logic across your builds. This is also an opportunity that I feel that the [Cake](https://cakebuild.net) project did really well, standardizing what they called *Addins* to make consuming functionality clearer for consumers. Mage has similar concepts with their [helpers](https://magefile.org/libraries/). Mage ships with some of these included for things like removing and copying files. There is plenty of neat functionality in there to make it convenient and prevent you from having to write all of that Go code yourself. That concept can also be seen being expanded upon in the [Gnorm](https://github.com/gnormal/gnorm) repo with the *mage_helpers.go* file. I think that be can be extended even further into a concept like addins for Cake that I mentioned previously. Let's see what they may look like.

## Converting the Download Task to a Helper

Here is the task from the [mage-example](https://github.com/phillipsj/mage-example) repo that I have on GitHub.

```Go
func Download() error {
	mg.Deps(Build)

	url := "https://gist.githubusercontent.com/phillipsj/07fed8ce06f932c19ab7613d8426d922/raw/13d3fc0ca54d136ad5744fd4448b65dbc87f32dc/random.txt"
	out, err := os.Create(filepath.Join("bin", "random.txt"))
	if err != nil {
		return err
	}
	defer out.Close()

	resp, err := http.Get(url)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if _, err := io.Copy(out, resp.Body); err != nil {
		return err
	}

	return nil
}
```

Let's now move this out to its own function.

```Go
func GetFile(url string, file string) error {
	out, err := os.Create(file)
	if err != nil {
		return err
	}
	defer out.Close()

	resp, err := http.Get(url)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if _, err := io.Copy(out, resp.Body); err != nil {
		return err
	}

	return nil
}
```

If we take a look at our download task, it is much cleaner.

```Go
func Download() error {
	mg.Deps(Build)

	url := "https://gist.githubusercontent.com/phillipsj/07fed8ce06f932c19ab7613d8426d922/raw/13d3fc0ca54d136ad5744fd4448b65dbc87f32dc/random.txt"
	return GetFile(url, filepath.Join("bin", "random.txt"))
}
```

## Creating a Download Package

The last piece, in my opinion, is to move this into a package that could be consumed. I will call this the *dl* package for download, much like the pattern with the other Mage packages.

```Go
package dl

import (
	"io"
	"net/http"
	"os"
)

func GetFile(url string, file string) error {
	out, err := os.Create(file)
	if err != nil {
		return err
	}
	defer out.Close()

	resp, err := http.Get(url)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if _, err := io.Copy(out, resp.Body); err != nil {
		return err
	}

	return nil
}
```

Now here is what it looks like to consume the package.

```Go
func Download() error {
	mg.Deps(Build)

	url := "https://gist.githubusercontent.com/phillipsj/07fed8ce06f932c19ab7613d8426d922/raw/13d3fc0ca54d136ad5744fd4448b65dbc87f32dc/random.txt"
	return dl.GetFile(url, filepath.Join("bin", "random.txt"))
}
```

You can find the package that I created called [mage-helpers](https://github.com/phillipsj/mage-helpers) on GitHub.

## Wrap Up

Hopefully, this provided you with more examples of how Mage could be used beyond just the basic example. I plan to keep adding helpers to my *mage-helpers* repository, which will only make authoring builds with Mage easier.

Thanks for reading,

Jamie
