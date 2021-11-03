---
title: "Cross-Platform Go: File Paths"
date: 2021-11-02T21:36:14-04:00
tags:
- Go
- Golang
- Cross-Platform
---

I was fortunate enough to kick this week off with one heck of a bug. I discovered the bug last week, and on Friday, after an excellent debugging session with breakpoints and stepping into each call, I found the cause. That was a good way to head into the weekend, and I knew that I would have to determine a solution this week. The library that I discovered the issue was initially designed to run in the context of a Linux OS and Linux containers. Given that I was adapting this code to work on Windows shouldn't have come as a surprise that I would run into an issue of some sort. This issue was pretty cool, so I thought I would share and write it up. I will do my best to describe the problem.

## The Bug

The issue I was running into had two facets. The first part was realizing that tar files always have a Unix style path separator, the `/`. That meant that the code was consuming the list of files from the tar file needed to be aware of the path separator. The second part was caused by searching the list of files for files with a specific path. An example would be good about now, so let's say we were looking for files inside of the tar that was inside of `/usr/local/bin`. We would get files passed in, and any file like `/usr/local/bin/kubectl` would match, and we would return that file to extract. If the file had been `/var/lib/kubectl`, then it wouldn't be extracted from the tar. The code needed to achieve transversing the path, so a for loop was used.

```Go
// This is a map of the directory to find the files and the directory to write it out to.
dirs := map[string]string{"/usr/local/bin" : "<location to write>" }

for folder := filepath.Dir(path); ; folder = filepath.Dir(folder) {
    if d, ok := dirs[folder]; ok { }
}
```

This loop used the [Dir](https://cs.opensource.google/go/go/+/refs/tags/go1.17.2:src/path/filepath/path.go;l=580) function, which removes the last element. Then it sees if the remaining path matches what is in the dirs map. If so, it does some other manipulation and returns. So it is feeding in a string with a Unix style path from the tar file, and we are trying to match on a string that is also a Unix style path. Now we are into the interesting piece because on Linux, and this works perfectly fine. However, I noticed in the loop we are using the filepath package and the *Dir* function. That function uses the *Clean* function in the same package, which uses the path separator of the operating system. This means that we pass in `/usr/local/bin`, but we get out `\\usr\\local\\bin`, a Windows-style path. If we pass that Windows-style path into our dirs map, it will not find it because the dirs map is using the Unix style separator. The result was that on Linux, it found the files in the directory specified, but on Windows, it failed due to the use of the filepath package, and it corrected the path separator. 

## The Fix

Fixing this issue was interesting within its self, and luckily we could rely on the filepath package to get us out of this pickle. Two functions are built-in for converting the file paths. Those two are [ToSlash](https://cs.opensource.google/go/go/+/go1.17.2:src/path/filepath/path.go;l=166) and [FromSlash](https://cs.opensource.google/go/go/+/refs/tags/go1.17.2:src/path/filepath/path.go;l=176). `ToSlash` converts to Unix style and if it is already Unix style then it just returns. `FromSlash` converts to the operating system's separator. With that knowledge, I realized that I would need to use `ToSlash` to force the path back to Unix style to search for it in the dirs map. 

```Go
// This is a map of the directory to find the files and the directory to write it out to.
dirs := map[string]string{"/usr/local/bin" : "<location to write>" }

for folder := filepath.Dir(path); ; folder = filepath.Dir(folder) {
    if d, ok := dirs[filepath.ToSlash(folder)]; ok { }
}
``` 

After that minor tweak and a thorough round of testing, I fixed the bug.

## Wrapping Up

Hopefully, you have been able to follow along and understand what was happening. The filepath package functions were behaving just as I would expect. We were passing in a string, converting that string to a proper path for the operating system. However, that was causing our bug because we were comparing an OS corrected path to a string containing a Unix-style path. That would work on Linux, but once Windows was involved, it would fail. The solution just ended up making sure that we converted the path back to a set style.

```
TLDR; Compare strings that represent paths by either forcing to a standard or using the filepath package.
```

I hope you found this helpful or at least enjoyable.

Thanks for reading,

Jamie

