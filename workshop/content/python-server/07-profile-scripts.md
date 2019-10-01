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

if [[ "$STATUS" != "0" ]]; then
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

View the contents of `sh.local` script:

```execute
cat etc/profile.d/sh.local
```

It contains:

```
if [ -f /opt/app-root/bin/activate ]; then
    source /opt/app-root/bin/activate
fi
```

which will activate the Python virtual environment.

It is necessary to check that the activation script exists as the profile scripts will also be triggered when the `assemble.sh` script is run during the building of the image. If there are steps in the profile scripts which can only be run when the container image is run, it would be necessary to add other checks in the profile scripts to determine if it is being executed for a build or at runtime.

View the contents of the `assemble.sh` script:

```execute
cat etc/assemble.sh
```

The contents of this should be:

```
!/bin/bash

python3 -m venv /opt/app-root

source /opt/app-root/bin/activate

pip3 install --no-cache-dir --upgrade pip setuptools wheel

pip3 install --no-cache-dir -r requirements.txt

fix-permissions /opt/app-root
```

This is where the Python virtual environment was first created that was later activated from the `sh.local` script.

Note that because we are now using a virtual environment, before we install the application packages, we first ensure that the `pip`, `setuptools` and `wheel` packages are the most up to date versions. This is necessary as those installed into the Python virtual environment by `python3 -m venv` may not be the latest.

With the profile scripts set up in this case, they will always be run for the main command run for the container. They will also be run if using `podman exec` so long as it is an interactive shell or a shell script that is being run. If running an executable directly, such as `python`, you should use a command of the form:

```
podman exec <container-id> bash -c "python ..."
```

The execution of the command in a sub shell will ensure the profile scripts get run. If it is a command that you would regularly run, it is better that you add a script to your application code which wraps it up so you don't have to worry about using a sub shell.

These changes have set us up with using a Python virtual environment, so onwards to the next issue of reaping of zombie processes.