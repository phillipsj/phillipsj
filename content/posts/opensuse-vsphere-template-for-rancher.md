---
title: "openSUSE vSphere Template for Rancher"
date: 2022-04-16T13:39:53-04:00
tags:
- Open Source
- Linux
- openSUSE
- openSUSE Tumbleweed
- VMware
- vSphere
- Rancher
- RKE1
- RKE2
- Kubernetes
- K8s
- Packer
- cloud-init
- cloudbase-init
---

[Rancher](https://rancher.com/) has a feature called [node drivers](https://rancher.com/docs/rancher/v2.6/en/admin-settings/drivers/node-drivers/) that allow for the automatic creation of clusters against different environments. One of those exists for VMware vSphere for both RKE1 and RKE2. This driver leverages [cloud-init](https://cloud-init.io/) for Linux and [cloudebase-init](https://cloudbase.it/cloudbase-init/) for Windows to create a VM from vSphere templates. This assumes that you have a vSphere template already created with all the necessary packages installed and configured. Often users need to create these templates to ensure the correct setup exists. 

[openSUSE Leap](https://get.opensuse.org/leap) doesn't leverage cloud-init by default, except in the [JeOS](https://en.opensuse.org/Portal:JeOS) images for OpenStack. We will need to ensure that cloud-init is installed and configured correctly for use with vSphere and our node driver. I am going to guide you through how to leverage [Packer](https://www.packer.io/) and the vSphere builder to automate the creation of a template based on openSUSE Leap. We will install Packer, create our Packer configuration, then work through the provisioning steps, and finally convert our VM to an OVA template that will be placed into a content library.

**This has been tested on several Linux distributions and on the same distributions with WSL.**

## Preparation

There is some preparation that is going to be required before we can get started. At a high level here is what needs to be done

• Download the openSUSE Leap ISO
• Create our ISO folder in our VMWare data store
• Create our vSphere Content Library
• Upload our Leap ISO to our ISO folder

*Optionally you may want to create a dedicated account for Packer in vSphere. We won't cover that here and will assume you are using an account with the correct permissions.*

### Download the openSUSE ISO

We will be using the openSUSE Leap 15.3 ISO and in this example I will use the offline ISO, feel free to use the network image if you desire. Let's get our ISO and checksum file.

```Bash
wget https://download.opensuse.org/distribution/leap/15.3/iso/openSUSE-Leap-15.3-3-DVD-x86_64-Build38.1-Media.iso.sha256
wget https://download.opensuse.org/distribution/leap/15.3/iso/openSUSE-Leap-15.3-3-DVD-x86_64-Build38.1-Media.iso
```

Let's verify our download with our checksum.

```Bash
$ sha256sum -c openSUSE-Leap-15.3-3-DVD-x86_64-Build38.1-Media.iso.sha256
openSUSE-Leap-15.3-3-DVD-x86_64-Build38.1-Media.iso: OK
```

Keep the checksum file as you will need to put the checksum value in our Packer template.

### Creating the data store folder

Open of vCenter for your cluster. Navigate to the data store that you want to use and add a folder called `iso`. Inside of `iso` create a folder called `linux`. Finally, inside of the `linux` folder create a folder called `openSUSE`. 

*iso-datastore.png*

### Creating the content library

Create a content lbriary to save your templates. [Here](https://docs.vmware.com/en/VMware-vSphere/7.0/com.vmware.vsphere.vm_admin.doc/GUID-2A0F1C13-7336-45CE-B211-610D39A6E1F4.html) are the official docs on how to do that.

*content-library.png*

### Uploading the ISO

Navigate to the openSUSE folder that we created in previous step and click on `Upload Files`. Select the openSUSE ISO that we downloaded and upload it to that location.

## Packer installation and setup

We just have a few more steps left before we can start creating our Packer template. First we need to install Packer. You can download it from [here](https://www.packer.io/downloads) or you can use a package manager.

Windows:

```PowerShell
choco install packer
```

openSUSE:

```Bash
$ wget https://releases.hashicorp.com/packer/1.8.0/packer_1.8.0_linux_amd64.zip
$ unzip packer_1.8.0_linux_amd64.zip && mv packer ~/bin
```

macOS: 

```Bash
brew tap hashicorp/tap
brew install hashicorp/tap/packer
```

Now that we have it Packer installed, we need to make sure that we have a few other tools installed. You will need `xorriso` or `mkisofs` on Linux/macOS. On Windows you will need [`oscdimg`](https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/oscdimg-command-line-options). These are all used to create ISOs to mount your unattend configuration. In the case of openSUSE that would be an [AutoYaST](https://doc.opensuse.org/projects/autoyast/) file. That wraps up everything we need before we start creating our Packer configuration.

## Packer Configuration

We are now getting to the section we all want. Let's first create a directory for our project.

```Bash
mkdir packer-opensuse-template && cd "$_"
```

Now I am a big fan of how Terraform started laying out projects when 0.12 was introduced. We will follow a similar pattern. Let's create our `versions.pkr.hcl`.

```HCL
packer {
  required_version = ">= 1.8.0, < 2.0.0"
  required_plugins {
    vsphere = {
      version = ">= 0.0.1"
      source = "github.com/hashicorp/vsphere"
    }
  }
}
```

Now we can run `packer init` to install our plugin and make sure that our `versions.pkr.hcl` is valid.

```Bash
$ packer init .
Installed plugin github.com/hashicorp/vsphere v1.0.3 in "/home/phillipsj/.config/packer/plugins/github.com/hashicorp/vsphere/packer-plugin-vsphere_v1.0.3_x5.0_linux_amd64"
```

Great, let's now start create our `source.pkr.hcl` file that defines our vSphere VM that will be used to build.

```HCL
source "vsphere-iso" "opensuse" {
  // vCenter Server Endpoint Settings and Credentials
  vcenter_server      = var.vsphere_endpoint
  username            = var.vsphere_username
  password            = var.vsphere_password
  insecure_connection = var.vsphere_insecure_connection

  // vSphere Settings
  datacenter = var.vsphere_datacenter
  cluster    = var.vsphere_cluster
  datastore  = var.vsphere_datastore
  folder     = var.vsphere_folder

  // Virtual Machine Settings
  guest_os_type        = "sles15_64Guest"
  vm_name              = "linux-opensuse-15.3-v${local.build_version}"
  firmware             = "efi"
  CPUs                 = 1
  cpu_cores            = 2
  RAM                  = 4096
  cdrom_type           = "sata"
  disk_controller_type = ["pvscsi"]
  storage {
    disk_size             = 20000
    disk_thin_provisioned = true
  }
  network_adapters {
    network      = "VM Network"
    network_card = "vmxnet3"
  }
  vm_version           = 19
  remove_cdrom         = true
  tools_upgrade_policy = true
  notes                = "Version: v${local.build_version}\nBuilt on: ${local.build_date}\n${local.build_by}"

  // Removable Media Settings
  iso_paths    = ["[datastore1] iso/linux/openSUSE/openSUSE-Leap-15.3-3-DVD-x86_64-Build38.1-Media.iso"]
  iso_checksum = "sha256:c1515358daec1ab7c3be2b7c28636eac2e18f0ad550b918ed0550722b87f8b49"
  cd_content   = local.data_source_content
  cd_label     = "cidata"

  // Boot and Provisioning Settings
  boot_order = "disk,cdrom"
  boot_wait  = "5s"
  boot_command = [
    "<esc><enter><wait>",
    "linux ",
    "biosdevname=0 ",
    "net.ifnames=0 ",
    "netdevice=eth0 ",
    "netsetup=dhcp ",
    "lang=en_US ",
    "textmode=1 ",
    "autoyast=device:///autoinst.xml",
    "<enter><wait>"
  ]
  shutdown_command = "echo '${var.build_password}' | sudo -S -E shutdown -P now"

  // Communicator Settings and Credentials
  communicator = "ssh"
  ssh_username = var.build_username
  ssh_password = var.build_password
  ssh_port     = 22
  ssh_timeout  = "30m"

  // Template and Content Library Settings
  convert_to_template = false
  content_library_destination {
    library     = "templates"
    description = "Version: v${local.build_version}\nBuilt on: ${local.build_date}\n${local.build_by}"
    ovf         = true
    destroy     = true
    skip_import = false
  }
}
```

With our source defined we can create our `builder.pkr.hcl` which defines provisioning steps that we need to execute. This will mainly be executed to cleanup our system to prepare it for becoming a template. We also configure cloud-init.

```HCL
build {
  sources = ["source.vsphere-iso.opensuse"]
  // Configure cloud-init for vSphere and Rancher node driver.
  provisioner "shell" {
    inline = [
      "rm -rf /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
      "rm -rf /etc/cloud/cloud.cfg.d/99-installer.cfg",
      "rm -rf /etc/netplan/00-installer-config.yaml",
      "echo 'disable_vmware_customization: false' >> /etc/cloud/cloud.cfg",
      "echo 'datasource_list: [ NoCloud, VMWare, OVF, None ]' > /etc/cloud/cloud.cfg.d/90_dpkg.cfg"
    ]
  }
  //Setting hostname to localhost.
  provisioner "shell" {
    inline = [
      "cat /dev/null > /etc/hostname",
      "hostnamectl set-hostname localhost"
    ]
  }
  // Cleaning the /tmp directories.
  provisioner "shell" {
    inline = [
      "if [ -f /etc/udev/rules.d/70-persistent-net.rules ]; then",
      "rm /etc/udev/rules.d/70-persistent-net.rules",
      "fi"
    ]
  }
  // Disable swap.
  provisioner "shell" {
    inline = [
      "swapoff -a"
    ]
  }
  // Cleaning persistent udev rules.
  provisioner "shell" {
    inline = [
      "rm -rf /tmp/*",
      "rm -rf /var/tmp/*"
    ]
  }
  // Cleaning the SSH host keys.
  provisioner "shell" {
    inline = [
      "rm -f /etc/ssh/ssh_host_*"
    ]
  }
  // Cleaning the machine-id.
  provisioner "shell" {
    inline = [
      "truncate -s 0 /etc/machine-id",
      "rm /var/lib/dbus/machine-id",
      "ln -s /etc/machine-id /var/lib/dbus/machine-id"
    ]
  }
  // Cleaning cloud-init.
  provisioner "shell" {
    inline = [
      "cloud-init clean -s -l"
    ]
  }
  // Cleaning the shell history.
  provisioner "shell" {
    inline = [
      "unset HISTFILE",
      "history -cw",
      "echo > ~/.bash_history",
      "rm -fr /root/.bash_history"
    ]
  }
}
```

You will notice that we have some variables defined that we need to create. Let's create a `variables.pkr.hcl`.

```HCL
variable "vsphere_endpoint" {
  type        = string
  description = "The fully qualified domain name or IP address of the vCenter Server instance. (e.g. 'sfo-w01-vc01.sfo.rainpole.io')"
}

variable "vsphere_username" {
  type        = string
  description = "The username to login to the vCenter Server instance. (e.g. 'svc-packer-vsphere@rainpole.io')"
  sensitive   = true
}

variable "vsphere_password" {
  type        = string
  description = "The password for the login to the vCenter Server instance."
  sensitive   = true
}

variable "vsphere_insecure_connection" {
  type        = bool
  description = "Do not validate vCenter Server TLS certificate."
  default     = true
}

variable "vsphere_datacenter" {
  type        = string
  description = "The name of the target vSphere datacenter. (e.g. 'sfo-w01-dc01')"
}

variable "vsphere_cluster" {
  type        = string
  description = "The name of the target vSphere cluster. (e.g. 'sfo-w01-cl01')"
}

variable "vsphere_datastore" {
  type        = string
  description = "The name of the target vSphere datastore. (e.g. 'sfo-w01-cl01-vsan01')"
}

variable "vsphere_folder" {
  type        = string
  description = "The name of the target vSphere cluster. (e.g. 'sfo-w01-fd-templates')"
}

variable "build_username" {
  type        = string
  description = "The username to login to the guest operating system. (e.g. 'rainpole')"
  sensitive   = true
}

variable "build_password" {
  type        = string
  description = "The password to login to the guest operating system."
  sensitive   = true
}
```

The last item before we check our work is creating a `locals.pkr.hcl` file.

```HCL
locals {
  build_by      = "Built by: HashiCorp Packer ${packer.version}"
  build_date    = formatdate("YYYY-MM-DD hh:mm ZZZ", timestamp())
  build_version = formatdate("YY.MM", timestamp())
  data_source_content = {
    "/autoinst.xml" = templatefile("${abspath(path.root)}/data/autoinst.pkrtpl.hcl", {
      build_username = var.build_username
      build_password = var.build_password
    })
  }
}
```

We have only two items left to do. The first one is to create our `vars.auto.pkrvars.hcl`. This is where we will set our variables.

```HCL
vsphere_endpoint            = "vcenter-url"
vsphere_username            = "administrator@vsphere.local"
vsphere_password            = "SecretPassword"
vsphere_insecure_connection = true
vsphere_datacenter          = "dc1"
vsphere_cluster             = "cluster1"
vsphere_datastore           = "datastore1"
vsphere_folder              = "packer"
build_username              = "packer"
build_password              = "P@ckerI5C001"
```

The last item is the `autoyast` template. Create a directory named `data` and add a file named `autoinst.pkrtpl.hcl`. Place the following in that file.

```HCL
<?xml version="1.0"?>
<!DOCTYPE profile>
<profile xmlns="http://www.suse.com/1.0/yast2ns" xmlns:config="http://www.suse.com/1.0/configns">
  <scripts>
    <chroot-scripts config:type="list">
      <script>
        <chrooted config:type="boolean">true</chrooted>
        <filename>add_${build_username}_sudo_rule.sh</filename>
        <interpreter>shell</interpreter>
        <source>
<![CDATA[
#!/bin/sh
echo "Defaults:${build_username} !targetpw
${build_username} ALL=(ALL,ALL) NOPASSWD: ALL" > /etc/sudoers.d/${build_username}
]]>
          </source>
      </script>
    </chroot-scripts>
  </scripts>
  <general>
    <mode>
      <confirm config:type="boolean">false</confirm>
      <forceboot config:type="boolean">true</forceboot>
      <final_reboot config:type="boolean">false</final_reboot>
    </mode>
  </general>
  <report>
    <messages>
      <show config:type="boolean">false</show>
      <timeout config:type="integer">10</timeout>
      <log config:type="boolean">true</log>
    </messages>
    <warnings>
      <show config:type="boolean">false</show>
      <timeout config:type="integer">10</timeout>
      <log config:type="boolean">true</log>
    </warnings>
    <errors>
      <show config:type="boolean">false</show>
      <timeout config:type="integer">10</timeout>
      <log config:type="boolean">true</log>
    </errors>
  </report>
  <keyboard>
    <keymap>english-us</keymap>
  </keyboard>
  <language>
    <language>en_US</language>
    <languages>en_US</languages>
  </language>
  <timezone>
    <hwclock>UTC</hwclock>
    <timezone>Etc/UTC</timezone>
  </timezone>
  <partitioning config:type="list">
    <drive>
      <enable_snapshots config:type="boolean">false</enable_snapshots>
      <initialize config:type="boolean">true</initialize>
      <partitions config:type="list">
        <partition>
          <create config:type="boolean">true</create>
          <crypt_fs config:type="boolean">false</crypt_fs>
          <filesystem config:type="symbol">ext4</filesystem>
          <format config:type="boolean">true</format>
          <loop_fs config:type="boolean">false</loop_fs>
          <mount>/</mount>
          <mountby config:type="symbol">device</mountby>
          <partition_id config:type="integer">131</partition_id>
          <partition_nr config:type="integer">2</partition_nr>
          <raid_options />
          <resize config:type="boolean">false</resize>
          <size>max</size>
          <subvolumes config:type="list">
            <listentry>boot/grub2/i386-pc</listentry>
            <listentry>boot/grub2/x86_64-efi</listentry>
            <listentry>home</listentry>
            <listentry>opt</listentry>
            <listentry>srv</listentry>
            <listentry>tmp</listentry>
            <listentry>usr/local</listentry>
            <listentry>var/crash</listentry>
            <listentry>var/log</listentry>
            <listentry>var/opt</listentry>
            <listentry>var/spool</listentry>
            <listentry>var/tmp</listentry>
          </subvolumes>
        </partition>
      </partitions>
      <pesize />
      <type config:type="symbol">CT_DISK</type>
      <use>all</use>
    </drive>
  </partitioning>
  <bootloader>
    <loader_type>grub2</loader_type>
		<global>
			<activate>true</activate>
			<timeout config:type="integer">1</timeout>
			<boot_mbr>true</boot_mbr>
		</global>
  </bootloader>
  <networking>
    <ipv6 config:type="boolean">false</ipv6>
    <keep_install_network config:type="boolean">true</keep_install_network>
    <dns>
      <dhcp_hostname config:type="boolean">true</dhcp_hostname>
      <resolv_conf_policy>auto</resolv_conf_policy>
      <hostname>opensuse-leap-x64</hostname>
    </dns>
    <interfaces config:type="list">
      <interface>
        <bootproto>dhcp</bootproto>
        <name>eth0</name>
        <startmode>auto</startmode>
        <usercontrol>no</usercontrol>
      </interface>
    </interfaces>
  </networking>
  <firewall>
    <enable_firewall config:type="boolean">false</enable_firewall>
    <start_firewall config:type="boolean">false</start_firewall>
  </firewall>
  <software>
    <packages config:type="list">
      <package>apparmor-parser</package>
      <package>grub2</package>
      <package>glibc-locale</package>
      <package>iputils</package>
      <package>kernel-default</package>
      <package>sudo</package>
      <package>yast2</package>
      <package>yast2-firstboot</package>
      <package>zypper</package>
      <package>yast2-trans-en_US</package>
      <package>wget</package>
      <package>curl</package>
      <package>grub2-branding-openSUSE</package>
      <package>less</package>
      <package>net-tools</package>
      <package>growpart</package>
      <package>open-vm-tools</package>
      <package>open-iscsi</package>
      <package>insserv-compat</package>
      <package>cloud-init</package>
    </packages>
    <patterns config:type="list">
      <pattern>sw_management</pattern>
      <pattern>yast2_install_wf</pattern>
      <pattern>minimal_base</pattern>
      <pattern>devel_basis</pattern>
    </patterns>
    <remove-packages config:type="list">
      <package>telnet</package>
      <package>virtualbox-guest-kmp-default</package>
      <package>virtualbox-guest-tools</package>
      <package>snapper</package>
      <package>snapper-zypp-plugin</package>
    </remove-packages>
  </software>
  <services-manager>
    <default_target>multi-user</default_target>
    <services>
      <disable config:type="list" />
      <enable config:type="list">
        <service>sshd</service>
        <service>cloud-init</service>
        <service>cloud-config</service>
        <service>cloud-final</service>
      </enable>
    </services>
  </services-manager>
  <groups config:type="list">
    <group>
      <gid>100</gid>
      <groupname>users</groupname>
      <userlist />
    </group>
  </groups>
  <user_defaults>
    <expire />
    <group>100</group>
    <groups />
    <home>/home</home>
    <inactive>-1</inactive>
    <no_groups config:type="boolean">true</no_groups>
    <shell>/bin/bash</shell>
    <skel>/etc/skel</skel>
    <umask>022</umask>
  </user_defaults>
  <users config:type="list">
    <user>
      <user_password>${build_password}</user_password>
      <username>root</username>
    </user>
    <user>
      <fullname>Built by Packer</fullname>
      <gid>100</gid>
      <home>/home/${build_username}</home>
      <password_settings>
        <expire />
        <flag />
        <inact>-1</inact>
        <max>99999</max>
        <min>0</min>
        <warn>7</warn>
      </password_settings>
      <shell>/bin/bash</shell>
      <uid>1000</uid>
      <user_password>${build_password}</user_password>
      <username>${build_username}</username>
    </user>
  </users>
  <kdump>
    <add_crash_kernel config:type="boolean">false</add_crash_kernel>
  </kdump>
</profile>
```

Now we can run `packer fmt` to make sure that we have everything formatted correctly.

```Bash
$ packer fmt .
```
Once that comes back clean, we need to run `packer validate` to ensure that we don't have any other issues.

```Bash
$ packer validate -syntax-only .
Syntax-only check passed. Everything looks okay.
```

If the validate comes back clean, then everything is ready to actually execute. If it doesn't, then go back through and address the isssues that are listed.

## Building our Image

We made it! We are ready to actually build our image.