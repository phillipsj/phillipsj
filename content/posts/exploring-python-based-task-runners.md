---
title: "Exploring Python-Based Task Runners"
date: 2024-09-13T07:53:34-04:00
draft: true
tags:
- Open Source
- Python
- Tools
- DevOps
- Make
---

I was looking at task runners that are Python-based, and I discovered a lot more of these than I was expecting. I decided I would write a post about all the ones that I found. There are two honorable mentions because they’re cross-platform and one of those is written in Rust. You may be asking yourself why not use [Make](https://www.gnu.org/software/make/), [Bash](https://www.gnu.org/software/make/), or [PowerShell](https://github.com/PowerShell/PowerShell). Two of these aren't really cross-platform and PowerShell is a source of contention. 

[Node](https://nodejs.org/) has an interesting thing with [npm](https://www.npmjs.com/) in `scripts`. This is first-class support for addressing running tasks in a standardized way in a Node project. This solves so many problems, however, many languages don't have that kind of functionality out of the box. 

## DoIt

https://github.com/pydoit/doit

## Taskipy

https://github.com/taskipy/taskipy

## Poe The Poet

https://poethepoet.natn.io/

## PyInvoke

https://github.com/pyinvoke/invoke

## PDM

https://github.com/pdm-project/pdm

## Honorable Mentions

### Just

https://github.com/casey/just

### Task

https://taskfile.dev/
