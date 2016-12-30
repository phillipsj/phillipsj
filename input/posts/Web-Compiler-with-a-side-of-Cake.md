---
Title: Web Compiler with a side of Cake
Published: 2015-11-25 19:00:00
Tags:
- Open Source
- Cake
RedirectFrom: blog/html/2015/11/25/web_compiler_with_a_side_of_cake.html
---

My team has been using [React](http://facebook.github.io/react/) to create any front-end components that need to be interactive. So far it has been a pleasant experience. We started using JSX for our HTML. However, now that we are nearing a production release we wanted to precompile the JSX. We had intially planned to use the [React.NET](http://reactjs.net/) project, but the JSX support has been dropped in support of using [Babel](https://babeljs.io/). Babel’s documentation isn’t the best, so in looking for alternatives before diving in to Babel, I stumbled across [Web Compiler](https://github.com/madskristensen/WebCompiler) by Mads Kristensen. It just so happens that there is a Visual Studio Extension for it and it will compile LESS, SASS, JSX, and CoffeeScript. Since we are planning to use SASS in the future this appeared to be a great option. The extension makes it easy to use as part of the IDE. There is also a nuget package for it that makes it easy to use with MSBUILD. Now that all of our needs are covered it is time to see if we can get it to work with Cake.

Configuring Web Compiler for use with Cake was extremely easy. Here are the steps needed to have Web Compiler working as part of your Cake builds.

1. Edit your packages.config for Cake, you also need Cake.MSBuildTask.
```
<?xml version="1.0" encoding="utf-8"?>
<packages>
    <package id="Cake" version="0.5.5" />
    <package id="Cake.MSBuildTask" version="0.0.4"/>
    <package id="BuildWebCompiler" version="1.8.273"/>
</packages>
```

2. Now add the Web Compiler as an addin in your build.cake file.
```
// Addins
#addin Cake.MSBuildTask

#r .\tools\BuildWebCompiler\tools\WebCompiler.exe
```

3. Now create your JSX compile tasks, now use the GetFiles to find all compilerconfig.json files.
```
Task("CompileJSX")
  .Does(() => {
    var compilerConfigs = GetFiles("./src/Orchard.Web/Modules/**/compilerconfig.json");
    foreach(var compilerConfig in compilerConfigs){
      Information(string.Format("Compliing JSX for {0}.", compilerConfig.ToString()));
      var webCompilerClean = new WebCompiler.CompilerCleanTask();
      webCompilerClean.FileName = compilerConfig.ToString();
      MSBuildTaskExecute(webCompilerClean);

      var webCompilerBuild = new WebCompiler.CompilerBuildTask();
      webCompilerBuild.FileName = compilerConfig.ToString();
      MSBuildTaskExecute(webCompilerBuild);
    }
});
```

It is that easy. I may, in the future, remove the need for the MSBuildTask runner.

Hope someone finds this of value.