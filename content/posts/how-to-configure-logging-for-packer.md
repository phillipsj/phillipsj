---
Title: "How to configure logging for Packer"
date: 2018-11-25T13:05:53
Tags: 
- Open Source
- PowerShell
- Microsoft And Linux
- Bash 
- Linux
- Microsoft
- Packer
---
# How to configure logging for Packer

I have been working with [Packer](https://www.packer.io) extensively over the last seven months. I have slowly been gaining knowledge for working with it in various scenarios and I always discover something new buried in the documentation that I haven't had the need to use or I just didn't know it existed. One of these newly discovered items is how logging works with Packer. 

[Logging](https://www.packer.io/docs/other/debugging.html#debugging-packer) info is inside of the debugging section and I would encourage you to turn it on when running locally as the information is valuable and more helpful than what is written out to the console. Below are the instructions for enabling the logging on both Windows and Linux.

## Configuring Packer logging

Packer depends on two environment variables being configured. These two variables are **PACKER_LOG** and **PACKER_LOG_PATH**, both need to be configured our no logging will occur. I will be calling my log file **packerlog.txt**, however, it can be named whatever you like.

### Setting in current session

If you want to temporarily configure these for your sessions here is how you do that for both PowerShell and Bash. Once these are set the next time you run the **packer** command there will be a **packerlog.txt** file in the current working directory.

#### PowerShell

```PowerShell
> $env:PACKER_LOG=1
> $env:PACKER_LOG_PATH="packerlog.txt"
```

#### Bash

```Bash
$ export PACKER_LOG=1
$ export PACKER_LOG_PATH="packerlog.txt"
```

This is great for the one time session where you need detailed log information. I have found that I usually execute Packer from within [VS Code](https://code.visualstudio.com/) and my terminal buffer is overwritten so I can't always scroll back far enough. This has caused me to enable it permanently and add the log file to my *gitignore* file.

### Setting it permanently in your profile

I am a big fan of this method and this causes the least pain for me. I always dislike running a command, getting an error, then realizing that I need to execute it again with logging turned on. Let's see how to do this in PowerShell and Bash.

#### PowerShell

Here is how you will set this using your PowerShell profile. First, find and open your PowerShell profile. You can do that with the **$profile** command in a PowerShell console. Once that file is opened add the following lines.

```PowerShell
# Packer log settings
$env:PACKER_LOG=1
$env:PACKER_LOG_PATH="packerlog.txt"
```

Now close and reopen the console and type the following to verify that it worked.

```PowerShell
> echo $env:PACKER_LOG
1
> echo $env:PACKER_LOG_PATH
packerlog.txt
```

### Bash

This is almost identical to how you do it for PowerShell, except the file name is a little different. Open your **.bashrc** which is located in your *$home* directory and add the following lines.

```Bash
# Packer log settings
export PACKER_LOG=1
export PACKER_LOG_PATH="packerlog.txt"
```

Now close your current Bash console and reopen, now we can test that they are working correctly.

```Bash
$ echo $PACKER_LOG
1
$ echo $PACKER_LOG_PATH
packerlog.txt
```

## Conclusion

That is all it takes to get a really useful log file for Packer that will save you time when something goes wrong. Thanks for reading and I hope you find this useful too.

Jamie
