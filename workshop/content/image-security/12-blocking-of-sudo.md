The `su` command isn't the only way of becoming `root` in Linux. The preferred method is actually to use `sudo`. The `/etc/passwd` file being writable means that access to `sudo` also needs to be locked down.

Let's first verify how you could become `root` using `sudo`.

In the container you already have running, create the copy of the `/etc/passwd` file.

```execute
cp /etc/passwd /tmp/passwd
```

and generate the hashed password value:

```execute
HASHED_PASSWORD=`openssl passwd -1 secret`
```

This time when we update the `/etc/passwd` file with the hashed password, we will do it for the current user. We also change the group ID for the user from group ID 0 to group ID 10, corresponding to the `wheel` group.

```execute
cat /tmp/passwd | sed "s%`whoami`:x:`id -u`:0%`whoami`:${HASHED_PASSWORD}:`id -u`:10%" > /etc/passwd
```

The `wheel` group is used because anyone in the `wheel` group can by default use `sudo`.

Run `id` using `sudo`:

```execute
sudo id
```

When prompted, enter the password:

```execute
secret
```

The result should be:

```
uid=0(root) gid=0(root) groups=0(root)
```

This verifies this also would allow one to become `root`.

Stop the current container by killing it.

```execute-2
podman kill `podman ps -ql`
```

The means of disabling use of `sudo` so this cannot be done is to remove the ability for any user in the `wheel` group to run `sudo`. This can be done from the `Dockerfile` using:

```
RUN sed -i.bak -e 's/^%wheel/# %wheel/' /etc/sudoers
```

To verify this change, switch location to the `~/greeting-v8` sub directory.

```execute
cd ~/greeting-v8
```

View the contents of the `Dockerfile` by running:

```execute
cat Dockerfile
```

Build the container image:

```execute
podman build -t greeting .
```

Start a container with an interactive shell:

```execute
podman run -it --rm greeting bash
```

and go through the steps again to test it.

Make the copy of the `/etc/passwd` file.

```execute
cp /etc/passwd /tmp/passwd
```

Generate a hashed password value, where the value of the password is `secret`.

```execute
HASHED_PASSWORD=`openssl passwd -1 secret`
```

and update the `/etc/passwd` file.

```execute
cat /tmp/passwd | sed "s%`whoami`:x:`id -u`:0%`whoami`:${HASHED_PASSWORD}:`id -u`:10%" > /etc/passwd
```

Try again running `sudo`.

```execute
sudo id
```

When prompted, enter the password:

```execute
secret
```

This time it should fail with the error:

```
default is not in the sudoers file.  This incident will be reported.
```

Stop the container once more.

```execute-2
podman kill `podman ps -ql`
```

This rounds out the discussion of how to set up a container image which is portable to different container runtimes and is secure.

Important to understand is that although containers provide a way of isolating application processes from being able to access the underlying host, they should not be the only mechanism you rely on to protect yourself against malicious actors.

You should always design container images so as to be able to be run as a non `root` user if there is no need to have any special privileges. Better still, design the container image to run as an arbitrary user ID to accomodate container platforms that may force applications to run as different user IDs. Finally, if the container platform doesn't itself enforce it, always drop any capabilities from containers that you do not need, such as kernel level abilities to become the `root` user.

Before moving on, delete any stopped containers:

```execute
podman rm $(podman ps -aq)
```

and clean up the images which were created:

```execute
podman rmi greeting
```
