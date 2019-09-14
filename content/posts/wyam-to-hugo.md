---
title: "Wyam to Hugo"
date: 2019-09-14T13:52:17-04:00
tags:
- Open Source
- Wyam
- PowerShell
- Hugo
---

I have been using Wyam as my static site generator for a little over two years. Recently, Wyam is morphing into a new software called [Statiq](https://github.com/statiqdev/Framework) and with that change comes a change in the license. This license change prompted me to speed up the timing of the migration that I wanted to do to Hugo. With this migration, this removes the last thing that I use .NET for outside of my employment. This migration marks a significant milestone that I have wanted for some time. Let's get into how to perform the migration.

The migration was surprisingly easier than expected. I was using stock Wyam without a lot of customizations, so your results may vary if you traveled further from stock. The front matter that Wyam uses only differs from the front matter of Hugo when it comes to dates. Wyam wants the front matter to contain the following:

```md
Published: 08/27/2019 20:29:57
```

That differs from what Hugo expects. Hugo expects that the date is formatted using [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) and to use a different key. Below is how the date needs formatted.

```md
date: 2019-08-27T20:29:57
```

Since this was the only piece of front matter that I had to change, I created a quick PowerShell script to do it.  Execute this script inside of your posts folder. It finds all your markdown files, parses out the front matter, converts the date, then replaces the old key and value with the new ones.

```PowerShell
#! /usr/bin/env pwsh

Get-ChildItem -Path .\ -Filter *.md -File -Name | ForEach-Object {
    $content = Get-Content -Path $_
    $junk, $parsedDate = $content[2] -Split ":", 2    
    $fmtDate = Get-Date $parsedDate.Trim() -format s
    $content[2]= $content[2] -replace "(Published:).*", "date: $($fmtDate)"
    $content | Set-Content $_
}
```

After I ran this script, I tested that all my posts were being built and displayed correctly. Fortunately, that was all that was needed. The last part of the migration were some of my additional pages. The markdown ones were just copied and paste, and I did have a few based on Razor. However, I wasn't really using any Razor syntax, so I cheated and just copied and pasted the HTML into the markdown version in Hugo. Another quick check that everything looked 90% correct, I wired it all up in Netlify to deploy on pushing to master.

The final step was to find a theme that I liked, and I landed on [minimo](https://github.com/MunifTanjim/minimo) thanks to [Todd Ginsberg](https://todd.ginsberg.com/) and his excellent looking site. An interesting side effect has been a 100 on my Google Page Speed test and a 90 in an online accessibility test.

Future improvements will be increasing my accessibility score and possible switching to [Font Awesome](https://fontawesome.com/) for the icons.

Thanks for reading, 

Jamie
