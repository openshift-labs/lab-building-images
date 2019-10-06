When containers are shutdown, the application processes are gone, but a copy of the state of the container state is kept. You can see a list of all containers, including the stopped containers by running:

```execute
podman ps -a
```

Because we have started a number of containers, you should see multiple stopped containers listed.

```
CONTAINER ID  IMAGE                             COMMAND  CREATED         STATUS                     PORTS  NAMES
bc6140b151f1  docker.io/library/busybox:latest  sh       9 minutes ago   Exited (0) 7 minutes ago          optimistic_yonath
5c2547826248  docker.io/library/busybox:latest  date     10 minutes ago  Exited (0) 10 minutes ago         dazzling_elgamal
0821c06bed60  docker.io/library/busybox:latest  date     10 minutes ago  Exited (0) 10 minutes ago         mystifying_euler
```

When we ran the containers, we ran them in the foreground, with any output from the containers displayed in the terminal.

The output from the container was also captured to a log file. You can view the log file for a container, running or stopped, by running the `podman logs` command with the container ID as argument.

```execute
podman logs `podman ps -ql`
```

In addition to the log file for a container, a copy of changes made to the filesystem from within the container are also kept. It is possible to copy files out of the stopped container, or create a new container image from a stopped container.

Although there are some uses for a stopped container, they do consume space, so it is important to delete the stopped containers. If you do not do so, eventually you will run out of disk space.

To delete a single stopped container, you can use `podman rm` with the container ID as argument.

```execute
podman rm `podman ps -ql`
```

You should now have just the two stopped containers remaining.

```execute
podman ps -a
```

To delete all stopped containers, run:

```execute
podman rm $(podman ps -aq)
```

Although `podman ps -a` will respond with running containers as well as stopped containers, the `podman rm` command will only delete stopped containers.

There should now be no remaining containers.

```execute
podman ps -a
```

If you know that you do not need to interact with the stopped container after it has been shutdown, you can use the `--rm` option when running `podman run`.

```execute
podman run --rm busybox date
```

With this option, the stopped container will be automatically deleted.

```execute
podman ps -a
```
