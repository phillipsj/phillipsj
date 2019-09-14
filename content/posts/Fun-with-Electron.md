---
Title: Fun with Electron
date: 2016-05-13T20:00:00
Tags:
- Electron
- OSS
- Node
RedirectFrom: blog/html/2016/05/13/fun_with_electron
---

So I have had the privilege to get to learn a little about [Electron](http://electron.atom.io/). My team inherited an app that was built using [AppJS](http://appjs.com/). Since that project is deprecated,we needed to move it to a new platform. I started looking around and decided to give Electron a try since I have been using [Atom](https://atom.io/) and [VSCode](https://code.visualstudio.com/). Another great thing about Electron is that we can get to keep our deployment consistent since it also uses [Squirrel.Windows](https://github.com/Squirrel/Squirrel.Windows) like we have started using for our other desktop apps. An added bonus is we can use [React](http://facebook.github.io/react/) also.

My only recommendation is that it helps to have the following items installed on a Windows System as it will make building any native node modules easier.

*   [Python 2.7.x](https://www.python.org/downloads/release/python-2711/) matching the bitness of your Node.
*   [Visual C++ Compiler for Python 2.7](https://www.microsoft.com/en-us/download/details.aspx?id=44266)
*   [Visual C++ for Visual Studio 2015](https://www.visualstudio.com/vs-2015-product-editions)
*   [Windows 8.1 SDK](https://developer.microsoft.com/en-us/windows/downloads/windows-8-1-sdk)
