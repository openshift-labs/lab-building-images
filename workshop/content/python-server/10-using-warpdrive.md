By using an `assemble-image` and `start-container` script we have attempted to break out the more complex steps from the `Dockerfile` in order to keep it as simple as possible. The `start-container` script has had to change dependent on the WSGI server we want to use when running a WSGI application, and how we start the application will differ again for other types of web applications.

A big question is whether we can start to encapsulate some of this variation for different application types and web servers in a generic set of `assemble-image` and `start-container` scripts, where hook scripts can be supplied as necessary to handle any variations still required for certain circumstances.

A system which attempts to do just this is the `warpdrive` module. To see how this module can be used, change to the `~/flask-app-v6` sub directory.

```execute
cd ~/flask-app-v6
```

View the contents of the `bin/assemble-image` script:

```execute
cat bin/assemble-image
```

You should find:

```
#!/bin/bash

pip3 install --no-cache-dir warpdrive==0.31.0

warpdrive build

warpdrive fixup /opt/app-root
```

The script installs the `warpdrive` module, then delegates the task of building everything required for the application to `warpdrive` by running `warpdrive build`. The `warpdrive fixup` command is then run to fix up permissions on the directory where the application lives.

View the contents of the `bin/start-container` script:

```execute
cat bin/start-container
```

You should find:

```
#!/bin/bash

exec warpdrive start
```

Like with the builds, the responsibility of starting the application is handed to `warpdrive`, by running `warpdrive start`.

For the simple case of a build, `warpdrive` will install the required packages based on the `requirements.txt` file, but it can do much more.

In the case of starting the application, seeing that a `wsgi.py` file is provided, it will start `mod_wsgi-express` automatically with an appropriate set of options.

To see this in action, build the image:

```execute
podman build --no-cache -t flask-app .
```

and run the application:

```execute
podman run --rm -p 8080:8080 flask-app
```

Check it works by making a web request.

```execute-2
curl http://localhost:8080
```

Stop the container:

```execute-2
podman kill -s TERM `podman ps -ql`
```

Now try running the container again, but this time set the environment variable `WARPDRIVE_SERVER_TYPE=gunicorn`.

```execute
podman run --rm -p 8080:8080 -e WARPDRIVE_SERVER_TYPE=gunicorn flask-app
```

Check that this also works by making a web request.

```execute-2
curl http://localhost:8080
```

Stop the container:

```execute-2
podman kill -s TERM `podman ps -ql`
```

What you will see this time is that the `gunicorn` was run instead of `mod_wsgi-server`. This is because `warpdrive` knows how to run all the popular WSGI servers `gunicorn`, `mod_wsgi-express`, `uwsgi` and `waitress`, and will supply a set of default options which ensures they will work correctly in a container and with reasonable capacity allocated.

All we had to ensure was that the modules for any WSGI servers we wanted to use were installed, which was done in the `requirements.txt` file.

```execute
cat src/requirements.txt
```

If instead of a `wsgi.py` file an `app.py` file were supplied, rather than run a WSGI server, `warpdrive` will run it as `python app.py`. If the `app.py` need to be run with special options, or you wanted to take complete control of starting the application, you could instead supply an `app.sh` file and it would be run.

If you are instead using a web framework like Django, `warpdrive` will even detect that, will still use the production grade WSGI server you choose, but will also ensure that it is automatically setup to also host static media assets. Hosting of static media assets will be handled using the web server if it supports it, or by injecting the WhiteNoise middleware into the application to handle it if necessary.

In all cases, `warpdrive` will if the web server or application requires it, run it in a way that reaping of zombie processes is handled.

In other words, `warpdrive` is magic, and can handle all the hard work of running the build steps to setup an application and then run it.

More details on `warpdrive` can be found on [PyPi](https://pypi.org/project/warpdrive/) and by watching the YouTube video [Warpdrive, making Python web application deployment magically easy](https://www.youtube.com/watch?v=y_vwvqgRZK0). The project has been in stasis for the last couple of years, but the project is going to be rebooted and an attempt made to fill out the documentation for it.
