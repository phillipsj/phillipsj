---
Title: "Cake: Contributing to an Addin"
Published: 07/04/2017 16:48:17
Tags: 
- Open Source
- Cake
---
# Cake: Contributing to an Addin

It feels good as an open source project creator when you get an issue opened in your GitHub repo. I received one earlier this week, when someone submitted an issue asking if support for [SyncReleases](https://github.com/cake-contrib/Cake.Squirrel/issues/16) could be added to [Cake.Squirrel](https://github.com/cake-contrib/Cake.Squirrel). After a little dicussion with the submitter, me asking if they would like to do the addition, we agreed it would be a little easier for me to do it. 

In spirit of trying to get more contirbutors involved, I am going to document my thought process behind how I am going to add the support and where.

## Step 1: New addin or addition

This is the part that can go either way. Should I just create a new runner in the current Cake.Squirrel addin and add the appropriate aliases? Or, should I create a new addin since this is a different executable that will be called. After a little research in to existing addins, I found enough cases where either choice would be correct. I decided that *SyncReleases* didn't provide enough standalone utility, I would just add it to the existing addin.

## Step 2: Create a feature branch

This is adding a new feature to the addin and should have all development work in a feature branch. I created a new feature branch called *sync-releases-support*. I used GitFlow for my workflow.

## Step 3:  Create a new runner

I opened the project and added two new classes called *SyncReleaesRunner* and *SyncReleasesSettings*. Now I needed inherit from the correct base classes provided by Cake. *SyncReleasesSettings* inherits from *ToolSettings*. 

```
using Cake.Core.Tooling;

namespace Cake.Squirrel {
    /// <summary>
    /// Contains settings used by <see cref="SyncReleasesRunner"/>.
    /// </summary>
    public class SyncReleasesSettings : ToolSettings { }
}
```

Now I can put in the inheritance for the *SyncReleasesRunner* and implement the required methods.

```using System.Collections.Generic;
using Cake.Core;
using Cake.Core.IO;
using Cake.Core.Tooling;

namespace Cake.Squirrel {
    /// <summary>
    /// The SyncReleases runner.
    /// </summary>
    public class SyncReleasesRunner : Tool<SyncReleasesSettings> {
        /// <summary>
        /// Initializes a new instance of the <see cref="SyncReleasesRunner"/> class.
        /// </summary>
        /// <param name="fileSystem">The file system.</param>
        /// <param name="environment">The environment.</param>
        /// <param name="processRunner">The process runner.</param>
        /// <param name="tools">The tool locator.</param>
        public SyncReleasesRunner(IFileSystem fileSystem, ICakeEnvironment environment, IProcessRunner processRunner,
            IToolLocator tools) : base(fileSystem, environment, processRunner, tools) { }

        /// <summary>
        /// Gets the name of the tool.
        /// </summary>
        /// <returns>The name of the tool.</returns>
        protected override string GetToolName() {
            return "SyncReleases";
        }

        /// <summary>
        /// Gets the possible names of the tool executable.
        /// </summary>
        /// <returns>List of possible executable names.</returns>
        protected override IEnumerable<string> GetToolExecutableNames() {
            return new[] {"SyncReleases.exe"};
        }
    }
}
```

With those two things accomplished, I know have the bare bones implementation completed.

## Step 4: Identify parameters needed 

The basics are in place, now creation of actual settings and the *Run* method for the runner need implemented. To do this, I typically download a copy of the tool or go to the documentation and lookup any parameters or settings I can pass. *SyncReleases* can be found by going [here]() or by downloading a copy of Squirrel.Windows and running the following command.

```
$ .\SyncReleases.exe -h

Usage: SyncReleases.exe command [OPTS]
Builds a Releases directory from releases on GitHub

Options:
  -h, -?, --help             Display Help and exit
  -r, --releaseDir=VALUE     Path to a release directory to download to
  -u, --url=VALUE            When pointing to GitHub, use the URL to the
                               repository root page, else point to an existing
                               remote Releases folder
  -t, --token=VALUE          The OAuth token to use as login credentials
```

From the output you can see that there are only three options that need implemented. Now we just need to add those three as properties on the *SyncReleasesSettings* class.

```
using System;
using Cake.Core.IO;
using Cake.Core.Tooling;

namespace Cake.Squirrel {
    /// <summary>
    /// Contains settings used by <see cref="SyncReleasesRunner"/>.
    /// </summary>
    public class SyncReleasesSettings : ToolSettings {
        /// <summary>
        ///     Gets or sets the release directory path to download to.
        /// </summary>
        public DirectoryPath ReleaseDirectory { get; set; }

        /// <summary>
        /// Gets or sets the URL to the remote releases folder. When pointing to GitHub, use the URL 
        /// to the repository root page, else point to an existing remote Releases folder
        /// </summary>
        public Uri Url { get; set; }

        /// <summary>
        /// Gets or sets the OAth token to use as login credentials.
        /// </summary>
        public string Token { get; set; }
    }
}
```

With the settings now in place, it is time to implement the *Run* method on the runner.

## Step 5: Turning tool settings into options

Now that the settings are finished we just need to implement the *Run* method on the *SyncReleasesRunner*. Here is the code that was added.

```
/// <summary>
        /// Executes SyncReleases with the specificed parameters.
        /// </summary>
        /// <param name="settings">The settings.</param>
        public void Run(SyncReleasesSettings settings) {
            if (settings == null) {
                throw new ArgumentNullException(nameof(settings));
            }

            Run(settings, GetArguments(settings));
        }

        /// <summary>
        ///  Executes SyncReleases with the specificed parameters.
        /// </summary>
        /// <param name="settings">The settings.</param>
        /// <param name="processSettings">The process settings.</param>
        public void Run(SyncReleasesSettings settings, ProcessSettings processSettings) {
            if (settings == null) {
                throw new ArgumentNullException(nameof(settings));
            }
            if (settings == null) {
                throw new ArgumentNullException(nameof(processSettings));
            }
            Run(settings, GetArguments(settings), processSettings, null);
        }
        
        private ProcessArgumentBuilder GetArguments(SyncReleasesSettings settings) {
            var builder = new ProcessArgumentBuilder();
            if (settings.ReleaseDirectory != null) {
                builder.Append("--releaseDir {0}", settings.ReleaseDirectory.FullPath);
            }
            if (settings.Url != null) {
                builder.Append("--url {0}", settings.Url.ToString());
            }
            if (!string.IsNullOrEmpty(settings.Token)) {
                builder.Append("--token {0}", settings.Token);
            }

            return builder;
        }
```

Two *Run* method were implemented to allow altering of the *ProcessSettings* if desired. The *GetArguments* method is the method that does most of the work by converting the settings to command line options.

## Step 6: Add Cake aliases

Now we just need to add the aliases for the *SyncReleasesRunner* to the *SquirrelAlaises* class to make it easy to call these in your Cake file. Two aliases have been added, one for just the settings and another one for when you want control of the process settings.

```
 /// <summary>
        /// Runs SyncReleases using the specified settings.
        /// </summary>
        /// <example>
        /// <code>
        /// #tool "Squirrel.Windows" 
        /// #addin Cake.Squirrel
        /// 
        /// Task("SyncReleases")
        ///  .Does(() => {
        ///    var settings = new SyncReleasesSettings {
        ///        ReleaseDirectory = "pathToDirectory"
        ///        Url = new Uri("https://someurl.com");
        ///        Token = "myToken"
        ///    }; 
        /// 
        ///    SyncReleases(settings);
        /// });
        /// </code>
        /// </example>
        /// <param name="context">The context.</param>
        /// <param name="settings">The settings.</param>
        [CakeMethodAlias]
        public static void SyncReleases(this ICakeContext context, SyncReleasesSettings settings)
        {
            if (context == null)
            {
                throw new ArgumentNullException(nameof(context));
            }
            var runner = new SyncReleasesRunner(context.FileSystem, context.Environment, context.ProcessRunner, context.Tools);
            runner.Run(settings);
        }

        /// <summary>
        /// Runs SyncReleases using the specified settings, if output should be redirected, and 
        /// if it should be silent.
        /// </summary>
        /// <example>
        /// <code>
        /// #tool "Squirrel.Windows" 
        /// #addin Cake.Squirrel
        /// 
        /// Task("SyncReleases")
        ///  .Does(() => {
        ///    var settings = new SyncReleasesSettings {
        ///        ReleaseDirectory = "pathToDirectory"
        ///        Url = new Uri("https://someurl.com");
        ///        Token = "myToken"
        ///    }; 
        /// 
        ///    SyncReleases(settings, true, false);
        /// });
        /// </code>
        /// </example>
        /// <param name="context">The context.</param>
        /// <param name="settings">The settings.</param>
        /// <param name="redirectStandardOutput">Sets if the output of an tool is written to the <see cref="P:System.Diagnostics.Process.StandardOutput"/> stream.</param>
        /// <param name="silent">Sets if the tool output should be suppressed.</param>
        [CakeMethodAlias]
        public static void SyncReleases(this ICakeContext context, SyncReleasesSettings settings, bool redirectStandardOutput, bool silent)
        {
            if (context == null)
            {
                throw new ArgumentNullException(nameof(context));
            }
            var runner = new SyncReleasesRunner(context.FileSystem, context.Environment, context.ProcessRunner, context.Tools);
            runner.Run(settings, new ProcessSettings { RedirectStandardOutput = redirectStandardOutput, Silent = silent });
        }
```

## Step 7: Unit testing

The last and final step will be to add unit tests just to make sure that no huge mistakes have been made and to give confidence to the contributor that they didn't break anything when adding additional functionality.

There will need to be a new fixture created, and you guess it, called *SyncReleasesRunnerFixture*. The Cake team has done an awesome job helping you out on creating this by creating a *ToolFixture* that you can inherit from to help get going faster. It is a pretty sparse class and most of the work is done in the base class in this instance. You can see we reference the executable and call the *Run* method.

```
using Cake.Testing.Fixtures;

namespace Cake.Squirrel.Tests.Fixture {
    internal sealed class SyncReleasesRunnerFixture : ToolFixture<SyncReleasesSettings> {
        public SyncReleasesRunnerFixture() : base("SyncReleases.exe") { }

        protected override void RunTool() {
            var tool = new SyncReleasesRunner(FileSystem, Environment, ProcessRunner, Tools);
            tool.Run(Settings);
        }
    }
}

```

Now we are going to put this fixture to good use by writing some unit tests. We create *SyncReleasesTests* class and then create the unit tests needed to cover most of the functionality. You can see below the choices made.

```
using System;
using Cake.Core;
using Cake.Squirrel.Tests.Fixture;
using Cake.Testing;
using Should;
using Xunit;

namespace Cake.Squirrel.Tests {
    public class SyncReleasesRunnerTests {
        [Fact]
        public void Should_Throw_If_Settings_Are_Null() {
            // Given
            var fixture = new SyncReleasesRunnerFixture();
            fixture.Settings = null;

            // When
            var result = Record.Exception(() => fixture.Run());

            // Then
            result.ShouldBeType<ArgumentNullException>().ParamName.ShouldEqual("settings");
        }

        [Fact]
        public void Should_Throw_If_SyncReleasesl_Executable_Was_Not_Found() {
            // Given
            var fixture = new SyncReleasesRunnerFixture();
            fixture.GivenDefaultToolDoNotExist();

            // When
            var result = Record.Exception(() => fixture.Run());

            // Then
            result.ShouldBeType<CakeException>().Message.ShouldEqual("SyncReleases: Could not locate executable.");
        }

        [Theory]
        [InlineData("/bin/tools/Squirrel/SyncReleases.exe", "/bin/tools/Squirrel/SyncReleases.exe")]
        [InlineData("./tools/Squirrel/SyncReleases.exe", "/Working/tools/Squirrel/SyncReleases.exe")]
        public void Should_Use_SyncReleases_Executable_From_Tool_Path_If_Provided(string toolPath, string expected) {
            // Given
            var fixture = new SyncReleasesRunnerFixture();
            fixture.Settings.ToolPath = toolPath;
            fixture.GivenSettingsToolPathExist();

            // When
            var result = fixture.Run();

            // Then
            result.Path.FullPath.ShouldEqual(expected);
        }

        [Fact]
        public void Should_Throw_If_Process_Was_Not_Started() {
            // Given
            var fixture = new SyncReleasesRunnerFixture();
            fixture.GivenProcessCannotStart();

            // When
            var result = Record.Exception(() => fixture.Run());

            // Then
            result.ShouldBeType<CakeException>().Message.ShouldEqual("SyncReleases: Process was not started.");
        }

        [Fact]
        public void Should_Throw_If_Process_Has_A_Non_Zero_Exit_Code() {
            // Given
            var fixture = new SyncReleasesRunnerFixture();
            fixture.GivenProcessExitsWithCode(1);

            // When
            var result = Record.Exception(() => fixture.Run());

            // Then
            result.ShouldBeType<CakeException>()
                .Message.ShouldEqual("SyncReleases: Process returned an error (exit code 1).");
        }

        [Fact]
        public void Should_Find_SyncReleases_Executable_If_Tool_Path_Not_Provided() {
            // Given
            var fixture = new SyncReleasesRunnerFixture();

            // When
            var result = fixture.Run();

            // Then
            result.Path.FullPath.ShouldEqual("/Working/tools/SyncReleases.exe");
        }

        [Fact]
        public void Should_Add_Url_To_Arguments() {
            // Given 
            var fixture = new SyncReleasesRunnerFixture();
            fixture.Settings.Url = new Uri("https://google.com");

            // When
            var result = fixture.Run();

            // Then
            result.Args.ShouldEqual("--url https://google.com/");
        }
    }
}

```
# The End

Hopefully this helps walk you through at a high leve, the basics for making decisions and contributing to an existing Cake addin. I am more than happy to do pair programming with anyone that would like to perform a task on an addin that I suppport. 

A special thanks to [JKSnd](https://github.com/JKSnd) for making the request and got getting turned off by me asking if they would like to perform the addition.

