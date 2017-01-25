---
Title: "Cake: Developing Addins Part 3"
Published: 01/24/2017 20:51:30
Tags: 
---
# Cake: Developing Addins Part 3

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

Now that I have the *netlify-cli* being installed, I will need to create a new *Deploy* task that will be the one that uses the cli. I will use the **Npm.RunScript** command that is part of *Cake.Npm* to execute the local *netlify-cli* and pass the arguments directly to it right in the Cake task.

```

```