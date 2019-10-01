When running a full operating system with processes constantly being started and stopped, the processes will have an exit status. It is expected that the parent process will wait on any sub processes and acknowledge the exit of the process and retrieve the exit status as necessary. This will remove the state of the process from the kernel process table.

If this never happens and the parent process stops, any child processes will instead be attached to the main init process for the operating system. This is the process with process ID 1. That init process will then detect that the child process has stopped and clean things up so the entry gets removed from the kernel process table.

When running applications inside of containers, this same mechanism comes into play, except that the orphaned child processes are attached to whatever is running as process ID 1 inside of the container.

If the application running as process ID 1 doesn't look out for child processes that have stopped and clean things up, then the process table can start to fill up over time with entries for the stopped processes. These processes are referred to as zombie processes.

Because the processes have stopped, then any memory has already been released, but it will occupy an entry in the kernel process table, and so technically you could eventually run out of space in the kernel process table or kernel resources they consume.

As a consequence, whatever application runs as process ID 1 in the container must be implemented in a way that it cleans up these zombie processes.

For our application image the `run.sh` script was run when the container was started. This contained:

```
#!/bin/bash

exec python3 wsgi.py
```

At the end of this script, it did an `exec` of the Python interpreter to run our Python web application script. This results in the Python interpreter replacing the shell process as process ID 1.

It was necessary to use `exec` here so that our application became process ID 1 because the shell process wouldn't otherwise propagate signals to our application process, which would prevent the container from shutting down properly when being stopped.

In doing that though, it meant the responsibility to reap the zombie processes fell to our application.

For web servers which support multiple process, such as mod_wsgi, gunicorn and uWSGI, that they have to deal with the server processes stopping anyway, they will deal with the extra responsibility of reaping the zombie processes. If using a development server, or other single process web application, they may not. As such, it may be necessary to insert a process as process ID 1 which handles this, albeit that that process will also need to handle propagating signals to the managed process as well so it can be shutdown properly.

This zombine process problem is described in more detail in the article [Docker and the pid 1 zombie reaping problem](https://blog.phusion.nl/2015/01/20/docker-and-the-pid-1-zombie-reaping-problem/).

A solution often touted for this is to use a mini init process such as `tini` or `dumbinit` to perform the roll of process ID 1. The alternative is a more heavy weight process manager such as `supervisor`.

As it happens there is a simpler solution which requires only a shell script. This is something the article above said wasn't possible, but it is, as per article [How to propagate SIGTERM to a child process in a Bash script](http://veithen.io/2014/11/16/sigterm-propagation.html) and follow up with improved solution in [Forward SIGTERM to child in bash](https://unix.stackexchange.com/questions/146756/forward-sigterm-to-child-in-bash/444676#444676).

Our new `run.sh` script therefore would be:

```
#!/bin/bash

prep_term()
{
    unset term_child_pid
    unset term_kill_needed
    trap 'handle_term' TERM INT
}

handle_term()
{
    if [ "${term_child_pid}" ]; then
        kill -TERM "${term_child_pid}" 2>/dev/null
    else
        term_kill_needed="yes"
    fi
}

wait_term()
{
    term_child_pid=$!
    if [ "${term_kill_needed}" ]; then
        kill -TERM "${term_child_pid}" 2>/dev/null
    fi
    wait ${term_child_pid}
    trap - TERM INT
    wait ${term_child_pid}
}

prep_term

python3 wsgi.py &

wait_term
```

Note that instead of using `exec`, we execute the Python process in the background.

To verify this, change to then `~/flask-app-v4` sub directory:

```execute
cd ~/flask-app-v4
```

Build the image:

```execute
podman build -t flask-app .
```

and run the image:

```execute
podman run --rm -p 8080:8080 flask-app
```

Now stop the container using:

```execute-2
podman stop `podman ps -ql`
```

The container should still shutdown cleanly and without delay.

Note that such a solution is only essential if whatever application you run as process ID 1 doesn't deal with zombie processes. If you are using a production grade WSGI server, then it usually would perform this role, but still check as not all do so. For example, the Waitress WSGI server being a single process web server, does not. Many web servers based around `asyncio` module and `aiohttpd` also do not.

If you don't know whether your application may have this problem, there is no harm in using this mechanism even if it does, everything will still work okay.
