---
title: "Cross-Platform Go: Runtime Checks vs. Build Tags"
date: 2021-11-17T20:40:17-05:00
tags:
- Go
- Golang
- Cross-Platform
- Go Windows Dev
---

A large part of my job is to get various Go libraries and tools to work with Windows. As part of that process, I have developed a preference for dealing with platform-dependent items. Go has two common approaches that developers take, they either wrap that logic in an "if check" for the runtime, or they leverage build tags to compile the code required for that platform. Let's examine some examples to see the different approaches before telling you which one I prefer and why.

## Runtime If Check

The first example is going to be a runtime "if check." Here is the sample *main.go*.

```Go
package main

import (
	"fmt"
	"runtime"
)

func main() {
	fmt.Println(greeting())
}

func greeting() string {
	if runtime.GOOS == "windows" {
		return "Hello from Windows"
	} else {
		return "Hello, this isn't Windows"
	}
}
```

If we read the *greeting* function, you will notice the runtime *GOOS* check to see if it's windows. If it is, I return one message that says it's Windows; otherwise, I return a message that says it isn't Windows. This code is simple enough, and for really basic examples, it works well enough. Now, let's see an example using build tags.

## Build Tags

Go also can define build tags in files to only compile those files based on the defined GOOS when executing the build. If a GOOS isn't set, then it uses the platform that you are building on. Here is the example above using build tags. You can combine build tags by adding platform suffixes to different files too.

##### main.go

```Go
# main.go
package main

import (
	"fmt"
)

func main() {
	fmt.Println(greeting())
}
```

##### main_windows.go
```Go
//go:build windows
// +build windows
package main

func greeting() string {
    return "Hello from Windows"
}
```

##### main_unix.go
```Go
//go:build !windows
// +build !windows
package main

func greeting() string {
    return "Hello, this isn't Windows"
}
```

Notice with this approach that you also create separate files and place a suffix at the end. Now when you build your project, only the functionality that is compatible with your target platform.

## My preference

Now that we have both examples, my preference is for the build tags and multiple files. There are a couple of primary reasons that I personally favor this approach. The first reason is that it clarifies that the code base has different implementations based on the platform. The second reason is that it keeps platform-specific dependencies out of compilation. An example of that would be something like the [os/user](https://pkg.go.dev/os/user) package, which depends on the `netapi32.dll` if used on Windows to retrieve the username. This dll isn't typically an issue. However, if you are using Nanoserver container images, that dll isn't available. Suppose you used the "if check" approach, then the compiled code would contain that package. If you did the build tags, you can opt-out of including that package if you plan to run on a Windows container so you would be compatible with Nanoserver.

Thanks for reading,

Jamie
