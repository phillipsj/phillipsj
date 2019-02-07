---
Title: "Installing Azure Storage Explorer on Linux"
Published: 09/24/2018 16:19:29
Tags: 
- Azure
- Linux
- Microsoft And Linux
- Open Source
- Tools
---
# Installing Azure Storage Explorer on Linux

You can download the Linux version of [Azure Storage Explorer](https://azure.microsoft.com/en-us/features/storage-explorer/) from [here](https://go.microsoft.com/fwlink/?LinkId=722418&clcid=0x409).

```Bash
$ sudo apt install build-essential libsecret-1-0 libgconf-2-4
```
After these are installed, you will need to make sure that you .NET Core 2.x installed on your system. Links here.

After that, let's untar Storage Explorer.

```Bash
$ mkdir StorageExplorer
$ mv StorageExplorer-linux-x64.tar.gz StorageExplorer
$ cd StorageExplorer
$ tar -xvf StorageExplorer-linux-x64.tar.gz StorageExplorer
```

With it unpackaged, it should just run. Let's start it from the commandline.

```Bash
$ ./StorageExplorer
```

Now that we know it runs without issue, let's move it into a more permanent location and get some shortcuts created.

```Bash
$ rm StorageExplorer-linux-x64.tar.gz
$ cd ..
$ sudo mv StorageExplorer/ /opt
```

I am running Linux Mint 19 Xfce Edition, so I am going to create a launcher on my Xfce panel. Here is the screenshot of the settings I used for the launcher.

![](/images/other-posts/LauncherSettings.png)

I then selected the icon located in the StorageExplorer folder to be the icon for my Launcher.

![](/images/other-posts/LauncherIcon.png)

Now here is the final result on the panel.

![](/images/other-posts/LauncherOnPanel.png)

Hope someone else finds this helpful. Thanks for reading.