---
Title: "Building .NET Core apps old school with Make"
Published: 10/14/2018 20:31:28
Tags: 
- Open Source
- .NET Core
- Microsoft And Linux
- Tools
- Make
---
# Building .NET Core apps old school with Make

[Make](https://bit.ly/2FXluLS) is one of the OG build tools. Make was built by Stuart Feldman in 1976. Most tools in other languages riff on the name, that is how unknowingly ubiquitous it is. Makefiles are how you specificy builds for Make. Makefiles have a lot going for them, they are cross-platform with tools like [nmake](https://docs.microsoft.com/en-us/cpp/build/nmake-reference?view=vs-2017), they are simple, and there is a ton of info on how to create them. With all of that said, a Makefile, in my opinion, are really designed to work with CLI based toolings.

I am a big fan of Cake as you can tell from by blog. It fits nicely for glueing lots of tools together to get a great build. With my sudden interest in [the Unix phillosphy](https://en.wikipedia.org/wiki/Unix_philosophy) and functional programming, I really want to start focusing my workflow around simple composable tools. The .NET CLI, global tools, and other CLI tools start making this much easier to approach with .NET Core applications.

## Creating the Makefile

With this little bit of info out of the way, let's get started creating a .NET Core application build with Make.

```Bash
$ mkdir made && cd $_
$ dotnet new console
$ touch Makefile
```

Now that we have the basic structure out of the way we are going to create a basic set of targets along with a default task that runs all the other task. Open the *Makefile* and past the following:

```Makefile
all : clean restore build publish

clean:
	dotnet clean

restore:
	dotnet restore

build: 
	dotnet build

publish:
	dotnet publish -c Release -r linux-x64
	warp-packer --arch linux-x64 --input_dir bin/Release/netcoreapp2.1/linux-x64/publish --exec made --output made

run:
	dotnet run
```

Let's do a quick run through of all the above. We have five targets along with a default target named *all*. All executes if no target is specified when running Make. The other targets do the same thing as their name, but the if you look at the *publish* target you will see that we are running another CLI tool, [Warp](https://www.phillipsj.net/posts/warp-single-executable-dotnet-core-app). With that all resolved, let's run our Makefile and and see what happens.

```Bash
$ make clean
Microsoft (R) Build Engine version 15.8.169+g1ccb72aefa for .NET Core
Copyright (C) Microsoft Corporation. All rights reserved.

Build started 10/14/18 9:08:16 PM.

Build succeeded.
    0 Warning(s)
    0 Error(s)

Time Elapsed 00:00:00.68
```

That is exactly what was expected. Now let's just run Make in the directory with the Makefile, it will automatically excecute the *all* command.

```Bash
$ make
---Lots omitted---
Compressing input directory "bin/Release/netcoreapp2.1/linux-x64/publish"...
Creating self-contained application binary "made"...
All done
```

Let's see what was added to the project directory and execute our new file called *made*.

```Bash
$ ls 
bin  made  made.csproj  Makefile  obj  Program.cs

$ chmod +x made

$ ./made
Hello World!
```

## Where to go from here

Now this is a basic example, but where can we go from here. Well the possibilities are limitless really since any CLI tool can be used without any hassle. Here are some examples.

### Install .NET CLI Global Tools

Here is an example creating an *install* target that installs tools needed to build or deploy the applicaiton. In this example we are grabbing [dotnet-sshdeploy](https://github.com/unosquare/sshdeploy) and [dotnet-xdt](https://github.com/nil4/dotnet-transform-xdt).

```Makefile
all : clean build

install:
    dotnet tool install -g dotnet-sshdeploy
    dotnet tool install -g dotnet-xdt
```

### Install HashiCorp Packer

Here is an example creating an *install-packer* target that downloads packer and makes it ready to use in your project.

```Makefile
all : clean build

install-packer:
    echo "Fetching Packer..."
    wget -O packer.zip https://releases.hashicorp.com/packer/1.3.1/packer_1.3.1_linux_amd64.zip

    echo "Unzipping Packer..."
    unzip packer.zip

    echo "Making packer executable..."
    chmod +x ./packer
```

### Execute Azure CLI commands

Here is an example target called *build-azure* that shows how to execute Azure CLI commands.

```Makefile
all : clean build

build-azure:
    az webapp create --name Made --resource-group MyResoureGroup --plan MyPlan
```

## Conclusion

I plan more posts about Make and Makefiles in the future. Thanks for reading.