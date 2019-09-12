The first method for constructing a container image is to run a container using an existing container image, run any required steps to install or copy files into the container, and save the result as a new container image.

To illustrate this method, first start an instance of the `busybox` container with an interactive shell.

```execute
podman run -it --name interactive busybox sh
```

You would now run any commands to install additional packages. In the case of the `busybox` container image, it doesn't provide a package manager, so we will limit ourselves to creating a executable script file that we can run. To create the script file run:

```execute
cat > hello << EOF
#!/bin/sh

echo "Hello"
EOF
```

Make the script file executable:

```execute
chmod +x hello
```

In this case we create the script file by running a command inside of the container. The alternative is to copy the script file into the container from the local host.

Create a file on the local host by running:

```execute-2
cat > goodbye << EOF
#!/bin/sh

echo "Goodbye"
EOF
```

Also make it executable:

```execute-2
chmod +x goodbye
```

Copy this script file into the container by running:

```execute-2
podman cp goodbye interactive:/goodbye
```

Because we named the container with the name `interactive` we could use it in the target for where the file should be copied. If you hadn't named the container, you would need to use the container ID.

Check that you can see both files from the container.

```execute
ls -las
```

Now exit from the container by running:

```execute
exit
```

At this point the container has been stopped, as we exited the interactive shell process that was keeping it running. You can see that it has stopped by running:

```execute
podman ps -a
```

Although it has been stopped, because we didn't use the `--rm` option with `podman run`, the state of the container has been retained, including the changes we made to the filesystem from inside of the container.

To create a container image from the saved state of the container, run:

```execute
podman commit --change='CMD ["/hello"]' interactive hello
```

The name of the container image you created was `hello`. To see details for the container image run:

```execute
podman images
```

To run the container image, run:

```execute
podman run --rm hello
```

You were able to run the container image without specifying what command to run within the container, as the `--change` option used with `podman commit` above overrides the default command run when the container image is started.

You can still run the container image with an alternative command if required.

```execute
podman run --rm hello /goodbye
```
