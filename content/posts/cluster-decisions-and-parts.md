---
Title: "Cluster Decisions and Parts"
date: 2017-12-24T13:17:56
Tags:
    - Cloud
    - Docker
    - Linux
    - Containers
    - RaspberryPi 
---

# Cluster Decisions and Parts

In my last post I outlined several decisions that I would need to make when deciding how to create my container cluster
using Raspberry Pis. Here are my the parts that I ordered and the all the decisions that I have finalized.

## Parts List

I ordered everything from Amazon because of Prime and selection.

* 3 x [Raspberry Pi 3 Model B](http://amzn.to/2C6i4DQ)
* 3 x [32GB Samsung EVO Select MicroSD](http://amzn.to/2D61MaK)
* 1 x [Anker PowerPort 6](http://amzn.to/2BwTh8n)
* 1 x [HobbyMate Nylon Standoff Spacers](http://amzn.to/2BwURXR)
* 1 x [Anker 8-in-1 USB 3.0 Card Reader](http://amzn.to/2DG8569)

There are only a couple notable items in this list that I feel like I need to explain. The Anker PowerPort 6 is a heck
of a deal, not only does it deliver the power needed, can grow it my my cluster, but it also ships with six one foot
micro usb cables. That saves some money from other options. I also had to add the Anker USB card reader as my desktop
doesn't have one and my Surface has it's slot being used to expand my storage. I decided to not go with a fancy case
just yet, but if I do it will be this [one](http://amzn.to/2zpMTxU).

## Decisions

In my first post I outlined several decisions that I still needed to make and I have to say that all of them have been
decided.

### Container Engine

I would like to really try RKT, however, I am going to stick with Docker. It is a known quantity and it has ARM support.

### Orchestration

It is going to be Kubernetes. It has the momentum at the moment and is going to be less complex than trying to get all
the Apache bits to work.

### Networking

I may regret this decision, but I am going to just go with wireless. I will use my [Google Wifi](http://amzn.to/2l6CKkm)
to assign static IPs.

### Boards

My went with the [Raspberry Pi 3 Model B](http://amzn.to/2C6i4DQ). It is the obvious choice with great support.

### Operation System

I did a little research and asked [Alex Ellis](https://twitter.com/alexellisuk) on Twitter and
apparently [Rasbpian Stretch Lite](https://www.raspberrypi.org/downloads/raspbian/) is now working so that is what I am
going to go with.

---

I don't think there are remaining decisions. I am going to start the build in the next week and I will post up on all
the pieces as I get going.

Thanks for reading.
