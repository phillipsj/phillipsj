---
title: "Synology RT2600AC and MR2200AC Review"
date: 2021-04-17T19:10:58-04:00
tags:
- Synology
- RT2600AC
- MR2200AC
- Review
- Networking
---

After close to four years of usage of my [Google Wifi](https://www.phillipsj.net/posts/review-google-wifi/), I have decided to move on. Part of the reason is performance, one part Google retiring the wifi app, and the other is that I didn't want to give Google more data. I have narrowed it down to a few choices being Synology, TP-Link, or Ubiquiti. I had been on the fence about Ubiquiti after the past couple of years of news, and the most recent information removed them from consideration. I have been impressed by many Synology products, so I decided to give them a try. I will admit from a price perspective, and they are more expensive than what I could have done with TP-Link. I picked up the [Synology RT2600AC](https://www.synology.com/en-us/products/RT2600ac) and the [Synology MR2200AC](https://www.synology.com/en-us/products/MR2200ac) to build out a "mesh" wifi.

## Background

Now, we live in a 1700 sqft house which has an addition. That addition causes a lot of issues due to the interior wall thickness. The Google Wifi had three APs which provided me with excellent coverage in that area of the house. I knew that I would need an AP in that section of the house, so I added the MR2200AC. Now the Google Wifi had limited throughput in my environment. Couple that with not handling the 14+ devices connected at any time caused me to notice. I wanted something that could provide better throughput, and more control than the Google Wifi seems to allow.

## Synology RT2600AC

Setup was a breeze, and I configured my Wifi and Guest Wifi with the same SIDs and passwords as I had previously configured. Everything reconnected without a hiccup. The [Synology Router Manager](https://www.synology.com/en-us/srm) is, in my opinion, an excellent piece of software for managing a router. There is a lot of configuration and capability out of the box. I enabled DOH, DNS over HTTPS, for all of my network traffic, and there is the option to define a custom one or pick between Cloudflare and Google. There is support for adding storage and leveraging the router as a "NAS." It seems to have some of the available applications on their NAS products. You can also install applications for adding a DNS server, Radius server, and VPN server. There is the ability to join do a domain or configure LDAP too. I have found it to be an exciting blend of home and small business features. The mobile app is pleasant enough and works well for checking devices and traffic.

## Synology MR2200AC

Again, the setup was quick, and I had a working AP within seconds of plugging it in. I was getting a solid signal in the furthest point from the router, and devices quickly switched between the AP and the router. That is one thing I noticed with the Google Wifi, that devices didn't always switch or pick the closest router. The same devices with the Synology system seem to switch much better.

## Performance

Did it meet my expectations? I would say yes, it has. All of my devices connect and have excellent throughput. I am getting symmetric 867Mbps on the main router and symmetric 210Mbps on the AP. That is much better than seeing out Google Wifi, and it's enough to saturate my ISP out. The device isn't close to maxing out the CPU and memory usage, leaving plenty of room for running the additional services.

## Conclusion

Overall, I am happy with my purchase and feel confident to recommend it to anyone wanting additional control and options that may not be available on many consumer devices. It fits in that space of prosumer/small business that I think is perfect for users who need more features but aren't ready for an enterprise solution. If you have any questions, please reach out and ask.

Thanks for reading,

Jamie
