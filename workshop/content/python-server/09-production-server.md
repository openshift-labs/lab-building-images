For WSGI applications, production grade Python web servers such as Apache/mod_wsgi, gunicorn and uWSGI will all correctly reap zombie processes when used in a container.

As to which production WSGI server you might use, it usually comes down to personal preference as for a typical Python WGSI application the performance will be similar if they are set up correctly.

A few things to keep in mind are:

* The gunicorn WSGI server cannot handle serving of static files itself and you need to use a separate web server, or use a WSGI middleware such as WhiteNoise. The gunicorn server defaults to a single process with a single thread so needs to be reconfigured to increase capacity.

* The uWSGI server is usually paired with nginx and when used standalone in HTTP mode is not as performant. It can handle serving of static files, but again this is not as performant. The uWSGI server defaults to a single process with a single thread so needs to be reconfigured to increase capacity. Various other configuration changes will also be required to be set to enable master mode, threading, thundering heard support, disabling of multiple interpreter support, correct termination on signals, and more.

* For Apache/mod_wsgi you can use `mod_wsgi-express`, which can be installed using `pip`, with it automatically generating the Apache configuration so you don't have to set anything up. The `mod_wsgi-express` server configuration was actually designed with containers in mind and so has a default configuration that should work well with containers out of the box for most use cases. The default configuration is better than the default options used if you were configuring Apache/mod_wsgi yourself. The `mod_wsgi-express` server defaults to a single process for the WSGI application, with five threads for handling requests. Because Apache is used and setup for you it can handle static serving without you needing to use a separate web server.

To use Apache/mod_wsgi a couple of changes are needed to our Flask application.

Change to the `~/flask-app-v5` sub directory to review the changes.

```execute
cd ~/flask-app-v5
```

View the `requirements.txt` file by running:

```execute
cat src/requirements.txt
```

The `mod_wsgi` package has been added. As the Apache HTTPD web server is required that also needs to be installed, but this was already installed as part of the Python base image.

The `run.sh` file is then updated to use `mod_wsgi-express`.

```execute
cat etc/run.sh
```

It has been set to:

```
#!/bin/bash

ARGS=""

ARGS="$ARGS --port 8080"

ARGS="$ARGS --log-to-terminal"

ARGS="$ARGS --access-log"

if [ x"$MOD_WSGI_PROCESSES" != x"" ]; then
    ARGS="$ARGS --processes $MOD_WSGI_PROCESSES"
fi

if [ x"$MOD_WSGI_THREADS" != x"" ]; then
    ARGS="$ARGS --threads $MOD_WSGI_THREADS"
fi

if [ x"$MOD_WSGI_MAX_CLIENTS" != x"" ]; then
    ARGS="$ARGS --max-clients $MOD_WSGI_MAX_CLIENTS"
fi

if [ x"$MOD_WSGI_RELOAD_ON_CHANGES" != x"" ]; then
    ARGS="$ARGS --reload-on-changes"
fi

exec mod_wsgi-express start-server $ARGS wsgi.py
```

The `mod_wsgi-express start-server` command needs to be told to log to the terminal (`stdout`) and we override the port to listen on. Enabling of request logging is optional and that has also been set.

Other configuration has been added to allow you to tune the server capacity through environment variables if necessary to better match the requirements of your specific WSGI application, and utilise any memory or CPU quota that may be applied to your container.

The `wsgi.py` file being used already had the WSGI application entry point callable called `application`. If it was a different name you can set the `--callable-object` option to `mod_wsgi-express`.

Build the image by running:

```execute
podman build -t flask-app .
```

Run the image:

```execute-2
podman run --rm -p 8080:8080 flask-app
```

and make a web request:

```execute-2
curl http://localhost:8080
```

Although a production grade server, if you needed to do some code changes in the container to quickly test something, with the `run.sh` script above, automatic code reloading can be enabled for `mod_wsgi-express` by setting the required environment variable when running the container.

Stop the container:

```execute
podman kill -s TERM `podman ps -ql`
```
