Up till this point, the commands we have been running with our `greeting` container displayed a message but did not try and interact with the filesystem. In the last update to the `Dockerfile` an extra script was snuck in. This was called `party`. To run this command use:

```execute
podman run --rm greeting party
```

The output should be "Party".

Run it again, but this time override the user ID the container runs as:

```execute
podman run --rm -u 1000000 greeting party
```

This time you should seen an error message.

```
/opt/app-root/src/bin/party: line 3: /opt/app-root/src/party.txt: Permission denied
```

Look at the contents of the script, by running:

```execute
cat party
```

You should see:

```
#!/bin/sh

set -eo pipefail

date >> $HOME/party.txt

echo "Party"
```

The script failed because it attempted to write to a file, but the user ID the container was running as was not the owner of the area we set aside as a user workspace for the application to use.

Running:

```execute
podman run --rm -u 1000000 greeting ls -alsd ~
```

you should see output similar to:

```
0 drwxr-xr-x. 3 default root 17 Sep 26 23:10 /opt/app-root/src
```

The owner of the directory was the `default` user and the group was `root`. The directory is only writable to the user though. As a result the process running as user ID 1000000 couldn't create the file.

Because the permissions of directories cannot be changed at runtime, they need to be setup at the time the container image is built so that the random user ID can still access it.

Obviously since it is a random user ID we cannot know what the user ID will be in advance, so we can't set the owner to be different.

The only thing we can rely on is being able to access the directory through group access permissions.

If you remember, when we added the dedicated user of `default`, we set the group ID for that user to be group ID 0, which corresponds to the `root` group. The group of directories and files under `/opt/app-root` was also set to be this group.

This group ID was used rather than having a dedicated group for the user, or using the `users` group, to take advantage of the fact that when the container is run as a random user ID not in `/etc/passwd`, that it will be run with group ID of 0.

With this being the case, all we need to ensure is that any steps run from the `Dockerfile` which copy or write files under `/opt/app-root`, fix up permissions afterwards so that the owner is the `default` user, that the group ID is 0, and that the directories and files are group writable where necessary.
