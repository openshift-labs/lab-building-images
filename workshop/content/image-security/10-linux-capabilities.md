Container platforms such as OpenShift avoid this problem with root escalation by applying a more strict default security policy on containers. When using `podman` or `docker` though there is nothing by default in place to prevent it. Other container platforms may also not have default security policies in place which prevent this.

The way that OpenShift avoids the problem is to drop the Linux capabilities from the container which allow a user to change user ID through requests to the Linux kernel.

The two capabilities in question here are `SETUID` and `SETGID`.

When using `podman`, you can drop these capabilities using the `--drop-cap` option.

Let's try to become `root` again when these capabilities are dropped.

Start again with the interactive shell

```execute
podman run --cap-drop SETUID --cap-drop SETGID -it --rm greeting bash
```

Create the copy of the `/etc/passwd` file.

```execute
cp /etc/passwd /tmp/passwd
```

Generate the hashed password value:

```execute
HASHED_PASSWORD=`openssl passwd -1 secret`
```

and update the `/etc/passwd` file.

```execute
cat /tmp/passwd | sed "s%root:x%root:${HASHED_PASSWORD}%" > /etc/passwd
```

Try again to use `su` to become `root`.

```execute
su root
```

Enter the password:

```execute
secret
```

This time it should fail with the error:

```
su: cannot set groups: Operation not permitted
```

Verify that you are not `root` by running:

```execute
id
```

Regardless of measures we can put in place in the container image to prevent this, it is highly recommended that when deploying containers, to drop any Linux capabilities that you do not need. That way even if the way the container images was designed allowed switching to the `root` user from an unprivileged user, it would be blocked.

Stop the container by killing it.

```execute-2
podman kill `podman ps -ql`
```
