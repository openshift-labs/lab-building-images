Pushing functionality into the base images also allows you to capture functionality that may not always be required, but is sitting there ready when needed.

One example is the need for a process manager when it is necessary to run more than one application as a daemon process within the same container.

Here we can pre-install the `supervisord` application into the base image, along with logic to run it when custom `supervisord` config file snippets are supplied for running any applications.

Change to the `~/python-base-v4` sub directory:

```execute
cd ~/python-base-v4
```

In this case we changed the `start-container` script. View it by running:

```execute
cat bin/start-container
```

It should contain:

```
#!/bin/bash

if [ -d /opt/app-root/etc/supervisor ]; then
    exec supervisord --configuration /opt/app-root/etc/supervisord.conf --nodaemon
else
    exec warpdrive start
fi
```

In other words, if the directory `/opt/app-root/etc/supervisor` exists, it is assumed that you have placed in that a suitable `supervisord` config file snippet for your application and will run `supervisord`.

Build this base image:

```execute
podman build --no-cache -t python-base:v4 .
```

Now change to the `~/flask-app-v8` sub directory.

```execute
cd ~/flask-app-v8
```

View the contents of the `supervisor` directory which contains the config files:

```execute
ls -las etc/supervisor
```

and look at the `wsgi.conf` file:

```execute
cat etc/supervisor/wsgi.conf
```

It should contain:

```
[program:wsgi]
process_name=wsgi
command=warpdrive start
stdout_logfile=/proc/1/fd/1
stdout_logfile_maxbytes=0
redirect_stderr=true
```

This configures `supervisord` to run `warpdrive start`. You could stick any number of config files in this directory, one for each application you wanted to run and be managed within the same container.

Build the application image:

```execute
podman build --no-cache -t flask-app .
```

and run it:

```execute
podman run --rm -p 8080:8080 flask-app
```

You will see that `supervisord` is started and from it our application is hosted using `mod_wsgi-express`.

Make a web request to check it works:

```execute-2
curl http://localhost:8080
```

Now create an interactive shell within the container:

```execute-2
podman exec -it `podman ps -ql` bash
```

In the container, run `supervisorctl status` to check the state of any managed applications.

```execute-2
supervisorctl --configuration /opt/app-root/etc/supervisord.conf status
```

You can even restart the application without the container being shutdown. This is because it is `supervisord` which is running as process ID 1, and it will keep running.

```execute-2
supervisorctl --configuration /opt/app-root/etc/supervisord.conf restart wsgi
```

If you really wanted to, you could still shutdown the whole container by running:

```execute-2
supervisorctl --configuration /opt/app-root/etc/supervisord.conf shutdown
```

This will cause the managed applications to be stopped, then `supervisord` will be shutdown, and thus the container.
