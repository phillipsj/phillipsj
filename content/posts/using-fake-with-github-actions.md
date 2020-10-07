---
title: "Using Fake With GitHub Actions"
date: 2020-10-06T19:57:44-04:00
tags:
- GitHub Actions
- GitHub
- Open Source
- FSharp
- .NET
---

I have been working on an F# project that I will be sharing soon. One of the tasks that I have left is setting up CI/CD for the application. Since I am using F#, the natural choice is to leverage [Fake](https://fake.build). Fake is a build tool that leverages F# to write your build scripts. Getting started is easy, and I would recommend installing it as a [local tool](https://docs.microsoft.com/en-us/dotnet/core/tools/local-tools-how-to-use). I will walk you through all the steps of creating an empty F# project, configuring Fake, and making your GitHub Actions YAML file. 

## Creating your F# Project

Let's create a new F# project using the .NET CLI.

```Bash
$ dotnet new console -o fakegithubactions --language F#
The template "Console Application" was created successfully.

Processing post-creation actions...
Running 'dotnet restore' on fakegithubactions/fakegithubactions.fsproj...
  Determining projects to restore...
  Restored /home/phillipsj/code/fakegithubactions/fakegithubactions.fsproj (in 285 ms).

Restore succeeded.
```

Now let's change into the directory and run a build to make sure everything is okay.

```Bash
$ cd fakegithubactions && dotnet build
Microsoft (R) Build Engine version 16.7.0+7fb82e5b2 for .NET
Copyright (C) Microsoft Corporation. All rights reserved.

  Determining projects to restore...
  All projects are up-to-date for restore.
  fakegithubactions -> /home/phillipsj/code/fakegithubactions/bin/Debug/netcoreapp3.1/fakegithubactions.dll

Build succeeded.
    0 Warning(s)
    0 Error(s)

Time Elapsed 00:00:03.75
```

## Adding Fake as a local tool

We are going to bootstrap Fake using the [template](https://fake.build/fake-template.html) that is provided. Make sure you are in the project directory then execute the following command. You will be asked a few questions, and I have included those in the output below.

```Bash
$ dotnet new -i "fake-template::*" && dotnet new fake
The template "FAKE - Template" was created successfully.

Processing post-creation actions...
Template is configured to run the following action:
Description: Make scripts executable
Manual instructions: Run 'chmod +x *.sh'
Actual command: /bin/sh -c "chmod +x *.sh"
Do you want to run this action (Y|N)?
Y
Running command '/bin/sh -c "chmod +x *.sh"'...
Command succeeded.

Template is configured to run the following action:
Description: update to latest version
Manual instructions: Run 'dotnet tool update fake-cli'
Actual command: dotnet tool update fake-cli
Do you want to run this action (Y|N)?
Y
Running command 'dotnet tool update fake-cli'...
Command succeeded.
```

Now we have Fake installed as a local tool, let's execute a build with Fake.

```Bash
$ dotnet fake build
The last restore is still up to date. Nothing left to do.
run All
Building project with version: LocalBuild
Shortened DependencyGraph for Target All:
<== All
   <== Build
      <== Clean

The running order is:
Group - 1
  - Clean
Group - 2
  - Build
Group - 3
  - All
Starting target 'Clean'
Finished (TagStatus.Success) 'Clean' in 00:00:00.0133164
Starting target 'Build'
Finished (TagStatus.Success) 'Build' in 00:00:00.0003516
Starting target 'All'
Finished (TagStatus.Success) 'All' in 00:00:00.0001141

---------------------------------------------------------------------
Build Time Report
---------------------------------------------------------------------
Target     Duration
------     --------
Clean      00:00:00.0095657
Build      00:00:00.0002969
All        00:00:00.0000547
Total:     00:00:00.1599943
Status: Okay
---------------------------------------------------------------------
Performance:
 - Cli parsing: 250 milliseconds
 - Packages: 55 milliseconds
 - Script analyzing: 15 milliseconds
 - Script running: 316 milliseconds
 - Script cleanup: 1 millisecond
 - Runtime: 960 milliseconds
```

Great! We now have Fake installed, and we are using it to build our project. When you add this to source control, don't forget to include the *.config* folder containing the local tool manifest file. Let's create our GitHub Actions workflow.

## The GitHub Actions Workflow

Now we need to create our workflow YAML file. These go in a directory named *.github*. Here is the single line to make it.

```Bash
$ mkdir -p .github/workflows && touch .github/workflows/build.yml
```

Now open the *build.yml* file and add the following to define our workflow name and triggers. We will only trigger our build on pushes to *main* and pull requests to *main*.

```YAML
name: Build
on:
  # Trigger the workflow on push or pull request,
  # but only for the main branch
  push:
    branches:
      - main
  pull_request:
    branches:
      - main
```

Now we need to define our jobs, which we are only going to have one, and that is to build.

```YAML
jobs:
  build:
    name: Build
```

We need to define what operating system we want to build our application on. After looking at the one used by [Cake](https://github.com/cake-build/cake/blob/develop/.github/workflows/build.yml), I decided to build against Windows, Ubuntu, and MacOS as those are the platforms I plan to support. This goes right after the name attribute.

```YAML
runs-on: ${{ matrix.os }}
strategy:
  fail-fast: false
  matrix:
    os: [windows-latest, ubuntu-latest, macos-latest]
```

Next are the steps that need to occur during the job. We will need to check out our code and get all of our tags and branches, which will be leveraged later.

```YAML
steps:
  - name: Get the sources
    uses: actions/checkout@v2

  - name: Fetch all history for all tags and branches
    run: git fetch --prune --unshallow
```

We will need to install the .NET SDK and install our Fake .NET local tool.

```YAML
- name: Install .NET Core SDK 3.1.402
  uses: actions/setup-dotnet@v1
  with:
    dotnet-version: '3.1.402'
    
- name: Install Dotnet Tools
  run: dotnet tool restore
```

Finally, we can execute our Fake build.

```YAML
- name: Run Fake
  run: dotnet fake build
```

Here is the *build.yml* file in its entirety.

```YAML
name: Build
on:
  # Trigger the workflow on push or pull request,
  # but only for the main branch
  push:
    branches:
      - main
  pull_request:
    branches:
      - main
jobs:
  build:
    name: Build
    runs-on: ${{ matrix.os }}
    strategy:
      fail-fast: false
      matrix:
        os: [windows-latest, ubuntu-latest, macos-latest]
    steps:
      - name: Get the sources
        uses: actions/checkout@v2

      - name: Fetch all history for all tags and branches
        run: git fetch --prune --unshallow

      - name: Install .NET Core SDK 3.1.402
        uses: actions/setup-dotnet@v1
        with:
          dotnet-version: '3.1.402'
    
      - name: Install Dotnet Tools
        run: dotnet tool restore
        
      - name: Run Fake
        run: dotnet fake build
```

## Push to GitHub

The excitement is building at this point in time. We push to GitHub to see if our build works as expected.

![](/images/other-posts/fakegithubactions.png)

All three operating systems were built successfully. You are now bootstrapped for being able to extend the Fake build to meet your needs.

## Conclusion

I was hesitant to learn GitHub Actions. After configuring it, I will say that it is way better than Azure DevOps YAML. Do I think it is as clean as some other implementations? No, that is just a personal thing.

I look forward to diving in and learning more about what I can do as I get this new application published.

Thanks for reading,

Jamie 
