---
Title: Repository Pattern with Postgres.py
Published: 2014-03-05 19:00:00
Tags:
- Python
- Postgres
RedirectFrom: blog/html/2014/03/05/repository_pattern_with_postgres_py.html
---


At [PyTennessee](http://www.pytennessee.org/) I attended a presentation about ‘Postgres.py’_.  It is a nice simple interface.  The presentation and one of the project creators was no other
than ‘Chad Whitacre’_.  If you haven’t met Chad Whitacre then you are missing out.  He is a great example of someone who is truly an ambassador of the community.  During the presentation
there were lots of discussion about accessing data and it seems there was a focus on using the ‘active record’_ pattern.  However, I feel that the library would lend itself to the use of the [repository](http://martinfowler.com/eaaCatalog/repository.html) pattern. Without any more here is the [gist](https://gist.github.com/phillipsj/9367366).

```
from postgres.orm import Model
from postgres import Postgres

class Foo(Model):
        typname = "foo"

class FooRepository(connection_string):
        def __init__(self):
                self.db = Postgres(connection_string)
                self.db.register_model(Foo)

        def get_all(self):
                return self.db.all("SELECT foo.*::foo FROM foo")


repo = FooRepository("<connection-string>")

foos = repo.get_all()
```