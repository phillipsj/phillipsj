---
Title: "Azure SSO, AWS, and IAM Roles"
Published: 06/20/2018 21:50:31
Tags: 
- AWS
- Azure
- Amazon
- Microsoft
---
# Azure SSO, AWS, and IAM Roles

Did you know you could use Azure AD to SSO into your AWS accounts for your organization?  Here is a [blog post](https://www.cloudreach.com/blog/multi-aws-account-federation-microsoft-azure-ad/) that highlights how to wire it up. This works wonderfully for users that work in the AWS console. When you get into using EKS and you need access via tools like [Kubectl](https://kubernetes.io/docs/reference/kubectl/overview/), [Helm](https://helm.sh/), and the [AWS CLI](https://aws.amazon.com/cli/) you will need command line credentials to allow you to assume the correct roles to perform you job.

Fortunately for us, [Dave Johnson](https://github.com/dtjohnson) has come to the rescue with [aws-azure-login](https://github.com/dtjohnson/aws-azure-login) tool to allow you to generate AWS credentials using your Azure account from the CLI.

The instructions in the README are great, however, it seems that some users have had difficulty getting it working on the first go around. I am going to walk you through how I do the installation and use it on a day to day basis.

## Step 1: Collect needed information

The first step is going to be to collect the following information at a minimum:

* IAM Role ARN
* Azure Tenant ID
* Azure App ID URI

## Step 2: Install prereqs

Some of these steps can be skipped if you know you already have the requirements installed. At a minimum, according to the README you will need node 7.6.0 or higher, at this point, at a minimum I would install 8. I will be working through this tutorial using Ubuntu 18.04, the steps may slightly vary until we start working with the npm. I am going to install [nvm](https://github.com/creationix/nvm), a tool for managing Node versions. It also allows everything to execute as you which saves some small headaches.

Installing NVM:

```
~$ wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
# Follow the directions to log out and back into your shell or source it.
~$ nvm install 8
~$ node --version
v8.11.3
```

Now to install the requirements for the AWS CLI:

```
~$ sudo apt install python3-pip 
```

Now that we are done with the basic requirements let's get going.

## Step 3: Install AWS CLI 

All we need to do is run the following command, please note we are using Python 3 therefore, pip3 needs to be used:

```
~$ pip3 install awscli --upgrade --user
~$ export PATH=~/.local/bin:$PATH
~$ source ~/.profile
~$ aws --version
aws-cli/1/15/41 Python/3.6.5 Linux/4.15.0-23-generic botocore/1.10.41
```

## Step 4: Install azure-aws-login

This should be uneventful.

```
npm install -g aws-azure-login
```

## Step 4: Configure and run azure-aws-login

Now we just need to configure the tool using the information we gathered above. 

```
~$ aws-azure-login --configure
Configuring profile 'default'
? Azure Tenant ID: 111aaaa1-11aa-1111-111a-1a11aa1aa11a
? Azure App ID URI: https://signin.aws.amazon.com/saml/app-name
? Default Username: user@domain.com
? Default Role ARN: arn:aws:iam::111111111111:role/my-role
? Default Session Duration Hours (up to 12): 4
```

Now we can login and test it:

```
~$ aws-azure-login
Logging in with...
? Username: user@domain.com
? Password: [hidden] 
? Session Duration Hours (up to 12): 4
Assuming role arn:aws:iam::111111111111:role/my-role
```

## Step 5: Query AWS using CLI

Now we let's get the available regions to make sure it works.

```
~$ aws ec2 describe-regions
{
    "Regions": []    
}
```

That is it, now it is up and running. Now you can use Azure AD to get your credentials to access IAM roles in your AWS account and use those on the command line. You can also configure this to use profiles you desire. All that is needed is to pass --profile when you are configuring *aws-azure-login* and when you call the *aws cli*.
