---
title: "Ask Jamie: Team Function and Organization with DevOps"
date: 2020-11-11T20:19:06-05:00
tags:
- DevOps
- Opinion
- Ask Jamie
---

I am back with another set of questions that were asked on Twitter. It has had a fantastic response and a bunch of questions to explore. I hope everyone is enjoying these as much as I am. Here is the next set.

{{< tweet 1323007979436806144 >}}

## Try to erase or blur the lines

The first one in that tweet is about how to draw lines or, as I interpret, organize. My initial response is that there should be no lines. If we slice up functionality or split responsibilities, I don't feel that the culture is being embraced. Everyone should be participating in the practices as they feel. Not everyone is going want to be involved with DevOps practices, and that's okay within reason. I say within reason because they can choose to not be as involved as long as they are not actively being detrimental to the team. Everyone will have different interests, and people are not interchangeable, so leave room for people to naturally gravitate to the practices that interest them. Since you can see where I am going with these, you may guess how I will answer the questions that follow that one. I feel that product teams should own as much of their stack as possible, including infrastructure, tools, etc. Now there are infrastructure and tools that are orthogonal to a product stack. Those items are probably best managed by a dedicated team. This means we end up with the *it depends* answer, unfortunately. As with most things, continuously experiment with the organization until you find what works best for your team and company.

## Consistency vs. Independence

This is a delicate balance in many ways. Experimenting and trying as many different things is a pillar practice. That very same practice can be carried into this conversation. Decide what items make sense from a company perspective to be consistent, then outline areas that teams are free to choose. Multiple build servers or work trackers don't make a lot of sense from a cost perspective. Now teams picking different build tools within their projects or other analysis tools should be flexible. Hopefully, knowledge is shared, and eventually, consensus will be reached on which tools everyone agrees to use. It may not happen; that is all about picking which arguments are worth having and which are not. My feelings are that as long as teams use a specific class of tools, the particular tool matters less.

An example would be a security scanning tool. There are a few free ones that teams could choose from. If they started all purchasing their own, then there should be a conversation around it. Finding that balance will help with adoption and hopefully prevent people from feeling like something is being forced upon them.

The follow-up was about how much a team can decide what they can do. That really depends on how much support there is from your management. If management is receptive, focus as much on things you or the team can control. This builds confidence and provides proof that you or the team can deliver. Items outside of you or the team can be approached as proof of concept. Take something that is continually causing issues or causing pain, then apply a little *DevOps* to it as a proof of concept. Present that to the team or teams. Don't push too hard as you don't want to drive others away.

## Naysayers

Ah, the naysayers. This is a tough one and one that I still haven't been able to always improve. In many cases, it has come down to people feeling threatened that they will lose their jobs when you start automating and streamlining processes. It is a natural fear, and as someone championing DevOps, you have to be sensitive to that. In a tweet, I stated that I have never experienced anyone being replaced after automating a whole series of things over the years. There is typically so much work to be done in tech and IT with so little staff that the biggest thing I have experienced is not getting to hire more staff. The quality of life improvements when these the culture and practices are adopted has been astonishing to me. 

The research included in the **State of DevOps report** and [Accelerate](https://itrevolution.com/book/accelerate/) is a great place to start with those data-driven. The data is very compelling for those that are willing to learn or listen. I have found socializing the research, discussing it skeptically is more welcoming and gets people interested. 

Lastly, there is always the group that has the anecdotal evidence that it doesn't work or that it isn't possible. This is one of the most challenging groups to discuss culture and practices. I don't like to just give up. I have found that focusing my efforts on applying these has been more effective than winning someone who gets initially defensive. This group may never come around to explicitly, they do seem to be receptive to the results and benefits gained from the adoption. 

My advice is to take what you can get and just keep focusing on removing pain. As pain is removed, more people will get on board with the culture and practices. It will take time and patience. It will come.

## Conlusion

These are all my personal experiences, and all are things that I have tried in some capacity. Socializing these ideas and removing pain has been the most effective to me, along with understanding that people have fear. Some people are afraid they will lose their jobs, some are afraid they will be left behind, some are just afraid to learn new things and fail along the way. Make experimentation and failure acceptable while giving as much space as possible to try new things in a safe environment.

Thanks for reading,

Jamie
