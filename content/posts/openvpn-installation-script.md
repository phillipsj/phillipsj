---
Title: "OpenVPN Installation Script"
date: 2018-05-24T21:10:11
Tags: 
- Open Source
---
# OpenVPN Installation Script

#### TL;DR; All the features of the original that also allows passing arguments to make automation easier. The [repo](https://github.com/phillipsj/OpenVPN-install).

Recently I have had to work on installing and configuring a few OpenVPN servers. Since I needed to use OpenVPN, not OpenVPN access server, I started looking around the web to find a nice installation script that would make it easier and provide some guidance. After a little searching, I found this Github repo by Nyr called [openvpn-install](https://github.com/Nyr/openvpn-install). This script had a lot of nice features and provided a nice guided installation. After a couple more hours, I discovered this [fork](https://github.com/Angristan/OpenVPN-install) by Angristan that had a few tweaks that did appear to improve upon the security of the installation. After spending some time testing it out, I decided that it was the method I wanted to use to perform my installations. One major flaw that I found in both of these installation scripts is that neither one had implemented any parameterized arguments.

I decided that I was going to resolve the parameterization issue by forking the script and adding parameters. As anyone that has done Bash programming knows adding parameters isn't intuitive or dare I say, easy. So, after much Stackoverflow and blog post reading, I stumbled across [Argbash](https://argbash.io/). This is really awesome site that allows you to define your arguments and it will generate the parsing and the help for you without any efforts.

After using Argbash, I pushed up my changes to my fork that can be found [here](https://github.com/phillipsj/OpenVPN-install). The usage is straight forward, but here is a preview of getting the script and what it prints out. Also, note, that if an argument isn't provided, the user will be prompted just like in the original script.

```
$ wget https://raw.githubusercontent.com/phillipsj/OpenVPN-install/master/openvpn-install.sh
$ chmod +x openvpn-install.sh
$ ./openvpn-install.sh --help

The general script's help msg
Usage: ./openvpn-install.sh [-i|--ip <arg>] [-p|--port <arg>] [-d|--dns <arg>] [-c|--cihper <arg>] [-f|--diffie <arg>] [-r|--rsa <arg>] [-u|--client <arg>] [-k|--key <arg>] [-s|--secret <arg>] [-b|--bucket <arg>] [-t|--bucket-path <arg>] [-n|--(no-)skip-confirmation] [-h|--help]
        -i,--ip: external ip address (no default)
        -p,--port: Port to use (default: '1194')
        -l,--protocol: Protocol to use (default: 'TCP')
        -d,--dns: DNS servers to use (default: '1')
        -c,--cipher: Cipher to use (default: '3')
        -f,--diffie: Diffie-Hellman key you want to use (default: '3')
        -r,--rsa: RSA key you want to use (default: '3')
        -u,--client: Client Name (default: 'client')
        -n,--skip-confirmation,--no-skip-confirmation: Skip confirmation (off by default)
        -h,--help: Prints help
```

As you can see, I picked a few middle of the road defaults to assist with the automation. That's all, thanks for reading.
