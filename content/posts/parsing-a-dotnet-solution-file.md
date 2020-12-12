---
title: "Parsing a .NET Solution File"
date: 2020-12-11T22:04:18-05:00
tags:
- .NET
- Microsoft
---

I asked on Twitter yesterday if anyone had any recommendations for parsing a .NET solution file. I got a few responses, and after a little additional research, I discovered that Microsoft ships a library that can do it. In [Microsoft.Build](https://www.nuget.org/packages/Microsoft.Build/) NuGet package is the *Microsoft.Build.Construct* namespace that has the *SolutionFile.Parse(string)* method, which does precisely that. It is reasonably simple to use, and I have included a basic example.

```C#
using System;
using Microsoft.Build.Construct;

namespace HelloWorld {
    class Program {
        static void Main(string[] args) {
            var solution = SolutionFile.Parse("path to solution file");
            foreach(var project in solution.ProjectsInOrder) {
                Console.WriteLine($"{project.ProjectName} is of type: {project.ProjectType}");
            }
        }
    }
}
```

I learned something new to just solve a problem that I will post about soon.

Thanks for reading,

Jamies
