---
title: "Building Go Projects Like a Mage"
date: 2021-10-14T21:14:37-04:00
tags:
- Go
- Golang
- Mage
- Build Tools
---

Working on cross-platform projects comes with a lot of challenges. Several things about go can make that less difficult, like being able to target a different runtime and how you can create files for other runtimes to substitute platform-specific functions. These are excellent capabilities that I appreciate.

I do find myself with an issue that is when it comes to build tooling. Many people reach for make and or Bash. That's fine on a Unix, Linux, or arm system, yet those tools don't work well when it comes to windows. PowerShell is cross-platform and would be a good choice, yet it's another language to learn.

My background working with the Cake build tool in .net sent me looking for a build tool written in Go. You may be asking why Go? It is a language you are already using to write your code, and it is cross-platform. It solves my two most significant issues.

## Basic Example

Here is a basic image file example of downloading something and then cleaning and executing a build.

```Go
// +build mage

package main

import (
	"github.com/magefile/mage/mg"
	"github.com/magefile/mage/sh"
)

var Default = Build

func Clean() error {
	return sh.Rm("bin")
}

func Build() error {
	mg.Deps(Clean)
	if err := sh.Run("go", "mod", "download"); err != nil {
		return err
	}
	return sh.Run("go", "build", "-o", "./bin/")
}

func Download() error {
	mg.Deps(Build)
	url := "https://gist.githubusercontent.com/phillipsj/07fed8ce06f932c19ab7613d8426d922/raw/13d3fc0ca54d136ad5744fd4448b65dbc87f32dc/random.txt"
	err := sh.Run("curl", "-O", url)
	if err != nil {
		return err
	}
	return sh.Copy(filepath.Join("bin", "random.txt"), "random.txt")
}
```

There are three defined tasks. One to clean the previous build output, build the project, and then download a needed file. I have defined the build task as the default task and built out the required dependencies between tasks. To make bootstrapping Mage easier, I have also decided to use the [zero install option](https://magefile.org/zeroinstall/). Let's run our first task, which will be the default task.

```Bash
go run mage.go
```

You should now see a bin directory with your executable from your project. Let's run the download task now.

```Bash
go run mage.go download
Error: failed to run "curl -O https://gist.githubusercontent.com/phillipsj/07fed8ce06f932c19ab7613d8426d922/raw/13d3fc0ca54d136ad5744fd4448b65dbc87f32dc/random.txt: exec: "curl": executable file not found in $PATH"
exit status 1
```

Oops! We got an error because we don't have cURL installed on our system. Once cURL is installed, it should work. This is another good point about tools not being available on every OS. If we had used Go, we could lower our need for tools to be available. Check your bin directory, and you should see the *random.txt* file along with your executable.

```Bash
go run mage.go download
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    34  100    34    0     0    261      0 --:--:-- --:--:-- --:--:--   261
```

This is a basic example that I don't feel really shows the potential of Mage. Many seem to get hung up because it is just calling CLI apps using an exec. Why not just use Bash since it is doing the same thing. As I said previously, if we just used it to exec tools, we still gain the fact that it's cross-platform. It will work the same regardless if Bash is installed or can't be installed. 

## No CLI tools example

The second argument about how it's just an exec seems to not ponder the full potential. At the end of the day, it's all Go code, so we can do anything with Go. One area that Mage takes advantage of Go is that the dependency graph takes advantage of Goroutines to parallelize independent steps.

The next big item is that you can use Go instead of the CLI tool. In the example above, let's replace the curl exec in the download task with the *net/HTTP* module.

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

Now users don't need to be concerned if cURL is installed or not on their system. You may have noticed that I am not addressing that the Go CLI tools are being called. I have less of an issue with that because Go is just a hard requirement for everything since it is a Go project. I have some further ideas on how to address that in a future post.

The last piece that people often overlook is creating a way to share logic within all of your builds. We could put some unique logic in a go package then just pull that into all of your builds that need it. When using scripts, I have noticed they don't always get synced across repos. We could quickly wrap this file downloader in a package that we could share across all of our projects. This would help keep the logic the same and would allow any fixes to be consumed more efficiently.

## Wrapping up

I know this is a change, and I wouldn't be considering it if I worked on one platform. It works across Linux, Mac, and Windows, where this has become a pain point, and it didn't make sense to use a tool written in a language other than Go. Here is a [repository](https://github.com/phillipsj/mage-example) with the examples, and you can check the commits to see the changes. I will be updating it as I try different techniques. 

Thanks for reading, and please reach out to let me know what you are doing,

Jamie
