To inject a user into the `/etc/passwd` file, we first need to make it writable to any user that the container would be run as.

We already know that when random user IDs are used to run containers we can't know in advance what owner to set directories and files to if they need to be writable. What we could do was rely on the fact that running as a user ID not in the `/etc/passwd` file resulted in it using the group ID 0.

As it stands the owner of the `/etc/passwd` file is the `root` user, and the group ID also that of the `root` group, with group ID 0. The file just isn't writable to group, so we just need to make it writable.

```
RUN chmod g+w /etc/passwd
```

The next problem is how can we inject an entry for the user ID the container runs as, if one doesn't already exist.

You have already seen there were multiple scripts that we had been executing. It isn't practical to have to modify all these scripts to inject the user. This also doesn't help where we want to start an interactive shell, as we execute it directly and not via a script that we could modify.

The solution to having a series of steps run regardless of what command is run when the container is started, is to define an `ENTRYPOINT` for the container in the `Dockerfile`.

When an entry point is defined for a container, the command specified for the entry point will be run in place of `CMD`, with the value of `CMD` passed as arguments to the command for the entry point.

An entry point script which executes the original command for the container can be written as:

```
#!/bin/bash

exec "$@"
```

Copying this script into the container image and calling it `container-entrypoint`, we can then add to the `Dockerfile`:

```
ENTRYPOINT [ "container-entrypoint" ]
```

No matter what command we use to start the container, this script will always be run. The script therefore provides us a point where we can add commands to inject an entry in the `/etc/passwd` file if required.

```
#!/bin/bash

# Add an entry to the /etc/passwd file if required.

STATUS=0 && whoami &> /dev/null || STATUS=$? && true

if [[ "$STATUS" != "0" ]]; then
    echo "$(id -u):x:$(id -u):$(id -g)::`pwd`:/bin/bash" >> /etc/passwd
fi

# Execute the original container command.

exec "$@"
```

To verify these changes, switch location to the `~/greeting-v6` sub directory.

```execute
cd ~/greeting-v6
```

View the contents of the `Dockerfile` by running:

```execute
cat Dockerfile
```

Build the container image:

```execute
podman build -t greeting .
```

Now run:

```execute
podman run --rm -u 1000000 greeting whoami
```

Okay, we are cheating a little in that this is still utilising the fact that `podman run` will inject the user. It didn't fail at least by adding a second unnecessary entry.

```execute
podman run --rm -u 1000000 greeting grep 1000000 /etc/passwd
```

You will need to trust that when run with `docker run`, it will work as advertised.

This solves the problem, but is not a complete solution because the `/etc/passwd` being writable can be taken advantage of to become the `root` user. Make sure you keep reading and apply the other changes described.
