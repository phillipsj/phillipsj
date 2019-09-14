---
Title: "The SDK Microsoft.NET.Sdk specified could not be found"
date: 2017-12-19T15:17:47
Tags: 
- TeamCity
- MSBuild
- .NET Core
---
# The SDK Microsoft.NET.Sdk specified could not be found

Ah, the dreaded build error that I have been dealing with for sometime now. This was only affecting our .NET Core 2.0 projects. Then after a little more diligence today, I discovered this StackOverflow [post](https://stackoverflow.com/questions/46257393/msbuild-throws-error-the-sdk-microsoft-net-sdk-specified-could-not-be-found).

It seems that if you had .NET Core 1.x installed first, then later installed 2.0, the *MSBuildSDKsPath* system environment variable doesn't get updated to point to the new 2.0 location.  

Here is a screenshot from our TeamCity Server:

![](/images/other-posts/sdkpath.png)

The location is set to:

```
C:\Program Files\dotnet\sdk\1.0.4\Sdks
```

It should be set to if you have .NET Core 2.0 installed:

```
C:\Program Files\dotnet\sdk\2.0.0\Sdks
```

Once I made that correction, I needed to reboot the build agent. After it was back up, all my builds went **Green**!

Hope this helps others find it. I plan to submit this as a bug to Microsoft.
