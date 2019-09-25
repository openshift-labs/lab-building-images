To inspect the layers of the container image you just created, run:

```execute
podman history greeting
```

The output should be similar to:

```
ID             CREATED         CREATED BY                                      SIZE      COMMENT
b242dd054dde   4 minutes ago   /bin/sh                                         9.216kB
19485c79a9bb   6 days ago      /bin/sh -c #(nop) CMD ["sh"]                    9.216kB
<missing>      6 days ago      /bin/sh -c #(nop) ADD file:9151f4d22f19f41...   1.437MB
```

The top layer has captured the changes you made from the interactive shell session of the running container. The other layers were inherited from the `busybox` container image.

Because you constructed the container image from a running container, there is no way to see what individual commands you ran, or what files you copied into the container.

To see the metadata for the container image, you can also run:

```execute
podman inspect greeting
```

This includes details on the layers, but also information about the command run when the container image is run, and details of any environment variables set by the container image.
