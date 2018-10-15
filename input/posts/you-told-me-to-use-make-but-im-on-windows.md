---
Title: "You told me to use Make, but I'm on Windows"
Published: 10/15/2018 17:05:55
Tags: 
- Open Source
- .NET Core
- Microsoft And Linux
- Tools
- Make
---
# You told me to use Make, but I'm on Windows

In my [last]() post, I showed you how to use Make to build .NET Core applications. Now you may be saying, hey what do I do on Windows. Well, I mentioned in my last post about *nmake*, but I didn't provide much detail other than a reference to the documentation. With that said, here is how you get started with nmake.

## Install Visual C++ Development Tools

This is pretty easy as it now ships as a component of Visual Studio 2017. Hope over [here](https://blogs.msdn.microsoft.com/vcblog/2016/11/16/introducing-the-visual-studio-build-tools/) and read about it and make sure when you are installing Visual Studio 2017 that you install the **Visual C++ Build Tools** component.

With that out of the way, navigate to the following folder using PowerShell to see if nmake is now installed.

```PowerShell
$ cd "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Tools\MSVC\14.15.26726\bin\Hostx64\x64"
$ .\nmake.exe
Microsoft (R) Program Maintenance Utility Version 14.15.26730.0 
Copyright (C) Microsoft Corporation.  All rights reserved. 

NMAKE : fatal error U1064: MAKEFILE not found and no target specified 

Stop. 
```

Now that you have verified it is installed, we should make this easier to use. I don't like poluting my path, so I am going to add it to my path using my PowerShell profile.

```PowerShell
$env:Path += ";C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Tools\MSVC\14.15.26726\bin\Hostx64\x64"
```

Great, now restart PowerShell and type the following and you should see the below output.

```PowerShell
$ nmake
Microsoft (R) Program Maintenance Utility Version 14.15.26730.0 
Copyright (C) Microsoft Corporation.  All rights reserved. 

NMAKE : fatal error U1064: MAKEFILE not found and no target specified 

Stop. 
```

## Using it to build .NET Core Apps

Now that we have nmake installed and on our path, let's use it to build a .NET application.

Create a .NET Core Application.

```PowerShell
$ mkdir nmade | cd
$ dotnet new console
```

Now let's create a  Makefile.

```PowerShell
New-Item Makefile
```

Put the folliwing into your Makefile.

```Makefile
all : clean restore build publish 

setup-windows:

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    wget -O warp-packer.exe https://github.com/dgiagio/warp/releases/download/v0.1.1/windows-x64.warp-packer.exe

clean:
    dotnet clean

restore:
    dotnet restore

build:
    dotnet build

publish:
    dotnet publish -c Release -r win-x64
    warp-packer --arch windows-x64 --input_dir bin/Release/netcoreapp2.1/win-x64/publish --exec nmade.exe --output nmade.exe

run:
    dotnet run
```

Let's setup our Windows environment for the project.

```PowerShell
nmake setup-windows
```

Now let's run our Makefile using nmake.

```PowerShell
$ nmake
---omitting---
Creating self-contained application binary "nmade.exe"...
All done
```

That's it, really simple.

## Cross-Platform Usage

Now that we know we can create a single Makefile that can run cross-platform what do we need to do to ensure that we don't use tools that are incompatible? That is a great question and my simple answer is try to use tooling that you know is cross-platform. .NET CLI Global tools are a good example, using PowerShell on Windows is another example because there are many Linux commands that are aliases in PowerShell so your Makefile doesn't need to be rewritten. Finally another option is to add some more intellegience to your Makefile to determine the differences and execute different targets.

Thanks for reading.

Jamie