When working on a full operating system as a user, any shell environment is setup by login scripts. When running in a container there is no default mechanism in place that serves the same purpose. The only way to set environment variables is in the `Dockerfile` or via the container runtime. Neither of these allow for the environment to be set through a dynamic set of actions.

It is possible to build into a container image a system which emulates this, and which can be used to set the environment for the main application run in the container as well as separate applications, or interactive sections.

Let's build up the images with these changes and then we will dig into how they work.

Change to the `~/common-base-v2` sub directory.

```execute
cd ~/common-base-v2
```

Build the image:

```execute
podman build -t common-base .
```

Change to the `~/python-base-v2` sub directory.

```execute
cd ~/python-base-v2
```

We have made some changes here as well so rebuild it:

```execute
podman build --no-cache -t python-base .
```

Finally change to the `~/flask-app-v3` sub directory:

```execute
cd ~/flask-app-v3
```

Build it also:

```execute
podman build --no-cache -t flask-app .
```

Run the image:

```execute
podman run --rm -p 8080:8080 flask-app
```

Make a request against it:

```execute-2
curl http://localhost:8080
```

and create an interactive shell in the container:

```execute-2
podman exec -it `podman ps -ql` bash
```

From the interactive terminal work out which Python executable is in the `PATH`.

```execute-2
which python3
```

Rather than find the system Python executable, it should find it from the Python virtual environment located under `/opt/app-root/venv`.

Next verify what packages are installed:

```execute-2
pip3 freeze
```

You should see Flask and the packages it requires.

This confirms that the Python virtual environment was activated for the interactive terminal session, even though we didn't do anything explicit to ensure that happened for the session.

Kill off the container by killing process ID 1 in the container:

```execute-2
kill -SIGINT 1
```
