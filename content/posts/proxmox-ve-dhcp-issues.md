---
title: "Proxmox VE DHCP Issues"
date: 2021-06-06T16:23:01-04:00
tags:
- Open Source
- Virtual Machines
- Proxmox
- DHCP
- Homelab
---

I have been having some intermittent DHCP issues lately, some of it has specifically been related to the few Windows machines that I have. Other issues have been related to some different Linux distros. I decided that I would dig into these issues starting with the one that was the most frustrating which is my [Proxmox VE](https://www.proxmox.com/en/proxmox-ve) server not being available via DNS. Interestingly enough, any VM being created on Proxmox was leveraging DHCP and I could resolve them by name. Proxmox is using debian based OS underneath so I started doing some searching focus on the host not resolving by name. Everything was pointing to the fact that the DHCP settings where not configured correctly. Running the following command highlighted the issue.

```Bash
$ cat /etc/network/interfaces
auto lo
iface lo inet loopback

iface enp2s0 inet manual

auto vmbr0
iface vmbr0 inet static
        address 192.163.1.42/24
        gateway 192.163.1.1
        bridge_ports enp2s0
        bridge_stp off
        bridge_fd 0
```

You can see here that there is the phsyical network interface listed, *enp2s0*. That one is configured to manual and really doesn't need to be touched. The more interesting one is the **vrmb0** which is the virtual interface that is the network bridge. That one is configured to be static instead of leveraging DHCP. I did try changing the *enp2s0* first which resulted in there being two IPs assigned the static one for the bridge and one from DHCP. That was an interestign learning experience.

Okay, so I identified the issue and it gave me more info to research. After some digging it seems that I just needed to convert the **vrmb0** to DHCP instead of static. However, to perform that change, I need to create a DHCP reservation in my Synology Router to reserve the IP address so it will also have the same IP address. Having a static IP is a requirement by Proxmox. After making the reservation, I went and update the config file to be as such.

```Bash
auto lo
iface lo inet loopback

iface enp2s0 inet manual

auto vmbr0
iface vmbr0 inet DHCP
        address 192.163.1.42/24
        gateway 192.163.1.1
        bridge_ports enp2s0
        bridge_stp off
        bridge_fd 0
```

Then I flushed the DHCP client to pick up the settings change. This command may not be the best approach, it's just the one that I found and it didn't hurt my server.

```Bash
$ /sbin/dhclient -4 -v -i -d --no-pid \
  -cf ./dhcp.conf \
  -lf /var/lib/dhcp/dhclient.enp2s0.leases \
  -I enp2s0
```

Once that was completed, I was able to find that machine by name instead of having to use the IP.

I hope this helps someone else that is experiecing a similar issue.

Thanks for reading,

Jamie

