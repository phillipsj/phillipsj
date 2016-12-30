---
Title: 'Cake: Automating an existing project'
Published: 2016-07-24 15:22:36
Tags:
- Open Source
- Cake
- Tutorials
RedirectFrom: 2016/07/24/Cake-Automating-an-existing-project/
---

Hi, my name is Jamie and I am a [Cake](http://cakebuild.net/) addin author that doesn't build my addins using Cake. This seems kind of wrong too me and this is a bonus for you. I am going to walk you through how to use Cake to build your project, run your tests, create a [NuGet](https://www.nuget.org/) package, then publish to NuGet. I am going to walk you through performing this for my [Cake.XdtTransform](https://github.com/phillipsj/Cake.XdtTransform) project. The project is hosted on GitHub so you can see the final build. I am going to be using the wonderful extension created for [VsCode](https://code.visualstudio.com/) and will be doing most of my work in it, I will discuss the alternatives if you are not using VsCode. If you are going to continue with VsCode, then I would install the Cake Extension that has been created.

** Steps 1-2 can be skipped if you go grab those files from the [example](https://github.com/cake-build/example) project.

## Step 1:

By default all projects that use Cake starts with two files, the bootstrapper script, *build.ps1*, if on windows, or *build.sh*, on linux. The other file that is needed is the cake file, typically called *build.cake*.  In VsCode, open the project that you want to automate with Cake, open the command palette and run the Cake: Install Bootstrapper command, the select the bootstrapper file type that fits your system, in this example I have selected *Powershell*.  You should now see the *build.ps1* file in your project directory. At this point, there is not much more you are going to need to do with the bootstrapper file.

![](/images/cake-tutorial/VsCodeCakeBootstrapper.png)

![](/images/cake-tutorial/VsCodeCakeSelectBootstrapperType.png)

![](/images/cake-tutorial/VsCodeCakeSelectBootstrapperInstalled.png)

## Step 2:

Now you need to create your *build.cake* file. Once you have created the file we need to start putting in the basic plumbing that will be required. What is going to be shown below is typically the norm for most cake files, however, it isn't the only way it can be done. 

### Setting up arguments

Now you need to grab any arguments you want to pass to your cake file. The first argument we are going to grab that is passed in is the *target* argument. This will be the task that you want Cake to execute when it runs. It is set to *Default* if nothing is passed in. The second argument is the *configuration* that you want to target, it is set to "*Release* if nothing is passed. 

```
var target = Argument("target", "Default");
var configuration = Argument("configuration", "Release");
```

** A special note about arguments. If you open the bootstrapper file you will see that the arguments are parsed out by powershell then passed to your *build.cake* file. If you need to extend the arguments you will need to modify the bootstrapper file.

### Let's run Cake

At this point, lets open a powershell window and run:

```
$ .\build.ps1
```

You should see the following output:

```
Preparing to run build script...
Running build script...
Analyzing build script...
Processing build script...
Downloading and installing Roslyn...
Installing packages (using https://packages.nuget.org/api/v2)...
Copying files...
Copying Roslyn.Compilers.CSharp.dll...
Copying Roslyn.Compilers.dll...
Deleting installation directory...
Compiling build script...
```

You will also notice that a tools folder has been added to your project with a Cake folder, nuget.exe, and a packages.config.  This the bootstrapper getting nuget and configuring it, and then install Cake. This is pretty awesome as it doesn't require anything to be committed to your repository.

![](/images/cake-tutorial/BootstrapperGeneratedFoldersAndFiles.png)

## Step 3:

Now we need to do any preparation. In our example, we need to prepare by setting up our build directory and making our solution file path.

```
var buildDir = Directory("./src/Cake.XdtTransform/bin") + Directory(configuration);
var solution = "./src/Cake.XdtTransform.sln";
```

This is very basic, but you can imagine if you have a more complex setup like for a really complex build, you may have dozens of items that need prepared.

## Step 4:

Now we get to tasks. This is the targets that you will be executing to perform your build. Lots of items will be going on in this step and I will do my best to walk you through all of these.

### Cleaning the Directory

Always a good idea to clean any directories that you will be writing too.

```
Task("Clean")
    .Does(() =>{
        CleanDirectory(buildDir);
});
```

### Restoring NuGet Packages

This task introduces a new concept. If you look at the *.IsDependentOn* online, you will notice that we pass it the clean task. What this is doing is telling Cake, hey, before *Restore-NuGet-Packages* executes, the *Clean* tasks needs to occur first. This is the method that you will use to link your build tasks together to make sure that no matter which task you pass to be executed any dependent tasks are executed first. Finally, we call *NuGetRestore* which will fetch our NuGet packages. 

```
Task("Restore-NuGet-Packages")
    .IsDependentOn("Clean")
    .Does(() => {
        NuGetRestore(solution);
});
```

### Buiding the solution

Now that we have clean directories and restored NuGet packages we are ready to perform our build. We will create our build task with a dependency on *Restore-NuGet-Packages* to ensure that our packages are always restored before executing a build. We are going to use MSBuild to build our project.

```
Task("Build")
    .IsDependentOn("Restore-NuGet-Packages")
    .Does(() =>{
      // Use MSBuild
      MSBuild(solution, settings =>
        settings.SetConfiguration(configuration));  
});
```

## Finishing the Cake file

Now that we have the basics in place, lets finish the basic setup that needs to happen. We need to create a default task that will execute one of the tasks we just defined.

```
Task("Default")
    .IsDependentOn("Build");
```

Next we need to actually tell Cake to run the target parameter, which is you remember when we defined our arguments we defaulted to *Default*.

```
RunTarget(target);
```

Now we need to execute the Cake file to see if all the work we have done will execute and build our project.

```
$ .\build.ps1
```

You should see the following output:

```
Preparing to run build script...
Running build script...
Analyzing build script...
Processing build script...
Compiling build script...

========================================
Clean
========================================
Executing task: Clean
Cleaning directory C:/Users/cphil/code/Cake.XdtTransform/src/Cake.XdtTransform/bin/Release
Finished executing task: Clean

========================================
Restore-NuGet-Packages
========================================
Executing task: Restore-NuGet-Packages
MSBuild auto-detection: using msbuild version '14.0' from 'C:\Program Files (x86)\MSBuild\14.0\bin'.
All packages listed in packages.config are already installed.
Finished executing task: Restore-NuGet-Packages

========================================
Build
========================================
Executing task: Build
Microsoft (R) Build Engine version 14.0.25420.1
Copyright (C) Microsoft Corporation. All rights reserved.

Build started 7/24/2016 2:32:43 PM.
     1>Project "C:\Users\cphil\code\Cake.XdtTransform\src\Cake.XdtTransform.sln" on node 1 (Build target(s)).
     1>ValidateSolutionConfiguration:
         Building solution configuration "Release|Any CPU".
     1>Project "C:\Users\cphil\code\Cake.XdtTransform\src\Cake.XdtTransform.sln" (1) is building "C:\Users\cphil\code\C
       ake.XdtTransform\src\Cake.XdtTransform\Cake.XdtTransform.csproj" (3) on node 1 (default targets).
     ......
     2>Done Building Project "C:\Users\cphil\code\Cake.XdtTransform\src\Cake.XdtTransform.Tests\Cake.XdtTransform.Tests
       .csproj" (default targets).
     1>Done Building Project "C:\Users\cphil\code\Cake.XdtTransform\src\Cake.XdtTransform.sln" (Build target(s)).

Build succeeded.
    0 Warning(s)
    0 Error(s)

Time Elapsed 00:00:00.38
Finished executing task: Build

========================================
Default
========================================
Executing task: Default
Finished executing task: Default

Task                          Duration
--------------------------------------------------
Clean                         00:00:00.0091045
Restore-NuGet-Packages        00:00:00.3995194
Build                         00:00:00.4472326
Default                       00:00:00.0098848
--------------------------------------------------
Total:                        00:00:00.8657413
```

So it looks like we had a successful run of our Cake file. At this point we could just stop, but continue on as now we are getting into the more advanced topics.

## Step 5: 

In this step we are going to create a task that will execute our unit tests. In this example we are using [Fixie](http://fixie.github.io/), however, most major unit testing frameworks are supported. We will be adding a new concept that this step. We are going to start using the *tool* directive. The *tool* directive tells Cake that it needs to download additional tools to perform one of the tasks. The *tool* directive will place the tool package in the *tools* directory that the bootstrapper downloads NuGet and Cake too.

At the top of our Cake build file put the following *tool* directive.

```
#tool "nuget:?package=Fixie"
```

Now that we have the Fixie unit test runner being downloaded as part of our Cake file, we need to create our unit test task. In this task we use a pattern to tell Cake to search all directories looking for a bin folder and a configuration folder that matches and return all dlls with the name *Tests.dll*. Also note that our task is dependent on the build task.

```
Task("Run-Unit-Tests")
    .IsDependentOn("Build")
    .Does(() =>{
        Fixie("./src/\*\*/bin/" + configuration + "/*.Tests.dll");
});
```

Now that we have our test task in place and I want the default behavior to always run the unit tests. So I need to change the default task.

```
Task("Default")
    .IsDependentOn("Run-Unit-Tests");
```

Now we need to execute our Cake file and make sure nothing has been broken.

```
$ .\build.ps1
```

You should see the following output:

```
C:\Users\cphil\code\Cake.XdtTransform [develop ≡ +0 ~1 -0 !]> .\build.ps1
Preparing to run build script...
Running build script...
Analyzing build script...
Processing build script...
Installing tools...
Compiling build script...

...................

========================================
Run-Unit-Tests
========================================
Executing task: Run-Unit-Tests
------ Testing Assembly Cake.XdtTransform.Tests.dll ------

6 passed, 0 failed, took 0.33 seconds (Fixie 1.0.2).

Finished executing task: Run-Unit-Tests

========================================
Default
========================================
Executing task: Default
Finished executing task: Default

Task                          Duration
--------------------------------------------------
Clean                         00:00:00.0179829
Restore-NuGet-Packages        00:00:00.4070517
Build                         00:00:00.4498772
Run-Unit-Tests                00:00:00.4413167
Default                       00:00:00.0104593
--------------------------------------------------
Total:                        00:00:01.3266878
```

It looks like our tests all executed successfully and now we celebrate, but wait what good is all this work if we are not sharing it with the world.

Step 6:

If you look in the source directory under the Cake.XdtTransform folder you will notice that there is a nuspec file located in the directory called Cake.XdtTransform.nuspec. Since we have a nuspec file we should go ahead and create a NuGet package while we are here.

Luckily, the creators of Cake have already created the necessary tools to perform the packaging. All we need to do is create a task. We are going to name the task *Package* and we are going to make it dependent on the *Run-Unit-Tests* task, because we do not want to package if we fail our tests. We are not going to make this the default task as we want this task to be intentional.

```
Task("Package")
    .IsDependentOn("Run-Unit-Tests")
    .Does(() =>{
        NuGetPack("./src/Cake.XdtTransform/Cake.XdtTransform.nuspec", ​new NuGetPackSettings());
})
```

Now to test our handy work, we are going to run the Cake file, but this time we are going to pass a target of *Package*. What this will do is execute the *Package* task.

```
$ .\build.ps1 -Target Package
```

You should see the following output:

```
C:\Users\cphil\code\Cake.XdtTransform [develop ≡ +0 ~1 -0 !]> .\build.ps1
Preparing to run build script...
Running build script...
Analyzing build script...
Processing build script...
Installing tools...
Compiling build script...

...................

========================================
Package
========================================
Executing task: Package
Attempting to build package from 'Cake.XdtTransform.temp.nuspec'.
Successfully created package 'C:\Users\cphil\code\Cake.XdtTransform\Cake.XdtTransform.0.10.0.0.nupkg'.
Finished executing task: Package

Task                          Duration
--------------------------------------------------
Clean                         00:00:00.0127528
Restore-NuGet-Packages        00:00:00.4139956
Build                         00:00:00.4605471
Run-Unit-Tests                00:00:00.4670142
Package                       00:00:00.4101675
--------------------------------------------------
Total:                        00:00:01.7644772
```

# The finish line

So there you go, a basic walk through using Cake to perform the majority of the tasks that will need to be performed when working on a project. I have purposely left off the publishing of the project to a server or in this case NuGet, as there are more steps involved and those tasks are more about preference at that point. I know that I will probably let my CI server for the project, AppVeyor pick up the NuGet packae as an artifact and publish it. I may revist that in the new future as I learn to integrate Cake with a CI server.

Thanks for reading and hopefully you found this helpful.