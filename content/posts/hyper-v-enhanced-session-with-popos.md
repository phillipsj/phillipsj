---
Title: "Hyper-V enhanced session with Pop!_OS"
date: 2019-08-16T15:44:27
Tags: 
- Open Source
- Microsoft And Linux
- Linux
- Hyper-V
- Pop!_OS
---
# Hyper-V enhanced session with Pop!_OS

It's my day off, and I decided to have a little fun. I have been using the new Hyper-V enhanced session with Ubuntu since it is available in the image gallery. The enhanced session was announced back in [September 2018](https://www.omgubuntu.co.uk/2018/09/hyper-v-ubuntu-1804-windows-integration), and so far it is only available for Ubuntu and Arch. I have been trying out [Pop!_OS](https://system76.com/pop) by [System76](https://system76.com) lately, and it an Ubuntu derivative. I decided that I wanted to try to see if I could get the enhanced session to work with it too. Microsoft has a GitHub [repo](https://github.com/microsoft/linux-vm-tools) with installation scripts for Ubuntu, we will modify the installation script to run on Pop!_OS 19.04.

Here we go:

## Step 1: Download ISO

Download the ISO for Pop!_OS, I used the 19.04 Intel/AMD version.

## Step 2: Create Hyper-V Virtual Machine

Open Hyper-V and use the *Quick Create* option to create a VM named PopOS.

![](/images/enhanced-pop/quickcreatebutton.png)

Now select *Local Installation source*, click on *Change installation source* and select the ISO you downloaded. Make sure to uncheck the box saying it is a Windows VM as such secure boot will be disabled.

![](/images/enhanced-pop/quickcreatescreen.png)

After that is all configured, click on *Create Virtual Machine*. Once that is complete, start up the virtual machine and run through the installation. After the reboot, we will get started with the next steps.

## Step 3: Install libraries and configure XRDP

