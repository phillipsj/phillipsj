---
title: "PowerShell and Multi-Stage Container Builds"
date: 2020-11-17T21:13:37-05:00
tags:
- Open Source
- PowerShell
- PowerShell Containers
- Microsoft And Linux
- Containers
- Docker
---

Docker supports this concept of multi-stage builds. Multi-stage builds allow you to leverage an intermediate image that helps you to install development dependencies. Once you are through with those, you can copy any files to our final image to produce a container without those development dependencies. This makes a lot of sense when using a massive toolkit that requires 100s of megabytes or gigabytes, but the output is way less than that. The extra dependencies make your container larger and increase your attack surface from a security standpoint. 

At this point, you may be asking how does this relate to PowerShell. Well, this comes into play if you have started adding in testing using a module like [Pester](https://github.com/pester/pester). In a multi-stage build scenario, we would install the Pester module, run our tests, then, upon success, copy your script to your final image that you will deploy. Let's build a simple PowerShell script, write a Pester test for it, then create a multi-stage Dockerfile. If you want an introduction to PowerShell and containers, you can read my previous [post](https://www.phillipsj.net/posts/powershell-and-containers/).

## Script and Test

We will develop this locally to start. You could do this all straight up in a container if you want. Let's start by creating a *Hello.ps1* with the simple function below.

```PowerShell
function Get-Greeting {
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]
        $Name
    )

    Write-Host "Hello $($Name)"
}
```

Now we can test this out with a few scenarios.

```Bash
$ . ./Hello.ps1
$ Get-Greeting -Name Jamie
Hello Jamie
$ Get-Greeting Jamie
Hello Jamie
$ Get-Greeting

cmdlet Get-Greeting at command pipeline position 1
Supply values for the following parameters:
Name: 
Get-Greeting: Cannot bind argument to parameter 'Name' because it is an empty string.
```

Great, we now have a function that we can test with Pester. We will need to install Pester first.

```Bash
$ Install-Module -Name Pester -Force
```

Let's write our tests by creating *Hello.Tests.ps1*. We are going to create the following three tests to test all of our scenarios.

```PowerShell
BeforeAll {
    . $PSScriptRoot/Hello.ps1
}

Describe 'Get-Greeting' {
    It 'should throw an error when calling Get-Greeting with no parameter' {
        { Get-Greeting -Confirm:$false } | Should -Throw
    }

    It 'should call Get-Greeting with Name parameter' {
        Mock Write-Host {}
        Get-Greeting -Name Jamie
        Assert-MockCalled Write-Host -Exactly 1 -Scope It
        Assert-MockCalled Write-Host -Exactly 1 -Scope It -ParameterFilter { $Object -eq "Hello Jamie" }
    }

    It 'should call Get-Greeting with Name as positional parameter' {
        Mock Write-Host {}
        Get-Greeting Jamie
        Assert-MockCalled Write-Host -Exactly 1 -Scope It
        Assert-MockCalled Write-Host -Exactly 1 -Scope It -ParameterFilter { $Object -eq "Hello Jamie" }
    }
}
```

Finally, we can execute our tests to see if they all pass.

```Bash
$ Invoke-Pester -Output Detailed ./Hello.Tests.ps1

Starting discovery in 1 files.
Discovering in ../Hello.Tests.ps1.
Found 3 tests. 6ms
Discovery finished in 12ms.

Running tests from '../Hello.Tests.ps1'
Describing Get-Greeting
  [+] should throw an error when calling Get-Greeting with no parameter 17ms (13ms|4ms)
  [+] should call Get-Greeting with Name parameter 51ms (48ms|3ms)
  [+] should call Get-Greeting with Name as positional parameter 66ms (63ms|3ms)
Tests completed in 242ms
Tests Passed: 3, Failed: 0, Skipped: 0 NotRun: 0
```

We now have our script and tests; we can now put this all in a multi-stage Dockerfile to see how it will work.

## Multi-stage Dockerfile

Multi-stage Dockerfiles start with the initial image, which we will use to install Pester and execute our tests. If that is successful, we will copy just our Hello.ps1 to our final image to create our container. In the end, we will have a container without Pester installed.

Let's start by setting up our build image.

```Dockerfile
FROM mcr.microsoft.com/powershell:7.1.0-alpine-3.10 as build

SHELL ["pwsh", "-Command"]

RUN Install-Module -Name Pester -Force

COPY Hello.ps1 Hello.ps1
COPY Hello.Tests.ps1 Hello.Tests.ps1

RUN Import-Module Pester
RUN Invoke-Pester -Output Detailed ./Hello.Tests.ps1
```

We can then execute this build, and we should see that our tests successfully run.

```Bash
$ docker build .
...
Step 7/7 : RUN Invoke-Pester -Output Detailed ./Hello.Tests.ps1
 ---> Running in 02ea4b6cbd42

Starting discovery in 1 files.
Discovering in /Hello.Tests.ps1.
Found 3 tests. 148ms
Discovery finished in 284ms.

Running tests from '/Hello.Tests.ps1'
Describing Get-Greeting
  [+] should throw error when calling Get-Greeting with no parameter 161ms (110ms|51ms)
  [+] should call Get-Greeting with Name parameter 435ms (431ms|4ms)
  [+] should call Get-Greeting with Name as positional parameter 69ms (65ms|4ms)
Tests completed in 1.34s
Tests Passed: 3, Failed: 0, Skipped: 0 NotRun: 0
Removing intermediate container 02ea4b6cbd42
 ---> 19e96c72168d
Successfully built 19e96c72168d
```

We can add the final image, which will only be created if the build image executes correctly. After line 11 in our Dockefile, add the following.

```Dockerfile
FROM mcr.microsoft.com/powershell:7.1.0-alpine-3.10

COPY --from=build Hello.ps1 .

ENTRYPOINT ["pwsh"]
```

Now we can build our final container.

```Bash
$ docker build -t pshello .
Successfully built c6bc2b3660cd
Successfully tagged pshello:latest
```

Let's execute our *Get-Greeting* function from inside of the container by using the run command.

```Bash
$ docker run -it pshello:latest -Command "& { . .\Hello.ps1; Get-Greeting -Name Jamie }" 
Hello Jamie
```

Yay! It worked.

## Conclusion

This was a fun post to write. I was thinking about multi-stage builds, and I was curious about how these would work with PowerShell. The more complex your tests are, and scripts, the more useful this technique will be. We also now know how to package PowerShell scripts/commands in a container that we can ship to others to execute. 

Thanks for reading,

Jamie
