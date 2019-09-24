---
title: "NPM install on Linux without sudo"
date: 2019-09-23T21:59:16-04:00
tags:
- Open Source
- Linux
- Node
---

Requiring admin to install packages is one of the most frustrating things I have working on Linux. Its when I am using a tool that the package manager doesn't automatically expect package installation in the user's home directory. NPM does this when installing global tools, and here is the script I use to fix it. Luckily, [Glen Pike](https://github.com/glenpike) has this script called [npm-g_nosudo](https://github.com/glenpike/npm-g_nosudo) that configures NPM to use your home directory.

**As with all scripts from the internet, please read it before running it. If you have questions, please ask someone to explain it to you.**

Here is what happens before the nosudo script:

```Bash
$ npm install grunt -g
npm WARN checkPermissions Missing write access to /usr/local/lib
npm ERR! path /usr/local/lib
npm ERR! code EACCES
npm ERR! errno -13
npm ERR! syscall access
npm ERR! Error: EACCES: permission denied, access '/usr/local/lib'
npm ERR!  { [Error: EACCES: permission denied, access '/usr/local/lib']
npm ERR!   stack:
npm ERR!    'Error: EACCES: permission denied, access \'/usr/local/lib\'',
npm ERR!   errno: -13,
npm ERR!   code: 'EACCES',
npm ERR!   syscall: 'access',
npm ERR!   path: '/usr/local/lib' }
npm ERR!
npm ERR! The operation was rejected by your operating system.
npm ERR! It is likely you do not have the permissions to access this file as the current user
npm ERR!
npm ERR! If you believe this might be a permissions issue, please double-check the
npm ERR! permissions of the file and its containing directories, or try running
npm ERR! the command again as root/Administrator (though this is not recommended).

npm ERR! A complete log of this run can be found in:
npm ERR!     /home/username/.npm/_logs/2019-09-24T01_55_49_112Z-debug.log
```

Just as expected, I didn't run the command elevated, and it failed. However, we can run the nosudo script and fix that. All this script does is configure from PATH variables that map your NPM packages folder to a directory of your choosing with the default being your home directory. Then it writes those paths to your bashrc file to always map them in your shell. I like to download it first before executing.

Let's download and run the script now:

```Bash
$ wget https://raw.githubusercontent.com/glenpike/npm-g_nosudo/master/npm-g-nosudo.sh
$ chmod +x npm-g-nosudo.sh
$ ./npm-g-nosudo.sh
Choose your install directory. Default (/home/username/.npm-packages) :
Do you wish to update your .bashrc/.zshrc file(s) with the paths and manpaths? [yn] y
Don't forget to run 'source ~/.bashrc'

Done - current package list:

/home/phillipsj/.npm-packages/lib
└── (empty)
```

Now we need to source our updated bashrc, and we can install our global package.

```Bash
$ source ~/.bashrc
$ npm install grunt -g
/home/username/.npm-packages/bin/grunt -> /home/username/.npm-packages/lib/node_modules/grunt/bin/grunt
+ grunt@1.0.4
added 97 packages from 63 contributors in 3.772s
```

That makes the setup a little quicker, and it's what I do on every Linux distro install.

Thanks for reading,

Jamie