If you follow the link above to the Microsoft repo, there are installation scripts for versions of Ubuntu and Arch. We are going to modify the [Ubuntu 18.04 version](https://github.com/microsoft/linux-vm-tools/blob/master/ubuntu/18.04/install.sh) to accommodate Pop!_OS. This setup is pretty simple as it only requires us modifying lines 61 and 62. These lines define the Gnome Shell Session and the current desktop, which will not be Ubuntu when on Pop!_OS. We are going to modify lines 58, 59, 65, and 69 to create a little cleaner setup. However, it isn't necessary. How do we determine the Gnome Shell Session and the current desktop for Pop!_OS, we use the following command:

```Bash
$ printf 'Desktop: %s\nSession: %s\n' "$XDG_CURRENT_DESKTOP" "$GDMSESSION"

Desktop: pop:GNOME
Session: pop
```

We put that information here, lines61 and 62. This command would work for any desktop, so if you wanted to use KDE or Xfce, etc. You can modify these lines.

```Bash
export GNOME_SHELL_SESSION_MODE=pop
export XDG_CURRENT_DESKTOP=pop:GNOME
```

Here is the entire modified script:

```Bash
#!/bin/bash

#
# This script is for Pop!_OS 19.04 to download and install XRDP+XORGXRDP via
# source.
#

if [ "$(id -u)" -ne 0 ]; then
 echo 'This script must be run with root privileges' >&2
 exit 1
fi

apt update && apt upgrade -y

if [ -f /var/run/reboot-required ]; then
 echo "A reboot is required in order to proceed with the install." >&2
 echo "Please reboot and re-run this script to finish the install." >&2
 exit 1
fi

###############################################################################
# XRDP
#

# Install hv_kvp utils
apt install -y linux-tools-virtual
apt install -y linux-cloud-tools-virtual

# Install the xrdp service, so we have the auto-start behavior
apt install -y xrdp

systemctl stop xrdp
systemctl stop xrdp-sesman

# Configure the installed XRDP ini files.
# use vsock transport.
sed -i_orig -e 's/use_vsock=false/use_vsock=true/g' /etc/xrdp/xrdp.ini
# use rdp security.
sed -i_orig -e 's/security_layer=negotiate/security_layer=rdp/g' /etc/xrdp/xrdp.ini
# remove encryption validation.
sed -i_orig -e 's/crypt_level=high/crypt_level=none/g' /etc/xrdp/xrdp.ini
# disable bitmap compression since its local its much faster
sed -i_orig -e 's/bitmap_compression=true/bitmap_compression=false/g' /etc/xrdp/xrdp.ini

# Add script to setup the pop session properly
if [ ! -e /etc/xrdp/startpop.sh ]; then
cat >> /etc/xrdp/startpop.sh << EOF
#!/bin/sh
export GNOME_SHELL_SESSION_MODE=pop
export XDG_CURRENT_DESKTOP=pop:GNOME
exec /etc/xrdp/startwm.sh
EOF
chmod a+x /etc/xrdp/startpop.sh
fi

# use the script to setup the pop session
sed -i_orig -e 's/startwm/startpop/g' /etc/xrdp/sesman.ini

# rename the redirected drives to 'shared-drives'
sed -i -e 's/FuseMountName=thinclient_drives/FuseMountName=shared-drives/g' /etc/xrdp/sesman.ini

# Changed the allowed_users
sed -i_orig -e 's/allowed_users=console/allowed_users=anybody/g' /etc/X11/Xwrapper.config

# Blacklist the vmw module
if [ ! -e /etc/modprobe.d/blacklist_vmw_vsock_vmci_transport.conf ]; then
cat >> /etc/modprobe.d/blacklist_vmw_vsock_vmci_transport.conf <<EOF
blacklist vmw_vsock_vmci_transport
EOF
fi

#Ensure hv_sock gets loaded
if [ ! -e /etc/modules-load.d/hv_sock.conf ]; then
echo "hv_sock" > /etc/modules-load.d/hv_sock.conf
fi

# Configure the policy xrdp session
cat > /etc/polkit-1/localauthority/50-local.d/45-allow-colord.pkla <<EOF
[Allow Colord all Users]
Identity=unix-user:*
Action=org.freedesktop.color-manager.create-device;org.freedesktop.color-manager.create-profile;org.freedesktop.color-manager.delete-device;org.freedesktop.color-manager.delete-profile;org.freedesktop.color-manager.modify-device;org.freedesktop.color-manager.modify-profile
ResultAny=no
ResultInactive=no
ResultActive=yes
EOF

# reconfigure the service
systemctl daemon-reload
systemctl start xrdp

#
# End XRDP
###############################################################################

echo "Install is complete."
echo "Reboot your machine to begin using XRDP."
```

You can copy this and save it locally to execute, or you can grab it from this [gist](https://gist.github.com/phillipsj/a4b6e4a1070b4320ed19e061fe2dd83d)

```Bash
# Only run this if you don't want to create it yourself.
$ wget https://gist.githubusercontent.com/phillipsj/a4b6e4a1070b4320ed19e061fe2dd83d/raw/010f30404194e4831e76035601313079a1100243/install.sh

$ chmod +x install.sh
$ sudo ./install.sh
```

Once that completes, you need to shut down the VM.

## Step 4: Configure Hyper-V to use HvSocket for the PopOS VM

Now we need to enable the enhanced session using the following PowerShell command on your Windows host.

```PowerShell
$ Set-VM -VMName PopOS -EnhancedSessionTransportType HvSocket
```

Once that completes, we can restart our Pop VM, and you should be prompted to set resolution and login with the new enhanced session.

![](/images/enhanced-pop/resolutionprompt.png)

We are off to a good start as what resolution we want to use is prompted. Click on *Connect*, and we should be seeing the XRDP screen.

![](/images/enhanced-pop/xrdp.png)

Now you can have a more seamless experience running Pop!_OS on Hyper-V with fully copy past support and file sharing.

## Conclusion

I think this is pretty cool that you are not required to use Ubuntu to get these features. It only takes a little work to get this working for any Ubuntu-based distribution. I am pretty confident that this will work for Linux Mint, PepperMint, Xubuntu, Kubuntu, and ElementaryOS.

Thanks for reading,

Jamie
