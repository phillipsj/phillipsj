---
Title: "Cake Crumbs of the Week #2"
Published: 03/05/2017 21:06:52
Tags: 
- Open Source
- Cake
- Cake Crumbs
---
# Cake Crumbs of the Week #2

This is the second edition of my weekly series.  Here are a few more tips.

## Using the Addin directive instead of Tool and Reference.

I told you all that I would show you all and easier way that using the tool directive and reference.  Here it is. just remember that it doesn't work if the NuGet package doesn't follow the appropriate format.

### Before 

```
#tool nuget:?package=AutoMapper
#reference "tools/AutoMapper/lib/net45/AutoMapper.dll"
using AutoMapper;
```

### After

```
#addin nuget:?package=AutoMapper
using AutoMapper;
```

## Using CSX with Cake

Did you know that you can use can load CSX files into your Cake file.  How you have to do is us th following:

```
#load "./build/MyClass.csx"
```

That way if you need to create some custom classes and need intellisense then you can have it.

Thanks for reading,

Jamie