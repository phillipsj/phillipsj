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
To get started, here is the defintion of **Seam**:

> 1. the joining of two pieces (as of cloth or leather) by sewing usually near the edge
> 2. the space between adjacent planks or strakes of a ship
> 3. line, groove, or ridge formed by the abutment of edges
> 4. a weak or vulnerable area or gap found a seam
> ^^ Merriam-Websters

As you can tell, the fourth definition is the one that is what we are going to focus on. We want to put in a *weak* spot in our systems that will allow us to be able to make alterations. This term was first introducted to me in the book, [*Working effectively with Legacy Code*](http://amzn.to/2s8cQhZ) by [Micheal Feathers](https://twitter.com/mfeathers)

> A seam is a place where you can alter behavior in your program without editing in in that place.
> ^^ Micheal Feathers, Working effectively with Legacy Code

## Software Seams

There are many different techniques and tools that help to create these seams. Design patterns like the [Gang of Four](http://amzn.to/2qvPC58) or [SOLID](https://goo.gl/8cfmsN) principles to name a couple. Below I will go into more details

### Design Patterns

There are many design patterns that allow you to introduce *seams* into your software. The *Builder* pattern allows you to construct different representations of objects. The *Facade* pattern allows you to abstract out a subsystem, which creates a seam for you to introduce a different subsystem that supports the *Facade's* contract. There is the *Decorator* pattern that allows you to extend a class without disrupting the expected contract. The last one I am going to mention is the *Adaptor* pattern, which allows you to convert one interface into another that your recieving objects expect. I will leave the rest of the patterns upt to you to see how they provide seams.

### SOLID Principles

How you create seams in software is straight forward and something you are already doing.  If you are using interfaces and making your implementations depend on those interfaces then you have created a seam. You can inpmlement that interface in a new class and substitute that new class with new behavior into any consumer using that interface. That seam allows you to make implementation changes without effecting any consumers of that interface. This is the principle of **Depedency Inversion** and **Interface Segragation**. 

Another way this can be performed is if you base your implementaiton on a higher level abstraction. So if you are a C# developer you know that a **MemoryStream** inherits from **Stream**. So in your method signature, accept a *Stream*, which will allow you to consume a *MemoryStream*, *FileStream*, *BufferedStream*, etc.

## Architecture Seams

One could argue that design patterns and SOLID principles are all part of architecture and I wouldn't disagree. There still remains those higher level concepts that need addressed. Decisions of how each subsystem, groups of objects, communicate to build a complete application. The same techniques that are used to keep objects loosely coupled but tightly integrated apply to architeture. You put in the correct abstractions between subsystems to keep them from requiring specific implementations. 

This isn't a comprehensive list, but just a couple examples.

### Mediator Pattern

The [mediator](https://en.wikipedia.org/wiki/Mediator_pattern) pattern encapsulates the interactions between sets of objects, subsystems, in a single object.  The mediator holds and handles the message that needs to be communicated between the subsystems. This creates a seam as you can change or add subsystems that listens for that message. The [MediatR](https://github.com/jbogard/MediatR) project and the message bus in [MVVM Light](http://www.mvvmlight.net/) are examples of how this can be used.

### Gateway Pattern

The [gateway](https://www.martinfowler.com/eaaCatalog/gateway.html) pattern is an object used to encapsulate external services. The idea is that you don't want to leak an external service into your application. To keep from doing that, you wrap that external service in a gateway object, now your system depends on your abstract implementation of the service, not the concrete implementation. This gives you a seam that would allow you to change the external service and not require you to change your code to accomadate that change.

## Integration Seams

We are now to the part that sparked this whole post. The concepts we have learned so far also apply to system integrations. 

Microservices is an example of single responsibility. 

Enterprise Service Bus is an example of the mediator and gateway patterns.

When you start thinking of system integration in terms that you already understand it starts making it easier to reason about system integration. There are tons of tools available to aid you in adding these seams.

### API Gateway

The [API gateway pattern](http://microservices.io/patterns/apigateway.html) provides a gateway between your API consumer and your API implementation. This allows you to change the implementation without having to change the consumer. Other nice advantages of the API gateway is that some implementations collect analytics and provide authentication.

### Enterprise Service Bus

An enterprise services bus, ESB for short, provides some extra functionality, but gives you a seam that can decouple processes and systems. Most ESBs have functionality that handles relaying information, providing message queues, etc. Which all gives you flexibility when you have to integrate with external systems.

### Service Oriented Architecture

Service oriented architecture, SOA for short, can represent many things, but typically is used in reference to platforms that provide 

// Almost a whole different post.
Integration seams are always an interesting one for sure. [Jeremy Miller](https://jeremydmiller.com) did a recent post about the [different ways that microsrevices communicate](https://jeremydmiller.com/2017/05/24/how-should-microservices-communicate/). The part I want to focus on is the last section on *Avoiding these integration approaches*. It lists out three type sof integrations that you should try to avoid, I totally agree that you should avoid these types of integrations, I will be using examples where these types of integrations are useful, especially when trying to decouple from legacy systems.

