param(
    [string]
    $Title
)

# Get the draft by title.
$name = $Title -replace "\s+","-"
$name = $name.ToLower()
$invalid = [System.IO.Path]::GetInvalidFileNameChars()
$regex = "[$([Regex]::Escape($invalid))]"
$name = $name -replace $regex,""
$fullPath = Join-Path $PSScriptRoot "drafts/${name}.md"
$publishedPath = Join-Path $PSScriptRoot "input/posts/${name}.md"

$content = Get-Content -Path $fullPath

$content[2]= $content[2] -replace "(Published:).*", "Published: $(Get-Date)"

$content | Set-Content $publishedPath