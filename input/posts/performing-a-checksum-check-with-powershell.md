---
Title: "Performing a Checksum check with PowerShell"
Published: 08/14/2019 20:44:36
Tags: 
- Open Source
- PowerShell
- Microsoft And Linux
- Bash 
---
# Performing a Checksum check with PowerShell

I am a Linux distro hopper. I like to try out new Linux distros and see how well using PowerShell and .NET development work. However, there is a task that I always struggled to do on a Windows box, that task is to perform a checksum check any ISOs I download. On Linux it is pretty simple, you do the following:

```Bash
$ sha256sum pop-os_19.04_amd64_intel_10.iso
7e228c2928a046b86b5da07f3aa628052dfe9b12fcbde24a3c50f84f06b84cec pop-os_19.04_amd64_intel_10.iso.iso
```

So you compare that hash to the one on the website. You can even read from a file that is often available. However, I have never found an easy way to do this in Windows. It seems most people point you to a utility to download. I recently was searching the web and stumbled across the **Get-FileHash** command in PowerShell. Guess what, that command does exactly what I want. Here is how I use it:

```PowerShell
$ (Get-FileHash .\pop-os_19.04_amd64_intel_10.iso -Algorithm SHA256).Hash.ToUpper() -eq "7e228c2928a046b86b5da07f3aa628052dfe9b12fcbde24a3c50f84f06b84cec".ToUpper()
True
```

So I have created myself a little helper function and put that in my PowerShell profile, so I make this even more accessible.

```PowerShell
function Check-SHA265 {
 param(
 [Parameter(Position=0)]
 [string] $iso,
 [Parameter(Position=1)]
 [string] $hash
 )

 (Get-FileHash $iso -Algorithm SHA256).Hash.ToUpper() -eq $hash.ToUpper()
}
```

Then I can just do this:

```PowerShell
$ Check-SHA265 .\pop-os_19.04_amd64_intel_10.iso 7e228c2928a046b86b5da07f3aa628052dfe9b12fcbde24a3c50f84f06b84cec
True
```

I hope you find this useful as I do.

Thanks for reading,

Jamie
