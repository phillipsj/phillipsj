---
title: ".NET Global Tools With .NET Snap"
date: 2021-02-27T20:29:21-05:00
tags:
- Open Source
- .NET Core
- Microsoft And Linux
- Tools
- Ubuntu
- Snap
- Snapcraft
---

I have started to work with .NET again after taking a break. As usual, I am running some form of Ubuntu, and I have run into an interesting issue. I have been using the snap package, and I kept getting an interesting error when executing global tools.

```Bash
A fatal error occurred. The required library libhostfxr.so could not be found.
If this is a self-contained application, that library should exist in 
If this is a framework-dependent application, install the runtime in the global location [/usr/share/dotnet] or use the DOTNET_ROOT environment variable to specify the runtime location or register the runtime location in [/etc/dotnet/install_location].
```

To correct this issue, you need to define the location of the *DOTNET_ROOT*. The snap package location doesn't seem to be in the default resolver. You can do it like this; make sure to add it to your *.bashrc* or *.profile*.

```Bash
export DOTNET_ROOT=/snap/dotnet-sdk/current
```

After adding this, everything started working as expected. I hope this helps someone else.

Thanks for reading,

Jamie

