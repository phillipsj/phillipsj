---
Title: "Creating seams"
Published: 10/30/2017 20:39:56
Tags: 
- Architecture
- Craftsmanship
- Design
---
# Creating seams

This is going to be a post about software architecture and design, the basic concept of how to allow for changes in your software or system. By creating these joints or seams you will be able to make changes easily.

// Need to make this a block quote
To get started, here is the definition of **Seam**:

> 1. the joining of two pieces (as of cloth or leather) by sewing usually near the edge
> 2. the space between adjacent planks or strakes of a ship
> 3. line, groove, or ridge formed by the abutment of edges
> 4. a weak or vulnerable area or gap found a seam
> ^^ Merriam-Webster's

As you can tell, the fourth definition is the one that is what we are going to focus on. We want to put in a *weak* spot in our systems that will allow us to be able to make alterations. This term was first introduced to me in the book, [*Working effectively with Legacy Code*](http://amzn.to/2DHgA0L) by [Michael Feathers](https://twitter.com/mfeathers)

> A seam is a place where you can alter behavior in your program without editing it in that place.
> ^^ Michael Feathers, Working effectively with Legacy Code

## Software Seams

There are many different techniques and tools that help to create these seams. Design patterns like the [Gang of Four](http://amzn.to/2D67YzB) or [SOLID](https://goo.gl/8cfmsN) principles to name a couple. Below I will go into more detail.

### Design Patterns

There are many design patterns that allow you to introduce *seams* into your software. The *Builder* pattern allows you to construct different representations of objects. The *Facade* pattern allows you to abstract out a subsystem, which creates a seam for you to introduce a different subsystem that supports the *Facade's* contract. There is the *Decorator* pattern that allows you to extend a class without disrupting the expected contract. The last one I am going to mention is the *Adaptor* pattern, which allows you to convert one interface into another that your receiving objects expect. I will leave the rest of the patterns up to you to see how they provide seams.

### SOLID Principles

How you create seams in software is straight forward and something you are already doing.  If you are using interfaces and making your implementations depend on those interfaces then you have created a seam. You can implement that interface in a new class and substitute that new class with new behavior into any consumer using that interface. That seam allows you to make implementation changes without effecting any consumers of that interface. This is the principle of **Dependency Inversion** and **Interface Segregation**. 

Another way this can be performed is if you base your implementation on a higher level abstraction. So if you are a C# developer you know that a **MemoryStream** inherits from **Stream**. So in your method signature, accept a *Stream*, which will allow you to consume a *MemoryStream*, *FileStream*, *BufferedStream*, etc.

## Architecture Seams

One could argue that design patterns and SOLID principles are all part of architecture and I wouldn't disagree. There still remains those higher level concepts that need addressed. Decisions of how each subsystem, groups of objects, communicate to build a complete application. The same techniques that are used to keep objects loosely coupled but tightly integrated apply to architecture. You put in the correct abstractions between subsystems to keep them from requiring specific implementations. 

This isn't a comprehensive list, but just a couple examples.

### Mediator Pattern

The [mediator](https://en.wikipedia.org/wiki/Mediator_pattern) pattern encapsulates the interactions between sets of objects, subsystems, in a single object.  The mediator holds and handles the message that needs to be communicated between the subsystems. This creates a seam as you can change or add subsystems that listens for that message. The [MediatR](https://github.com/jbogard/MediatR) project and the message bus in [MVVM Light](http://www.mvvmlight.net/) are examples of how this can be used.

### Gateway Pattern

The [gateway](https://www.martinfowler.com/eaaCatalog/gateway.html) pattern is an object used to encapsulate external services. The idea is that you don't want to leak an external service into your application. To keep from doing that, you wrap that external service in a gateway object, now your system depends on your abstract implementation of the service, not the concrete implementation. This gives you a seam that would allow you to change the external service and not require you to change your code to accommodate that change.

## Integration Seams

We are now to the part that sparked this whole post. The concepts we have learned so far also apply to system integrations. 

Microservices is an example of single responsibility. 

Enterprise Service Bus is an example of the mediator and gateway patterns.

When you start thinking of system integration in terms that you already understand, it starts making it easier to reason about system integration. There are tons of tools available to aid you in adding these seams.

### API Gateway

The [API gateway pattern](http://microservices.io/patterns/apigateway.html) provides a gateway between your API consumer and your API implementation. This allows you to change the implementation without having to change the consumer. Other nice advantages of the API gateway is that some implementations collect analytics and provide authentication.

### Enterprise Service Bus

An enterprise services bus, ESB for short, provides some extra functionality, but gives you a seam that can decouple processes and systems. Most ESBs have functionality that handles relaying information, providing message queues, etc. Which all afford you flexibility when you have to integrate with external systems.

### Service Oriented Architecture

Service oriented architecture, SOA for short, can represent many things, but typically is used in reference to platforms that are monolithic in nature that provide integration, ETL, service bus, and much more. When I hear SOA, I can quickly fall into the trap of thinking about products like Oracle SOA Suite, IBM WebSphere, Mule ESB, etc. However, service oriented architecture is all about creating services that provide discrete contexts for performing work. It is worth mentioning that microservices are the same thing with a different priority placed on the *how* it is done. Having functionality be discrete allows services to be interchanged by changing the address the service call is being made. As long as the new service implements the existing contract they can be easily interchanged. This is within itself a type of seam. There are some specific types of services that are worth discussing in more detail.

Integration seams are always an interesting one for sure. [Jeremy Miller](https://jeremydmiller.com) did a recent post about the [different ways that microservices communicate](https://jeremydmiller.com/2017/05/24/how-should-microservices-communicate/). The part I want to focus on is the last section on *Avoiding these integration approaches*. It lists out three types of integrations that you should try to avoid, I totally agree that you should avoid these types of integrations, I will be using examples where these types of integrations are useful, especially when trying to decouple from legacy systems.

#### Publishing file drops to the file system and monitoring folders

I think this should be one of the last options. It does, at times, provide a way to decouple legacy systems. Typically, the system doing the file drop can change without the monitoring system caring how the file was placed into the folder. This would allow you to replace one of the legacy systems that generates the file with a different or more modern system that can create the same data file.

#### Publishing files to FTP servers

This isn't all that different from above. It is a complete headache to have to support and do, you do feel like you are giving up on life to do it this way. On a positive side, it does create a loosely coupled system that doesn't really care what generates the file, just as long as it gets uploaded to the FTP site.

#### Integration through shared databases. 

This one can create a huge mess and couple systems together that you would have never have dreamed were coupled. There are a few techniques you are going to have to do if you go down this road. When this is necessary to do to make changes to legacy systems and to dig yourself out of this hole, just make sure to use these safe guards.

* Always try to put your use of a shared table behind a database view. If you use a database view, then the underlying table can change, be moved, or replaced. Now you have a seam, think of a view as an interface. 
* Consider using stored procedures which can also create that abstraction between the actual table and the app.
* Place database objects like views or shared procedures in a separate schema/owner in the database. That way you can restrict access so others don't start using these objects or even know these exist.

As you can see this is a lot of overhead, but sometimes it is necessary.

## Conclusion

This is just a quick overview of some of the approaches that I have been wanting to catalog and describe. If you feel that something was misrepresented or poorly worded, please let me know. If you think I need to include more or different examples, please let me know.

Thanks for reading.

