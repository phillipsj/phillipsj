---
Title: 'Cake: Unit testing addins'
date: 2016-08-07T08:41:18
Tags:
- Open Source
- Cake
- Tutorials
RedirectFrom: 2016/08/07/Cake-Unit-testing-addins/index.html
---

I am back with another confession to make, my [Cake.XdtTransform]() project does not have any unit testing. So I decided this is a great opportunity to create a tutorial for unit testing a Cake addin.

## Step 1: Create unit test project

Create a new *class library* project named *Cake.XdtTransform.Tests*, as part of our Cake.XdtTransform solution, and delete the Class1.cs file that is automatically created. The first item you will need is the *Cake.Testing* Nuget package, so please install that into your *Cake.XdtTransform.Tests* project. *Cake.Testing* provides a nice set of fakes, fixtures, and extensions that can help with unit testing. At this point, you can pick your favorite unit testing frameworky, in this example we will create our unit tests using *Fixie* and *Should* for assertions, the Cake project uses *Xunit2*. There are lots of examples in the source code. Start by creating a class called *XdtTransformationTests.cs*. 

## Step 2: Code

Lets start writing our unit tests. We are going to follow a few other conventions from the Cake source code as I find it helpful. In your *XdtTransformationTests.cs* class. Let's create the initial class and the basic items needed.

```

namespace Cake.XdtTransform.Tests {
    public sealed class XdtTransformationTests {
       
    }
}

```

As you see we have created a class for the tests which is all that is really needed with Fixie. Before we can start testing we will create a fixture for our *XdtTransform* class. This is another convention that is prevalent throughout the Cake source code that I find useful. So create a folder in our *Cake.XdtTransform.Tests* project called *Fixtures*, and then create a class in that folder called *XdtTransformationFixture.cs*. Here is the basic structure of that class.

```

namespace Cake.XdtTransform.Tests.Fixtures {
    internal sealed class XdtTransformationFixture {
       
        public XdtTransformationFixture() { 

        }
    }
}

```

Now that we have the basic structure of the fixture we are going to go through several steps to get it setup for using in our tests. In Cake, these fixtures wrap the class you are testing and performs all the necessary setup. This is also the class that will use several of the fakes that are included in the *Cake.Testing* Nuget package. So lets start off by create our constructor.

```

namespace Cake.XdtTransform.Tests.Fixtures {
    internal sealed class XdtTransformationFixture {
        
        public XdtTransformationFixture(bool sourceFileExists = true, bool transformFileExists = true, bool targetFileExists = false) {
           
        }
    }
}

```

In this constructor we are going to be passing booleans to toggle if a file is needed. This way we can easily write unit tests that validate that we passed a valid file to our methods. Inside the constructor we need to setup the cake environment, the file system, and make sure our source and transform files exist.

```

using Cake.Core.IO;
using Cake.Testing;
using Cake.XdtTransform.Tests.Properties;

namespace Cake.XdtTransform.Tests.Fixtures {
    internal sealed class XdtTransformationFixture {
        public IFileSystem FileSystem { get; set; }
        public FilePath SourceFile { get; set; }
        public FilePath TransformFile { get; set; }
        public FilePath TargetFile { get; set; }

        public XdtTransformationFixture(bool sourceFileExists = true, bool transformFileExists = true, bool targetFileExists = false) {
            var environment = FakeEnvironment.CreateUnixEnvironment();
            var fileSystem = new FakeFileSystem(environment);
            fileSystem.CreateDirectory("/Working");

            if (sourceFileExists) {
                var sourceFile = fileSystem.CreateFile("/Working/web.config").SetContent(Resources.XdtTransformation_SourceFile);
                SourceFile = sourceFile.Path;
            }

            if (transformFileExists) {
                var transformFile = fileSystem.CreateFile("/Working/web.release.config").SetContent(Resources.XdtTramsformation_TransformFile);
                TransformFile = transformFile.Path;
            }

            if (targetFileExists) {
                var targetFile = fileSystem.CreateFile("/Working/transformed.config").SetContent(Resources.XdtTransformation_TargetFile);
                TargetFile = targetFile.Path;
            }
            else {
                TargetFile = "/Working/transformed.config";
            }

            FileSystem = fileSystem;
        }
    }
}

```

So lets walk through the code that is above. The first thing we do is use the *FakeEnvrionment* to create a *CakeEnvironment* for unix. Then we use that environment to create a *FakeFileSystem*. We then create a directory in our fake file system. After that we just make sure that we create any necessary files that we need to exist in that fake directory. You will also notice that we are using a few resources. Those files are real contents of the files that are represented just stored as resources in the project.

Now lets implement the method we will be testing using our fixture, the TransformConfig method. This method just wraps the XdtTransformation.TransformConfig method, but provides all the necessary environment configuration for it.

