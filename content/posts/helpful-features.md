---
Title: "Helpful Features"
date: 2018-03-17T20:30:37
Tags: 
- Open Source
- Developer Experience
- Django
- Grails
- Spring Boot
---
# Helpful Features

I have been learning other languages and frameworks. The frameworks that I have been learning are [Django](https://www.djangoproject.com/), [Grails](https://grails.org/), and [Spring Boot](https://projects.spring.io/spring-boot/). Each of of these frameworks bring a few interesting features to the table. Some of those features have been borrowed from frameworks like [Rails](http://rubyonrails.org/). 

I have been using ASP .NET MVC since the version 2.0 beta. It has come a long way, but it seems that it just doesn't have some of these interesting features. I am going to highlight some of these features, I know some are trivial to implement, but I feel they would bring a lot to the table when rapid prototyping or introducing the framework to someone new.

## Handling NULLs

I often find myself doing the following in .NET.

```
public ViewResult Details(int id)
{
    var book = db.books.find(id);
    if(book == null){
        return NotFound();
    }
    return View(book);
}
```

There are other *null* checks that we could perform or other ways to handle it. In Django, this would be how this would be done.

```
def details(request, book_id):
    book = get_object_or_404(Book, pk=book_id)
    return render(request, 'books/details.html', {'book': book})
```

That is a nice and simple concept. It handles the *null* check and it does all the logic for you.  In C# what would look something like this:

```
public ViewResult Details(int id)
{
    return ViewOrNotFound<Book>(id);
}
```

I would make it generic, that way it would autowire up the entity framework items.

## Autowiring the ORM

Django and Grails do an awesome job wiring up the ORM for you. It infers the confguration based on the models that you have defined. I think *Entity Framework* should be able to do it. Here is the configuration for entity framework.

```
public class BooksContext : DbContext
{
    public DbSet<Book> Books { get; set; }
       
    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        optionsBuilder.UseSqlServer(@"Server=(localdb)\mssqllocaldb;Database=MyDatabase;Trusted_Connection=True;");
    }
}
```

Then in my ASP .NET MVC project, I have to tell it I am going to use it. Since I know I have a **Book** model in my models folder, why can't I just do the following in the **Startup** class.

```
services.AddEntityFramework(true); // The true is to autowire, default would be false.
```

It can infer the database connection info from the *web.config* and it can infer the context from the models too. Then it would be easy to prototype, but you wouldn't be stuck once you needed to move past it. That is a common complaint with Rails, once you hit the limits, it hurts. This way easy default configs could be applied, but not take away your power.

## REST APIs from Models

Grails has some really cool features that I think are handy. The one that jumps out at me is the way it handles creating REST APIs.

In C# you would have to do the following:

```
    [Route("api/[controller]")]
    public class BooksController : Controller
    {
        // GET api/books
        [HttpGet]
        public IEnumerable<string> Get()
        {
            return new Book[] { book1, book2};
        }

        // GET api/books/5
        [HttpGet("{id}")]
        public string Get(int id)
        {
            return book5;
        }

        // POST api/books
        [HttpPost]
        public void Post([FromBody]string value)
        {
        }

        // PUT api/books/5
        [HttpPut("{id}")]
        public void Put(int id, [FromBody]string value)
        {
        }

        // DELETE api/books/5
        [HttpDelete("{id}")]
        public void Delete(int id)
        {
        }
    }
```

That is a lot of boilerplate to get a basic REST API up and running. We haven't even defined the model that is being used. Now lets compare that to Grails.

In Grails, all you have to do is define your model and add an attribute.

```
import grails.rest.*

@Resource(uri='/books')
class Book {

    String title

    static constraints = {
        title blank:false
    }
}
```

That attribute creates a full blown REST API based off the model and creates all your URL mappings. This is super helpful when prototyping and gettting started quickly. You can easily add a custom controller when you need to take more control or when the default doesn't cut it anymore.

## HTML is just another view

Grails also handles content negotiation like a *BOSS*. It treats HTML, JSON, and XML exactly the same. You can just do this in your controller:

```
class BookController {

    def list() {
        def books = Book.list()
        render books
    }
}
```

The header or the extension is inspected and the appropriate representation is returned. So if you send text/html you get an HTML page. If you send applicaton/json then you get JSON returned. Grails also provides a cool JSON view option that allows you to use a template to structure your JSON if you need something custom.

## Spring Boot Starters

Starters are a really nice feature that is offered. It allows you to choose the base configurations and depedencies to achieve a specific goal defined by the starter. A nice example is the *spring-boot-starter-aop* which gives you aspected oriented programming using AspectJ.

## That's all

Thanks for reading through this list, I hope as I learn more, that I can create another one of these. I think these are really cool features that make getting up and running easier, but doesn't limit you from moving beyond.
