---
Title: "Using OneDrive with Linux"
Published: 10/26/2018 22:09:22
Tags: 
- Open Source
- Microsoft And Linux
- Tools
- Ubuntu
- Rclone
- OneDrive
---
# Using OneDrive with Linux

I am a big user of [OneDrive](https://onedrive.live.com/about/), primarily because of the amount of storage for the price. In the past I have used [Google Drive](https://www.google.com/drive/), then I started using [DropBox](https://www.dropbox.com/) more. However, I have determined that OneDrive is the best solution for my needs. One big issue with many of these storage options is that DropBox is the only one with a native Linux client which is really unfortunate. That leaves me with using a non-official solution or switching to back to DropBox or just setting up my own [NextCloud](https://nextcloud.com/). Neither of those last two options are appealing to me right now, so let's see what options we have.

After doing some research there are primarilyy two options that have emerged as the best choices, in my opinion. Those solutions would be [Rclone](https://rclone.org/) and [OneDrive Free Client](https://github.com/skilion/onedrive). The biggest difference between the two would be the automatic sync that is provided by OneDrive Free Client and the fact that you will need to compile OneDrive Free Client yourself. Let's dive in and see how to install and configure both clients. I will be primarily using Ubuntu 18.x for this discussion, however, there are instructions for other distros on the websites.

## OneDrive Free Client

OneDrive Free Client is pretty cool and provides all the functionality that I could want, it works equally well with OneDrive and OneDrive for Business, with the latter being my primary experience.

### Installation

The first step is that you will need to install all the necessary packages for building the software, so let's get that all installed. We will be following the instructions on the GitHub page with one exception, make sure you install *build-essential* so you have *make* available.

```Bash
$ sudo apt install buiild-essential libcurl4-openssl-dev libsqlite3-dev
$ sudo snap install --classic dmd && sudo snap install --classic dub
```

Once those are are finished installing now we can clone the repo from GitHub and compile the application.

```Bash
$ git clone https://github.com/skilion/onedrive.git
$ cd onedrive
$ make
```

That should have executed successfully, now we just need to install the application using another *make* command.

```Bash
$ sudo make install
```

Once that finishes, which should be quickly, you now have the OneDrive Free Client installed and ready to be executed.

### Setup

The GitHub page doesn't explicitly cover executing the application for the first time. The application after the installation was installed in */usr/local/bin* as onedrive. This should be on your path so we just need to run the application.

```Bash
$ onedrive
Authorize this app visiting:

A really big URL.

Enter the response uri:
```

What this is doing is providing you a URL that you paste into your browser that will prompt a login into OneDrive and then ask for you to grant permission for the OneDrive Free client to access your OneDrive. You will be redirected if you give it the permission to a blank page. You will need to copy that URL and paste it back into terminal as the response URI.

Once that is finished you now have the OneDrive Free client functioning with your OneDrive. This will create a OneDrive directory in your home directory that will be used to sync your files. Unfortunately, this is still a manual process at this point and what we really want is for it to be automagic like it is on Windows.

### Automatic Syncing

The creator of this client knew that doing it manually would be a turn off, so they created a systemd service that you can install to make it a system service that will automatically start with the OS and keep your files synced.

To install the systemd service you can just follow what is in the GitHub page.

```Bash
systemctl --user enable onedrive
systemctl --user start onedrive
```

Now we can make sure it is up and running using the following command.

```Bash
journalctl --user-unit onedrive -f
-- Logs begin at Fri 2018-10-26 12:24:49 UTC. --
Oct 27 00:20:10 odc systemd[1374]: Started OneDrive Free Client.
```

That's it for getting up and running with the OneDrive Free client. There is plenty of configuration options and the ability to sync multiple OneDrive accounts, etc. All of that can be found on the GitHub page. I personally only used the automatic sync with a simple setup which mimics how I use it with Windows.

## Rclone

Rclone is an interesting project as it provides integrations for 30+ cloud storage providers. The beauty of that is not having to install multiple tools if you need to do work with other cloud storage. This is appealing to me since I do development against Azure and AWS. This means that I can use one tool for OneDrive, Azure, and AWS which decreases the cognitive load of having to know multiple tools.

### Installation

Rclone packages their client as a binary and you can either download it from [here](https://rclone.org/downloads/) for your system or you can use this handy script that they created. As always, before running random scripts on your system, pull them down and read them first.

```Bash
$ curl https://rclone.org/install.sh | sudo bash
rclone v1.44 has successfully installed.
Now run "rclone config" for setup. Check https://rclone.org/docs/ for more details.
```

Now that it is finished that is a nice touch for them to tell you the next command to run. So let's run it.

### Configuration

Just like what the results on the installation tells us we are going to run *rclone config*.

```Bash
$ rclone config
```

This will prompt us to enter what we want to do, we want to enter **n** here as that will setup a new remote.

```Bash
No remotes found - make a new one
n) New remote
s) Set configuration password
q) Quit config
n/s/q> n
```

Now it will prompt you for a name, I am going to call mine **onedrive**.

```Bash
name> onedrive
```

Now it is going to ask you what kind of storage you are configuring for the new remote. We are going to enter **18** for OneDrive.

```Bash
18 / Microsoft OneDrive
   \ "onedrive"
storage> 18
```

New it is going to prompt for **client_id** just hit enter and go with the default.

```Bash
Microsoft App Client Id
Leave blank normally.
Enter a string value. Press Enter for the default ("").
client_id> 
```

Again leave the **client_secret** blank.

```Bash
Microsoft App Client Secret
Leave blank normally.
Enter a string value. Press Enter for the default ("").
client_secret>
```

Now it is going to ask to do an advanced config, I would encourage you don't do this initially. I answer **n**.

```Bash
Edit advanced config? (y/n)
y) Yes
n) No
y/n> n
```

Now we need to use how we want to configure, I am going to use the *auto* config. This will launch your browser and have you sign into your OneDrive account, once you do that you will be asked to grant the application permissions that are listed in the browser, if you accept, it will then close itself and finish doing the configuration.

```Bash
Remote config
Use auto config?
 * Say Y if not sure
 * Say N if you are working on a remote or headless machine
y) Yes
n) No
y/n> y
```

Now it will ask you what type of account it is that you just logged into, choose **1** for OneDrive.

```Bash
Choose a number from below, or type in an existing value
 1 / OneDrive Personal or Business
   \ "onedrive"
 2 / Root Sharepoint site
   \ "sharepoint"
 3 / Type in driveID
   \ "driveid"
 4 / Type in SiteID
   \ "siteid"
 5 / Search a Sharepoint site
   \ "search"
Your choice> 1
```

A list of drives will be returned that you can access. I only have one and that is why I only see one below. Enter the drive that you want to use.

```Bash
Found 1 drives, please select the one you want to use:
0:  (personal) id=xxxxxxxxxxxxx
Choose drive to use:> 0
```

Confirm that it is indeed the drive you wanted by answering yes.

```Bash
Found drive 'root' of type 'personal', URL: https://onedrive.live.com/?cid=xxxxxxxxxxxxx
Is that okay?
y) Yes
n) No
y/n> y
```

Next to last step is to confirm that you are OK with all the information that is printed out to the terminal.

```Bash
drive_type = personal
--------------------
y) Yes this is OK
e) Edit this remote
d) Delete this remote
y/e/d> y
```

Finally the last step, it tells you that you have configured a remote and asks if you want to continue, I do not not, so I am going to enter **q**.

```Bash
Current remotes:

Name                 Type
====                 ====
onedrive             onedrive

e) Edit existing remote
n) New remote
d) Delete remote
r) Rename remote
c) Copy remote
s) Set configuration password
q) Quit config
e/n/d/r/c/s/q> q
```

Now that we have a remote successfully installed, we need to start syncing our files.

### Using

Here are some basic commands for working with Rclone.

List Directories in your OneDrive.

```Bash
$ rclone lsd onedrive:
```

List files in your OneDrive.

```Bash
$ rclone ls onedrive:
```

List files in a directory on OneDrive.

```Bash
$ rclone ls onedrive:Blog
```

Copying a directory to OneDrive.

```Bash
$ rclone copy /home/blog onedrive:blog
```

You can also run commands and like mount and sync. Mount is the interesting one as it will mount the onedrive to your filesystem and you can work with it like it is a local directory.

```Bash
$ rclone mount onedrive:/ /media/onedrive
```

### Automated Mounting

Syncing with Rclone isn't as smooth as OneDrive Free client the the project generally suggests doing it by hand. For my typical use case, I feel that mounting it like a drive works for me and I don't mind pushing the file up automatically when I save it or having to pull it down when I need to work with it.

First create a directory to mount to, I am going to create a *onedrive* directory in my home directory to mount. Make sure to get the entire directory path by typing *pwd*. We will need that in the next step.

```Bash
$ mkdir onedrive
$ pwd
/home/phillipsj/onedrive
```

With that out the way we are going to create a *systemd* based service that will mount our OneDrive on system startup. We will need the following information before we get started.

* The mounting location, see above for how to get that.
* The location of your config file, should be in ~/.config/rclone/rclone.conf
* Read about the [mount settings](https://rclone.org/commands/rclone_mount/) and know what tweaks you want to make.

Open your favorite editor and start typing.

```Bash
# /etc/systemd/system/onedrive.service
[Unit]
Description=OneDrive (rclone)
AssertPathIsDirectory=/home/phillipsj/onedrive
After=network-online.target
 
[Service]
Type=simple
User=phillipsj
ExecStart=/usr/bin/rclone mount \
        --config=/home/phillipsj/.config/rclone/rclone.conf \
        --cache-writes \
        --no-modtime \
        --stats=0 \
        --bwlimit=40M \
        --dir-cache-time=60m \
        --cache-info-age=60m onedrive:/ /home/phillipsj/onedrive
ExecStop=/bin/fusermount -u /home/phillipsj/onedrive
Restart=always
RestartSec=10
 
[Install]
WantedBy=default.target
```

Now save that to */etc/systemd/system/onedrive.service*, which will create the *onedrive.service* file. This was all inspired from reading this [gist](https://github.com/ajkis/scripts/blob/master/rclone/rclone-mount.service) and this [forum](https://forum.rclone.org/t/rclone-mount-on-startup-with-systemd/360/8) post.

Now all that left is to start the service and enable it.

```Bash
$ systemctl start onedrive
$ systemctl enable onedrive
```

Now you can navigate into the directory and see your OneDrive files.

```Bash
$ cd ~/onedrive
$ ls
Blog
```

## Conclusion

That's all folks, regardless of which method you decided to use you should have a working OneDrive on your Ubuntu, or any other Linux, installation. I hope others have found this help and stay tuned to a follow up post about how we can use Rclone to do some other really good things with the **CLOUD**.

Thanks for reading,

Jamie
