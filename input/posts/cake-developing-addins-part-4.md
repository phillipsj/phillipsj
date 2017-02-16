---
Title: "Cake: Developing Addins Part 4"
Published: 01/28/2017 11:45:30
Tags: 
- Open Source
- Cake
- Tutorials
- Netlify
---
# Cake: Developing Addins Part 4

* [Part 1](http://www.phillipsj.net/posts/cake-developing-addins-part-1)
* [Part 2](http://www.phillipsj.net/posts/cake-developing-addins-part-2)
* [Part 3](http://www.phillipsj.net/posts/cake-developing-addins-part-3)
* [Part 5](http://www.phillipsj.net/posts/cake-developing-addins-part-5)

So I wasn't ready to give up on making existing Cake tooling work. I have been working on a project at work and I discovered [Cake.Powershell](https://github.com/SharpeRAD/Cake.Powershell) and I figured I would give it a try. 

The first step would be to include the Cake.Powershell in the Cake file.

```
#addin nuget:?package=Cake.Powershell
```

With it added, I made a few tweaks to my *Netlify-Deploy* task by adding the *StartPowershellScript* command with the arguments I needed.

```
Task("Netlify-Deploy")
    .IsDependentOn("Install-Netlify-Cli")
    .IsDependentOn("Build")
    .Does(() => {
        var token = EnvironmentVariable("NETLIFY_PHILLIPSJ");
        var siteId = EnvironmentVariable("NETLIFY_SITEID");
        if(string.IsNullOrEmpty(token)) {
            throw new Exception("Could not get NETLIFY_PHILLIPSJ environment variable");
        }
        if(string.IsNullOrEmpty(siteId)) {
            throw new Exception("Could not get NETLIFY_SITEID environment variable");
        }
        
        StartPowershellScript("./node_modules/.bin/netlify deploy", args => {
            args.Append("p", "output").Append("s", siteId).Append("t", token);
        });
    });
```

With the previous post and the tweaks made in this one, I can successfully deploy my blog using the *netlify-cli* with a local install of the cli.  I will continue the development of *Cake.Netlify*, however I wanted to see this through since I started down this path.

Thanks for reading,

Jamie