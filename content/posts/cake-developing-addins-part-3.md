---
Title: "Cake: Developing Addins Part 3"
date: 2017-01-24T20:51:30
Tags: 
- Open Source
- Cake
- Tutorials
- Netlify
---
# Cake: Developing Addins Part 3

* [Part 1](http://www.phillipsj.net/posts/cake-developing-addins-part-1)
* [Part 2](http://www.phillipsj.net/posts/cake-developing-addins-part-2)
* [Part 4](http://www.phillipsj.net/posts/cake-developing-addins-part-4)
* [Part 5](http://www.phillipsj.net/posts/cake-developing-addins-part-5)

Back with another installment of my thought process. I have been thinking a little more about it before I get started on the actual addin, that I realized that I could put together a quick and dirty solution. I am going to use the [Cake.Npm](https://github.com/cake-contrib/Cake.Npm) addin to do it.  So here goes.

The first step would be to include the Cake.Npm in the Cake file for this blog.

```
#addin nuget:?package=Cake.Npm
```

With that out of the way, something that I have been considering is that I do not want the user to have to make sure that the *netlify-cli* is already installed. Yes, *Node* and *NPM* will need to be installed, but I can't control that. Another item that I would like for the future addin is to have it use a local version of *netlify-cli*.  To accomplish this, I am going to create a task that installs *netlify-cli* locally.

```
Task("Install-Netlify-Cli")
    .Does(()=> {
        Npm.Install(settings=>settings.Package("netlify-cli"));
    });
```

Now that I have the *netlify-cli* being installed, I will need to create a new *Deploy* task that will be the one that uses the cli. I will use the **Npm.RunScript** command that is part of *Cake.Npm* to execute the local *netlify-cli* and pass the arguments directly to it right in the Cake task. So I have been coding this as I am blogging and to say the least, it was a failure. I create a **package.json** to hold my wonderful deploy command and tried to pass the arguments as I needed.

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
        Npm.RunScript("deploy", settings => settings.WithArgument(string.Format("-s {0}", siteId)).WithArgument(string.Format("-t {0}", token)));
    });
```

Like I stated above this was a failure of an experiment. It is very close, but it just didn't work.  I will go ahead with actually creating an actual addin.  All of the fail can be found in the repo. I will not delete any of it.

Thanks for reading,

Jamie
