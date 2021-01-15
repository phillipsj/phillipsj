---
title: "openSUSE's Firewall and KDE Connect"
date: 2021-01-14T20:33:47-05:00
tags:
- KDE Connect
- KDE
- Open Source
- Linux
- openSUSE
- openSUSE Leap
- openSUSE Tumbleweed
---

I have become a fan of KDE's Plasma desktop and their awesome tool called [KDE Connect](https://kdeconnect.kde.org/). KDE Connect provides integration between the Plasma desktop and your smartphone. You pair your device running the KDE Connect mobile app with all your computers that run KDE Connect. It allows you to share links between browsers, SMS messages, clipboard sharing, control media, remote input, etc. There is a ton of functionality out of the box with plenty of extras that can be installed. The two features I use the most is the link and clipboard sharing, this allows me to send something to my phone when I need to go do something else and when I find a new piece of information, I can share it back to any of my connected computers. 

It isn't installed by default on openSUSE which is an intersting choice and is enough to install.

```Bash
$ sudo zypper install kdeconect-kdeconect
```

This wasn't the point of the post. What I realized after installing it was that it wasn't showing up on my phone as a device that I could pair it with. I immediately figured it must be a firewall settings so I opened up YaST and went to look at the firewall settings.

![Image of YaST Control Center with the Firewall section highlighted.](/images/opensuse-kdeconnect/yast-firewall.png)

I then click on the *home* zone to see what rules were enabled and which ones are available to be added. It was nice to see that preconfigured rules for KDE Connect already existed. If they hadn't existed then those would need to be added and the instructions are [here](https://userbase.kde.org/KDEConnect#I_have_two_devices_running_KDE_Connect_on_the_same_network.2C_but_they_can.27t_see_each_other).

![Image of firewall configuration for home zone.](/images/opensuse-kdeconnect/home-zone-kdeconnect.png)

All that was required was to highlight the *kdeconnect* rules and add them to the *Allowed* list for the *home* zone. Click *Accept* after adding *kdeconnect* and now you should be able to see your device to pair.

![Image of KDE Connect rules added to the firewall for the home zone.](/images/opensuse-kdeconnect/kdeconnect-added-to-zone.png)

That's it! While the official instructions show how to do it with the command line, you would need to figure out which firewall openSUSE is using. YaST makes it really easy to discover that they already exist and to configure it without needing to know the lower level stuff. Even as an experience Linux user, I have found YaST to be super helpful in just discovering features and settings without spending time searching on the command line. 

Thanks for reading,

Jamie
