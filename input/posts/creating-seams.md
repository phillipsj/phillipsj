---
Title: "Creating seams"
Published: 05/27/2017 14:58:30
Tags: 
- Architecture
- Craftsmanship
- Design
---
# Creating seams

This is going to be a post about software architecture and design, the basic concept of how to allow for changes in your software or system by creating these joints or seams you will be able to make changes easily.

// Need to make this a block qoute
To get started, here is the [Merriam-Websters](https://www.merriam-webster.com/dictionary/seam) defintion of **Seam**:

1. the joining of two pieces (as of cloth or leather) by sewing usually near the edge
2. the space between adjacent planks or strakes of a ship
3. line, groove, or ridge formed by the abutment of edges
4. a weak or vulnerable area or gap found a seam

As you can tell, the fourth definition is the one that is what we are going to focus on. We want to put in a *weak* spot in our systems that will allow us to be able to make alterations. This term was first introducted to me in the book, [*Working effectively with Legacy Code*](http://amzn.to/2s8cQhZ) by [Micheal Feathers](https://twitter.com/mfeathers)


// LEgacy code defition

A seam in software is....

## Software Seams

There are many different techniques and tools that help to create these seams. Design patterns like the [Gang of Four](http://amzn.to/2qvPC58) or [SOLID](https://en.wikipedia.org/wiki/SOLID_(object-oriented_design)) principles to name a couple. Below I will go into more details

### Design Patterns

### SOLID Principles

How you create seams in software is straight forward and something you are already doing.  If you are using interfaces and making your implementations depend on those interfaces then you have created a seam. You can inpmlement that interface in a new class and substitute that new class with new behavior into any consumer using that interface. That seam allows you to make implementation changes without effecting any consumers of that interface. This is the principle of **Depedency Inversion** and **Interface Segragation**. 

```
// Put code sample here to demonstrate
```

Another way this can be performed is if you base your implementaiton on a higher level abstraction. So if you are a C# developer you know that a **MemoryStream** inherits from **Stream**. So in your method signature, accept a *Stream*, which will allow you to consume a *MemoryStream*, *FileStream*, *BufferedStream*, etc.

```
// Another code sample.
```

[SOLID](https://en.wikipedia.org/wiki/SOLID_(object-oriented_design))

## Architecture Seams

## Integration Seams

// Almost a whole different post.
Integration seams are always an interesting one for sure. [Jeremy Miller](https://jeremydmiller.com) did a recent post about the [different ways that microsrevices communicate](https://jeremydmiller.com/2017/05/24/how-should-microservices-communicate/). The part I want to focus on is the last section on *Avoiding these integration approaches*. It lists out three type sof integrations that you should try to avoid, I totally agree that you should avoid these types of integrations, I will be using examples where these types of integrations are useful, especially when trying to decouple from legacy systems.

