---
title: "Raspberry Pi 400 Initial Impressions"
date: 2021-01-28T20:18:02-05:00
tags:
- Linux
- Open Source
- Raspberry Pi
---

My Raspberry Pi 400 finally arrived. After being on backorder, I canceled and reordered with [CanaKit](https://www.canakit.com/), and it came less than a week later. I highly recommend CanaKit as they have been solid when ordering compared to a lot of places. Where do I start? Here it is.

![Image of Raspberry Pi 400 Kit](/images/other-posts/pi400.jpg)

## Packaging and Presentation

The packaging was fantastic and reminded me a lot of Apple. Many brands are following the Apple approach to packaging. As soon as I opened the box, I was greeted by the Pi 400. Underneath that were the boxes containing the power supply and the mouse. There is also an HDMI cable and SD card with [Raspberry Pi OS](https://www.raspberrypi.org/software/). The composite material used for the keyboard and accessories feels well made. The mouse is excellent, in my opinion, and I enjoy using it. The smaller size of the keyboard is a little tough to get used to, and it too has a nice feel to the keys. Compared to the Pinebook Pro, the keyboard is much nicer, and I haven't missed any keystrokes with it.

## Operating System

I started with openSUSE Tumbleweed KDE edition made for the Raspberry Pi 4, which includes the 400, without much success. Everything booted fine, and I was dropped into a shell. I was able to log in at the shell, and I had to start X to get KDE started. Once KDE started up, the system was responsive and ran with 600MB of RAM, much like the Pinebook Pro. I did run into two more issues. The second issue was that the desktop was only running at 1920x1080 resolution instead of my monitor's native resolution, which is 3440x1440. The final issue was that the wifi didn't work. At this point, I decided that I would pivot. Luckily, I put that on a different SD card from the one that came with the kit.

At this point, I put back in the SD card that came with the kit and booted up Raspberry Pi OS. The wizard walks you through the keyboard, time zone, and language setup. Next was the wifi setup. It prompted me about seeing black borders on my monitor, which I acknowledged, and the last step was to update the system. After a quick reboot, I was back at the desktop running at 3440x1440. The system was idling at roughly 160MB of RAM. The wifi connected, and samba was able to find my NAS without any additional effort. I will say that Raspberry Pi OS is snappy. I didn't feel any hesitation or lag when using it. I plan to stick with Raspberry Pi OS until openSUSE gets a few more things ironed out.

## Performance Testing

I did this [post](https://www.phillipsj.net/posts/pinebook-pro-hugo-performance-compared/) a couple of weeks ago comparing the Pinebook Pro to my other machines. I made the comparison by building my blog with Hugo. I installed git and Hugo, then cloned the same commit to the 400. A quick Hugo build later, and here is the result with the others to compare.

Name           | CPU            | Cores/Threads | Total Time |
---------------|----------------|---------------|------------|
Custom Desktop | Ryzen 5 3600   | 6/12          | 727ms      |
Thinkpad x260  | Intel i5-6200U | 2/4           | 2426ms     |
Asus Zenbook   | Intel M-5Y10c  | 2/4           | 3054ms     |
Raspberry Pi   | BCM2711        | 4/0           | 3775ms     |
Pinebook Pro   | RK3399         | 6/0           | 4892ms     |

The Pi 400 is about a second faster building my blog than the Pinebook Pro and not too far off from my Zenbook. I plan to dive into some more of these comparisons as I find them interesting.

## Conclusion

I don't regret the purchase at all. I am looking forward to doing some of the activities in the book that came with the kit. I have wanted to get more into the hardware side of software, which may be the push that I need.

Thanks for reading,

Jamie