```

using Cake.Core.IO;
using Cake.Testing;
using Cake.XdtTransform.Tests.Properties;

namespace Cake.XdtTransform.Tests.Fixtures {
    internal sealed class XdtTransformationFixture {
        public IFileSystem FileSystem { get; set; }
        public FilePath SourceFile { get; set; }
        public FilePath TransformFile { get; set; }
        public FilePath TargetFile { get; set; }

        public XdtTransformationFixture(bool sourceFileExists = true, bool transformFileExists = true, bool targetFileExists = false) {
            var environment = FakeEnvironment.CreateUnixEnvironment();
            var fileSystem = new FakeFileSystem(environment);
            fileSystem.CreateDirectory("/Working");

            if (sourceFileExists) {
                var sourceFile = fileSystem.CreateFile("/Working/web.config").SetContent(Resources.XdtTransformation_SourceFile);
                SourceFile = sourceFile.Path;
            }

            if (transformFileExists) {
                var transformFile = fileSystem.CreateFile("/Working/web.release.config").SetContent(Resources.XdtTramsformation_TransformFile);
                TransformFile = transformFile.Path;
            }

            if (targetFileExists) {
                var targetFile = fileSystem.CreateFile("/Working/transformed.config").SetContent(Resources.XdtTransformation_TargetFile);
                TargetFile = targetFile.Path;
            }
            else {
                TargetFile = "/Working/transformed.config";
            }

            FileSystem = fileSystem;
        }

        public void TransformConfig() {
            XdtTransformation.TransformConfig(FileSystem, SourceFile, TransformFile, TargetFile);
        }
    }
}

```

Now we can get back to writing our unit tests. In our XdtTransformationTests class we need to test that we generate the correct errors when passing invalid data and we need to make sure that the XDT transformation correctly works. Lets go ahead and stub out all of these methods.

```

using System;
using System.IO;
using System.Text;
using Cake.Core.IO;
using Cake.XdtTransform.Tests.Fixtures;
using Should;
using Should.Core.Assertions;

namespace Cake.XdtTransform.Tests {
    public sealed class XdtTransformationTests {
        public void ShouldErrorIfSourceFileIsNull() {
           
        }

        public void ShouldErrorIfTransformFileIsNull() {
           
        }

        public void ShouldErrorIfTargetFileIsNull() {
            
        }

        public void ShouldErrorIfSourceFileNotExists() {
           
        }

        public void ShouldErrorIfTransformFileNotExists() {
           
        }

        public void ShouldTransformFile() {
           
        }
    }
}


```

### Checking for null arguments

With these method stubbed out, I am going to use a short hand in all the code examples with just the method name. The first three methods are going to look very similar.

```

public void ShouldErrorIfSourceFileIsNull() {
    // Given
    var fixture = new XdtTransformationFixture {SourceFile = null};

    // When
    var result = Record.Exception(() => fixture.TransformConfig());

    // Then
    result.ShouldBeType<ArgumentNullException>().ParamName.ShouldEqual("sourceFile");
}

```

So we configure our fixture and set it up so the source file is null. We then record the result and assert our expectation. In this case we expect that the *sourceFile* parameter will throw an ArgumentNullException.

The next few tests look almost identical.

```

public void ShouldErrorIfTransformFileIsNull() {
    // Given
    var fixture = new XdtTransformationFixture {TransformFile = null};

    // When
    var result = Record.Exception(() => fixture.TransformConfig());
 
    // Then
    result.ShouldBeType<ArgumentNullException>().ParamName.ShouldEqual("transformFile");
}

public void ShouldErrorIfTargetFileIsNull() {
    // Given
    var fixture = new XdtTransformationFixture {TargetFile = null};

    // When
    var result = Record.Exception(() => fixture.TransformConfig());

    // Then
    result.ShouldBeType<ArgumentNullException>().ParamName.ShouldEqual("targetFile");
}

```

### Checking if file exists

We are now going to unit test if the file exist and if it doesn't, make sure we are throwing our FileNotFoundException.

```

public void ShouldErrorIfSourceFileNotExists() {
    // Given
    var fixture = new XdtTransformationFixture(sourceFileExists: false) {
        SourceFile = "/Working/non-existing.config"
    };

    // When
    var result = Record.Exception(() => fixture.TransformConfig());

    // Then
    result.ShouldBeType<FileNotFoundException>().Message.ShouldContain("Unable to find the specified file.");
}

public void ShouldErrorIfTransformFileNotExists() {
    // Given
    var fixture = new XdtTransformationFixture(transformFileExists: false) {
        TransformFile = "/Working/non-existing-transform.config"
    };

    // When
    var result = Record.Exception(() => fixture.TransformConfig());

    // Then
    result.ShouldBeType<FileNotFoundException>().Message.ShouldContain("Unable to find the specified file.");
}

```

This doesn't look too different, other than the initial setup of the fixture. We are telling the fixture that the file does not need to exist and we are creating an invalid file path. Finally we record and assert the exception occurs.

### Checking the transform method

We are finally ready to test the method.

```

public void ShouldTransformFile() {
    // Given
    var fixture = new XdtTransformationFixture {
        TargetFile = "/Working/transformed.config"
    };

    // When
    fixture.TransformConfig();

    // Then
    var transformedFile = fixture.FileSystem.GetFile(fixture.TargetFile);
    transformedFile.Exists.ShouldEqual(true);
    string transformedString;
    using (var transformedStream = transformedFile.OpenRead()) {
        using (var streamReader = new StreamReader(transformedStream, Encoding.UTF8)) {
            transformedString = streamReader.ReadToEnd();
        }
    }
    transformedString.ShouldContain("<add key=\"transformed\" value=\"false\"/>");
}

```

We configure the fixture with the name of our target file. We run the transfom and then we grab the generated file from the fake file system, make sure it exists, then we see if it contains the transformed setting.

# The finish line

Now that we have unit tests, they are not of much use if we don't run them. So please refer to my previous [post](http://www.phillipsj.net/2016/07/24/Cake-Automating-an-existing-project/) about automating an existing project. Go to step 5 to see how to add Fixie and the task your your Cake file.

Thanks for reading. 
