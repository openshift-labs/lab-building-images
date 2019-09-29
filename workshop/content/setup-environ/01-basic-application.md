That was an extended detour but an important one. The result is that we now have a basic recipe for creating a container image which will be portable, offers a better level of security, and can accomodate the security policies of different container runtimes. Time to move onto creating a basic Python web service. For this we will use a Flask application.

Change to the `~/flask-app-v1` sub directory.

```execute
cd ~/flask-app-v1
```

View the contents of the directory:

```execute
ls -las
```

To view the `requirements.txt` file run:

```execute
cat requirements.txt
```

This lists the Python packages our application requires. For now we are installing just the `Flask` package.

The Flask application is defined in the `app.py` file:

```execute
cat app.py
```

The contents of this should be:

```
from flask import Flask, request

app = Flask(__name__)

@app.route("/")
def hello():
    print(request.environ)
    return "Hello, World!"
```

The Flask application returns "Hello, World!" for each request received.

We have also thrown in a `print()` statement to dump out the details of the request as some temporary debugging.

To view the `Dockerfile` run:

```execute
cat Dockerfile
```

The instructions specific to this application are:

```
COPY --chown=1001:0 app.py requirements.txt ./

RUN pip3 install --no-cache-dir --user -r requirements.txt && \
    fix-permissions /opt/app-root

ENV PATH=$HOME/.local/bin:$PATH

EXPOSE 8080

CMD [ "env", "FLASK_APP=app.py", "flask", "run", "--host=0.0.0.0", "--port=8080" ]
```

The `RUN` instruction runs `pip3` to install the Python packages listed in the `requirements.txt` file and fixes up the permissions afterwards.

We used the `--no-cache-dir` option to `pip3` as there is no point caching the downloads. This is because the next build is going to start over fresh anyway. If we don't disable caching, it will just make our image use more space.

Because we installed the Python packages into the per user Python site packages directory, we need to ensure that `$HOME/.local/bin` is included in the application search path.

For the web server we have run the Flask development server, listening on port 8080. This is defined using the `CMD` instruction, with the port also documented used the `EXPOSE` instruction.

We have overridden the host the web server listens on to use "0.0.0.0" so it will accept requests from outside of the container.

Build the container image:

```execute
podman build -t flask-app .
```

and run it:

```execute
podman run --rm -p 8080:8080 flask-app
```

Because it is a web service, we need to expose the port that the requests are being accepted on. This is done using the `-p` option, with the values being the external port to be used, and the port the web server inside of the container is listening on. In this case we used the same port.

We can now make a web request against the application using:

```execute-2
curl http://localhost:8080
```

You will see that the request is logged by the Flask development server, but our debug statement hasn't shown up.

Interrupt the application using:

```execute
<ctrl-c>
```

You should see the application shutdown and the container will exit.

What you should also see at this point is that our debug statement with details of the request were also finally flushed out. It should start out something like:

```
{'wsgi.version': (1, 0), 'wsgi.url_scheme': 'http', ...}
```

Our Python web application works, but there are a few issues here already that we need to improve on.

The first is that our debugging statements output from the application didn't get logged immediately.

The second is that although installing the Python packages into the per user site packages directory worked okay in this case, using it can cause problems.

The third and final one is that we shouldn't be using the Flask development server, and Flask even warns us about that.

We will revisit each of these in subsequent exercises, as well as cover other recommendations on how to structure the container image to make it easier to support and work on.
