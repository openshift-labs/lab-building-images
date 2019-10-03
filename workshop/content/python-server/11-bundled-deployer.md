If you were to use something like `warpdrive`, or develop your own set of scripts for building and deploying your application, to ensure that it was used as the first choice for all Python applications in your organisation, there is no reason why you couldn't bundle it with the common Python base image. This way you avoid everyone doing their own thing and the image for every different application being a snowflake that doesn't resemble any others. This will make it easier to support and maintain everything as all will use the same deployer.

To do this, it is just a matter of pushing the `assemble-image` and `start-container` script into the common Python base image and the application image `Dockerfile` executes them from the base image.

Change to the `~/python-base-v3` sub directory:

```execute
cd ~/python-base-v3
```

List the `bin` directory:

```execute
ls -las bin
```

These are the same scripts as we used in the last version of the Flask application.

Build the base image.

```execute
podman build --no-cache -t python-base .
```

Change to the `~/flask-app-v7` sub directory:

```execute
cd ~/flask-app-v7
```

List what directories and files we now have:

```execute
ls -lasR
```

Now we only have the `src` directory and the application code. There are no scripts for doing the build and deployment as they are part of the base class.

Build the application image:

```execute
podman build --no-cache -t flask-app .
```

and run it:

```execute
podman run --rm -p 8080:8080 flask-app
```

Make a web request:

```execute-2
curl http://localhost:8080
```

and shutdown the container when done.

```execute-2
podman kill -s TERM `podman ps -ql`
```
