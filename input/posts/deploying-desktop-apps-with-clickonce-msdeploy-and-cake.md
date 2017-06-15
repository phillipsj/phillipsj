---
Title: "Deploying Desktop Apps with ClickOnce, MSDeploy, and Cake"
Published: 06/15/2017 04:56:55
Tags: 
- Open Source
- Cake
- DevOps
---
# Deploying Desktop Apps with ClickOnce, MSDeploy, and Cake

I have been working on a project that has me automating the deployment of a desktop application. We serve this application using RemoteApp, but we would like to start offering both a RemoteApp version for remote employees and a ClickOnce version for employees that are on-premise. This particular application has been a thorn in my side, it is the last remaining application that we do not have a deployment pipeline configured. 

This post is about how I remedied the situation. I had already configured a Cake build for this application so that was part was solved. The remaining items that needed to be configured are below.

* Migrating the App to semantic versioning with automation
* Publishing a ClickOnce App
* Publishing a RemoteApp

I am going to break this post up into sections based on the tasks that needed to accomplish, in case you don't need all the other bits.

## Migrating to Semantic Versioning

As a team we adopted [GitFlow](http://nvie.com/posts/a-successful-git-branching-model/) workflow for git, so we are already using the branching strategy and tagging our releases with the version number. After looking around at a few tools, I decided to just adopt [GitVersion](https://github.com/GitTools/GitVersion), which also happens to be included with Cake. 

To make life easier, I decided to use the *version.cake* file that I have seen in the Cake and Cake-Contrib repos.  It is a nice, easy to use, wrapper around GitVersion.

```
public class BuildVersion {
    public string Version { get; private set; }
    public string SemVersion { get; private set; }
    public string Milestone { get; private set; }
    public string CakeVersion { get; private set; }
    public string InformationalVersion { get; private set; }

    public static BuildVersion CalculatingSemanticVersion(ICakeContext context) {
        if (context == null) {
            throw new ArgumentNullException("context");
        }

        string version = null;
        string semVersion = null;
        string milestone = null;
        string informationalVersion = null;

        if (context.IsRunningOnWindows()) {
            context.Information("Calculating Semantic Version...");
            if (!context.BuildSystem().IsLocalBuild) {
                context.GitVersion(new GitVersionSettings{
                    UpdateAssemblyInfoFilePath = "./src/SolutionInfo.cs",
                    UpdateAssemblyInfo = true,
                    OutputType = GitVersionOutput.BuildServer
                });

                version = context.EnvironmentVariable("GitVersion_MajorMinorPatch");
                semVersion = context.EnvironmentVariable("GitVersion_LegacySemVerPadded");
                informationalVersion = context.EnvironmentVariable("GitVersion_InformationalVersion");
                milestone = string.Concat(version);
            }

            GitVersion assertedVersions = context.GitVersion(new GitVersionSettings {
                OutputType = GitVersionOutput.Json,
            });

            version = assertedVersions.MajorMinorPatch;
            semVersion = assertedVersions.LegacySemVerPadded;
            informationalVersion = assertedVersions.InformationalVersion;
            milestone = string.Concat(version);

            context.Information("Calculated Semantic Version: {0}", semVersion);
        }

        if (string.IsNullOrEmpty(version) || string.IsNullOrEmpty(semVersion)) {
            context.Information("Fetching version from SolutionInfo...");
            var assemblyInfo = context.ParseAssemblyInfo("./src/SolutionInfo.cs");
            version = assemblyInfo.AssemblyVersion;
            semVersion = assemblyInfo.AssemblyInformationalVersion;
            informationalVersion = assemblyInfo.AssemblyInformationalVersion;
            milestone = string.Concat(version);
        }

        var cakeVersion = typeof(ICakeContext).Assembly.GetName().Version.ToString();
        
        return new BuildVersion {
            Version = version,
            SemVersion = semVersion,
            Milestone = milestone,
            CakeVersion = cakeVersion,
            InformationalVersion = informationalVersion
        };
    }
}
```

Then all you need to add before your Cake setup or tasks is the following line that calculates the version.

```
var buildVersion = BuildVersion.CalculatingSemanticVersion(context: Context);
```

Now you can just use the *BuildVersion* object where ever you need the version information in your Cake file. If you are relying on AssemblyInfo and SolutionInfo then that is automatically updated. Everyone has specific ways they would like to label their branches and this just requires a *GitVersion.yml* file in the root of your repository.  Here is an example.

```
mode: ContinuousDelivery
branches:
    releases?[/-]:
        mode: ContinuousDeployment
        tag: rc
    dev(elop)?(ment)?$:
        mode: ContinuousDeployment
        tag: alpha
    hotfix(es)?[/-]:
        mode: ContinuousDeployment
        tag: beta
ignore:
    sha: []
```

You can read more on the [GitVersion](https://github.com/GitTools/GitVersion) website.

## Publishing a ClickOnce App

ClickOnce has not always been the friendliest way to deploy applications. The default site that is generated isn't the best and there is always confusion around how it works. The [ClickTwice](https://github.com/agc93/ClickTwice) project by [Alistair Chapman](https://www.agchapman.com/) improves the website design and the automation tools provided to package the site, removes much of that pain. There is support for CSX and Cake with the project and you know that I used the Cake addin. Here is what it looks like to publish a ClickOnce app using the [HTML5Up Solid State](https://html5up.net/solid-state) template.

```
PublishApp("./path-to-project") 
    .WithHandler(new AppInfoHandler(new AppInfoManager()))
    .WithHandler(new AppDetailsPageHandler("ClickTwice.Templates.SolidState") {
        FileNameMap = new Dictionary<string, string> {
                        {"index.html", "details.html"}
        }})
    .WithHandler(new InstallPageHandler(fileName: "index.html", linkText: "Details", linkTarget: "details.html"))
    .SetConfiguration(configuration)
    .ThrowOnHandlerFailure()
    .WithVersion($"{buildVersion.Version}.%2a")
    .To("./artifacts/publish/");
```    

You will notice that I am passing the semantic version, without any labels, to the tool to make sure it versions correctly. Now all that is left is to create a MsDeloy package for deployment to IIS. [Rob Schiefer](http://www.dotnetcatch.com/) has done an awesome job evanglising the use of MsDeploy for deploying everything, so I knew that would be the approach I would try first. This was the tricky part, but after reading Rob's blog posts and sifting through the documentation I was able to figure it out. Again, another Cake addin to the rescue, [Cake.MsDeploy](https://github.com/cake-contrib/Cake.MsDeploy).

```
var publishDir = MakeAbsolute(Directory("./artifacts/publish"));
var clickOncePackage = MakeAbsolute(File("./artifacts/clickonce.zip"));
MsDeploy(new MsDeploySettings {
    Verb = Operation.Sync,
    Source = new ContentPathProvider {
        Direction = Direction.source,
        Path = publishDir.ToString()
    },
    Destination = new PackageProvider {
        Direction = Direction.dest,
        Path = clickOncePackage.ToString()
    }
});
```

I needed to use a Content Path Provider as the source and a PackageProvider as the destination and that created the correct package I needed to make it work.  Then all that is left is to use MsDeploy to push that provide to our host server.

```
var clickOncePackage = MakeAbsolute(File("./artifacts/clickonce.zip"));
MsDeploy(new MsDeploySettings {
    Verb = Operation.Sync,
    RetryAttempts = 5,
    RetryInterval = 5000,
    Source = new PackageProvider {
        Direction = Direction.source,
        Path = clickOncePackage.ToString()
    },
    Destination = new ContentPathProvider {
        Direction = Direction.dest,
        Path = "C:\\inetpub\\wwwroot\\clickonce",
        IncludeAcls = false,
        AuthenticationType = AuthenticationScheme.NTLM,
        Username = $"{server}\\{username}",
        Password = password,
        ComputerName = server
    },  
    AllowUntrusted = true 
});
```

## Publishing a Remote App

After reading even more posts by Rob, documentation, and experimentation, I discovered that it wasn't that difficult to deploy an executable to the server and redirect the RemoteApp to use the new version.  You again use a Content Path Provider and a  Package provider. 

Again, using Cake.MsDeploy here is what it looks like.

```
var remoteAppDir = MakeAbsolute(Directory("./src/MyApp/bin/" + configuration));
var remoteAppPackage = MakeAbsolute(File("./artifacts/remote-app.zip"));
MsDeploy( new MsDeploySettings {
    Verb = Operation.Sync,
    Source = new ContentPathProvider {
        Direction = Direction.source,
        Path = remoteAppDir.ToString()
    },
    Destination = new PackageProvider {
        Direction = Direction.dest,
        Path = remoteAppPackage.ToString()
    }
});
```  

After the package was created, I used MsDeploy to push that app to the server and then, the big trick, execute a post sync command that executes a Powershell command to configure the RemoteApp. All of this can be seen below.  One trick to note is that I used curly braces to box in my powershell command instead of qoutes. That was a change I had to make to get it to work and will save you lots of time surfing the web wondering why it didn't work.

```
var remoteAppPackage = MakeAbsolute(File("./artifacts/remote-app.zip"));
var exePath = $"C:\\Program Files\\Vendor\\MyApp\\{buildVersion.SemVersion}";
MsDeploy(new MsDeploySettings {
    Verb = Operation.Sync,
    RetryAttempts = 5,
    RetryInterval = 5000,
    Source = new PackageProvider {
        Direction = Direction.source,
        Path = remoteAppPackage.ToString()
    },
    Destination = new ContentPathProvider {
        Direction = Direction.dest,
        Path = exePath,
        IncludeAcls = false,
        AuthenticationType = AuthenticationScheme.NTLM,
        Username = $"{server}\\{username}",
        Password = password,
        ComputerName = server
    },
    AllowUntrusted = true,
    PostSyncCommand = "powershell -Command {Set-RDRemoteApp -CollectionName QuickSessionCollection -Alias MyApp -FilePath " + exePath + "}"
}); 
```

Hope you find you this helpful, if you need any items clarified or want to discuss you can leave a comment or find my on social media. 

Thanks, for reading.