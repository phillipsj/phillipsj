---
title: "Pode a Powershell Web Framework"
date: 2020-11-03T22:52:04-05:00
draft: true
tags:
- Open Source
- PowerShell
- Polaris
- REST API
---

[Pode](https://badgerati.github.io/Pode/) is a PowerShell based web framework that I learned about recently. After a little investigation, it really seems to be a more tradtional style web framework that is conventiently written in PowerShell. There is a view engine for rendering HTML templates, it can serve up assets like CSS and JavaScript, and the application structure is familiar. Before I start walking through creating an application, my initial thoughts are that this is more geared toward those familiar with existing web development frameworks. This means there is a little more that might be needed to learn and that there is more resources to learn it.

## Why PowerShell frameworks

This is also the time to clarify why I keep exploring these frameworks. My background is as a developer that has migrated into DevOps, Cloud Engineering, and Site Reliabitliy Engineer. I am very comfortable with any programming langauge and can use most to build an API or website. The one thing that I have learned is that isn't true for a lot of people that are comming into these areas from a non-developer background. Tools like Bash, PowerShell, and Python are heavily used within these fields due to the nature of the work that relies on PowerShell modules, shell scripting, and automation libraries produced by vendors in Python. These are all approachable langauges for most that work in tech and frameworks like Pode, Polaris, UniversalDashboard, etc. allow people who have built skills in these languages to build small web APIs and websites to solve very specific problems. I don't feel these are intended to really compete with the typical list of web frameworks that are often used and not really aimed at the developer market.

I wrote the paragarph above yesterday when I started this post. Today, I saw an article on [ZDNet](https://www.zdnet.com/article/programming-language-pythons-popularity-ahead-of-java-for-first-time-but-still-trailing-c/) that was discussing how Python has passed Java in the [TIOBE Index](https://www.tiobe.com/tiobe-index/) and is now #2 behind C. That is a big testament to the appeal of Python. An interesting part of the article, I have pulled out here.


> "I believe that Python's popularity has to do with general demand," writes Jansen. "In the past, most programming activities were performed by software engineers. But programming skills are needed everywhere nowadays and there is a lack of good software developers. 

The qoute highlights that programming isn't something just for developers anymore and that is how I feel about a lot of these tools that are poppping up. These tools allow others to get tasks completed and deliver value.

## Building a web app to create a virtual machine

Once upon a time, when I was getting interested in this new thing called DevOps, I worked on a protoype of a web app that would allow users to request virtual machines to be allocated by the operations team. It was a cool concept and that was around 2011. I am going to take this idea and build a web app that has a form that will you can use to have a virtual machine created. This is a funny concept when we start thinking about modern cloud environments, it's still a fun thing to work through and it's real life.

### Installing Pode and project setup

Let's start by installing Pode.

```Bash
$ Install-Module -Name Pode
```

