---
Title: "Building a Container Cluster"
date: 2017-12-18T19:47:47
Tags:
- Cloud
- Docker 
- Linux
- Containers
---
# Building a Container Cluster

As part of my certification journey, I am going to need to setup a small networking lab. I could easily do this with virtual machines, but that wouldn't be as fun. So I am joining everyone else and I am going to build me a small container cluster to play with. Lots of advantages to building one of these.

### Advantages
* Use Docker more
* Learn about Swarm or Kubernetes
* Learn about networking
* Play with tiny computers.

I can't really think of any disadvantages to doing it. I do have a list of decisions to make. I am going to list them out.  

## Container Engine

I have two choices, I can pick either [Docker](https://www.docker.com/) or [RKT](https://coreos.com/rkt/). Since I just found out about RKT yesterday, I will just go ahead using Docker.

## Container Orchestration

Since I will be using Docker, I have choices. I do not know if [Apache Marathon](https://mesosphere.github.io/marathon/) w/Mesos works with ARM. I will do some research. The only tutorials I have found cover [Kubernetes](https://kubernetes.io/) and [Docker Swarm](https://docs.docker.com/engine/swarm/). I will do a little research and make a decision.

## Networking

Most tutorials use the LAN ports and connect the cluster to a hub. There is tutorial that covers using the WIFI. I think to start I will go with WIFI in my build. It saves a little cost and looks cleaner, although not as cool.

## Board

Ah, the real question. I haven't did a lot of research on alternatives to the Raspberry Pi, so I am going to stick to the well known. So it is a choice between the [Pi 3 Model B](https://www.raspberrypi.org/products/raspberry-pi-3-model-b/) or [Pi Zero W](https://www.raspberrypi.org/products/raspberry-pi-zero-w/). The cost difference isn't much and I think having more compute would be better.

## Operation System

Three choices have seem to be the most common: [Raspbian Jessie](https://downloads.raspberrypi.org/raspbian/images/raspbian-2017-07-05/), [Raspbian Jessie Lite](https://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2017-07-05/), and [HyperiotOS](https://blog.hypriot.com). I will probably use Raspbian Jessie Lite. I need to do some extra research.

<hr>

I will be posting up all the decisions that I made and why I made them. The shopping list will be posted also with a total cost. Expect more posts as I go about building my cluster.
