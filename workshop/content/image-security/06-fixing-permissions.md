To fix the access permissions on everything under the `/opt/app-root` directory one way is to add to the `Dockerfile`, just before switching `USER` to 1001, the following `RUN` instruction:

```
RUN chown -R 1001:0 /opt/app-root && \
    chmod -R g=u /opt/app-root
```

This will ensure that that directories are owned by the `default` user, have the group ID 0, and where a directory or file was writable, grant write access via the group as well.

Although this works, adding it as a separate `RUN` instruction will result in a copy being made of every file into a new layer. This is because updates to permissions on files are regarded as a change to the file. Even running `chmod` on a file where the resulting permissions would be the same will still trigger a copy.

When updating permissions, to avoid copies being made, you should only fix the permissions in the context of the same layer where the file was created. In the case of files created from commands executed as part of a `RUN` instruction, that means doing it as part of the same set of commands. For example:

```
RUN useradd -u 1001 -g 0 -M -d /opt/app-root/src default && \
    mkdir -p /opt/app-root/src && \
    chown -R 1001:0 /opt/app-root && \
    chmod -R g=u /opt/app-root
```

If you have multiple `RUN` instructions where this would need to be done against the same root directory, each time it is run, copies will still be made of any files which were created in a prior layer.

You can also encounter problems when the directories contain symlinks off to files outside of the directory hierarchy, as `chmod` will attempt to apply the changes to the file the symlink points at. This may fail where there is no permissions to change the file which is the target of the symlink.

As such, a smarter method is needed when updating permissions so that a file is not touched if the permissions are already what is required, or if the user running the script doesn't have appropriate permissions.

This can be done by using the `find` command but it gets a bit messy as it involves multiple steps.

```
#!/bin/sh

# Allow this script to fail without failing a build
set +e

SYMLINK_OPT=${2:--L}

# Fix permissions on the given directory or file to allow group read/write of
# regular files and execute of directories.

[ $(id -u) -ne 0 ] && CHECK_OWNER=" -uid $(id -u)"

# If argument does not exist, script will still exit with 0,
# but at least we'll see something went wrong in the log
if ! [ -e "$1" ] ; then
  echo "ERROR: File or directory $1 does not exist." >&2
  # We still want to end successfully
  exit 0
fi

find $SYMLINK_OPT "$1" ${CHECK_OWNER} \! -gid 0 -exec chgrp 0 {} +
find $SYMLINK_OPT "$1" ${CHECK_OWNER} \! -perm -g+rw -exec chmod g+rw {} +
find $SYMLINK_OPT "$1" ${CHECK_OWNER} -perm /u+x -a \! -perm /g+x -exec chmod g+x {} +
find $SYMLINK_OPT "$1" ${CHECK_OWNER} -type d \! -perm /g+x -exec chmod g+x {} +

# Always end successfully
exit 0
```

Rather than attempt to include these commands in the `Dockerfile` each time permissions need to be fixed, it is better to save these in a `fix-permissions` script which is copied into the container image, and that script then executed.

In case the above steps need to change, rather than use those above, you can obtain an original copy of the script from:

* https://github.com/sclorg/s2i-base-container/blob/master/core/root/usr/bin/fix-permissions

Having added the script to the container image, we could then use:

```
RUN useradd -u 1001 -g 0 -M -d /opt/app-root/src default && \
    mkdir -p /opt/app-root/src && \
    chown -R 1001:0 /opt/app-root && \
    fix-permissions /opt/app-root
```

Note that this only fixes permissions on directories and files, it doesn't change the owner or group. If the `RUN` instruction is being executed as the `root` user, you will need to first run `chown` to set the owner and group. Luckily this doesn't result in copies being made of files and we can do it recursively on the root directory.

In addition to using `fix-permissions` along with existing commands in a `RUN` instruction, you may still need to run it standalone in it's own `RUN` instruction. This would be required after having used the `COPY` instruction to copy files into the container image. You may also need to set the owner and group since `COPY` by default always gives them owner and group of `root`.

```
COPY hello goodbye party bin/

RUN chown -R 1001:0 /opt/app-root && \
    fix-permissions /opt/app-root
```

You can avoid the need to change the owner and group by specifying what they should be in the `COPY` command.

```
COPY --chown=1001:0 hello goodbye party bin/

RUN fix-permissions /opt/app-root
```

This will result in copies being made of any files which had to have permissions changed because the `COPY` was a separate layer of its own. There is no way to avoid this, as the `COPY` instruction provides no way of setting permissions at the time files are copied into the container image.

To verify these changes, switch location to the `~/greeting-v5` sub directory.

```execute
cd ~/greeting-v5
```

View the contents of the `Dockerfile` by running:

```execute
cat Dockerfile
```

Build the container image:

```execute
podman build -t greeting .
```

Run again the `party` script and override the user ID the container runs as:

```execute
podman run --rm -u 1000000 greeting party
```

This time the script should complete successfully as the permissions of the directory allow it to create files.

```execute
podman run --rm -u 1000000 greeting ls -alsd ~
```
