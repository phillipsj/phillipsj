---
title: "My Thoughts on Static Typing"
date: 2020-10-24T21:10:44-04:00
tags:
- Functional
- Languages
- Open Source
- Rust
- .NET
- Static Typing
- Dynamic Typing
- Python
- PowerShell
---

I haven't done a post that doesn't involve a lot of code in some time. I have had this idea in my head for a few months, and I have finally decided to write about it. I will focus on the areas that I know, yet this can be extrapolated across most languages and runtimes. There is this big debate about static typing vs. dynamic typing that keeps happening. Plenty of businesses have been successful in building their software with both styles of languages. Different languages optimize for different scenarios, and there are trade-offs for those optimizations. Ultimately, the language didn't really matter. There has been research around typing and testing. It seems that most conclude there is possibly a small difference. Now I believe in testing, and I don't have an issue with static typing. There are some cool things that you can do with a sound type system and compiler. The alternative is the cool stuff you can do with languages that are dynamically typed. You can really push Python, Ruby, or JavaScript to do some cool things, those things might not always be wise, yet the ability to be creative is there. So now I am at the crux of my argument, and here it is:

>"If you really want static typing, then go all the way and adopt a language that doesn't allow nulls."


Let's break this down. What I mean is that people make the argument that "oh C# is better than Python because it has static typing and prevents a specific class of errors." While that is true, C# still allows nulls and doesn't require you to handle all cases in a switch statement. Compare that to a functional language like F# (not the purest choice), Haskel, or even a language like Rust. Those languages require you to handle all cases when pattern matching or they do not compile. You are forced to handle nulls, and if you want to do unsafe things, you have to explicitly acknowledge that is what you want to do. C# now allows you to have [non-nullable reference types](https://docs.microsoft.com/en-us/dotnet/csharp/tutorials/nullable-reference-types), which does enforce that. I haven't seen that feature widely adopted. So as I see it, many languages like C#, Java, etc. don't take the type checking and compiler to the level I feel would make it vastly superior to Python, especially if you start adding type hints to it.

 This post isn't intended to be negative. It is just a thought about the topic that I keep thinking about.

Thanks for reading,

Jamie
