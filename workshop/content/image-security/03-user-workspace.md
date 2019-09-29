The first instruction added to the `Dockerfile` to setup the container image to run as a dedicated user was:

```
RUN useradd -u 1001 -g 0 -M -d /opt/app-root/src default && \
    mkdir -p /opt/app-root/src && \
    chown -R 1001:0 /opt/app-root
```

This adds a new UNIX user account in the user database. The user ID of 1001 was used, and the group ID for the new user was set as 0, which is that for the `root` group. We will get to the reasons for using this particular group ID for the user later.

The home directory of the user was set to `/opt/app-root/src`, but the complete directory hierarchy under `/opt/app-root` has also notionally been reserved as a user workspace and ownership passed to the user.

The idea here is that `/opt/app-root` would act as a root directory for installing anything related to the application. This would be in place of installing the application under `/usr/local`, `/usr` or `/`. This has the benefit of keeping everything related to the application under one directory and not spread across the file system.

To ensure the container runs as the dedicated user, we next add:

```
USER 1001
```

All `RUN` instructions after this point in the `Dockerfile`, if there were any, would be run as this user ID. Because it is the last time `USER` is specified, it also defines the user ID that the container started from the container image will run as.

Note that we have used an integer user ID here rather than the user name. This is done so that a container platform the image is being deployed to, or other tooling, can validate what actual user ID the container would run as.

If we had set `USER` to the user name `default` it can't be determined what actual user ID the container would run as, as the `/etc/passwd` file could have been modified to map the user `default` to the `root` user ID of 0.

As such, always use an integer user ID value for the `USER` instruction to allow for automated auditing of the container image and what user ID it would run as.

The next instruction added is:

```
WORKDIR /opt/app-root/src
```

The `WORKDIR` instruction sets the working directory for subsequent instructions in the `Dockerfile`, as well as the default directory in which processes are run when the container image is run. It is set the same as the home directory for the user.

Next we set environment variables using the `ENV` instruction. These environment variables will be available to use in subsequent instructions and in the running container.

```
ENV HOME=/opt/app-root/src \
    PATH=/opt/app-root/src/bin:/opt/app-root/bin:$PATH
```

The environment variable for the users `HOME` directory is set explicitly to avoid confusion as to what the value is. This is done because what the `HOME` directory is set to can otherwise change based on what the `USER` is defined as at that point when the `RUN` instructions from the `Dockerfile` are processed.

The search `PATH` for applications is set to include `bin` directories in the root of the user workspace and also the `src` subdirectory. This is added as a convenience so an absolute path is not required, so long as programs or scripts are installed into one of these directories.

Having set the `WORKDIR` as well as adding the `bin` directories to `PATH`, the `COPY` command for adding the scripts is changed to copy them to the `bin` directory, relative to the specified working directory of `/opt/app-root/src`.

```
COPY hello goodbye party bin/
```

Since the scripts are now in `PATH`, we also change the default command run when the container is started to not use an absolute pathname.

```
CMD [ "hello" ]
```

The `USER` instruction is what ultimately resulted in the container image running as our dedicated user, but the other changes set us up with a user workspace for holding our application, which will come in useful later.
