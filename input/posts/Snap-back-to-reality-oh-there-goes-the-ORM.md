---
Title: 'Snap back to reality, oh, there goes the ORM'
Published: 2015-04-09 20:00:00
Tags:
- ORM
- Dapper
- Reality
RedirectFrom: blog/html/2015/04/09/snap_back_to_reality_oh_there_goes_the_orm.html
---

I find myself going down this rabbit hole every six months it seems. I get lured in by the promises of an ORM. First it was [Castle’s Active Record](http://www.castleproject.org/projects/activerecord/), then Linq2SQL, then Entity Framework, finally I settled on [NHibernate](http://nhibernate.info/) as it worked better than others and I just liked the feel of it all. Then I discovered [Dapper](https://github.com/StackExchange/dapper-dot-net), oh how I really like Dapper. Dapper provides just enough abstraction to ADO .NET that I do not have to fiddle with data adapters or readers, or build commands. It provides all the power of SQL that I find that I need and all the object mapping I could want.

The hardest issue that I have with Dapper after using an ORM that bites me every time is the easy resolution of related objects. The building of an [object graph](http://www.elegantcoding.com/2011/08/object-graph.html) with an ORM is just an after thought until those [N+1 issues](http://ayende.com/blog/1328/combating-the-select-n-1-problem-in-nhibernate) creep up or you realize that you are retrieving so much extra cruft that you just don’t really need. The great part about Dapper is that those things have to be intentianal and at times feel really manual, however, I have found that execute the extra queries to build an object with relations is actually faster most of the time, and if it isn’t I do not take the penalty throughout the entire applicaiton.

Just had this on my mind and thought I would share. Hopefully the future me doesn’t keep falling in this, “It looks so easy” trap and I just stick with using a micro orm, that provides just enough.