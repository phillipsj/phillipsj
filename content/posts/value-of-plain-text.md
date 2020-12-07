---
title: "Value of Plain Text"
date: 2020-12-06T22:16:54-05:00
tags:
- Opinion
- Text
- Plain Text
- Just Text
---

I was listening to a podcast today when one of the hosts said you could just set up your blog on Blogger. Some of the reasons were good reasons, such as not having to self-host. I immediately started wondering why a platform like Blogger or WordPress is often recommended and directly compared to self-hosting when static blog sites offer many advantages. Static sites can be hosted on many platforms like GitHub Pages, Netlify, or a cloud provider's blob storage with little to no cost. The significant advantage there is that typically your data is just stored as plain text. I then realized that I have increasingly started to use more tools that focus on plain text. You are not locked into any specific vendor, and it can easily be manipulated or modified by almost all tools. Markdown, YAML, TOML, JSON, AscIIDoc, XML, and reStructured text all come to mind as popular plain text formats. Migrating markdown from one platform to another can be done with minimal effort and doesn't require a database.

I have been using a static site generator since I originally migrated away from Blogger in 2014. I started with a project called [tinkerer](https://github.com/vladris/tinkerer) powered by Python, then [Wyam](https://github.com/Wyamio/Wyam) powered by .NET, to now running on [Hugo](https://github.com/gohugoio/hugo) powered by Go. The primary motivator was to have more control and ownership of my content. I just didn't want it locked away in a proprietary format on a platform that may not survive. I have since focused on keeping more stuff just as plain text for the same reason.

So why am I writing this post today? Well, plain text is simple and not proprietary. There is a lot of value in having your stuff stored that way, especially knowledge. I immediately thought about the [The Pragmatic Programmer](https://pragprog.com/titles/tpp20/the-pragmatic-programmer-20th-anniversary-edition/), specifically the section on **The Power of Plain Text** where they make the argument that our base material is knowledge which is essential to not store in a format that you may not be able to access in the future. Had I forgotten that tip? I don't think I have. I believe it has been driving a lot of the decisions that I have been making lately.

An additional influence on that has been my increasing use and interest in Linux. All configuration in Linux is just a text file with a particular name stored in a specific location. The more you use it, the more you are pushed into accessing those files. I find that I do a lot of editing of my *bashrc* file manipulating my path, or adding aliases. I even do this on Windows now, preferring to configure my PowerShell profile over editing my path in the Control Panel. If I need a specific environment configuration when working in PowerShell, it makes sense to keep it in plain text and specific to that environment.

One final item and this is on that is really a good tip that I picked up from the book [Land the Tech Job You Love](https://pragprog.com/titles/algh/land-the-tech-job-you-love/), which is to store your resume in a plain text format. Formatting changes and can get wonky between versions of a word processor. By storing as plain text, you can quickly transform it into what you need without fixing a lot of formatting issues. 

## Wrapping UP

What was the purpose of this post? Well, I guess it was to talk about the wisdom in having just plain text for storing knowledge. I am going to continue pursuing systems that allow me to leverage plain text. I need to find an excellent note-taking software or system that leverages plain text. It will need to be something that works well for mobile as that is when I make most of my notes. That is really the last main item that I don't already have a plain text solution for handling. 

Thanks for reading,

Jamie
