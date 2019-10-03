To ensure that a container image runs as a non privileged user, we can specify the user to run as in the `Dockerfile`. This is done using the `USER` instruction.

Linux distributions pre-define a number of UNIX user accounts, but these are associated with specific services and it is wise to avoid them. There is also usually a `nobody` user, but running as this user ID could have other implications.

The best approach is to add a new dedicated user account and setup the container image to run as this user.

Change location to the `~/greeting-v4` sub directory.

```execute
cd ~/greeting-v4
```

View the contents of the `Dockerfile` by running:

```execute
cat Dockerfile
```

This time you should see:

```
FROM fedora:31

RUN dnf install -y --setopt=tsflags=nodocs procps which && \
    dnf clean -y --enablerepo='*' all

RUN useradd -u 1001 -g 0 -M -d /opt/app-root/src default && \
    mkdir -p /opt/app-root/src && \
    chown -R 1001:0 /opt/app-root

USER 1001

WORKDIR /opt/app-root/src

ENV HOME=/opt/app-root/src \
    PATH=/opt/app-root/src/bin:/opt/app-root/bin:$PATH

COPY hello goodbye party bin/

CMD [ "hello" ]
```

We have made a few changes to the `Dockerfile` in this example. Before diving into the changes, build the image by running:

```execute
podman build -t greeting .
```

Run the image to test it:

```execute
podman run --rm greeting
```

Now check what user ID it is running as:

```execute
podman run --rm greeting id
```

The result should be:

```
uid=1001(default) gid=0(root) groups=0(root)
```

The container is running as the `default` user with user ID of 1001, without needing to tell the container runtime what to run it as.
