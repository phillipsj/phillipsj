---
Title: "Create more resilient  PowerShell scripts on Linux"
date: 2019-05-30T21:51:39
Tags: 
- Open Source
- PowerShell
- Microsoft And Linux
- Bash 
- Snap
---
# Create more resilient PowerShell scripts on Linux

I had previously written this [post](https://www.phillipsj.net/posts/using-powershell-scripts-from-bash) on how to execute PowerShell scripts from Bash. In that post, I discussed how to add the [shebang](https://en.wikipedia.org/wiki/Shebang_(Unix)) at the start of your script that will be ignored on non-Linux systems, but on Linux systems, it will provide the path to the interpreter you want to use, in our case it would be PowerShell. Here is a simple example:

```PowerShell
#! /usr/bin/pwsh

Write-Host 'Hello from a PowerShell script.'
```

So when this script executes, it will use the **/usr/bin/pwsh** location as the interpreter. That is all great if you did a distribution package installation like using the Debian or RPM package. However, if you use the Snap installation, the location for PowerShell is different. If I use the *which* command on a system with the Snap package for PowerShell installed I get the following location:

```Bash
$ which pwsh
/snap/bin/pwsh
```

Hmm, our script above will not work because the interpreter is defining an incorrect location. Fortunately, Linux provides a mechanism for handling this type of scenarios. This mechanism is the [env](https://en.wikipedia.org/wiki/Env) command which allows you to pass an executable and it will lookup the interpreter via the **PATH** variable. Let's take a look at that is happening.

First let's look at our path:

```Bash
$ echo $PATH
/home/phillipsj/.npm-packages/bin:/home/phillipsj/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/home/phillipsj/.dotnet/tools
```

In my **PATH** you will see that the **/snap/bin** directory is listed along with **/usr/bin**. PowerShell will be installed in either one of these locations. So we can use the **env** command to determine which interpreter to use without hard coding the path. Here is what that is going to look like in the script above:

```PowerShell
#! /usr/bin/env pwsh
Write-Host 'Hello from a PowerShell script.'
```

With just this simple change, our PowerShell scripts will be able to use this method that PowerShell can be installed making those scripts more portable.

I hope you find this helpful.

Thanks for reading,

Jamie
