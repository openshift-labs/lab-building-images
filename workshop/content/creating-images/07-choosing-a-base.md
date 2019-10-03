In the examples so far we have used the `busybox` container image. This image is convenient for demonstrations because it is small, but for real world applications it isn't really suitable.

For real world applications you will want to choose a more complete base image built from one of the more popular Linux distributions.

Popular choices for base images are:

* [Fedora](https://hub.docker.com/_/fedora)
* [CentOS](https://hub.docker.com/_/centos)
* [Debian](https://hub.docker.com/_/debian)
* [Ubuntu](https://hub.docker.com/_/ubuntu)
* [Alpine](https://hub.docker.com/_/alpine)

If you require a supported base image and have a Red Hat subscription you could also use a Red Hat Enterprise Linux (RHEL) base image. This can be a full RHEL base image, or Red Hat also makes available a set of [Universal Base Images (UBI)](https://www.redhat.com/en/blog/introducing-red-hat-universal-base-image). These are RHEL based images, but with different levels of functionality included. The full featured variants of these images still require a Red Hat subscription, but the less functional variants can be used and distributed without a subscription.

For the remainder of this workshop we will be using a Fedora base image.

Delete the `greeting` image created from the `busybox` image.

```execute
podman rmi greeting
```

Change location to the `~/greeting-v2` sub directory.

```execute
cd ~/greeting-v2
```

View the contents of the `Dockerfile` by running:

```execute
cat Dockerfile
```

This time you should see:

```
FROM fedora:31

COPY hello goodbye /

CMD [ "/hello" ]
```

Only the `FROM` instruction has been changed. This time the `fedora:31` base image is referenced instead of the `busybox` image.

Build the image by running:

```execute
podman build -t greeting .
````

The build may take a little bit longer as the `fedora` base image needs to be pulled down and it is somewhat larger than the more minimal `busybox` base image.

When the build has completed check that the container image runs:

```execute
podman run --rm greeting
```

Run the image again but this time create an interactive shell.

```execute
podman run -it --rm greeting /bin/bash
```

From the interactive shell, you can dig around inside the container image. You will see that it contains a complete base Fedora operating system environment.

When you are finished, shutdown the container by running:

```execute
exit
```
