Creating a container image interactively by running commands in a running container, or from a tarball created from a saved container image have their uses, but the primary way used to create container images is using a `Dockerfile`.

A `Dockerfile` defines the details of the base image from which a new container image is to be created, along with the instructions to create it.

```execute
cd ~/hello-v1
```

```execute
cat Dockerfile
```

```execute
podman build -t greeting .
```

```execute
podman run --rm greeting
```

```execute
podman run --rm greeting /goodbye
```
