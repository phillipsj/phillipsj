# Borrowed From https://github.com/wekempf/wekempf.github.io/blob/develop/New-Post.ps1
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
$name = Join-Path $PSScriptRoot "input/posts/${name}.md"
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