---
Title: ".NET Core 2.0 Preview on Ubuntu"
date: 2017-07-27T19:48:13
Tags: 
- Open Source
- Dotnet Core
- Microsoft And Linux
---
# .NET Core 2.0 Preview on Ubuntu

I have wanted to play with the new .NET core 2.0 preview and I wanted to do it on Ubuntu 16.04. So I am going to walk you through how to install it.

**This post is intended to developers that are new to Ubuntu**.

The first step is to have a working Ubuntu 16.04 system, this can be in the cloud, virtual, docker, or bare metal. Now that you have a working Ubuntu 16.04 system, lets follow the guide found [here](https://www.microsoft.com/net/core#linuxubuntu). This guide wants you to run the following commands:

```
sudo sh -c 'echo "deb [arch=amd64] https://apt-mo.trafficmanager.net/repos/dotnet-release/ xenial main" > /etc/apt/sources.list.d/dotnetdev.list'
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 417A0893
sudo apt-get update
```

The frist command in this list adds the dotnet package repository to your list of repositories in Ubuntu. Then you add the key that authenticates the packages. Then you run an update, refreshing the list of packages.

The next step, if you are following the instructions, would have you install .NET core 1.0.4. That is not what we want, we want the latest and greatest. However, we don't easily know that name to enter. This is where the following command comes into play. Type into the terminal:

```
sudo apt search dotnet-dev
```

This command is going to search for list of repositories for packages that start with *dotnet-dev*. You should see the following list:

```
Sorting... Done
Full Text Search... Done
dotnet-dev-1.0.0-preview2-003121/xenial 1.0.0-preview2-003121-1 amd64
  Microsoft .NET Core 1.0.0 - SDK Preview 2

dotnet-dev-1.0.0-preview2-003131/xenial 1.0.0-preview2-003131-1 amd64
  Microsoft .NET Core 1.0.1 - SDK 1.0.0 Preview 2-003131

dotnet-dev-1.0.0-preview2-003156/xenial 1.0.0-preview2-003156-1 amd64
  Microsoft .NET Core 1.0.3 - SDK 1.0.0 Preview 2-003156

dotnet-dev-1.0.0-preview2-1-003177/xenial 1.0.0-preview2-1-003177-1 amd64
  Microsoft .NET Core 1.1.0 - SDK 1.0.0 Preview 2.1-003177

dotnet-dev-1.0.0-preview2.1-003155/xenial 1.0.0-preview2.1-003155-1 amd64
  Microsoft .NET Core 1.1.0 Preview1 - SDK 1.0.0 Preview 2.1-003155

dotnet-dev-1.0.0-preview3-004056/xenial 1.0.0-preview3-004056-1 amd64
  Microsoft .NET Core 1.0.1 - SDK Preview 3

dotnet-dev-1.0.0-preview4-004233/xenial 1.0.0-preview4-004233-1 amd64
  Microsoft .NET Core 1.0.1 - SDK Preview 4

dotnet-dev-1.0.0-rc3-004530/xenial 1.0.0-rc3-004530-1 amd64
  Microsoft .NET Core 1.0.3 - SDK RC 3

dotnet-dev-1.0.0-rc4-004769/xenial 1.0.0-rc4-004769-1 amd64
  Microsoft .NET Core 1.0.3 - SDK RC 4

dotnet-dev-1.0.0-rc4-004771/xenial 1.0.0-rc4-004771-1 amd64
  Microsoft .NET Core 1.0.3 - SDK RC 4

dotnet-dev-1.0.1/xenial 1.0.1-1 amd64
  .NET Core SDK 1.0.1

dotnet-dev-1.0.3/xenial 1.0.3-1 amd64
  .NET Core SDK 1.0.3

dotnet-dev-1.0.4/xenial 1.0.4-1 amd64
  .NET Core SDK 1.0.4

dotnet-dev-1.1.0-preview1-005051/xenial 1.1.0-preview1-005051-1 amd64
  .NET Core SDK 1.1.0

dotnet-dev-1.1.0-preview1-005077/xenial 1.1.0-preview1-005077-1 amd64
  .NET Core SDK 1.1.0

dotnet-dev-2.0.0-preview1-005977/xenial,now 2.0.0-preview1-005977-1 amd64 [installed]
  Microsoft .NET Core 2.0.0 - SDK Preview 1
```

And look at the last entry in the list, it is the .NET core 2.0 preview 1 package. To install it type:

```
sudo apt-get install -y dotnet-dev-2.0.0-preview1-005977
```

Now you have the .NET core 2.0 preview installed.  Type the following to verify:

```
dotnet --version
```

And you should see:

```
2.0.0-preview1-005977
```

Now we can pick the instructions back up and create a hello world console app by doing the following:

```
mkdir hwapp
cd hwapp
dotnet new console
dotnet run
Hello World!
```

If all of that works, you now have the latest and greatest .NET core running on Ubuntu.
