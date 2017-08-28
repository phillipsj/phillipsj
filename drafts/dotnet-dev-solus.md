---
Title: ".NET Core on Solus"
Published: 08/28/2017 21:28:46
Tags: 
- Open Source
- Dotnet Core
- Microsoft And Linux
- Tools
---
# .NET Core on Solus

I have always liked and followed the [Solus](https://solus-project.com) project. I have always liked anything [Ikey Doherty](https://github.com/ikeydoherty) has been involved with dating back to his Linux Mint days.  

I decided I would do a full install on my extra machine and see what it has to offer. I have to say it is an amazing desktop environment and as it gains momentum it is going to really take footing.

## How do I get .NET Core 2.0 running?

So, here I sit with a beautiful new desktop environment that is great to use. I went to the .NET core [homepage](https://www.microsoft.com/net/core#linuxdebian) and opened up the examples for Debian Linux. I decided I would install the libraries listed in their version, then do the download of the tar and give it a try.

Here is what I was greated with:

```
$ sudo eopkg install curl libunwind gettext
The following package(s) are already installed and are not going to be installed again:
curl  gettext  libunwind
No packages to install.
```

Wow, all the depedencies are already installed. Just move to step 2.

```
$ curl -sSL -o dotnet.tar.gz https://aka.ms/dotnet-sdk-2.0.0-linux-x64
$ mkdir -p ~/dotnet && tar zxf dotnet.tar.gz -C ~/dotnet
$ export PATH=$PATH:$HOME/dotnet
```

Now run the following to see if it worked.

```
dotnet
```

It worked!

```
Usage: dotnet [options]
Usage: dotnet [path-to-application]

Options:
  -h|--help            Display help.
  --version         Display version.

path-to-application:
  The path to an application .dll file to execute.
```

Can you believe it? It just worked out of the box with less work than what was previously involved. That is amazing.