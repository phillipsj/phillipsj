---
Title: "Creating a desktop version of the Azure Portal with Nativefier"
Published: 09/08/2019 14:04:57
Tags: 
- Azure Portal
- Azure
- Microsoft
- .NET
---
# Creating a desktop version of the Azure Portal with Nativefier

When I am busy throughout the day, I have tons of tabs open across multiple browsers. Since I mainly working in the cloud, most of the applications I use are the browser. With so many tabs and browsers open I will lose the tab that is running the Azure Portal which increases the chance that I will have multiple tabs of it, creating even more difficult.

I have recently learned about [Nativefier](https://github.com/jiahaog/nativefier) which is tool for wrapping any webpage in an Electron app to create a more native like experience. I think this will be a great thing to test out with the Azure Portal. I can create a native app that I can track in my taskbar which makes finding it much easier.

## Requirements

It works on Linux/MacOS/Windows operating systems and requires a version of Node greater than version 6, I am using 12.

## Installation

Installation is super simple, you just need to npm install it as a global package.

```Bash
$ npm install nativefier -g
+ nativefier@7.7.0
added 323 packages from 303 contributors in 23.294s
```

That's it, now we can create an Azure Portal "native" app.

## Azure Portal as a native app

Now we can get down to business making it happen. We will provide it a name and we have to set the internal URLs to make sure when the sign-in redirect is triggered that it doesn't open your system browser. The URLs need to stay inside of your "native" app. You can restrict those those internal URLs more if you desire.

```Bash
$ nativefier --name "AzurePortal" "https://portal.azure.com" --internal-urls ".*?"
Packaging app for platform linux x64 using electron v5.0.10
```

Now, I am on Linux, so this is a little different for me. The app was created in my home directory and I had to run it from there first. This may work differently on other desktop environments, but on Ubuntu Budgie I am not getting the menu for it either. On Windows everything is working as I expect. 

Here is the "native" Azure Portal app.

![](/images/nativefier/azureportalapp.jpg)


Thanks for reading,

Jamie
