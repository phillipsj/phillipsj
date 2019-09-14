---
Title: "Bash to PowerShell: Simple Scripts"
date: 2018-10-21T21:50:21
Tags: 
- Open Source
- PowerShell
- Microsoft And Linux
- Bash 
---
# Bash to PowerShell: Simple Scripts

I said in a previous post that I was going to cover how to convert Bash scripts to PowerShell. I am going to start with a few simple scripts and I will do another post with converting a more complex script.  There is a GitHub repo called [Simple Bash Scripts](https://github.com/ruanyf/simple-bash-scripts) and I will use some of these scripts as the example as most of these are pretty simple.

## Interactive Script

There is a script in the above repo called [Interactive.sh](https://github.com/ruanyf/simple-bash-scripts/blob/master/scripts/Interactive.sh). This script basically just asks a few questions and writes the answers to the shell.

Here is the example in Bash:

```Bash
#! /bin/bash
echo "Hey what's Your First Name?";
read a;
echo "welcome Mr./Mrs. $a, would you like to tell us, Your Last Name";
read b;
echo "Thanks Mr./Mrs. $a $b for telling us your name";
echo "*******************"
echo "Mr./Mrs. $b, it's time to say you good bye"
```

Now let's see what this will look like in PowerShell. First create a file called *Interactive.ps1" and open it in your favorite editor. The first step we are going to take is to add the info that points to what shell needs to execute this file in case you intend to execute this script on Linux too.

```PowerShell
#! /usr/bin/pwsh
```

Now that we have that information, the next thing we need to handle is the prompt for the file that is of interest. We can do this with the *Read-Host* function in PowerShell.

```PowerShell
#! /usr/bin/pwsh

$a = Read-Host -Prompt "Hey what's Your First Name?"
```

Great, let's see how that works by executing it.

```
$ ./Interactive.ps1
Hey what's Your First Name?: 
```

That is working as expected, let's add the next prompt.

```PowerShell
#! /usr/bin/pwsh

$a = Read-Host -Prompt "Hey what's Your First Name?"
$b = Read-Host -Prompt "Welcome Mr./Mrs. $a, would you like to tell us, Your Last Name?"
```

That doesn't look much different that before. Now we can finish it out by adding the last three statements that call the *echo* Bash command. We will use the *Write-Host* command which happens to be the command that *echo* would call if we used the alias.

```PowerShell
#! /usr/bin/pwsh

$a = Read-Host -Prompt "Hey what's Your First Name?"
$b = Read-Host -Prompt "Welcome Mr./Mrs. $a, would you like to tell us, Your Last Name?"
Write-Host "Thanks Mr./Mrs. $a $b for telling us your name";
Write-Host "*******************"
Write-Host "Mr./Mrs. $b, it's time to say you good bye"
```

That was a pretty easy migration. If we didn't change from using the *echo* alias it would look even more like the Bash script. What I like most is that the *Read-Host* command handles reading the console when you use the *Prompt* option.

## Directory Size

There is a script in the above repo called [directorySize.sh](https://github.com/ruanyf/simple-bash-scripts/blob/master/scripts/directorySize.sh). This script basically just asks for a directory and returns the size.

Here is the example in Bash:

```Bash
#!/bin/bash

echo " Enter your directory: "
read x
du -sh "$x"
```

Let's see what this will look like while introducing a few new concepts.

```PowerShell
#! /usr/bin/pwsh

$pth = Read-Host -Prompt "Enter your directory:"
$size = Get-ChildItem -Path $pth -Recurse | Measure-Object -Property Length -Sum
Write-Host ($size.Sum/1mb)
```

In the example above we show the use of the pipe operator, *Get-ChildItem*, and *Measure-Object*. *Get-ChildItem* will get all items from the specificed location and *Measure-Object* calculates numeric properties of objects, which in PowerShell is everything.

## Testing a File

There is a script in the above repo called [test-file.sh](https://github.com/ruanyf/simple-bash-scripts/blob/master/scripts/test-file.sh). This script basically just ask for a file name. Once a file name is provided it tests to properties of that file.

Here is the example in Bash:

```Bash
#!/bin/bash
# test-file: Evaluate the status of a file
echo "Hey what's the File/Directory name (using the absolute path)?";
read FILE;

if [ -e "$FILE" ]; then
    if [ -f "$FILE" ]; then
        echo "$FILE is a regular file."
    fi
    if [ -d "$FILE" ]; then
        echo "$FILE is a directory."
    fi
    if [ -r "$FILE" ]; then
        echo "$FILE is readable."
    fi
    if [ -w "$FILE" ]; then
        echo "$FILE is writable."
    fi
    if [ -x "$FILE" ]; then
        echo "$FILE is executable/searchable."
    fi
else
    echo "$FILE does not exist"
    exit 1
fi
exit
```

Now let's see what this will look like in PowerShell. First create a file called *Test-File.ps1" and open it in your favorite editor. The first step we are going to take is to add the info that points to what shell needs to execute this file in case you intend to execute this script on Linux too.

```PowerShell
#! /usr/bin/pwsh
```

Now that we have that information, the next thing we need to handle is the prompt for the file that is of interest. We can do this with the *Read-Host* function in PowerShell.

```PowerShell
#! /usr/bin/pwsh

$file = Read-Host -Prompt "Hey what's the File/Directory name (using the absolute path)?"
```

Great, let's see how that works by executing it.

```Bash
$ ./Test-File.ps1
Hey what's the File/Directory name (using the absolute path)?:
```

Okay that is a good start, let's handle the first case of making sure that the file exists. PowerShell provides the *Test-Path* function that will test if a file exists..

```PowerShell
#! /usr/bin/pwsh

$file = Read-Host -Prompt "Hey what's the File/Directory name (using the absolute path)?"

if(Test-Path $file){
    # Hanlde all the cases.
}
else {
    # Print that the file is null or empty.
}
```

This is nice and easy, not much here as PowerShell makes checking if the file exists is built in. With the first if statement handled, we should just go ahead and write the message that the input provided wasn't valid. We will handle that with the *Write-Host* command. We could also use *echo* which is an alias for *Write-Host*, but we want to be a little more explicit.

```PowerShell
#! /usr/bin/pwsh

$file = Read-Host -Prompt "Hey what's the File/Directory name (using the absolute path)?"

if($file -and (Test-Path $file){
    # Hanlde all the cases.
}
else {
    Write-Host "$FILE does not exist."
    Exit 1
}
```
 
A quick test shows that it is behaving as desired.

```
$ ./Test-File.ps1
Hey what's the File/Directory name (using the absolute path)?: text.txt
text.txt does not exist.

$ ./Test-File.ps1
Hey what's the File/Directory name (using the absolute path)?: test.txt
```

Now we can get to the main part of the application. PowerShell has a robust Object model that comes with a lot of power. We are going to handle each case one at a time. The first check is to see if the file you provided is actually a file.

```PowerShell
#! /usr/bin/pwsh

$file = Read-Host -Prompt "Hey what's the File/Directory name (using the absolute path)?"

if($file -and (Test-Path $file){
    if(!$item.PSisContainer){
        Write-Host "$FILE is a regular file."
    }
}
else {
    Write-Host "$FILE does not exist."
    Exit 1
}
```

Now run the command and pass a file name, you should see that it is a regular file written to your console. Let's add the directory check.

```PowerShell
#! /usr/bin/pwsh

$file = Read-Host -Prompt "Hey what's the File/Directory name (using the absolute path)?"

if($file -and (Test-Path $file){
    if(!$item.PSisContainer){
        Write-Host "$FILE is a regular file."
    }
    if($item.PSisContainer){
        Write-Host "$FILE is a directory."
    }  
}
else {
    Write-Host "$FILE does not exist."
    Exit 1
}
```

Feel free to test it out. Now we want to check various properties if it is a file.

```PowerShell
#! /usr/bin/pwsh

$file = Read-Host -Prompt "Hey what's the File/Directory name (using the absolute path)?"

if($file -and (Test-Path $file){
    $item = Get-Item $file

    if(!$item.PSisContainer){
        Write-Host "$FILE is a regular file."
    }
    if($item.PSisContainer){
        Write-Host "$FILE is a directory."
    }  

    if($item.IsReadOnly) {
        Write-Host "$FILE is readable."
    }

    if(!$item.IsReadOnly) {
        Write-Host "$FILE is writable."
    }

    if(-not ($item.Attributes | Where-Object { $_ -ne "Hidden"})){
        Write-Host "$File is searchable."
    }
}
else {
    Write-Host "$FILE does not exist."
    Exit 1
}
```

Now if you run the script above it will operate just like how the Bash version works. The biggest concept in this example, in my opinion, is the introduction of the *Where-Object* commandlet. This allows you to use a SQL like query syntax to search inside lists for values and use a comparison object to test for the desired value.

## Conclusion

Hope you found this helpful and if there is anything specific you would like to see please let me know. I have it planned to convert one a more complicated Bash script to PowerShell in the near future.

Thanks for reading,

Jamie
