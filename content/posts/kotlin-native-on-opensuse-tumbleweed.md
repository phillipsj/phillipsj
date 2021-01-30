---
title: "Kotlin Native on openSUSE Tumbleweed"
date: 2021-01-29T21:38:57-05:00
tags:
- openSUSE
- Tumbleweed
- Kotlin
- Linux
- Open Source
---


I have started diving deeper into [Kotlin](https://kotlinlang.org) and doing a little tinkering with Kotlin Native. I am using IntelliJ to make it easy, and I ran into an issue. After creating a new Kotlin Native project using the IntelliJ wizard, the [tutorial](https://kotlinlang.org/docs/tutorials/native/using-intellij-idea.html) I ran into a build error. Here is the error I was getting when trying to run or build the project.

```
error while loading shared libraries: libtinfo.so.5: cannot open shared object file: No such file or directory
```

After a quick search, it seems that *libtinfo.so.5* is related to the ncurses5 library and needs to be installed. openSUSE Tumbleweed has ncurses6 installed by default. A quick search with zypper displays both installed and available packages.

```Bash
$ zypper search ncurses
Loading repository data...
Reading installed packages...

S  | Name                          | Summary                                                     | Type
---+-------------------------------+-------------------------------------------------------------+--------
   | busybox-ncurses-utils         | Busybox applets replacing ncurses-utils                     | package
   | gambas3-gb-ncurses            | The ncurses component for Gambas                            | package
   | libncurses5                   | Terminal control library                                    | package
   | libncurses5-32bit             | Terminal control library                                    | package
i  | libncurses6                   | Terminal control library                                    | package
i  | libncurses6-32bit             | Terminal control library                                    | package
   | libyui-ncurses-devel          | Libyui-ncurses header files                                 | package
   | libyui-ncurses-doc            | Libyui-ncurses documentation                                | package
   | libyui-ncurses-pkg-devel      | Libyui-ncurses-pkg header files                             | package
   | libyui-ncurses-pkg-doc        | Libyui-ncurses-pkg documentation                            | package
i  | libyui-ncurses-pkg14          | Libyui - yast2 package selector widget for the ncurses UI   | package
   | libyui-ncurses-rest-api-devel | Libyui header files                                         | package
   | libyui-ncurses-rest-api14     | Libyui - The REST API plugin for the Ncurses frontend       | package
   | libyui-ncurses-tools          | Libyui-ncurses tools                                        | package
i  | libyui-ncurses14              | Libyui - Character Based User Interface                     | package
i  | ncurses-devel                 | Development files for the ncurses6 terminal control library | package
   | ncurses-devel-32bit           | Development files for the ncurses6 terminal control library | package
   | ncurses-devel-static          | Static libraries for the ncurses6 terminal control library  | package
i  | ncurses-utils                 | Tools using the new curses libraries                        | package
   | ncurses5-devel                | Development files for the ncurses5 terminal control library | package
   | ncurses5-devel-32bit          | Development files for the ncurses5 terminal control library | package
   | ncurses5-devel-static         | Static libraries for the ncurses5 terminal control library  | package
```

I decided that I would install the ncurses5-devel package to be on the safe side.

```Bash
$ sudo zypper install ncurses5-devel
Loading repository data...
Reading installed packages...
Resolving package dependencies...

The following 2 NEW packages are going to be installed:
  libncurses5 ncurses5-devel

2 new packages to install.
```

After that completed, a quick run of the Kotlin app in IntelliJ produced the following. 

```
BUILD SUCCESSFUL in 158ms
1 actionable task: 1 executed

> Task :compileKotlinNative UP-TO-DATE
> Task :linkDebugExecutableNative

> Task :runDebugExecutableNative
Hello, Kotlin/Native!
```

That's it, a missing library that was thankfully easy to install. I hope this helps someone else that runs into this issue.

Thanks for reading,

Jamie
