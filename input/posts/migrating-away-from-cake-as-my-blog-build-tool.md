---
Title: "Migrating away from Cake as my blog build tool"
Published: 11/25/2018 21:02:50
Tags: 
- Open Source
- .NET Core
- Microsoft And Linux
- Tools
- Cake
- Small Sharp Tools
- Wyam
---
# Migrating away from Cake as my blog build tool

I have been using [Wyam](https://wyam.io/) as my blog engine for almost two years. As part of using Wyam, I have been using the awesome [Cake.Wyam]() addin for building my blog. I have paired that along with a few other Cake addins to create a Cake build script that orchestrates my builds. With [Wyam 2.0](https://wyam.io/blog/version-2.0) being released and the .NET Core global tool now existing I have decided that I am going to move to a much simpler build script. This post is going to serve as the guide to how I migrated away.

## Tools used in Cake

In Cake, I use the following addins:

* [Cake.Npm](https://www.nuget.org/packages/Cake.Npm/) - Used to install the [netlify-cli](https://www.netlify.com/docs/cli/) tool.
* [Cake.Wyam](https://www.nuget.org/packages/Cake.Wyam/) - Used to execute Wyam commands from Cake.
* [Cake.Netlify](https://www.nuget.org/packages/Cake.Netlify/) - Used to execute netlify-cli commands from Cake.

As you can see, the biggest advantage to Cake was for the Wyam support and since I was already using Cake, I decided to go ahead and just use it for everything.

## Migration

I have stated previously that .NET global tools would make it possible to migrate away from Cake so today is the day that I do it. The first step is going to be to remove the following files from my project and source control.

![](/images/removing-cake/cakefiles.png)

Since I am using the Netlify CLI tool, I am just going to make my entire build process an NPM script. I am going to open up my *package.json* and add the following:

```JSON
"scripts": {
  "postinstall": "dotnet tool install -g Wyam.Tool",
  "build" : "wyam --recipe Blog --theme CleanBlog --update-packages",
  "start": "wyam --recipe Blog --theme CleanBlog --update-packages --preview --watch",
  "predeploy": "npm run build",
  "deploy": "./node_modules/.bin/netlify deploy --dir=output --prod"
}
```

I am just hooking into the NPM standard scripts. I install the global .NET Core tool automatically after I execute NPM *install* helps since you only have to run one command. I have configured a plain *build* command, then I leveraged the *start* default command to execute the preview with a watch. Finally, I created a *predeploy* and *deploy* scripts to wire up running the build then deploying to Netlify. With all of this complete, here is me running Wyam using the NPM scripts.

```Bash
$ npm start
    Executing pipeline "AtomFeed" (16/16) with 3 child module(s)
        Executed pipeline "AtomFeed" (16/16) in 11 ms resulting in 2 output document(s)
    Executed 16/16 pipelines in 22315 ms
Preview server listening at http://localhost:5080 and serving from path file:///home/phillipsj/code/phillipsj/output with LiveReload support
Watching paths(s) file:///home/phillipsj/.nuget/packages/Wyam.Blog.CleanBlog.2.0.0/content, theme, input
Watching configuration file file:///home/phillipsj/code/phillipsj/config.wyam
Hit Ctrl-C to exit
```

Works like a charm, I just need to modify my AppVeyor build to execute my npm publish command and I am in business. 

![](/images/removing-cake/wyam-running-on-linux.png)

## Conclusion

Thanks for reading along and I hope you find this useful.

Jamie