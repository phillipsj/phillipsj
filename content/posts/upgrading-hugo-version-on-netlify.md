---
title: "Upgrading Hugo Version on Netlify"
date: 2021-01-12T19:26:54-05:00
tags:
- Open Source
- Netlify
- Hugo
---

I haven't upgraded the version of Hugo that I am using to build my site on Netlify for a few versions. I decided today that I would perform some of this maintenance and bring you all along for the ride. 

In the repository for this blog, there is a *netlify.toml* file used to define the configuration for Netlify. You can read more about this file [here](https://docs.netlify.com/configure-builds/file-based-configuration/). Here is mine.

```TOML
[build]
  publish = "public"
  command = "hugo --gc --minify"

[context.production.environment]
  HUGO_VERSION = "0.75.1"
  HUGO_ENV = "production"
  HUGO_ENABLEGITINFO = "true"

[context.deploy-preview.environment]
  HUGO_VERSION = "0.75.1"

[[headers]]
  for = "rss.*"
  [headers.values]
    Content-Type = "application/rss+xml; charset=UTF-8"
[[headers]]
  for = "*.rss"
  [headers.values]
    Content-Type = "application/rss+xml; charset=UTF-8"

[[redirects]]
  from = "/feed.rss"
  to = "/posts/index.xml"
  status = 200

[[redirects]]
  from = "/atom.rss"
  to = "/posts/index.xml"
  status = 200
```

I don't have much in this file. You can see on lines 6 and 11 that I define the version of Hugo to use for building both the production and preview environments. Hugo 0.75.1 is about three months old and is even behind what I use locally to test the site. Let's check my local Hugo version.

```Bash
$ hugo version
Hugo Static Site Generator v0.79.0 linux/amd64 BuildDate: unknown
```

You will see that I am running 0.79.0 locally. Let's upgrade our *netlify.toml* to the newer version.

```TOML
[build]
  publish = "public"
  command = "hugo --gc --minify"

[context.production.environment]
  HUGO_VERSION = "0.79.0"
  HUGO_ENV = "production"
  HUGO_ENABLEGITINFO = "true"

[context.deploy-preview.environment]
  HUGO_VERSION = "0.79.0"

[[headers]]
  for = "rss.*"
  [headers.values]
    Content-Type = "application/rss+xml; charset=UTF-8"
[[headers]]
  for = "*.rss"
  [headers.values]
    Content-Type = "application/rss+xml; charset=UTF-8"

[[redirects]]
  from = "/feed.rss"
  to = "/posts/index.xml"
  status = 200

[[redirects]]
  from = "/atom.rss"
  to = "/posts/index.xml"
  status = 200
```

Awesome, now that the upgrade is complete, we can commit and push to our repository. Netlify will detect the version to use and start building our site with the newer version. Now you may be asking why I am setting my version instead of just letting it roll. I like to pin versions that I am using because that then makes it a known variable. If I ever run into issues with my theme or a feature, I know exactly which version is being used on Netlify to build it vs. what I am using locally.

Thanks for reading,

Jamie
