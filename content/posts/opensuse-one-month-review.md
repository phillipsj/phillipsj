---
title: "openSUSE One Month Review"
date: 2021-01-23T12:17:41-05:00
tags:
- Open Source
- Linux
- openSUSE
- openSUSE Leap
- openSUSE Tumbleweed
---

I started my [openSUSE for a month](https://www.phillipsj.net/posts/opensuse-for-a-month/) 34 days ago. I started with one system running openSUSE Tumbleweed, and now I have three systems running openSUSE, two running Tumbleweed, and one running Leap. I guess at this point, you have realized I am hooked. openSUSE has been a surprisingly good distribution regardless if choosing Leap or Tumbleweed. I haven't had one single issue occur this entire time. Some items have required some additional configuration compared to Ubuntu, but not many more compared to Fedora. Let me break down my experiences so others can get an idea of the different areas I think are notable. Tumbleweed has easily been the best rolling distro experience that I have ever experienced. 

### Software Availability

There isn't any software that I feel is missing, and I think the opposite about it. It seems that most things are in the repositories, and if it's not there, OBS has it. Flatpak, Snap, and AppImage all work just fine. I have used both Docker and podman, depending on which one you like using for containers. I will say that most enterprise style software is available, but some commercial software has a focus on Ubuntu, who can blame them, ad don't ship RPMs for me to have tried. That has been exceptionally rare. KDE, Gnome, and Xfce are officially supported, and many others are installable.

Now I don't use YaST all that much, but it has been a nice piece of system management software to have when troubleshooting firewall rules, group management, etc. It does a great job of surfacing some of the basic configurations that ship out of the box. I feel other distros sometimes leave me recreating things because I don't know what exists or how it is configured.

Finally, I will say that *zypper* does seem a touch slower than other package managers. I don't notice it most of the time, so that it may be perceived. I will add a note that [snapper](https://en.opensuse.org/openSUSE:Snapper_Tutorial) is installed and configured by default. Anytime you run a package management command, a snapshot is taken of your system.

### Btrfs and Filesystem

Fedora has recently joined the [Btrfs](https://btrfs.wiki.kernel.org/index.php/Main_Page) club, which openSUSE has been using for years. I did the default installation, which put everything on the same partition. I could have separated my home directory into a different partition using XFS, but I wanted to give the defaults a try. I haven't had one single issue with Btrfs running on either a SATA SSD or an NVMe drive. The cool feature that I previously mentioned is the ability to take snapshots. That is the primary mechanism in use by Tumbleweed. Every update moves to a new snapshot. If you run into an issue, you can revert to the previous snapshot. I plan to dive into more features of Btrfs as I get time as I want to learn how to make the best use of it.

Now I know Ubuntu is shipping ZFS, and I know most consider ZFS to be the better option. The big thing for me is that Btfs ships with the Linux kernel, which means no custom kernels or kernel modules need to be used. That is an essential feature for me and one that I don't quickly dismiss.

### Hardware Support

I have it installed on an Asus Zenbook, Lenovo Thinkpad x260, and a custom desktop. The two laptops are older and all Intel-based. Both Leap and Tumbleweed supported all the features on both laptops. My function keys work, wifi works, Bluetooth works, and so do external displays. The Thinkpad is running Leap, a 5.3 kernel, and I can say that it works perfectly. The custom desktop runs a Ryzen 5 3600, AMD B550 chipset, NVMe Gen 3, and an AMD 5500XT. I have had to run Tumbleweed on it for the newer kernel version, and I already knew that Ubuntu 20.04 didn't work well on it, so I knew Leap wouldn't either.

The only initial issue that I had with it was the built-in NIC card, and the official driver support wouldn't be in the Linux kernel 5.10, which was recently released. Once 5.10 was released, my internal NIC started working. Now what you will notice is that I don't have an NVidia graphics card in any of my machines, and that is by design. I have started to shy away from NVidia because it requires a kernel module to work. This removes a whole layer of trouble. Being all AMD does pose some issues needing to be on the newest kernel to get support or wait if you buy something too new. I consider all of that in my choices when building my desktop. So there is that limitation. It does apply uniform across most Linux distros.

### Community

Now I have heard reports that the community is maybe not as friendly as others. I have had only positive experiences with the community. It is smaller than other distros, yet it is very welcoming and friendly. I feel like I can get plugged in and involved much more manageable than some of these larger communities. 

## Conclusion

I decided to start using it because of CoderRadio and LinuxUnplugged. Lots of discussion about it and the number of people that had provided feedback was pretty cool. This made me curious to give it a try again, and I am glad that I did. It has all the features I could want or need. Now I have had years of Linux experience, so newer Linux users may not prefer my preferences and characteristics that I appreciate. I am not going to say that it isn't user friendly. There is just a lot of information surfaced by the installer and YaST that may be overwhelming.

Thanks for reading,

Jamie
