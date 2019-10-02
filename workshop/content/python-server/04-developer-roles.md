Breaking out common configuration or functionality into intermediate base images enables it to be shared across multiple application images without needing to duplicate it.

This has the benefit that if a change is needed to address a bug, or you need to add additional packages or functionality, it need only be done in one place.

Any derived images depending on the intermediate image will need to be rebuilt, but it is only a rebuild that would be required and it wouldn't be necessary to be changing the common code in multiple places.

Taking this approach also helps in an organisation in drawing lines between developer roles. There is no need for all developers to be experts on how to create container images. Put those who are the experts in charge of the intermediate base images and the job of maintaining and supporting them. A developer working on the code then doesn't have to worry about it, and can get on with developing the application code.

Operations teams may even want to take responsibility for the intermediate base images to ensure that what they include satisfies their operational requirements around monitoring and security.

Container technology may be the latest cool thing around, but it can still be difficult to do it right. Design things in a way that simplifies things for developers. Using intermediate base images is one way of doing that.

With a goal of simplifying what a typical developer has to deal with, lets update our Python Flask application to use the Python base image.

Change to the `~/flask-app-v2` sub directory.

```execute
cd ~/flask-app-v2
```

View the contents of the directory:

```execute
ls -lasR
```

You will see that the structure has been changed with the application source code moved into the `src` sub directory. We have also created an `bin` directory. This contains an `assemble-image` script which includes the steps to build and install the application source code:

```execute
cat bin/assemble-image
```

and a `start-container` script which says how to start the application.

```execute
cat bin/start-container
```

View the contents of the `Dockerfile` by running:

```execute
cat Dockerfile
```

This now looks like:

```
FROM python-base:latest

COPY --chown=1001:0 . /opt/app-root/

RUN assemble-image

CMD [ "start-container" ]

EXPOSE 8080
```

The set of instructions has therefore been much simplified. In part because we are inheriting from the Python base image, but also because we have pushed the steps for how to assemble the container image into the `assemble-image` script. The `start-container` script in turn contains the instructions to start the application.

Copying the files into the container image has also been simplified by laying out the directories and files so they match where we want them to be installed under `/opt/app-root`. Only a single `COPY` command is then required to copy the completed directory hierarchy into the container image.

Build the new version of the image:

```execute
podman build --no-cache -t flask-app .
```

and run the image:

```execute
podman run --rm -p 8080:8080 flask-app
```

Send a request to the application:

```execute-2
curl http://localhost:8080
```

and when done stop the application.

```execute
<ctrl-c>
```
