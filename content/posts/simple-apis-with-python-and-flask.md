---
title: "Simple APIs with Python and Flask"
date: 2020-10-24T13:50:59-04:00
tags:
- Simple APIs
- Open Source
- Python
- Flask
- REST API
---

My post on [Polaris](https://www.phillipsj.net/posts/powershell-rest-api-with-polaris/) started out with me looking at building a simple REST API with Python. I had to pivot a little based on some other limitations, but I will revisit this now. Python is one of those languages that I can't ever seem to use, yet I keep coming back to it. Maybe one of these days, I will get to use it more than I currently do. [Flask](https://flask.palletsprojects.com/en/1.1.x/) keeps building apps simple, and I discovered this library called [Flask-RESTful](https://flask-restful.readthedocs.io/en/latest/) that is really elegant. Unfortunately, there is a GitHub [issue](https://github.com/flask-restful/flask-restful/issues/883), where one of the developers suggests using [MethodViews](https://flask.palletsprojects.com/en/1.1.x/views/#method-based-dispatching) in Flask instead. Given there hasn't been a new release in some time, I thought it would be better to checkout MethodView.

MethodViews allow you to define a class that implements all the HTTP verbs that will serve your API resource. You can designate our routes that align with the methods in that class. It is a clean and straightforward approach that the last time I felt this way was when [Nancy](https://github.com/NancyFx/Nancy) was released for .NET. Let's build a simple API with Flask.

## Installing Flask

We need to create a Python virtual environment, source it, then install Flask.

```Bash
$ mkdir simple-api && cd simple-api
$ python3 -m venv .env
$ source .env/bin/activate
$ pip install Flask
Successfully installed Flask-1.1.2 Jinja2-2.11.2 MarkupSafe-1.1.1 Werkzeug-1.0.1 click-7.1.2 itsdangerous-1.1.0
```

## The Code

With Flask installed, we need to create the Python file that will be our application.

```Bash
$ touch api.py
```

Let's open that in your favorite editor and import the modules we need, which is Flask and the MethodView

```Python
from flask import Flask
from flask.views import MethodView
```

Now we need to create our MethodView, which is our API resource.

```Python
class People(MethodView):
    def get(self, id):
        if id is None:
            return "Returns list of people!"
        else:
            return "Returns single person by id!"

    def post(self):
        return "Creates a new person!"

    def delete(self, id):
        return "Deletes a person by id!"

    def put(self, id):
        return "Updates a person by id!"
```

There isn't much in here. We are just getting the basics in place. Now let's create our Flask application and create our routes.

```Python
app = Flask(__name__)

people_view = People.as_view('people_api')
app.add_url_rule('/people/', defaults={'id': None},
                 view_func=people_view, methods=['GET',])
app.add_url_rule('/people/', view_func=people_view, methods=['POST',])
app.add_url_rule('/people/<int:id>', view_func=people_view,
                 methods=['GET', 'PUT', 'DELETE'])
```

At this point, this would be a fully functional Flask application. I like to make mine executable without the extras, so I make it executable.

```Python
if __name__ == "__main__":
    app.run(debug=True)
```

Here is the complete *api.py* file.

```Python
from flask import Flask, session
from flask.views import MethodView


class People(MethodView):
    def get(self, id):
        if id is None:
            return "Returns list of people!"
        else:
            return "Returns single person by id!"

    def post(self):
        return "Creates a new person!"

    def delete(self, id):
        return "Deletes a person by id!"

    def put(self, id):
        return "Updates a person by id!"

app = Flask(__name__)

people_view = People.as_view('people_api')
app.add_url_rule('/people/', defaults={'id': None},
                 view_func=people_view, methods=['GET',])
app.add_url_rule('/people/', view_func=people_view, methods=['POST',])
app.add_url_rule('/people/<int:id>', view_func=people_view,
                 methods=['GET', 'PUT', 'DELETE'])


if __name__ == "__main__":
    app.run(debug=True)
```

If you install a tool like [HTTPie](https://httpie.org/), we can test it out with the following commands.

#### Get all people

```Bash
$ http http://127.0.0.1:5000/people/
HTTP/1.0 200 OK
Content-Length: 23
Content-Type: text/html; charset=utf-8
Date: Sat, 24 Oct 2020 17:38:55 GMT
Server: Werkzeug/1.0.1 Python/3.8.6

Returns list of people!
```

#### Get a single person

```Bash
$ http http://127.0.0.1:5000/people/1
HTTP/1.0 200 OK
Content-Length: 28
Content-Type: text/html; charset=utf-8
Date: Sat, 24 Oct 2020 17:39:15 GMT
Server: Werkzeug/1.0.1 Python/3.8.6

Returns single person by id!
```

#### Update a person


```Bash
$ http put http://127.0.0.1:5000/people/1 
HTTP/1.0 200 OK
Content-Length: 23
Content-Type: text/html; charset=utf-8
Date: Sat, 24 Oct 2020 17:40:03 GMT
Server: Werkzeug/1.0.1 Python/3.8.6

Updates a person by id!
```

#### Create a person

```Bash
$ http post http://127.0.0.1:5000/people/
HTTP/1.0 200 OK
Content-Length: 21
Content-Type: text/html; charset=utf-8
Date: Sat, 24 Oct 2020 17:41:08 GMT
Server: Werkzeug/1.0.1 Python/3.8.6

Creates a new person!
```

#### Delete a person

```Bash
$ http delete http://127.0.0.1:5000/people/1
HTTP/1.0 200 OK
Content-Length: 23
Content-Type: text/html; charset=utf-8
Date: Sat, 24 Oct 2020 17:41:57 GMT
Server: Werkzeug/1.0.1 Python/3.8.6

Deletes a person by id!
```

## Conclusion

What can I say? I really like Python and many of the libraries/frameworks that are available. All of this was possible in 32 lines of code. I feel it is entirely understandable and clear where to add in the additional logic. Adding more resources would be creating a class, implementing the HTTP methods that you need, and the routes that you want those to have.

Thanks for reading,

Jamie 
