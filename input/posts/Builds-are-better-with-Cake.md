---
Title: Builds are better with Cake
Published: 2015-10-18 20:00:00
Tags:
- Orchard
- Open Source
- Cake
RedirectFrom: blog/html/2015/10/18/builds_are_better_with_cake
---

As most of you know, my team has been using Orchard to build our next application. While we have found the majority of what Orchard has to offer great, there has been trouble with the build for Orchard. We decided it was time to create a different way to build Orchard that was easier for junior devs to understand and easier for us to consume.

We narrowed it down to [Psake](https://github.com/psake/psake), [Fake](http://fsharp.github.io/FAKE/), or [Cake](http://cakebuild.net/), as these really don’t require anything special that isn’t already on our build servers. I have used tools like [Albacore](http://albacorebuild.net/) in the past, but the extra dependency on Ruby was the deal breaker.

I have used all of these in the past, except for Cake. It is one of the newer build systems on the scene and it just so happens to use C# for its syntax. I have been happy with all, but considering we all primarily work in C#, it just seemed like Cake would be the best fit.

After having worked with Cake for the last two weeks converting the Orchard build from MSBuild file to Cake, I can say that Cake is now easily my favorite build tool and I cannot forsee wanting to use much of anything else. The community has been great and helpful, most of the important tooling has already been created, the only thing that I have had an issue with is changing my way of thinking. The shift from MSBuild to a build tool like Cake, sometimes throws your mind for a loop.

Cake supports of using MSBuild tasks, extra file helpers, Slack integration, etc. all come in the form of an Addin.  Cake is easily extending using their Addin structure, just add a little C# to a project, and Cake can now use that new feature.

I have easily converted customized MSBuild tasks that the Orchard project has created into a Cake Addin called [Cake.Orchard](https://www.nuget.org/packages/Cake.Orchard/) and it is found on Nuget. I have almost completed the conversation of the Orchard build and will be sharing that in the near future.

Stay tuned if you are interested in adding Cake to your projects.