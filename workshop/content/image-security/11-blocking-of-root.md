In order to not be reliant on Linux capabilities being dropped from the running container, we need to disable the ability to use `su` in the set up of the container image itself. This can be done by editing the PAM configuration for `su` and disabling it.

This can be done from the `Dockerfile` using:

```
RUN sed -i.bak -e '1i auth requisite pam_deny.so' /etc/pam.d/su
```

It will have the affect of inserting at the start of the `/etc/pam.d/su` file the line:

```
auth requisite pam_deny.so
```

This will block all use of `su`, even for the `root` user.

To verify this change, switch location to the `~/greeting-v7` sub directory.

```execute
cd ~/greeting-v7
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

We didn't drop any capabilities in this case as we want to make sure the disabling of `su` works even without doing that.

Now run `su`:

```execute
su root
```

This should error immediately with the error:

```
su: Authentication failure
```

There was no need to go through the steps to add a hashed password to `/etc/passwd` to check this, as the line we added to `/etc/pam.d/su` was inserted before the line where the `/etc/passwd` file would even have been checked.
