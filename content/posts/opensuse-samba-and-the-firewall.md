---
title: "openSUSE, Samba, and the Firewall"
date: 2021-01-03T13:34:59-05:00
draft: true
tags:
- Open Source
- Linux
- openSUSE
- openSUSE Leap
- openSUSE Tumbleweed
---

I have been using either openSUSE Leap 15.2 or Tumbleweed for the last couple of weeks. As I continue to learn the system, one item that I need to work is connecting to my NAS. All systems are different, yet most distros have this working out of the box; openSUSE just required a little configuration. After digging around, I realized that the firewall wasn't allowing Samba traffic. 

Let me show you how to configure openSUSE to have it work. 

## Configuring openSUSE for Samba

Let me show you the issue. When I open Dolphin and navigate to Network -> Shared Folders (SMB), I didn't see my NAS listed.

![Image of Dolphin without finding Samba shares](/images/opensuse-samba/no-samba-shares-found.png)

My initial thought was that Samba wasn't installed. In fact, it is installed, so then I decided to ping my NAS, which worked. That left me with checking the firewall with YaST. 

![Image of YaST](/images/opensuse-samba/yast.png)

I noticed in the firewall section had multiple zones defined, so I started checking those zones to see if any included Samba in the allowed. There are a few, but the one that jumps out is called *home*. This connection is my home network, so I figured that would be an excellent zone to leverage.

![Image of firewall settings and zones](/images/opensuse-samba/home-firewall-zone.png)

The next piece was to figure out how to leverage the zone with my network connection. After digging around a little, I noticed that the network connection, under the general configuration tab, had a place to set the firewall zone. 

![Image of network connection settings](/images/opensuse-samba/open-network-settings.png)

I decided to try by setting the firewall zone for the network connection to *home*.

![Image of network connection firewall zone set to home](/images/opensuse-samba/firewall-set-network-settings.png)

A quick application of that change and a jump back to Dolphin was all that was required. I was seeing my NAS show up.

![Image of Dolphin with Samba shares found](/images/opensuse-samba/samba-shares-found.png)

## Conclusion

I want to write that I was initially frustrated by this choice, yet I wasn't. I felt this was adding security to my setup. Having predefined zones and setting those zones per network connection brings more control to my system. So far, the defaults have worked exactly how I expect, so I haven't found the need to make any tweaks.

Thanks for reading,

Jamie
