---
title: "SSH Key-Based Auth for Windows"
date: 2023-01-30T21:12:48-05:00
tags: 
- Open Source
- Terraform
- HashiCorp
- Windows
- Windows Server
- SSH
- PowerShell
---

We often don't think about setting up key-based authentication using SSH for Windows. It often comes in very handy for automation tasks and other headless use cases. After digging around, I discovered that it isn't as straightforward as one would think. There are a couple of tweaks that need to be made outside of the documentation provided [here](https://learn.microsoft.com/en-us/windows-server/administration/openssh/openssh_keymanagement). One of the tweaks is to ensure that you enable public key authentication in the SSH config, the other one is that the administrators authorized keys is commented out as described [here](https://stackoverflow.com/a/50502015) in step five. 

## PowerShell Script

Here is the PowerShell that can be used to automate the process.

```PowerShell
# Install SSH
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

# OPTIONAL but recommended:
Set-Service -Name sshd -StartupType 'Automatic'

# Start the sshd service
Start-Service sshd

# Confirm the Firewall rule is configured. It should be created automatically by setup. Run the following to verify
if (!(Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue | Select-Object Name, Enabled)) {
    Write-Output "Firewall Rule 'OpenSSH-Server-In-TCP' does not exist, creating it..."
    New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
} else {
    Write-Output "Firewall rule 'OpenSSH-Server-In-TCP' has been created and exists."
}

# Set default shell for OpenSSH
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force;

# Get the public key 
$authorizedKey = Get-Content -Path "<path to your public key>"
New-Item -Force -ItemType Directory -Path $env:USERPROFILE\.ssh; Add-Content -Force -Path $env:USERPROFILE\.ssh\authorized_keys -Value $authorizedKey

# Set the config to allow the pubkey auth
$sshd_config="C:\ProgramData\ssh\sshd_config" 
(Get-Content $sshd_config) -replace '#PubkeyAuthentication', 'PubkeyAuthentication' | Out-File -encoding ASCII $sshd_config
(Get-Content $sshd_config) -replace 'AuthorizedKeysFile __PROGRAMDATA__', '#AuthorizedKeysFile __PROGRAMDATA__' | Out-File -encoding ASCII $sshd_config
(Get-Content $sshd_config) -replace 'Match Group administrators', '#Match Group administrators' | Out-File -encoding ASCII $sshd_config
Get-Content C:\ProgramData\ssh\sshd_config

# Reload the config
Restart-Service sshd
```

## Bootstrapping SSH in AWS 

Now let's demonstrate how to apply the above PowerShell script in AWS. We will create a Windows EC2 instance, and configure that security group to allow both RDP and SSH. Finally, we will generate an SSH key using Terraform that we can inject into our PowerShell script that will get executed as userdata on the instance. The Terraform will output the SSH command at the end, so you can SSH into your instance.

```HCL
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.51.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "tls" {}

data "aws_ami" "windows" {
  most_recent = true
  owners = ["801119661308"]

  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Core-Base-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }  
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "local_file" "private_key" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "winssh.pem"
  file_permission = "0600"
}

# Bootstrapping PowerShell Script
data "template_file" "windows-userdata" {
  template = <<EOF
<powershell>
# Install SSH
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

# OPTIONAL but recommended:
Set-Service -Name sshd -StartupType 'Automatic'

# Start the sshd service
Start-Service sshd

# Confirm the Firewall rule is configured. It should be created automatically by setup. Run the following to verify
if (!(Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue | Select-Object Name, Enabled)) {
    Write-Output "Firewall Rule 'OpenSSH-Server-In-TCP' does not exist, creating it..."
    New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
} else {
    Write-Output "Firewall rule 'OpenSSH-Server-In-TCP' has been created and exists."
}

# Set default shell for OpenSSH
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force;

# Get the public key 
$authorizedKey = "${trimspace(tls_private_key.ssh.public_key_openssh)}"
New-Item -Force -ItemType Directory -Path $env:USERPROFILE\.ssh; Add-Content -Force -Path $env:USERPROFILE\.ssh\authorized_keys -Value $authorizedKey

# Set the config to allow the pubkey auth
$sshd_config="C:\ProgramData\ssh\sshd_config" 
(Get-Content $sshd_config) -replace '#PubkeyAuthentication', 'PubkeyAuthentication' | Out-File -encoding ASCII $sshd_config
(Get-Content $sshd_config) -replace 'AuthorizedKeysFile __PROGRAMDATA__', '#AuthorizedKeysFile __PROGRAMDATA__' | Out-File -encoding ASCII $sshd_config
(Get-Content $sshd_config) -replace 'Match Group administrators', '#Match Group administrators' | Out-File -encoding ASCII $sshd_config
Get-Content C:\ProgramData\ssh\sshd_config

# Reload the config
Restart-Service sshd
</powershell>
EOF
}

resource "aws_security_group" "aws-windows-sg" {
  name        = "windows-sg"
  description = "Allow incoming connections"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming SSH connections"
  }  
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming RDP connections"
  }  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }  
  
  tags = {
    Name = "windows-sg"
  }
}

resource "aws_instance" "winssh" {
  ami               = data.aws_ami.windows.id
  instance_type     = "t2.micro"  
  source_dest_check = false
  key_name          = "<key pair name>"
  user_data         = data.template_file.windows-userdata.rendered 

  vpc_security_group_ids = [aws_security_group.aws-windows-sg.id]

  root_block_device {
    volume_size           = 30
    volume_type           = "gp2"
    delete_on_termination = true
    encrypted             = true
  }

  tags = {
    Name = "winssh"
  }

  lifecycle {
    ignore_changes = [ami]
  }
}

output "ssh_command" {
  value = "ssh Administrator@${aws_instance.winssh.public_dns} -i ./${local_file.private_key.filename}"
}
```

# Wrapping Up

This was a fun one to work on. I have been using SSH with Windows for some time, yet I hadn't tried to configure key-based authentication. I know have this post to reference in the future. I hope you too find this useful.

Thanks for reading,

Jamie