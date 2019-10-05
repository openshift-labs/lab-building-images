To dig down into how this all holds together, change back to the `~/common-base-v2` subdirectory.

```execute
cd ~/common-base-v2
```

View the contents of the `Dockerfile`:

```execute
cat Dockerfile
```

A key change this time is the addition of the `ENV` instruction:

```
ENV BASH_ENV=/opt/app-root/etc/profile \
    ENV=/opt/app-root/etc/profile \
    PROMPT_COMMAND=". /opt/app-root/etc/profile"
```

What these environment variables do is tell the shell programs `sh` and `bash`, that when they are executed, they should source the shell script located at `/opt/app-root/etc/profile` before they do anything else.

The `BASH_ENV` and `ENV` environment variables come into play for non interactive shell sessions, and the `PROMPT_COMMAND` for interactive shell sessions.

View the contents of the file which is placed at `/opt/app-root/etc/profile` by running:

```execute
cat etc/profile
```

The contents should be:

```
unset BASH_ENV PROMPT_COMMAND ENV

# Add an entry to the /etc/passwd file if required.

STATUS=0 && whoami &> /dev/null || STATUS=$? && true

if [ x"$STATUS" != x"0" ]; then
    echo "$(id -u):x:$(id -u):$(id -g)::`pwd`:/bin/bash" >> /etc/passwd
fi

# Read in additional shell environment profile files.

for i in /opt/app-root/etc/profile.d/*.sh /opt/app-root/etc/profile.d/sh.local; do
    if [ -r "$i" ]; then
        . "$i" >/dev/null
    fi
done
```

This will unset the environment variables as we only need to do this once. Any environment variables set by the profile scripts will be inherited by child processes, including shells.

We then update the `/etc/passwd` file to add a user entry if one doesn't exist. This has been moved from the `container-entrypoint` script since these profile scripts will already be automatically run when the container entry point script is run. All the container entry point script now contains is:

```
#!/bin/bash

exec "$@"
```

The last part of the `profile` script sources any profile scripts ending with `.sh` in the `/opt/app-root/etc/profile.d` directory, as well as the `sh.local` script in that directory.

This structure of the profile scripts is similar to what is used in Linux distributions, but we are using it to setup the environment for the container and the application.

Jumping over to the `~/flask-app-v3` sub directory:

```execute
cd ~/flask-app-v3
```

View the contents of the `assemble-image` script:

```execute
cat bin/assemble-image
```

The contents of this is now:

```
#!/bin/bash

pip3 install --no-cache-dir -r requirements.txt

fix-permissions /opt/app-root
```

The difference is that the `--user` option is no longer being used with `pip3` to install packages into the per user site packages directory. Yet, we aren't running as `root` at this point so can't be installing into the system Python installation either. This is because it is installing packages into a Python virtual environment.

Change directory to the `~/python-base-v2` sub directory.

```execute
cd ~/python-base-v2
```

View the contents of the `Dockerfile`:

```execute
cat Dockerfile
```

Here you will see that we have added at the end of the file:

```
COPY --chown=1001:0 . /opt/app-root/

RUN python3 -m venv /opt/app-root/venv && \
    . /opt/app-root/venv/bin/activate && \
    pip3 install --no-cache-dir --upgrade pip setuptools wheel && \
    fix-permissions /opt/app-root
```

This creates a Python virtual environment with `/opt/app-root/venv` as the root directory. We also ensure that the latest versions of `pip`, `setuptools` and `wheel` packages are installed, as what is installed using `python3 -m venv` when creating the virtual environment may not be the latest versions.

To ensure the Python virtual environment is activated the file `/opt/app-root/etc/profile.d/python.sh` is added to the container image:

```execute
cat etc/profile.d/python.sh
```

This contains:

```
PYTHONUNBUFFERED=1
PYTHONIOENCODING=UTF-8
LC_ALL=en_US.UTF-8
LANG=en_US.UTF-8

export PYTHONUNBUFFERED
export PYTHONIOENCODING
export LC_ALL
export LANG

if [ -f /opt/app-root/venv/bin/activate ]; then
    . /opt/app-root/venv/bin/activate
fi
```

It is necessary to check that the activation script for the Python virtual environment exists as the profile scripts will also be triggered when the `assemble-image` script is run during the building of the image. If there are steps in the profile scripts which can only be run when the container image is run, it would be necessary to add other checks in the profile scripts to determine if it is being executed for a build or at runtime.

We also set again the environment variables we set in the `Dockerfile` in case the profile scripts need to be run again to restore the environment after being stripped for a managed sub process.

With the profile scripts set up in this case, they will always be run for the main command run for the container. They will also be run if using `podman exec` so long as it is an interactive shell or a shell script that is being run. If running an executable directly, such as `python`, you would use a command of the form:

```
podman exec <container-id> bash -c "python ..."
```

The execution of the command in a sub shell will ensure the profile scripts get run. If it is a command that you would regularly run, it is better that you add a script to your application code which wraps it up so you don't have to worry about using a sub shell.

These changes have set us up with using a Python virtual environment, so onwards to the next issue of reaping of zombie processes.
