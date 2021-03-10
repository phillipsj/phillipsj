---
title: "Fixie Tests With Nuke Lightweight Integrations"
date: 2021-03-09T20:27:49-05:00
tags:
- Open Source
- .NET Core
- Tools
- Nuke
- Fixie
---

I have been exploring [Nuke](https://nuke.build) as a .NET build system. So far I am really enjoying using it and many of its concepts. One thing that Nuke doesn't yet have support for is [Fixie](https://fixie.github.io/), a lightweight and conventioned driven testing framework. Nuke has this concept called [lightweight integration](https://nuke.build/docs/authoring-builds/cli-tools.html#lightweight-integration) that allows you to define a few details as attributes that will configure a basic tool for you to use in your Build.cs. In the case of Fixie, those details are the package id and the package executable for the *Fixie.Console* package. Once that has been configured, you will have a tool that you can pass arguments as a string. It is very basic and not as feature rich as an actual tool, just remember this is meant to be lightweight. Let's jump in and see this in action.

## Solution Setup

You will need a solution configured with a project, a project for our tests, and Nuke configured. I have a repository that can be cloned located [here](https://github.com/phillipsj/fixie-example). Once you have that complete, let's open the *Build.cs* in your favorite editor.

## Fixie Lightweight Tool

If you read the Fixie documentation for setting up the *Fixie.Console* tool, it suggests that you place it in your tests project as a tool reference. With Nuke, you can just define that as a *PackageDownload* in the **_build.csproj** file. Here is that snippet that needs added to the *ItemGroup*.

```XML
<ItemGroup>
    <PackageReference Include="Nuke.Common" Version="5.0.2" />
    <PackageDownload Include="Fixie.Console" Version="[2.2.2]" />
</ItemGroup>
```

Open the *Build.cs* file so we can create our Fixie tool.

```CSharp
readonly Tool Fixie;
```

Now we can decorate that with the *PackageExecutable* attribute and define the package id and package executable. The package id is *Fixie.Console* and the executable is *dotnet-fixie.dll*.

```CSharp
[PackageExecutable(packageId: "Fixie.Console", 
                   packageExecutable: "dotnet-fixie.dll")]
readonly Tool Fixie;
```

We now have a tool that will execute Fixie. We need to add our target for Fixie.

```CSharp
Target Tests => _ => _
    .DependsOn(Compile)
    .Executes(() =>
    {
        var testsDirectory = SourceDirectory + "/FixieExample.Tests";
        Fixie("--no-build", workingDirectory: testsDirectory);
    });
```

We are going to pass the **--no-build** argument to Fixie to not trigger a build since we are executing it after the compile target. The last step is that we need to 


We need to set the working directory to our tests project. Now we can execute our tests target to see our tool in action.

```Bash
$ nuke -Target Tests
...........
╬═════════
║ Test
╬══

> /usr/bin/dotnet /home/phillipsj/.nuget/packages/fixie.console/2.2.2/lib/netcoreapp2.0/dotnet-fixie.dll --no-build
@ /home/phillipsj/code/fixie-example/src/FixieExample.Tests

Running FixieExample.Tests

1 passed, took 0.02 seconds


═══════════════════════════════════════
Target             Status      Duration
───────────────────────────────────────
Restore            Executed        0:01
Compile            Executed        0:01
Test               Executed        0:01
───────────────────────────────────────
Total                              0:04
═══════════════════════════════════════

Build succeeded on 3/9/2021 9:35:35 PM. ＼（＾ᴗ＾）／
```

We have succesfully created a lightweight integration for Fixie in Nuke. 

## Conclusion

I don't know about you, I find this an fascinating feature. Having the ability to create a typed implementation of a tool that isn't supported is very useful for those that don't have the time or need to add a more complex implementation. It also allows getting your tools as part of execution leveraging the built in capabilities of .NET.

Thanks for reading,

Jamie
