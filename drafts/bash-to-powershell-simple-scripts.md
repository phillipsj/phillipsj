---
Title: "Bash to PowerShell: Simple Scripts"
Published: 10/20/2018 10:25:21
- Open Source
- PowerShell
- Microsoft And Linux
- Bash 
---
# Bash to PowerShell: Simple Scripts


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

Great, let's see how that works be executing it.

```
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

if($file && Test-Path $file){
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

if($file && Test-Path $file){
    if(Test-Path $_ -pathType leaf){
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

if($file && Test-Path $file){
    if(Test-Path $_ -pathType leaf){
        Write-Host "$FILE is a regular file."
    }
    if(Test-Path $_ -pathType container){
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

if($file && Test-Path $file){
    $item = Get-Item $file
    if(!$item.PSisContainer){
        Write-Host "$FILE is a regular file."
    }
    if(!$item.PSisContainer){
        Write-Host "$FILE is a directory."
    }  

    if($item.IsReadOnly) {
        Write-Host "$FILE is readable."
    }

    if(!$item.IsReadOnly) {
        Write-Host "$FILE is writable."
    }
    
    if [ -x "$FILE" ]; then
        echo "$FILE is executable/searchable."
fi 
}
else {
    Write-Host "$FILE does not exist."
    Exit 1
}
```