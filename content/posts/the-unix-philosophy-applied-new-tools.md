---
title: "The Unix Philosophy Applied: New Tools"
date: 2020-12-12T22:37:48-05:00
tags:
- Linux
- OSS
- Open Source
- Unix
- The Unix Philosophy
---

I have been thinking about creating a new tool to solve a problem. I like to just let these ideas and the design just simmer while working through quick examples of solving specific problems. A new idea brings loads of excitement that sometimes carries you forward with the idea that may have a better alternative. 

Before I decided to start doing development, I got my copy of the book [Just for Fun](https://www.amazon.com/Just-Fun-Story-Accidental-Revolutionary/dp/0066620732). Linus starts talking about what made Unix attractive and impressive. Much of that starts resonating with me as I have been a massive fan of composability for years. Composability can help create orthogonality, which means that you can change one part without affecting other parts of your system. Since Unix tools are tools that perform a single function that can then be piped to another tool to compose a complex tool, any one of those tools can change and not impact others' functions. These concepts got me thinking about the tool that I was going to produce. I realized that I didn't need to write a tool to perform what I wanted to do. I could easily compose a tool using a combination of grep, find, and xargs to achieve the same goal. 

Once I realized that I could do it with simple yet powerful tools that already exist, I was embarrassed. It is just a mindset that I need to develop. I have started developing that intuition with PowerShell. I just need to build it for Bash and Linux tools. It will take plenty of practice to get there, I am determined. As a developer, it is hard to not reach into the programming toolbox. The funny thing is that it wasn't how I thought when I first got started. I need to explore this more and understand where that inflection point occurs between the different approaches.

Thanks for reading,

Jamie
