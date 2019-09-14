---
Title: "How to configure logging for Terraform"
date: 2018-11-25T20:52:26
Tags: 
- Open Source
- PowerShell
- Microsoft And Linux
- Bash 
- Linux
- Microsoft
- Terraform
---
# How to configure logging for Terraform

I have been working with [Terraform](https://www.terraform.io) extensively over the last year. I have slowly been gaining knowledge for working with it in various scenarios and I always discover something new buried in the documentation that I haven't had the need to use or I just didn't know it existed. There have been many times that I just used the error returned from the *plan* or *apply* step to figure out my issue, recently I have needed more info and found that I could have Terraform perform verbose logging that puts out way more information that makes it easier to debug my issue.

[Logging](https://www.terraform.io/docs/internals/debugging.html) info can be found in the *Debugging Terraform* section of the documentation and I would encourage you to turn it on when running locally. The information is valuable and more helpful than what is written out during *plan* or *apply*. Below are the instructions for enabling the logging on both Windows and Linux. I will be setting mine to **TRACE**, but know that you can set it to **DEBUG**, **INFO**, **WARN**, or **ERROR**. I have chosen to use the most verbose setting as I don't want to have to rerun commands when I hit an issue just to debug. 

## Configuring Terraform logging

Terraform depends on two environment variables being configured. These two variables are **TF_LOG** and **TF_LOG_PATH**, both need to be configured our no logging will occur. I will be calling my log file **terraform.txt**, however, it can be named whatever you like.

### Setting in current session

If you want to temporarily configure these for your sessions here is how you do that for both PowerShell and Bash. Once these are set the next time you run the **terraform** command there will be a **terraform.txt** file in the current working directory.

#### PowerShell

```PowerShell
> $env:TF_LOG="TRACE"
> $env:TF_LOG_PATH="terraform.txt"
```

#### Bash

```Bash
$ export TF_LOG="TRACE"
$ export TF_LOG_PATH="terraform.txt"
```

This is great for the one time session where you need detailed log information. I have found that I usually execute Terraform from within [VS Code](https://code.visualstudio.com/) and my terminal buffer is overwritten so I can't always scroll back far enough. This has caused me to enable it permanently and add the log file to my *gitignore* file.

### Setting it permanently in your profile

I am a big fan of this method and this causes the least pain for me. I always dislike running a command, getting an error, then realizing that I need to execute it again with logging turned on. Let's see how to do this in PowerShell and Bash.

#### PowerShell

Here is how you will set this using your PowerShell profile. First, find and open your PowerShell profile. You can do that with the **$profile** command in a PowerShell console. Once that file is opened add the following lines.

```PowerShell
# Terraform log settings
$env:TF_LOG="TRACE"
$env:TF_LOG_PATH="terraform.txt"
```

Now close and reopen the console and type the following to verify that it worked.

```PowerShell
> echo $env:TF_LOG
TRACE
> echo $env:TF_LOG_PATH
terraform.txt
```

### Bash

This is almost identical to how you do it for PowerShell, except the file name is a little different. Open your **.bashrc** which is located in your *$home* directory and add the following lines.

```Bash
# Terraform log settings
export TF_LOG=TRACE
export TF_LOG_PATH="terraform.txt"
```

Now close your current Bash console and reopen, now we can test that they are working correctly.

```Bash
$ echo $TF_LOG
TRACE
$ echo $TF_LOG_PATH
terraform.txt
```

## Conclusion

That is all it takes to get a really useful log file for Terraform that will save you time when something goes wrong. Thanks for reading and I hope you find this useful.

Jamie
