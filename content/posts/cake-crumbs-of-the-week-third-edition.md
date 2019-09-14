---
Title: "Cake Crumbs of the Week #3"
date: 2017-03-21T21:06:52
Tags: 
- Open Source
- Cake
- Cake Crumbs
---
# Cake Crumbs of the Week #3

This is the third edition of my weekly series.  Here are a few more tips.

## How to pin your Cake version

The bootstrapper for Cake will always download the latest and greatest version of Cake.  Sometimes this is the behavior that you want and other times it isn't.  The general recommendation by the Cake team is to always pin your version in the **pacakges.config** file located in the **tools** directory. This can be found [here](http://cakebuild.net/docs/tutorials/getting-started) in the project documentation.

![](/images/other-posts/cake-pinning.png)

However, if you are like most people, your .gitignore file has the following lines:

```
# User-specific files
*.suo
*.user
*.userosscache
*.sln.docstates

# Cake - C# Make
tools
```

If notice that last line, it will ignore everything in the **tools** directory. If you noticed in the documentation above you want to ignore everything in that folder except for the **packages.config**.  To do that you have to do a little gitignore [tomfoolery](https://www.merriam-webster.com/dictionary/tomfoolery).  You will need to change your gitignore to ignore all files under that directory except for your **packages.config**. How exactly that is achieved is below.

```
# User-specific files
*.suo
*.user
*.userosscache
*.sln.docstates

# Cake - C# Make
tools/*
!tools/packages.config
```

With that in your gitignore file, your Cake version will be pinned for your project. Then when you are ready to upgrade you can change the version number in the packages.config or you can delete it and run the bootstrapper.

## Baking a build with a Recipe

Did you know that if you are not a glutton for punishment and your build needs are pretty normal you can use this *best kept secret* in the Cake-Contrib organization called [Cake.Recipe](https://github.com/cake-contrib/Cake.Recipe). [Gary Park](http://www.gep13.co.uk/) has been operating a covert mission, in the open, to make configuring a Cake build really easy. All you need to do is to load the Cake.Recipe NuGet package in a file called *setup.cake*.  That name is purely convention so feel free to alter it. Once that is in place you will need to update the bootstrapper to execute *setup.cake*.  Then just set your environment variables you want to use, using the conventions defined [here](https://github.com/cake-contrib/Cake.Recipe/blob/develop/Cake.Recipe/Content/environment.cake). Once that is complete you can do a basic build parameters configuration, adjust some tool settings you need and BAM! You have a build that compiles and discovers your tests to be executed without you having to define everything. Lots of other cool items in there that I will be blogging about shortly.

Here is an example from the [Cake.CsvHelper](https://github.com/RadioSystems/Cake.CsvHelper) project, but the Cake-Contrib organization is full of examples too:

```
#load nuget:https://www.myget.org/F/cake-contrib/api/v2?package=Cake.Recipe&prerelease

Environment.SetVariableNames();

BuildParameters.SetParameters(context: Context, 
                            buildSystem: BuildSystem,
                            sourceDirectoryPath: "./src",
                            title: "Cake.CsvHelper",
                            repositoryOwner: "RadioSystems",
                            repositoryName: "Cake.CsvHelper",
                            appVeyorAccountName: "RadioSystems");

BuildParameters.PrintParameters(Context);

ToolSettings.SetToolSettings(context: Context,
                            dupFinderExcludePattern: new string[] { 
                                BuildParameters.RootDirectoryPath + "/src/Cake.CsvHelper.Tests/*.cs" },
                            testCoverageFilter: "+[*]* -[xunit.*]* -[Cake.Core]* -[Cake.Testing]* -[*.Tests]* ",
                            testCoverageExcludeByAttribute: "*.ExcludeFromCodeCoverage*",
                            testCoverageExcludeByFile: "*/*Designer.cs;*/*.g.cs;*/*.g.i.cs");
Build.Run();
```

You have a really awesome build that even prints ASCII art.

```
----------------------------------------
Setup
----------------------------------------
Executing custom setup action...
  ____         _               ____              _   _        _
 / ___|  __ _ | | __  ___     / ___| ___ __   __| | | |  ___ | | _ __    ___  _ __
| |     / _` || |/ / / _ \   | |    / __|\ \ / /| |_| | / _ \| || '_ \  / _ \| '__|
| |___ | (_| ||   < |  __/ _ | |___ \__ \ \ V / |  _  ||  __/| || |_) ||  __/| |
 \____| \__,_||_|\_\ \___|(_) \____||___/  \_/  |_| |_| \___||_|| .__/  \___||_|
                                                                |_|

Starting Setup...
Calculating Semantic Version...
Calculated Semantic Version: 0.1.0-unstable0003
Building version 0.1.0-unstable0003 of Cake.CsvHelper (Release, Default) using version 0.18.0.0 of Cake. (IsTagged: False)

========================================
Export-Release-Notes
========================================
Skipping task: Export-Release-Notes
```

** A reminder that this is still prerelease. **

Thanks for reading,

Jamie
