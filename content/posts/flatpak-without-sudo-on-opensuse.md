---
title: "Flatpak Without sudo on openSUSE"
date: 2021-01-05T20:05:43-05:00
tags:
- Open Source
- Linux
- openSUSE
- openSUSE Leap
- openSUSE Tumbleweed
- Flatpak
---

I have been using Flatpak for the last few years. I have used it on numerous distros in that time, and openSUSE is the first time I ran into any quirks. It seems that on openSUSE, without an additional configuration, you have executed Flatpak commands with admin privileges. Searching didn't turn up anything, so I opened YaST to check if a group was created for Flatpak that I wasn't assigned. In YaST, that would be *Security and Users --> User and Group Management*.

![Image of YaST Security and Users section](/images/opensuse-flatpak/yast-user-groups.png)

Once you open *User and Group Management*, you will see several tabs, click on the *Groups* tab, and see all the groups on your box. Notice that flatpak group.

![Image of User and Group Management Groups Tab](/images/opensuse-flatpak/flatpak-group.png)

Go back to the *User* tab and click your user account. Then press the *Edit* button to open the editing screen.

![Image of User and Group Management Users Tab](/images/opensuse-flatpak/edit-user.png)

Once there, click on the *Details* tab and check the box next to the flatpak group to enable it.

![Image of Edit User Details Tab](/images/opensuse-flatpak/add-flatpak-group-user.png)

After enabling the flatpak group, click on *Ok* to save the changes. You will now be back on the *Users* tab, and you should see the flatpak group listed in your groups column.

![Image of User and Group Management Users Tab with updated groups](/images/opensuse-flatpak/group-added.png)

With that simple change, you can now run Flatpak commands without needing to use *sudo*.

Thanks for reading,

Jamie
