---
Title: "Installing .NET Core 2.1 on Solus"
Published: 07/01/2018 19:13:37
Tags: 
- Open Source
- Dotnet Core
- Microsoft And Linux
- Tools
---
# Installing .NET Core 2.1 on Solus

Apparently my previous [post](https://www.phillipsj.net/posts/dotnet-dev-solus) was linked on [Reddit]() and a user was having issues. Here is an update for getting .NET Core 2.1 running on Solus. Most of the dependencies that are needed for 2.1 to run are already installed, the only one not installed is *liblttng-ust*.

```
~$ sudo eopkg install liblttng-ust 
```

Now let's install 2.1.

```
~$ curl -sSL -o dotnet.tar.gz https://download.microsoft.com/download/8/8/5/88544F33-836A-49A5-8B67-451C24709A8F/dotnet-sdk-2.1.300-linux-x64.tar.gz
~$ mkdir -p ~/dotnet && tar zxf dotnet.tar.gz -C ~/dotnet
~$ export PATH=$PATH:$HOME/dotnet
```

Now run the following to see if it worked.

```
~$ dotnet
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

Now let's create a test project to verify.

```
~$ dotnet new console -o test
~$ cd test
~$ dotnet run
Hello World!
```

Hope this helps anyone trying to get it installed.  What I feel is extremely cool is that Solus ships 95% of the dependencies pre-installed.