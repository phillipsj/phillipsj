---
title: "Enabling Staticcheck in GoLand"
date: 2021-10-05T21:45:38-04:00
tags:
- Go
- Golang
- GoLand
- Staticcheck
- Linters
---

[Staticcheck](https://staticcheck.io) is a linter for Go that does an excellent job of providing feedback where you can simplify your code or make it more idiomatic. It seems that the VSCode Go extension will install it by default, depending on how you perform the initial setup. If you are using GoLand, I haven't seen it listed as an option out of the box. However, it is easy to enable yourself just like you would with *gofmt* or *goimports* as a file watcher. Let's get started.

## Install staticcheck

The first step is to install staticcheck, which can be done with the *go install* command.

```Bash
go install honnef.co/go/tools/cmd/staticcheck@latest
```

Now, we can ensure that our path is correctly pointing to our *GOBIN* directory.

```Bash
which staticcheck
~/go/bin/staticcheck
```

Great, now to configure GoLand.

## Adding a custom file watcher in GoLand

We will configure the staticcheck watcher to be scoped to a project, and this should be the same if you want it to be global. Go to *File-->Settings*.

Now you need to select the *Tools* item in the left menu. Then click on *File Watchers*.

![](/images/staticcheck-goland/settings-tools-dialog.png)

You should be on the *File Watchers* dialog.

![](/images/staticcheck-goland/file-watchers-dialog.png)

Next, click on the *+* icon and select *custom template*.

![](/images/staticcheck-goland/choose-template.png)

Finally, you can create a new file watcher by entering the name, selecting the file type, executable, and output path.

![](/images/staticcheck-goland/new-file-watcher.png)

After you save, you should see a list of the watchers. Click on apply and close the settings dialog.

![](/images/staticcheck-goland/file-watcher-list.png)

Congratulations, you know, have staticcheck inspecting your files.

## Testing

Here is some sample code that you can paste into a go file in the project.

```Go
package main

import (
	"fmt"
	"strings"
)

func main() {
	test := "this is a test"
	if strings.Contains(test, "hi") {
		test = strings.Replace(test, "hi", "", -1)
	}
	fmt.Println(test)
}
```

Once you save, you should see the following in the output window.

```Bash
~/go/bin/staticcheck
main.go:10:2: should replace this if statement with an unconditional strings.Replace (S1017)

Process finished with exit code 1
```

# Conclusion

I was honestly surprised to learn about this difference between these editors. Staticcheck is a nice feature for someone first learning Go to recognize areas that could be improved, so I will be enabling this file watcher going forward.

I hope you found this helpful and thanks for reading,

Jamie
