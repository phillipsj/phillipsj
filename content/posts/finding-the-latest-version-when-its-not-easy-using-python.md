---
title: "Finding the Latest Version When It's Not Easy Using Python"
date: 2024-09-15T20:50:03-04:00
tags:
- Python
- OSS
- Open Source
- DevOps
- CICD
---

Do you want to know a frustrating problem that I often face? I need to download some software as part of a pipeline that doesn't have an easy way to download the latest version. This is often a challenging endeavor as many vendors don't provide the latest tag to reference. I could probably have achieved this similarly to how it was done with this snippet of bash.

{{< gist steinwaywhw a4cd19cda655b8249d908261a62687f8 >}}

However, what is the fun in that. I had a slightly similar, but different use case, so I decided to work on doing it with Python. I didn't want to depend on anything outside the standard library. That means I will be using the built in `url`, `html`, and `re` libraries to get this done. Let me explain how I did it. 

## Solution

Python has this really cool [HTMLParser](https://docs.python.org/3/library/html.parser.html) library that can be used to parse an HTML of a web page. The software that I needed to get the latest release had an HTML page with the latest release on it, but the download URL had the version as part of it. The version is the item that I don't know. I decided to parse the HTML page looking for the anchor tag that had an HREF that matched a regex of the download URL with the version information being a wildcard.

Here is what I settled on:

```Python
from html.parser import HTMLParser
import re

class LatestVersionHTMLParser(HTMLParser):
    def __init__(self, pattern):
        super().__init__()
        self.pattern = pattern
        self.matching_tags = []

    def handle_starttag(self, tag, attrs):
        if tag == 'a':
            href = dict(attrs).get('href')
            if href and re.match(self.pattern, href):
                self.matching_tags.append(href)
```

When I initialize the class, I pass the pattern that I want to search for in the anchor tags. Then I print the only result that should be found.

```Python
from urllib.request import Request, urlopen

url = "https://mysterysoftware.com/software/"
pattern = "https:\/\/download\.mysterysoftware\.com\/.*\/Software\/ToolOne\-.*\.zip"

request = Request(url, headers={'User-Agent': 'Mozilla/5.0'})
with urlopen(request) as response:
    content = response.read().decode('utf-8')
    parser = LatestVersionHTMLParser(pattern)
    parser.feed(html_content)
    print(parser.matching_tags[0])
```

## Wrapping Up

This was a fun little item to figure out. Yes, it's a little brittle and could use some more work, but like most things, it gets the job done. I would like for more companies to publish their software to better allow programmatic consumption by publishing a way to always pull the latest version without having to know it.

Thanks for reading,

Jamie