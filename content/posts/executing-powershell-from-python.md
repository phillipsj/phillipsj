---
title: "Executing PowerShell from Python"
date: 2020-10-25T19:51:56-04:00
tags:
- Open Source
- Python
- PowerShell
---

I have an experiment that I am working on and thought that leveraging Python would be fun. As part of that experiment, I would need to execute PowerShell from Python since only PowerShell cmdlets are available to do what I need. After a little research a week of letting it simmer, I was able to sit down the last night and work it out. Part of it is my unfamiliarity with Python for what I am doing, and the other part is just me not thinking about the problem holistically.

## What you need

You will need PowerShell installed on your system and Python 3.6+. This would work cross-platform. I did my testing on Kubuntu 20.10 running PowerShell as a snap package. You will not need any external libraries since we use one of the many great libraries that ship out of the box with Python.

## The code

All we need is to create a file call *ps.py*, and then we can import the [subprocess](https://docs.python.org/3.8/library/subprocess.html) module.

```Python
import subprocess
```

Now we can make our *run* method that we will use to execute our PowerShell command.

```Python
def run(self, cmd):
    completed = subprocess.run(["powershell", "-Command", cmd], capture_output=True)
    return completed
```

Let's make our Python file executable and then create the commands we want to execute. One command has the correct syntax, and one command has bad syntax. This will demonstrate how to use the return of the *subprocess.run* method.

```Python
if __name__ == '__main__':
    hello_command = "Write-Host 'Hello Wolrd!'"
    hello_info = run(hello_command)
    if hello_info.returncode != 0:
        print("An error occured: %s", hello_info.stderr)
    else:
        print("Hello command executed successfully!")
    
    print("-------------------------")
    
    bad_syntax_command = "Write-Hst 'Incorrect syntax command!'"
    bad_syntax_info = run(bad_syntax_command)
    if bad_syntax_info.returncode != 0:
        print("An error occured: %s", bad_syntax_info.stderr)
    else:
        print("Bad syntax command executed successfully!")
```

Here is the complete file.

```Python
import subprocess


def run(self, cmd):
    completed = subprocess.run(["powershell", "-Command", cmd], capture_output=True)
    return completed


if __name__ == '__main__':
    hello_command = "Write-Host 'Hello Wolrd!'"
    hello_info = run(hello_command)
    if hello_info.returncode != 0:
        print("An error occured: %s", hello_info.stderr)
    else:
        print("Hello command executed successfully!")
    
    print("-------------------------")
    
    bad_syntax_command = "Write-Hst 'Incorrect syntax command!'"
    bad_syntax_info = run(bad_syntax_command)
    if bad_syntax_info.returncode != 0:
        print("An error occured: %s", bad_syntax_info.stderr)
    else:
        print("Bad syntax command executed successfully!")
```

Execute *ps.py*, and we can see the output. The first command didn't fail and returned an exit code of zero, and we print that it ran successfully. The second command has a typo, and we get an exit code of one that we then print the error that came from standard error.

```Bash
$ python ps.py
Hello command executed successfully!
-------------------------
An error occurred: %s b"\x1b[91mWrite-Hst: \x1b[91mThe term 'Write-Hst' is not recognized as the name of a cmdlet, function, script file, or operable program.\nCheck the spelling of the name, or if a path was included, verify that the path is correct and try again.\x1b[0m\n"
```

## Conclusion

That's it, now you can feel free to build up any kind of command that you want to be executed, even multiline commands, and it should work.

Thanks for reading,

Jamie
