If you are able to abstract out common build and deployment scripts into a base image and the application image `Dockerfile` instructions end up always being the same, you can simplify it even further again using what is called an onbuild image.

This is a special type of base image which includes a set of instructions in the `Dockerfile`, which instead of being executed when the base image is being built, are executed at the start of building any derived image which uses the base image.

Change to the `~/python-onbuild-v1` sub directory:

```execute
cd ~/python-onbuild-v1
```

View the contents of the `Dockerfile`:

```execute
cat Dockerfile
```

It should contain:

```
FROM python-base:latest

ONBUILD COPY --chown=1001:0 . /opt/app-root/

ONBUILD RUN assemble-image

ONBUILD CMD [ "start-container" ]

ONBUILD EXPOSE 8080
```

These are the instructions we had in the `Dockerfile` for the Flask application, but where except for the `FROM` instruction, each is prefixed with `ONBUILD`.

Build the base image. Note that when doing this we are supplying to `podman build` the `--format docker` option. This is because `ONBUILD` is not part of the OCI specification for portable container images, and instead is a feature of the original `docker` image format.

```execute
podman build --format docker -t python-onbuild .
```

These `ONBUILD` instructions will be recorded in the container image manifest, but no action is take at the time the base image is built.

Change to the `~/flask-app-v9` sub directory.

```execute
cd ~/flask-app-v9
```

View the contents of the `Dockerfile` we have now.

```execute
cat Dockerfile
```

All it contains is:

```
FROM python-onbuild:latest
```

Beyond specifying the base image, there are no additional instructions.

Build the image though:

```execute
podman build --format docker --no-cache -t flask-app .
```

and you will see that the instructions from the base image which were prefixed with `ONBUILD` were executed in the context of building the derived image instead.

Thus, the application source files were copied from the directory where the subsequent build is run.

Run the container image:

```execute
podman run --rm -p 8080:8080 flask-app
```

and make a web request:

```execute-2
curl http://localhost:8080
```

The applications works just as it did before.

Stop the container:

```execute-2
podman kill -s TERM `podman ps -ql`
```

Although the `ONBUILD` feature is interesting, that it is not part of the OCI specification it may not be supported by container platforms that support building images for you. Only use it and become dependent on it if you know that your target platforms will support it.
