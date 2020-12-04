---
title: "Diagnostics Part 1"
date: 2020-12-03T18:02:22-05:00
tags:
- DevOps
- Opinion
- SRE
- Diagnostics
---

I really enjoy working on mechanical things, especially things that run on gasoline. I have often felt that it was one of the reasons that I got into software development. I could tinker with things without all the grime and expense. I stepped away from doing as much of that as I have gotten older and would like to get more into it. YouTube has been great in that respect as I have found a couple of YouTube channels that I like to watch. 

The first channel focus on small engines, items like push mowers, pressure washers, generators, etc., that have been discarded. The channel creator tries to get the machines working again, and I assume that he probably does resale those, and it reduces a lot of waste. He has a very set diagnostic routine that he always follows when working on an unknown machine. He checks that the engine can rotate freely, that there is fuel, and if there is a spark that will trigger the fuel combustion. He seldomly deviates from checking those three items and will never proceed to work on other glaring issues until he knows the info related to those three items. If one of those items doesn't pass, he fixes it until all three are confirmed to be in a known good state. Only after that does he proceed to work on any other issues.

The second channel that I often watch is an automotive shop owner who records himself diagnosing and repairing vehicles that come into his shop. Interestingly, many shops send vehicles to him just to be diagnosed. He always says one thing, and that is **"Stick to your diagnostic routine"**. He mentions he didn't stick to his routine all of the time and just jumped in with an educated guess as to what the cause of the issue is. He then says that he has lost many hours chasing that educated guess to only find out that if the routine had been followed, he would have found the issue sooner. The cool thing about his channel is that he spends a lot of time leveraging diagnostic tools and wiring diagrams when diagnosing problems.

## What does this have to do with technology

At this point, if you have stayed, you may be wondering what this has to do with technology. We have a lot of issues that we have to troubleshoot or, should I say, diagnose. What is your routine? Do you stick to it? I know that I don't, and I know that many others I have worked with don't. I end up making educated guesses that sometimes take longer than if I had started with the basics. The basics for a combustion engine are fuel, air, and ignition (spark). What are those items within a given area of tech? Are there basics that can always be checked before jumping to a more complex cause? We don't typically have diagrams to work from, and it's not like all of our applications are roughly the same. Maybe our applications are more similar than we know. Perhaps focusing on diagraming out workflows would be valuable. If workflows were diagrammed, it would be easier to spot the areas that may cause an issue. 

Both channels show using various diagnostic tools to perform tests to eliminate potential issues. This is an area that I don't feel gets leveraged as often as they should in tech. Debuggers, memory profilers, CPU profilers, and network profilers are essential tools that can really help you diagnosis an issue swiftly. Yet, we don't focus on developing the skills with these tools. We learn these skills out of necessity, not out of routine. Most vehicles have a dashboard with various gauges, warning lights, etc., that provide critical information for safe operation. Those multiple indicators of the health of the vehicle were not haphazardly developed. They were planned. Those items were purposely built into the vehicle to alert the driver of an issue, then assist in narrowing down that issue. If the problem isn't as coarse as the dashboard, then the onboard computer records diagnostic codes that help narrow it down even further. Without that level of instrumentation, monitoring, and observability, it would be challenging to diagnose many issues in a modern vehicle. What would it be like to work on a system that had that level of information? A system instrumented to provide critical stats while running to let you know that there is an issue. Yes, I am being a little sarcastic, yet the automotive industry does this as standard. You wouldn't purchase a vehicle without these types of features.

## Wrapping Up

I am starting to drift a little now, so I will stop here and just let this simmer. I will be doing another post on the topic with how some of these questions can be approached.

Thanks for reading,

Jamie
