---
title: "Why I created my own Terraform extension"
date: 2019-12-11T22:08:10-05:00
tags:
- Open Source
- PowerShell
- Microsoft And Linux
- Bash
- Azure
- Azure DevOps
- Terraform
---

It has been a little over a year ago since I released an Azure DevOps [extension](https://marketplace.visualstudio.com/items?itemName=JamiePhillips.Terraform&ssr=false#overview) for Terraform to the Visual Studio Marketplace. Recently, someone asked why I chose to create my extension vs. using one of the existing extensions. It came down to three reasons: flexibility, control, and simplicity. Many of the other extensions work just fine, but the behavior was not what I wanted. I wanted an extension that installed Terraform and then would let me leverage the PowerShell task to perform all of my actual commands. The PowerShell task provided me the ultimate flexibility and control over how my Terraform commands were executed and allowed me to perform executions in specific folders and not all. Many of the other extensions have improved over the last year, but in general, I felt many were too UI driven and didn't leverage Terraform's ability to leverage environment variables. Some of the extensions that currently in the marketplace require installation of Terraform every single time a task executed, increasing the build times. This tells me that the extension isn't leveraging the tool cache on the first run of the task. Other tasks have odd expectations for how the commands should be structured. Given this I decided to make my own extension, in reality I could and probably should have leveraged the [Chocolatey](https://chocolatey.org/) task to install Terraform. This would be my recommendation solution to anyone that wants more control. 

Here are some code examples of how I use Terraform.

## Initializing Terraform

```PowerShell
$path = "your folder with your terraform"
if ((Test-Path $path) -and (Get-ChildItem -Recurse -Path $($path)\\**\\*.tf).Count -gt 0) { 
    $dirs = Get-ChildItem $path | ?{$_.PSIsContainer}
    $dirs | ForEach-Object {
        Set-Location $_.FullName
        terraform init --input=false
    }
}
```

## Validating as part of CI

```PowerShell
$path = "your folder with your terraform"
if ((Test-Path $path) -and (Get-ChildItem -Recurse -Path $($path)\\**\\*.tf).Count -gt 0) { 
    $dirs = Get-ChildItem $path | ?{$_.PSIsContainer}
    $dirs | ForEach-Object { terraform validate --check-variables=false $_.FullName }
}
```
 
## Conclusion

I probably could make those other extensions work as I want, but I think that makes it more complicated than it needs to be, and reading these PowerShell snippets tells the user exactly how it works.

Thanks for reading,

Jamie
