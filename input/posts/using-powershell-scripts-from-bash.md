---
Title: "Using PowerShell scripts from Bash"
Published: 09/22/2018 20:54:19
Tags:
- Open Source
- PowerShell
- Microsoft And Linux
- Bash 
---
# Using PowerShell scripts from Bash

This may seem like a funny post, but I really enjoy using PowerShell and Linux. If you are like me and like doing the same then maybe you will find this useful. I am going to show how you can make a PowerShell script executable directly from Bash.

The first step is to make sure that you install PowerShell. Instructions can be found [here](https://github.com/powershell/powershell#get-powershell).

Once you have PowerShell installed on your system, let's create a PowerShell script. This is the PowerShell script I use to create draft blog posts. Please create this script and name is *New-Draft.ps1*.

```PowerShell
param(
    [string]
    $Title,
    [string[]]
    $Tags
)
$name = $Title -replace "\s+","-"
$name = $name.ToLower()
$invalid = [System.IO.Path]::GetInvalidFileNameChars()
$regex = "[$([Regex]::Escape($invalid))]"
$name = $name -replace $regex,""
$name = Join-Path $PSScriptRoot "${name}.md"
if (Test-Path $name) {
    throw "${name} already exists"
}
$tagText = ""
if ($Tags) {
    $Tags = $Tags | % { """$_""" }
    $tagText = "[$($Tags -join ", ")]"
}
$content = @"
---
Title: "${Title}"
Published: $(Get-Date)
Tags: ${tagText}
---
# ${Title}
"@
Set-Content -Path $name -Value $content
```

To call this script you will need to do the following in PowerShell.

```
$ .\New-Draft.ps1 "My New Post"
```

This will create a markdown file in the current directory with the title passed in and the contents from the script.

Now, I get tired of typing the *pwsh* command before running my script when I am working on Linux. Luckily, on Linux if you put a [shebang](https://goo.gl/L5xL7e) at the start of the script and the path to the interpreter we want to use. Then all that is left is marking the script as executable. Once these items are in place, we can execute the PowerShell script directly from Bash.

Okay, so enough discussion. Let's get going.

Type the following command in Bash to determine the location of the PowerShell executable on your system.

```
$ which pwsh
/usr/bin/pwsh
```

Now that we know  the location, let's edit the *New-Draft.ps1* script to add our shebang.

```PowerShell
#! /usr/bin/pwsh

param(
    [string]
    $Title,
    [string[]]
    $Tags
)
$name = $Title -replace "\s+","-"
$name = $name.ToLower()
$invalid = [System.IO.Path]::GetInvalidFileNameChars()
$regex = "[$([Regex]::Escape($invalid))]"
$name = $name -replace $regex,""
$name = Join-Path $PSScriptRoot "${name}.md"
if (Test-Path $name) {
    throw "${name} already exists"
}
$tagText = ""
if ($Tags) {
    $Tags = $Tags | % { """$_""" }
    $tagText = "[$($Tags -join ", ")]"
}
$content = @"
---
Title: "${Title}"
Published: $(Get-Date)
Tags: ${tagText}
---
# ${Title}
"@
Set-Content -Path $name -Value $content
```

With that line added the final step is to make it executable.

```
$ chmod +x New-Draft.ps1
```

Now we can run our PowerShell script from Bash and the shebang will make sure the script is ran using PowerShell.

```
$ ./New-Draft.ps1 "My Next Post"
```

There you go, how to make your PowerShell scripts run directly from Bash without the need of running PowerShell first.