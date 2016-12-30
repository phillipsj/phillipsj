---
Title: 'Cake: Creating your first addin'
Published: 2016-07-31 15:22:46
Tags:
- Open Source
- Cake
- Tutorials
RedirectFrom: 2016/07/31/Cake-Creating-your-first-addin/index.html
---


In this tutorial, I will be walking you through the basics of creating a Cake Addin. There are going to be assumptions that you know how to create a project using Visual Studio or your tool of choice. It also assumes you know how to use NuGet to install packages in your project.  Let's get started, we are going to create a really simple addin that gives you the ability to upload a file to an FTP site.

## Step 1: Setup

Create a new *class library* project in Visual Studio named *Cake.Ftp* and delete the Class1.cs file that is automatically created. Your library doesn't have to follow this naming convention, but this is the community standard that is the most prevalent. The first item you will need is the *Cake.Core* Nuget package, so please install that into your *Cake.Ftp* project. Now that is handled you are going to need to create two files. One of those files will be the primary file that holds your logic and the other file will be your Cake aliases.

### An important note:

Cake aliases are convenience methods that make your functionality available from your Cake file. Without the alias, the convenience of just calling your method in the Cake file will not be there and you will have to perform other steps. So remember to always create aliases for your addins. To read more about aliases see the documentation [here](http://cakebuild.net/docs/fundamentals/aliases).

The first file that needs created is *FtpClient.cs*, this will house the primary logic of our FTP addin. After that file has been created go ahead and create the *FtpAliases.cs* class which will house our aliases.

## Step 2: Code

Now lets start building our our *FtpClient*. We are just going to have the basic functionality of uploading a file to an FTP server to start.  So lets create our constructor.

```
namespace Cake.Ftp {
    public class FtpClient {
        public FtpClient() {}
    }
}
```

That looks pretty standard and doesn't appear to be anything new that you wouldn't expect. To upload a file we are going to need access to the file system, we need to know about the Cake environment, and I would like to perform some logging. Luckily, Cake provides some interfaces for use that provide us with access to these environments. Additionally, this will allow for unit testing if we so choose. Cake uses one of my favorite dependency injection frameworks, [Autofac](https://autofac.org/) for dependency injection, so all you need to do is put these in your constructor and Cake handles the rest.  

```

using System;
using Cake.Core;
using Cake.Core.Diagnostics;
using Cake.Core.IO;

namespace Cake.Ftp {
    public class FtpClient {
        private readonly IFileSystem _fileSystem;
        private readonly ICakeEnvironment _environment;
        private readonly ICakeLog _log;
        private readonly StringComparison _comparison;

        public FtpClient(IFileSystem fileSystem, ICakeEnvironment environment, ICakeLog log) {
            if (fileSystem == null) {
                throw new ArgumentNullException(nameof(fileSystem));
            }
            if (environment == null) {
                throw new ArgumentNullException(nameof(environment));
            }
            if (log == null) {
                throw new ArgumentNullException(nameof(log));
            }

            _fileSystem = fileSystem;
            _environment = environment;
            _log = log;
            _comparison = environment.Platform.IsUnix() ? StringComparison.Ordinal : StringComparison.OrdinalIgnoreCase;
        }
    }
}

```

Of course as you see above it is a good practice that if any of these items that you need to create your class are not available to throw an error. You may have noticed by now that we have a *StringComparison* class being created in the constructor, the purpose of this is to make sure we compare strings correctly regardless of operating system.

Now with all the basic stuff out of the way lets start creating our file upload method. We are going to create our initial definition for our method. We need the FTP location, the file that we need to upload, the username, and the password we want to use. Then we are going to make sure that none of our required parameters are null, finally we check to make sure that we are actually passed an FTP URI.

```

public void UploadFile(Uri serverUri, FilePath fileToUpload, string username, string password) {
    if (serverUri == null) {
        throw new ArgumentNullException(nameof(serverUri), "Server URI is null.");
    }
    if (fileToUpload == null) {
        throw new ArgumentNullException(nameof(fileToUpload), "File to upload is null.");
    }
    if (string.IsNullOrWhiteSpace(username)) {
        throw new ArgumentNullException(nameof(username), "Username is null.");
    }
    if (string.IsNullOrWhiteSpace(password)) {
        throw new ArgumentNullException(nameof(password), "Password is null.");
    }
    if (serverUri.Scheme != Uri.UriSchemeFtp) {
        throw new ArgumentOutOfRangeException("Server URI scheme is not FTP.");
    }
}

```


With all the plumbing out of the way, we are going to create our FTP Request, create our credentials, grab our file, and upload it. While we are doing that we are going to add some verbose logging and some informational logging to help debug if there are any issues. 

```

using System;
using System.IO;
using System.Net;
using System.Text;
using Cake.Core;
using Cake.Core.Diagnostics;
using Cake.Core.IO;

// Constructor and namespace.

 public void UploadFile(Uri serverUri, FilePath fileToUpload, string username, string password) {
     if (serverUri == null) {
         throw new ArgumentNullException(nameof(serverUri), "Server URI is null.");
     }
     if (fileToUpload == null) {
         throw new ArgumentNullException(nameof(fileToUpload), "File to upload is null.");
     }
     if (string.IsNullOrWhiteSpace(username)) {
         throw new ArgumentNullException(nameof(username), "Username is null.");
     }
     if (string.IsNullOrWhiteSpace(password)) {
         throw new ArgumentNullException(nameof(password), "Password is null.");
     }
     if (serverUri.Scheme != Uri.UriSchemeFtp) {
         throw new ArgumentOutOfRangeException("Server URI scheme is not FTP.");
     }

     // Adding verbose logging for the URI being used.
     _log.Verbose("Uploading file to {0}", serverUri);

     // Creating the request
     var request = (FtpWebRequest) WebRequest.Create(serverUri);
     request.Method = WebRequestMethods.Ftp.UploadFile;

     // Adding verbose logging for credentials used.
     _log.Verbose("Using the following credentials {0}, {1}", username, password);
     request.Credentials = new NetworkCredential(username, password);

     // Using the abstracted filesystem to get the file.
     var uploadFile = _fileSystem.GetFile(fileToUpload);
           
     using (var streamReader = new StreamReader(uploadFile.OpenRead())){
         // Get the file contents.
         var fileContents = Encoding.UTF8.GetBytes(streamReader.ReadToEnd());
         request.ContentLength = fileContents.Length;

         // Writing the file to the request stream.
         var requestStream = request.GetRequestStream();
         requestStream.Write(fileContents, 0, fileContents.Length);
         requestStream.Close();

         // Getting the response from the FTP server.
         var response = (FtpWebResponse) request.GetResponse();

         // Logging if it completed and the description of the status returned.
         _log.Information("File upload complete, status {0}", response.StatusDescription);
         response.Close();
    }
 }

```

## Step 3: Cake Aliases

Now the only piece that is left is to create your Cake aliases. If your *FtpAliases* file, create the following, static method. The only parameter that you don't use in your *FtpClient* is the ICakeContext and if you notice this just basically an extension method to the Cake context. Make sure to annotate the extension method with the *CakeMethodAlias* attribute so it is make visible in the cake file. I like to add *CakeAliasCategory* attributes, but it isn't necessary.

```

using System;
using Cake.Core;
using Cake.Core.Annotations;
using Cake.Core.IO;

namespace Cake.Ftp {
    [CakeAliasCategory("FTP")]
    public static class FtpAliases {
        [CakeMethodAlias]
        public static void FtpUploadFile(this ICakeContext context, Uri serverUri, FilePath fileToUpload, 
            string username, string password) {
            if (context == null) {
                throw new ArgumentNullException(nameof(context));
            }
            var ftpClient = new FtpClient(context.FileSystem, context.Environment, context.Log);
            ftpClient.UploadFile(serverUri, fileToUpload, username, password);
        }
    }
}

```

At this point, you would be finished creating your first addin, however, a nice touch would be to document your method using XML comments amd provide a code example, another Cake project and community standard. With these added, if your addin is added to the Cake website, the documentation on the site will automagically be available.

```

using System;
using Cake.Core;
using Cake.Core.Annotations;
using Cake.Core.IO;

namespace Cake.Ftp {
    /// <summary>
    /// Contains functionality for working with FTP
    /// </summary>
    [CakeAliasCategory("FTP")]
    public static class FtpAliases {
        /// <summary>
        /// Uploads the file to the FTP server using the supplied credentials.
        /// </summary>
        /// <example>
        /// <code>
        /// Task("UploadFile")
        ///   .Does(() => {
        ///     var fileToUpload = File("some.txt");
        ///     FtpUploadFile("ftp://myserver/random/test.htm", fileToUpload, "some-user", "some-password");
        /// });
        /// </code>
        /// </example>
        /// <param name="context">The context.</param>
        /// <param name="serverUri">FTP URI requring FTP:// scehma.</param>
        /// <param name="fileToUpload">The file to be uploaded.</param>
        /// <param name="username">Username of the FTP account.</param>
        /// <param name="password">Password of the FTP account.</param>
        [CakeMethodAlias]
        public static void FtpUploadFile(this ICakeContext context, Uri serverUri, FilePath fileToUpload, 
            string username, string password) {
            if (context == null) {
                throw new ArgumentNullException(nameof(context));
            }
            var ftpClient = new FtpClient(context.FileSystem, context.Environment, context.Log);
            ftpClient.UploadFile(serverUri, fileToUpload, username, password);
        }
    }
}

```

# The finish line

There you go, a basic tutorial on creating a Cake addin. I hope to publish a follow up tutorial shortly on how to perform unit testing of a Cake addin. If you are finding these useful or have any suggestions or ideas on what I should do next, please let me know on Twitter [@phillipsj73](https://twitter.com/phillipsj73).