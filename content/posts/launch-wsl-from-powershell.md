---
Title: "Launch WSL from PowerShell"
date: 2018-06-19T21:57:56
Tags: 
- Microsoft And Linux
- Windows Subsystem for Linux
- Tools
---
# Launch WSL from PowerShell

Just wanted to do a quick post of something that I learned today. You don't have to launch *Bash for Windows* by clicking the icon or by pressing the start button and typing. You can just as easily run it from the command line. 

Open a PowerShell:

```
Windows PowerShell
Copyright (C) Microsoft Corporation. All rights reserved.

Loading personal and system profiles took 652ms.
C:\Users\phillipsj>
```

Type *wsl* and you should now be running *Bash*:

```
C:\Users\phillipsj>wsl
phillipsj@DESKTOP:/mnt/c/Users/phillipsj$

phillipsj@DESKTOP:/mnt/c/Users/phillipsj$ bash --version
GNU bash, version 4.4.19(1)-release (x86_64-pc-linux-gnu)
Copyright (C) 2016 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>

This is free software; you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
```

That's it, I am still working on my other posts and they should be coming out shortly.
