---
Title: "Cake: More SFTP"
date: 2017-03-01T21:59:22
Tags: 
---
# Cake: More SFTP

I am back with more about SFTP usage from a Cake file. I have probably made this more difficult that needed, but I finally got a solution that I am happy with using. This solution involves using [WinSCP](https://winscp.net/eng/index.php) and the project's .NET wrapper.

## 1. Add the NuGet package and import the dll.

It's worth mentioning here that this is the only method in which this will work. The dll is not included in the correct NuGet folder since it isn't placed into the *net45* folder. This is also true for the SharpSSH package too.

```
#tool nuget:?package=WinSCP
#reference "tools/WinSCP/lib/WinSCPnet.dll"
using WinSCP;
```

## 2. The Cake Task

Much of this code has been taken straight from the example.  The one thing that I had to do was reference the WinSCP.exe directly by telling the session the location of the executable. This may not be necessary for everyone.

```
Task("SFTP")
    .Does(() => {
        Information("Starting FTP upload...");
        // Setup session options
        var sessionOptions = new SessionOptions {
                Protocol = Protocol.Sftp,
                HostName = ftpUri,
                UserName = ftpUserName,
                Password = ftpPassword,
                SshHostKeyFingerprint = ftpFingerprint
            };

         using (Session session = new Session()) {
                // Setting executable Path
                var winScpExe = File("./tools/WinSCP/content/WinSCP.exe");
                session.ExecutablePath = winScpExe.Path.FullPath;
                // Connect
                session.Open(sessionOptions);
 
                // Upload files
                TransferOptions transferOptions = new TransferOptions();
                transferOptions.TransferMode = TransferMode.Binary;
 
                TransferOperationResult transferResult;
                transferResult = session.PutFiles(exportFile, "/home/", false, transferOptions);
 
                // Throw on any error
                transferResult.Check();
 
                // Print results
                foreach (TransferEventArgs transfer in transferResult.Transfers) {
                    Information("Upload of {0} succeeded", transfer.FileName);
                }
          }
});
```

Thanks for reading and I hope someone else finds this useful too.

Jamie
