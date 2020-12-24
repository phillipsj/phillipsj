---
title: "openSUSE Leap Initial Impressions"
date: 2020-12-24T14:35:16-05:00
tags:
- Open Source
- Linux
- openSUSE
- openSUSE Leap
---

I finally got openSUSE Leap installed on my Thinkpad. It is running kernel 5.3.18, which should be sufficient for this 4+-year-old Thinkpad. So far, all the hardware works as expected with no issues. Leap is the non-rolling release that tracks with SUSE Linux Enterprise Linux, SLES, and tends to touch on the older software and favors the LTS versions. Of course, I installed KDE Plasma as my desktop, which is version 5.18, the LTS version. While there a few small differences, the user avatar issue doesn't exist, which is good to know. If there weren't already a bug for it, I would file one as this narrows down the issue's introductions. I again did the default filesystem configuration with Btrfs for my whole system. Performance has been acceptable, and I don't seem to have this odd graphical glitch occurring on Kubuntu 20.10. The issue wasn't consistent but did happen. I may have to see if Tumbleweed on this machine has the same problem. 

Installing codecs was again a breeze. I used the same method of installing *opi* to add packman repos. I also leveraged *opi* to install hugo since it isn't available in the main repositories. Hugo is the newest version, so that was nice to see. Firefox on Leap is the latest ESR version, a tad unfortunate, but not a deal-breaker. All of my Firefox extensions work just fine. I used rustup to install Rust, which went smoothly. I also used the same pattern to get gcc and other dev tools installed.

So far, another uneventful and seamless experience. If I want stability and an extended support cycle, this would be an excellent choice. I have tried snap or flatpak yet, and there is some software that I can't get any other way, so I will probably try out flatpak sooner than later. I am happy with it, and there is nothing to give me pause initially.

Thanks for reading,

Jamie
