#! /usr/bin/pwsh

param(
    [string]
    $Title,
    [string[]]
    $Tags
)
$name = $Title -replace "\s+","-"
$name = $name -replace "\.+","dot"
$name = $name -replace "\'+", ""
$name = $name -replace "\,", ""
$name = $name.ToLower()
$invalid = [System.IO.Path]::GetInvalidFileNameChars()
$regex = "[$([Regex]::Escape($invalid))]"
$name = $name -replace $regex,""
$name = Join-Path $PSScriptRoot "drafts/${name}.md"
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

Thanks for reading,

Jamie

**If you enjoy the content then consider [buying me a coffee](https://www.buymeacoffee.com/aQPnJ73O8).**
"@
Set-Content -Path $name -Value $content