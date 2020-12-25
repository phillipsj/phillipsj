---
title: "Steam on openSUSE Tumbleweed"
date: 2020-12-25T12:00:07-05:00
tags:
- Open Source
- Linux
- openSUSE
- openSUSE Tumbleweed
---

I have heard a lot about [Hotshot Racing](https://store.steampowered.com/app/609920/Hotshot_Racing/) on the [Ubuntu Podcast](https://ubuntupodcast.org/), so I wanted to check it out. I had recently installed [openSUSE Tumbleweed](https://www.phillipsj.net/posts/opensuse-tumbleweed-initial-thoughts/) on my desktop, and I was curious if setting up Steam would be challenging or not on it. I immediately decided to check the repositories by searching using zypper.

```Bash
$ sudo zypper search steam
S  | Name                        | Summary                                                     | Type
---+-----------------------------+-------------------------------------------------------------+--------
   | bitlbee-steam               | Steam protocol plugin for BitlBee                           | package
   | ca-certificates-steamtricks | Provides /etc/ssl/certs/ca-certificates.crt                 | package
   | libopenssl1_0_0-steam       | Secure Sockets and Transport Layer Security for steam       | package
   | libopenssl1_0_0-steam-32bit | Secure Sockets and Transport Layer Security for steam       | package
   | libpurple-plugin-libsteam   | Steam plugin for libpurple                                  | package
   | pidgin-plugin-libsteam      | Steam plugin for Pidgin                                     | package
   | steam                       | Installer for Valve's digital software distribution service | package
   | steam-devices               | Device support for Steam-related hardware                   | package
   | steamcmd                    | Command-line version of the Steam client                    | package
   | steamtricks                 | Workarounds for problems with Steam on Linux                | package
   | steamtricks-data            | Steamtricks companion data repository                       | package
```

I wasn't too surprised that it was available and there are also some packages for devices and tricks. These two packages get installed when you install Steam. Now that I know it exists, I just ran the install command in zypper.

```Bash
$ sudo zypper install steam
```

Once that was complete, I launched Steam and logged in. Everything was working as expected. I did need to enable Steam Play for other titles in the advanced section of Steam Play in the settings. That allows Proton for titles that are verified to work with Proton. I then picked the latest stable version of Proton. After that, I installed Hotshot Racing, which uses Proton, with everything working without a hiccup. I plugged in my Logitech F310 gamepad, which Steam detected, and I could use it to play the game. 

Overall, I would say the experience was seamless. Everything just worked and worked no differently than it does on other Linux distros that I have installed Steam. I didn't know what to expect with openSUSE, and I can say that I am glad. We have a ton of great distros that everything works. If you are running Leap, the Steam package exists there too, so I would expect it to be no different.

Thanks for reading,

Jamie
