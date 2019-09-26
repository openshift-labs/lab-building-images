Creating a container image interactively by running commands in a running container, or from a tarball created from a saved container image have their uses, but the primary way used to create container images is using a `Dockerfile`.

Change location to the `~/greeting-v1` sub directory.

```execute
cd ~/greeting-v1
```

List the files in the directory.

```execute
ls -las
```

The `Dockerfile` defines the details of the base image from which a new container image is to be created, along with the instructions to create it. View the contents of the `Dockerfile` by running:

```execute
cat Dockerfile
```

You should see:

```
FROM busybox:latest

COPY hello goodbye /

CMD [ "/hello" ]
```

The `FROM` instruction in the `Dockerfile` gives the name of the base image.

The `COPY` instruction is used to copy files from the local directory into the image.

The `CMD` instruction is used to set the command which should be run if the container image is run without specifying an explicit command.

To build a container image using the instructions in the `Dockerfile` run:

```execute
podman build -t greeting .
```

Look at the layers of the container image by running:

```execute
podman history greeting
```

The output should be similar to:

```
ID             CREATED         CREATED BY                                      SIZE      COMMENT
460214264921   9 minutes ago   /bin/sh -c #(nop) CMD [ "/hello" ]              0B
8021112aa5fe   9 seconds ago   /bin/sh -c #(nop) COPY hello goodbye /          3.072kB
19485c79a9bb   2 weeks ago     /bin/sh -c #(nop) CMD ["sh"]                    3.072kB
<missing>      2 weeks ago     /bin/sh -c #(nop) ADD file:9151f4d22f19f41...   1.437MB
```

You can see that a layer has been created in the container image for the `COPY` and `CMD` statements from our `Dockerfile`.

To run the container image, run:

```execute
podman run --rm greeting
```

Or to run an alternative command, use:

```execute
podman run --rm greeting /goodbye
```

For a full list of the instructions you can use in a `Dockerfile` check out the [Dockerfile reference](https://docs.docker.com/engine/reference/builder/).

The workshop will not be going through everything you can do from a `Dockerfile`. Instructions you can use in a `Dockerfile` will be introduced, and the `COPY` and `CMD` statements covered in more details as necessary, as we proceed through the remainder of the workshop.
