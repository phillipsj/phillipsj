---
Title: 'Shockingly Sweet: Electron and Cake'
Published: 2016-07-23 22:48:40
Tags:
- Open Source
- Cake
- Electron
RedirectFrom: 2016/07/23/Shockingly-Sweet-Electron-and-Cake/index.html
---

We have recently started using [Electron](http://electron.atom.io/) for an application we have been developing. We have enjoyed the experience so much we have decided as a team that all desktop applications going forward will be Electron based. This is great as it keeps the web development skills sharp even when making a desktop application, plus it leverages our knowledge in web technologies and we don't have to context switch. 

To keep the consistency with all our other projects we decided to use Cake to build our Electron applications. We use [electron-builder](https://github.com/electron-userland/electron-builder) to perform the heavy lifting with a few NPM scripts.  We then execute those NPM scripts using Cake. You can take a look at the complete solution [here](https://github.com/phillipsj/shockingly-sweet). Below I will walk you through the Cake file.

So we start off by getting the [Cake.Npm](https://github.com/philo/cake-npm) addin.

```
#addin Cake.Npm
```

With the addin for NPM added we have the typical arguments section and as far as the default task, is typically what you see in Cake. We are going to focus on the Electron specific tasks.

Calling an NPM script that configures the environment and performing an NPM install:

```
Task("Npm-Install")   
    .Does(() => {
       Npm.RunScript("setupEnv");
       Npm.Install();
});
```


Running a clean on the project using an NPM script.

```
Task("Clean")
    .IsDependentOn("Npm-Install")
    .Does(() => {
        Npm.RunScript("clean");
});
```

Now we have the main part, which is running the dist NPM script that packages the application and builds the executable.

```
Task("Build")
    .IsDependentOn("Clean")
    .Does(() => {
        Npm.RunScript("dist");
});
```

So yes, the majority of this process relies upon NPM scripts, which we could easily just move the calls into the Cake file and out of the package.json.  The main advantage that I am not showing here, is the addins that we use like [Cake.AzureStorage](https://github.com/RadioSystems/Cake.AzureStorage) to push the packaged application to Azure, or some of the other addins we use that are just easier for us to create that functionality in .NET. 

Hope this is helpful.