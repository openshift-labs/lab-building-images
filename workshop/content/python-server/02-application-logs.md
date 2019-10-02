Any log messages recorded by an application should be logged to the console, either `stdout` or `stderr`. An application should not log to a file.

The reason for logging to the console is it allow the container runtime to capture the logs from all containers and make then accessible, or pipe them into a log aggregation system. In the case of `podman`, logs can be accessed using the `podman logs` command.

If your application logs to a file, the log file is only usually accessible within the container. To view the applications logs you would need to access the container. If log messages are sent to a file, and the log file is not truncated periodically, you could eventually exceed any file system quota granted to the container and cause a failure of the application.

Usually applications will log to `stderr` and we saw that with the Flask development server when it logged a request. When we used the `print()` statement in Python it output the message to `stdout`, which as you saw was only displayed when the container was shutdown.

The reason for this is that `stdout` is buffered when using Python, and output is only flushed when the buffer limit is reached or output forcibly flushed. This is a problem with containers because if the container were to crash suddenly, you can loose important log information you need to debug the problem.

In order to avoid this when using Python, you need to disable the buffering of `stdout` by the Python process. This can be done by setting the environment variable:

```
PYTHONUNBUFFERED=1
```

It is also recommended that the following environment variables relating to text encoding be set.

```
PYTHONIOENCODING=UTF-8
LC_ALL=en_US.UTF-8
LANG=en_US.UTF-8
```

These are needed because Linux environments often default to being setup to use ASCII as the default encoding. For user environments the default encoding is usually overridden by login script files, but this doesn't happen for services.

We can test that setting `PYTHONUNBUFFERED=1` solves the problem for `stdout` by running:

```execute
podman run --rm -p 8080:8080 -e PYTHONUNBUFFERED=1 flask-app
```

Trigger a web request again using:

```execute-2
curl http://localhost:8080
```

This time you should see both the record of the request logged by the Flask development server, and our debug statement using `print()`.

Stop the web server process using:

```execute
<ctrl-c>
```

To set the environment variables so they are automatically applied to the container, the `ENV` instruction can be used in the `Dockerfile`.

A limitation of setting environment variables in the `Dockerfile` is that they cannot be set dynamically based on other checks. For this they would need to be set at the time the container is run, from a script inside of the container image.

A further issue is that if an application executes or manages sub processes, it can strip all but a minimal set of environment variables, meaning they will not be set for the sub processes. By setting the environment variables in the `Dockerfile`, it makes it potentially necessary to duplicate the settings in script files in the container image still.

If the environment only needed to be set for the initial command the container is run with, they could be set in the `container-entrypoint` script. If this were done though they would not be set were `podman exec` used to run commands in the running container separate to the initial command. It also doesn't help with sub processes where the environment has been stripped.

There is a solution which goes part way to addressing these issues, but the need to start adding more and more custom configuration starts to become a problem if in the long term you need to create distinct images for different applications. This is because you start duplicating common configuration in multiple places, which makes it much harder to update and maintain.

Before we progress further, lets looks at breaking out what will be common configuration for a specific language runtime into a base image which can be used by multiple application images. This can also include all that configuration we are doing in the `Dockerfile` to set up a dedicated user account and lock down access to `root`.
