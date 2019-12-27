---
title: "My CKA Experience"
date: 2019-12-26T20:55:38-05:00
tags:
- CNCF
- Kubernetes
- Cloud
- Open Source
---

I just recently passed the [Certified Kubernetes Administrator](https://www.cncf.io/certification/cka/) exam, and I want to share my experience and advice. 

### Experience

Overall, I felt the experience was perfectly fine. This isn't the first time that I have taken a certification exam remotely. The preparation is the same as the others. Basically, clean your desk leaving only a single computer and screen visible. Place sheets over other things in the room like bookshelves. I route my cables for my webcam, so I rerouted those to have slack as you will need to be able to pan your area with your webcam. I will say that the actual exam was better than the two I had taken with PearsonVue. I will still do remote exams with PearsonVue, but this one was much smoother. There are a few simulators available on GitHub, and there is the one by [Killer.sh](https://www.cncf.io/certification/cka/).

### Advice

If you search for CKA with your favorite search engine, you are going to get a ton of hits for tips, tricks, etc. While I did find those helpful, there are so many different approaches and takes on it that I overwhelmed myself. I do encourage you to look over a few and pick the ones that you think speak to you the best, then stick to it. Here are my takeaways. You can only reference the Kubernetes docs, so you will have to memorize any configuration you need to do for your editor and profile. I spent a few minutes at the start doing the setup.

#### It's all CLI

It's all on the CLI, be comfortable knowing how to do all the things you would generally want to do if you are not used to it.

#### Be comfortable with Vim or Nano

Yep, I used Vim during the exam. I have practiced using Vim over the years, and I am comfortable using it. If you are not, I would suggest you install it and start running through Vim Tutor. You can access that by typing the following in your terminal.

```bash
$ vim tutor
```

Run through it until you are comfortable with the basics. I made heavy used of *dd*, *r*, and *dw*. It was just quicker than doing all those deletes. I would also suggest creating a *.vimrc* file that has your tabs set to two and expanded.

```bash
set tabstop=2
set expandtab
```

I also learned about the [*set paste*](https://coderwall.com/p/if9mda/automatically-set-paste-mode-in-vim-when-pasting-in-insert-mode) command, along with doing visual editing for large blocks of text.

Vim is the default editor for kubectl, so if you want to use Nano, don't forget you will need to set the **KUBE_EDITOR** environment variable to Nano. Remember, if you accidentally end up in Vim, press **ESC** then type **:q** or **:q!** to exit.

```bash
KUBE_EDITOR="nano"
```

#### kubectl configuration 

Many of the CKA posts recommend configuring an alias for kubectl. I personally didn't do that, and I don't think saving those few keystrokes would have made a difference for me. I would suggest that you know how to configure Bash completion. It is one line you that you need to add to the *.bashrc*.

```bash
echo 'source <(kubectl completion bash)' >>~/.bashrc
```

This command can also be found in the Kubernetes documentation [here](https://kubernetes.io/docs/tasks/tools/install-kubectl/#optional-kubectl-configurations), so you can reference that. I do suggest that you keep the phrase, "go slow to go fast" on your mind. Let the autocomplete do its job and don't type like crazy. I feel I make more mistakes trying to type fast then just taking my time and not having to repeat it 5-6 times.

#### kubectl generators and imperative commands

Learn how to use generators to bootstrap your YAML. This information is listed under the [Best Practices](https://kubernetes.io/docs/reference/kubectl/conventions/#best-practices) for kubectl. It's going to be way faster than writing the YAML by hand. 

Imperative commands are just commands that create things without needing YAML. If you are not required to generate YAML for a question or to bootstrap a specific configuration, then don't.  

I will add to this section that there is a [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/) in the docs. 

#### kubectl explain and help

This can be said for any CLI tool. Use the built-in help along with the explain command offered by kubectl. 

#### Online training

Everyone has different styles, I feel the best options are the following.

* [Linux Academy CKA](https://linuxacademy.com/course/cloud-native-certified-kubernetes-administrator-cka/)
* [Certified Kubernetes Administrator with Practice Tests](https://www.udemy.com/course/certified-kubernetes-administrator-with-practice-tests/) on Udemy.

### Parting thoughts

Practice, practice, practice. That's all I can really say. Do the things in the courses as many times as you can until you can do it reflexively, understand the why, and learn the docs. You get to use those during the exam.

Good luck and thanks for reading,

Jamie
