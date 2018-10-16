---
Title: "PowerShell and Bash Compatibility"
Published: 10/16/2018 08:03:07
Tags: 
- Open Source
- PowerShell
- Microsoft And Linux
- Bash 
---
# PowerShell and Bash Compatibility

Wow! I can't believe that I just created a post with this title, times are truly changing. In my last couple posts I have been talking about using Make to create cross-platform builds, however, one key issue to contend with is that the shell environments are drastically different at times. How would it be possible to this if the environments are that different? I am going to answer that question in this post and discuss areas that are interchangeable between PowerShell and Bash.

## Disclaimer

I am just treating Bash as the default shell on Linux, much of this applies to other shells like zsh. Typically Make will use whatever is set in the variable SHELL. To find what is set on your system as default type run:

```Bash
$ echo $SHELL
/bin/bash
```

You can see mine is Bash and I am pretty sure that by default on most Ubuntu based distros this will be true.

## PowerShell Aliases

We are very fortunate that PowerShell ships with aliases for popular Linux tools. We can use commands like mkdir, wget, curl, cd, pwd, etc. There are tons of these aliases to the tune of roughly 160 aliases shipped OTB with PowerShell for Windows. If you would like to find a list of these aliases, open PowerShell and run the following command:

```PowerShell
$ Get-Alias
CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Alias           ? -> Where-Object
Alias           % -> ForEach-Object
...
```

Most of the common commands that you would execute if you where using Bash are present in these aliases. If you read through the list you will see what these aliases map to in PowerShell. An interesting note is that PowerShell for Linux ships with only 109 aliases OTB. The reason for this difference is because aliases aren't needed for common Linux tools so they are disabled.

If you stick to just using these aliases in your Makefile or scripts that you create, then you should be able to interchangeably run these commands on Windows and Linux.

Other operators that write stdin and stdout work as expected with PowerShell and Bash.

```Bash
$ *command* > output.txt
```

```PowerShell
$ *command* > output.txt
```

## Adding PowerShell Aliases

If you don't see a commonly used alias you can add it by doing the following:

```PowerShell
$ New-Alias -Name "MyAlias" -Value "echo"
$ MyAlias "Hi there!
Hi there!
```

That's all there is to it. You can also add custom functions to add functionality that cannot be aliased. Here is how to create a function to implement the *touch* command.

```PowerShell
function touch {
    param(
        [Parameter(Mandatory=$true, Position=1)]
        [string]$file
    )

    if(Test-Path $file){
        (Get-ChildItem $file).LastWriteTime = Get-Date
    }
    else{
        Write-Output $null > $file
    }
}
```

## Conclusion

This was just a high-level walk through of all that is possible with making PowerShell and Bash compatible for those that work in mixed environments. In the end, I would suggest just moving all scripts to PowerShell since it is cross-platform and provides, in my opinion, a more robust programming model with the power to drop into .NET if needed to accomplish a task.

Thanks for reading, Jamie.