In the previous exercise you executed the `date` command in the container started from the `busybox` container image. You can execute any application which is included within the container image.

If you want to create a container, and interact with it to run commands in it, you can run an interactive shell.

```execute
podman run -it busybox sh
```

When running a command that requires an interactive terminal, you need to supply the `-it` options to `podman run`. This causes a terminal to be allocated and `stdin` will be kept open to allow input.

In this case we also abbreviated the name of the container image to `busybox`. When no version tag is specified, `latest` will be used. When no image registry host is used, the default image registries defined in the global `podman` configuration will be searched. As we had already pulled down the `busybox:latest` image from Docker Hub, it will be matched.

To see the list of processes running inside of the container, run:

```execute
ps
```

You should see output similar to:

```
PID   USER     TIME  COMMAND
    1 root      0:00 sh
    8 root      0:00 ps
```

Only processes started within the context of the container will be visible. Processes running on the underlying container host are not visible.

To see the list of containers which are running, you can run on the container host:

```execute-2
podman ps
```

You should see the container you started above running the interactive shell.

```
CONTAINER ID  IMAGE                             COMMAND  CREATED        STATUS            PORTS  NAMES
501dc9f07da7  docker.io/library/busybox:latest  sh       2 minutes ago  Up 2 minutes ago         priceless_mahavira
```

To access an existing container from the container host and run a command within it, you can use the `podman exec` command. As with `podman run`, if running a command that requires an interactive terminal, use the `-it` options.

When running `podman exec` you need to supply the ID of the container. You can capture the container ID for the last container started by running:

```execute-2
CONTAINER_ID=`podman ps --latest --format {{ "{{.ID" }}}}`; echo $CONTAINER_ID
```

To create a second interactive terminal running in the existing container, now run:

```execute-2
podman exec -it $CONTAINER_ID sh
```

Run `ps` again in the original interactive terminal:

```execute
ps
```

You should now see two shell processes running.

Exit from the first interactive terminal by running:

```execute
exit
```

Because this was the main process running in the container, having process ID 1, the container will be shutdown resulting in the second interactive terminal session also being closed.
