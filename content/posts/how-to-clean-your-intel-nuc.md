---
title: "How to Clean Your Intel NUC"
date: 2021-07-04T12:38:37-04:00
tags:
- Intel NUC
- minipc
- Dev Environment
- Homelab
- Gear
---

My new job has me relying a lot more on VMs, and I have had to do a little work on my homelab, so I could support running tools like [Proxmox VE](https://www.proxmox.com/en/proxmox-ve) and [Harvester](https://github.com/harvester/harvester). I have been using most of my Intel NUCs for a few years, and I started noticing that they are noisier now. Given the noise, I decided to take them apart, clean out all the dust, then apply some new thermal paste. I recorded a temperature before I cleaned each one and a temperature post-cleaning. The dust removal and new thermal paste dropped temps on average roughly 7 degrees Celsius. That isn't too shabby, and it decreased the overall fan noise. I decided to take some pictures of me cleaning my Intel NUC 8th Gen i5, model [NUC8i5BEK](https://www.intel.com/content/www/us/en/products/sku/126148/intel-nuc-kit-nuc8i5beh/specifications.html). The process is similar for others. Actually, the main difference is the heatsink fan and cooler. The rest is pretty much identical. If you have any questions about doing it, just reach out, and answer any questions. Here is the before temp.

![screenshot of the temperature before new thermal paste and cleaning](/images/nuc-clean/before-clean-and-paste.png)

Here is the NUC.

![picture of the nuc](/images/nuc-clean/before.jpg)

Turn the NUC upside down.

![nuc upside down showing bottom](/images/nuc-clean/bottom.jpg)

Remove the bottom of the NUC.

![nuc with the bottom removed](/images/nuc-clean/bottom-removed.jpg)

You will need to disconnect all cables and the wifi antenna.

![picture showing the wifi antenna to remove](/images/nuc-clean/remove-wifi.jpg)

Next, find the two motherboard screws on each side and remove those.

![picture showing the motherboard screws](/images/nuc-clean/motherboard-screws.jpg)

Now the whole motherboard should lift out. I would suggest lifting up at the front. I just gave it a little flex, and the ports all moved freely. Once it is free, flip it over so the fan and heatsink on facing you. You will need to remove the fan first, which has been just a couple of screws.

![picture of the heatsink before removed](/images/nuc-clean/heatsink-before.jpg)

Then you can remove the heatsink, which is just a few screws too.

![picture with the heatsink removed](/images/nuc-clean/removed-heatsink.jpg)

I used compressed air to remove the dust from the fan and heatsink. I then used isopropyl alcohol and cotton swabs to remove all the dust in the top of the case and off the board.

![picture of the dirty case top](/images/nuc-clean/dirty-casetop.jpg)

![picture of the dirty fan](/images/nuc-clean/dirty-fan.jpg)

![picture of the dirty heatsink](/images/nuc-clean/dirty-heatsink.jpg)

I then cleaned off the existing thermal paste. I applied a new [Arctic MX-4](https://www.arctic.de/en/MX-4/ACTCP00008B) thermal paste.

![new thermal paste on the CPU](/images/nuc-clean/new-thermal-paste.jpg)

I then just put everything back together how I removed it. The trickiest part is going to be putting the motherboard back into the case. I found that inserting the rear first then flex of the front a little allowed it to drop back in. Here is a screenshot of the new temps.

![screenshot of the temperature after new thermal paste and cleaning](/images/nuc-clean/after-clean-and-paste.png)

I hope you found this helpful. It takes just a matter of minutes if you have everything ready.

Thanks for reading,

Jamie
