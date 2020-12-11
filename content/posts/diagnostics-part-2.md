---
title: "Diagnostics Part 2"
date: 2020-12-10T21:51:34-05:00
tags:
- DevOps
- Opinion
- SRE
- Diagnostics
---

In [part 1](https://www.phillipsj.net/posts/diagnostics-part-1/), I discussed two YouTube channels that I watched in which both creators had a routine for diagnosing problems. They both stick to the same basic formula regardless of the situation because when they didn't, they spent time chasing a false lead to only find out it was something simple. As I said in the last post, this has me asking myself what my routine is. 

After doing this for 13+ years, I don't think that I have a go-to routine to diagnose tech-related issues. I eventually check connectivity, permissions, configuration, etc. I just don't review these in any particular order, and I usually dive into what my past experiences have told me is the issue. I think I am doing myself a disservice by not taking the time to determine what routine I want and codifying that. If I make myself a playbook with a checklist and run through a set of items consistently each time there is an issue, I would think the time to resolution will be much quicker. Even if it isn't always faster, it will help get into a better mindset and build confidence. Let's explore what this may look like.

The first thing that should be on the list is system connectivity. Check if there is communication occurring between any servers and/or databases. That would include checking ports that you know are being used. Next would be memory, CPU, and disk metrics to determine if the system in question has limited resources. Then check permissions for accounts that are used to access the servers and/or databases. Once these things are known to be good, the next best place would be recent changes. This one can be tricky, depending on how your systems are managed. Having infrastructure as code, changelogs, and just regular communication about changes in the system and any dependent systems will go a long way in helping diagnose issues. If I make it this far in my checklist, it may be time to break out a memory profiler, CPU profiler, database tracer, or network tracer. These tools are invaluable when you need them yet are not used all that often. Practice using these types of tools to build and maintain confidence in them. Here is the final list that we have discussed:

* System Connectivity
* Metrics
* Permissions
* Recent changes
* Diagnostic Tools

At this point, you may be saying that the list is a lot to check and isn't always the easiest to do quickly. I concur, and I think this gets into your monitoring and observability practices. Most of these items can be automated in some form or fashion. Having a diagnostic/health check built into your system that tests connectivity will make a single step that can be triggered and included as part of an alert. CPU, memory, and disk checks can be monitored and recorded so you can cross-reference. Permissions could also be checked as part of the diagnostic/health check. This leaves recent system changes that can be tracked and recorded with automation leveraging your work tracking system or code repositories. The last piece is then collecting this information and building a dashboard with a tool like Grafana that can bring it all together to quickly see the system with a more complete picture of what is occurring. Over time that will get refined and improved while also codifying your years of experience. I have more thoughts on this topic, and at least one more post will be incoming.

Thanks for reading,

Jamie

