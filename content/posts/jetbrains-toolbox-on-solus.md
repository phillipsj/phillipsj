---
Title: "JetBrains Toolbox on Solus"
date: 2018-02-27T21:54:10
Tags: 
- Open Source
- Dotnet Core
- Microsoft And Linux
- Tools
- Solus
---
# JetBrains Toolbox on Solus

As it has been said before, I am a huge fan of [Solus](https://solus-project.com/). I believe it is a great project and solves a lot of the pains of other distros. In the Solus Software Center, under **Third Party**, are several of the JetBrains apps. This is a nice feature, however, I find that using the [JetBrains Toolbox](https://www.jetbrains.com/toolbox/app/) app easier to use and it makes sure that everything is always up-to-date and I can install any EAPs that I desire.

![](/images/jetbrains-toolbox/softwarecenter.png)

The JetBrains Toolbox app is distributed as an [AppImage](https://appimage.org/) and requires the Fuse package to be installed. Solus already handles this for us, so it is just a matter of downloading, unpacking, and make it part of the startup process when you login.

## Installation

Let's download and install.

```
$ curl -sSL -o jetbrains-toolbox.tar.gz https://download.jetbrains.com/toolbox/jetbrains-toolbox-1.6.2914.tar.gz
$ mkdir -p ~/jetbrains-toolbox && tar zxf jetbrains-toolbox.tar.gz -C ~/jetbrains-toolbox
```

Now navigate to the **jetbrains-toolbox** directory, open the sub folder. Double click on the AppImage icon and toolbox app should lauch. Login with your JetBrains account and you can start downloading the IDEs that you want.

![](/images/jetbrains-toolbox/ides.png)

## Conclusion

This is super simple to get going and works as it does any other platform. It would be nice if Solus would start shipping the toolbox app instead of each IDE separetley.

