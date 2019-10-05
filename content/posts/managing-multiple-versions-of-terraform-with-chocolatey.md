---
Title: "Managing multiple versions of Terraform with Chocolatey"
date: 2019-08-01T21:39:45
Tags: 
- Open Source
- Microsoft And Linux
- Tools
- PowerShell
- Terraform
- Chocolatey
---
# Managing multiple versions of Terraform with Chocolatey

Let's install multiple versions of Terraform using the [Side by Side](https://chocolatey.org/docs/commandsinstall#examples) installation feature of Chocolatey.

```PowerShell
$ choco install terraform --version 0.12.5 -my
$ choco install terraform --version 0.11.14 -my
$ choco install terraform --version 0.11.9 -my
```

If you look in the following directory, **C:\ProgramData\chocolatey\lib**, you will see a folder for each version of Terraform installed. However, when you run the following command.

```PowerShell
$ terraform --version
Terraform v0.11.9
```

That should reflect the last version that we installed. Chocolatey uses this tool called [ShimGen](https://github.com/chocolatey/shimgen) to generate a "symlink" to the version installed. We could leverage that tool to allow switching between multiple versions. However, it requires Administrator privileges to work. We are going to use a PowerShell alias for Terraform so when we enter a directory with a **.terraform-version** file, and we will read the version number in that file an set the alias to that location. That filename follows the convention of the [tfenv](https://github.com/tfutils/tfenv#terraform-version) project so you can be cross-platform with this workflow.

Let's create a directory to host our **.terraform-version** file.

```PowerShell
$ mkdir tftesting
$ cd .\tftesting\
$ New-Item -Name .terraform-version -ItemType file
```

Now we can open it and add the following.

```
0.11.14
```

Great, we have the version we want to use defined. Now we need to open our PowerShell profile since that is what I am using. We are going to add a function that checks for the **.terraform-version** file, if it exists, it will set an alias called **tf** to point to the correct version.

To find your PowerShell profile, you can use the *$PROFILE* variable.

```PowerShell
$ $PROFILE
C:\Users\<username>\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
```

Open that file, if it doesn't exist, then create it with the following command.

```PowerShell
if (!(Test-Path -Path $PROFILE)) {
  New-Item -ItemType File -Path $PROFILE -Force
}
```

With your profile now opened, let's create our function.

```PowerShell
# This is inspired heavily by Set-PsEnv: https://github.com/rajivharris/Set-PsEnv

$tfenvfile = ".terraform-version"

function Set-TfEnv {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    param()

    #return if no env file
    if (!( Test-Path $tfenvfile)) {
        Write-Verbose "No .terraform-version file"
        Remove-Alias -Name tf
        return
    }

    $terraformVersion = @(Select-String .\.terraform-version -Pattern '([0-9]).([0-9])([0-9]).([0-9])([0-9])').Matches[0].Value
    Write-Verbose "Parsed .terraform-version file"
    Set-Alias -Name tf -Value "C:\ProgramData\chocolatey\lib\terraform.$($terraformVersion)\tools\terraform.exe" -Scope Global
}
```

We now have our function defined, that looks for that file; if it exists, it creates an alias to the specified version. Now let's wire this up to execute when we change into a directory.

In our profile, add the following right after our new function.

```PowerShell
function prompt {
    Set-TfEnv
}
```

Now open a new PowerShell window, navigate to our directory and when we type the **tf --version** command we should see the output of the version as defined in *.terraform-version*.

```PowerShell
$ cd ./tftesting
$ tf --version
Terraform v0.11.14

Your version of Terraform is out of date! The latest version
is 0.12.6. You can update by downloading from www.terraform.io/downloads.html
```

I am going to work on making this a proper PowerShell module and put it in the PowerShell gallery.  I hope you find this helpful and I will post when I get it published.

Thanks for reading,

Jamie
