---
Title: "Running Falcon from a Windows Container"
date: 2018-06-26T21:20:29
Tags:
- Docker
- Cloud
- Python 
- Windows Container
---
# Running Falcon from a Windows Container

I haven't shown much love for Windows lately, so I felt like doing a post about deploying a [Falcon](https://github.com/falconry/falcon) app to a [Windows Server Core](https://docs.microsoft.com/en-us/windows-server/administration/server-core/what-is-server-core) container. This should be pretty quick.

Let's build our Falcon app.

Open a PowerShell and enter the following, I assume you have Python 3.6.x installed.

Create your virtual environment first.

```
~$ python -m venv ./venvs/falcon
```

Now activate it.

```
~$ .\venvs\falcon\Scripts\Activate.ps1
(falcon) ~$
```

Install Falcon and uWSGI into that virtual environment.

```
~$ pip install falcon waitress
```

Now create the folder for your code.

```
~$ mkdir falcon
~$ cd falcon
```

We will not need any additional packages so let's freeze our requirements.

```
~$ pip freeze > requirements.txt
```

We will use the create a super simple example of a falcon app. Once the falcon code has been created save it as **app.py**. Since we installed [waitress](https://github.com/Pylons/waitress), which is a WSGI server that runs on Windows, we will import and use it in this example.

```
import falcon
from waitress import serve

class HelloWorld(object):
    def on_get(self, req, resp):
        """Handles GET requests"""
        resp.status = falcon.HTTP_200  
        resp.body = '{"message": "Hello world!"}'

app = falcon.API()

hello_world = HelloWorld()

app.add_route('/', hello_world)

serve(app, listen='*:8080')
```

Now you can run it with the following:

```
~$ python .\app.py
```

Navigate to the following [http://127.0.1.1:8080/](http://127.0.1.1:8080/) and you should get back a simple JSON message. Now our app works. 

Finally, we are to the point we are going to wire up the container. The Python foundation is awesome and provides pre-baked images for Windows Server Core. Here is the Dockerfile that we need to create.

```
FROM python:3.6.5-windowsservercore-1709

COPY . /app
WORKDIR /app
RUN pip install -r requirements.txt

ENTRYPOINT ["python"]
CMD ["app.py"]
```

This should all look pretty standard. Now it is time to build the image, just know there will be a few warnings about the path. These are not critical for this example.

```
~$ docker build -t falcon .
```

Now let's run it, we will use a different port to show it is working.

```
~$ docker run -d -p 3000:8080 falcon
```

Navigate to [http://localhost:3000](http://localhost:3000) and the message from above should be seen.

Hope someone finds this helpful and that Python runs just fine on Windows containers.
