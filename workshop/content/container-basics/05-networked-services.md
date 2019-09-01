All the containers you have run so far remained attached to the terminal from which they were run. The output from the container was displayed to the terminal and you only got the command prompt back when the container was stopped.

Long lived network services run in a container will need to be detached from the terminal and run as a background process.

To run a web server using the `busybox` image, which serves up files from the local `htdocs` directory run:

```execute
podman run --rm -d --name httpd -p 80:80 -v `pwd`/htdocs:/htdocs busybox httpd -f -h /htdocs -vv
```

The `-d` option to `podman run` causes the container to be detached from the terminal and run in the background.

To allow us to more easily identify and interact with the container, we use the `--name` option to give it the name `httpd`.

As the web server is a network service, we need to specify the network ports it exposes. This is done using the `-p` option.

The `-v` option is used to mount the local `htdocs` directory into the container so the web server can access the files it contains.

Finally, for the command run in the container, we use `httpd -f -h /htdocs -vv`.

The `-f` option to `httpd` ensures that the web server runs as a foreground process within the context of the container. If this is not done, the container would exit immediately. The `-h` option gives the location of the files to serve, and `-vv` enables verbose logging.

To verify that the container is running, run:

```execute
podman ps
```

To tail the output from the container, run:

```execute
podman logs -f httpd
```

Instead of the container ID, we use the `httpd` name we assigned to the container. The `-f` option says to tail the log files continually.

To make a web request against the web server run:

```execute-2
curl localhost
```

As the container has been detached from the terminal, to stop the container you need to run:

```execute-2
podman stop --timeout 2 httpd
```
