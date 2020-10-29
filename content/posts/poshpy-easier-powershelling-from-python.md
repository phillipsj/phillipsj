---
title: "Poshpy: Easier PowerShelling from Python"
date: 2020-10-28T14:21:30-04:00
Tags: 
- Open Source
- Python
- poshpy
- PowerShell
- Microsoft And Linux
---

My recent post on [executing PowerShell from Python](https://www.phillipsj.net/posts/executing-powershell-from-python/) has led me to create a Python package for making it even easier to execute PowerShell from Python. My package is called [poshpy](https://pypi.org/project/poshpy/) and the source code is up on [GitHub](https://github.com/blueghostlabs/poshpy). I have started thinking about a roadmap of features that could be useful. One item that will be a focus was suggested on Reddit, which adds the ability to handle returned objects. I have a rough idea of that one that I hope to have it implemented shortly. If there is anything you would like to see, please open an issue on GitHub first before doing any work to discuss. Here is a short example of the current API, which may change or evolve over time.

```Python
import poshpy

completed_cmd = poshpy.execute_command("Write-Host 'Hello Wolrd!'")
if completed_cmd.return_code == 0:
    print(completed_cmd.standard_out)
else:
    print(completed_cmd.standard_error)
```

Now you can build up a multiline command like so:

```Python
import poshpy

my_command = '''\
$ErrorActionPreference="Stop"
Write-Host "Hello %s"
''' % "world"

completed_cmd = poshpy.execute_command(my_command)
if completed_cmd.return_code == 0:
    print(completed_cmd.standard_out)
else:
    print(completed_cmd.standard_error)
```

I hope that you will find this as useful as I feel that it is. I already have some use cases for it, so keep an eye for a few tweets from me.

Thanks for reading,

Jamie
