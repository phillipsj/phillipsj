---
title: "Creating Windows Services With Go"
date: 2022-02-14T21:37:36-05:00
tags:
- go
- golang
- gopher
- Open Source
- OSS
- Windows
- Windows Services
---

Go ships with lots of functionality in the standard library. Once of those packages allows you to create Windows Services using Go. I am going to show you how to create an application that will log environment variables that can be ran standalone or registered as a Windows service. Let's get started.

## Basic Application

We will be using one external library which is [logrus](https://github.com/Sirupsen/logrus). Here is the basic application without any Windows Service functionality.

```Go
package main

import (
	"os"

	"github.com/sirupsen/logrus"
)

var log = logrus.New()

func main() {
	// gets all environment variables
	envs := os.Environ()

	file, err := os.OpenFile("enviroservice.log", os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0666)
	if err == nil {
		log.Out = file
	} else {
		log.Info("failed to log to file, using default stderr")
	}

	log.Info("current environment is:")
	for _, e := range envs {
		log.Info(e)
	}
	log.Info("complete")
}
```

We can run this to see if we get our log file.

```Bash
go run main.go
```

If we open the log file the environment variables should be printed out.

```
time="2022-02-14T21:54:45-05:00" level=info msg="current Environment is:"
time="2022-02-14T21:54:45-05:00" level=info msg="ALLUSERSPROFILE=C:\\ProgramData"
time="2022-02-14T21:54:45-05:00" level=info msg="ChocolateyInstall=C:\\ProgramData\\chocolatey"
time="2022-02-14T21:54:45-05:00" level=info msg=complete
```

We are now ready to create a Windows Service using this application.

## Creating a Windows Service

