The `podman` application also implement commands `save` and `load`. That there are two similar sets of commands can be confusing. Let's try again with these commands.

First run:

```execute
podman save -o saved.tar hello
```

This time we are using the name of the container image, rather than the name or ID of a stopped container.

To view the contents of the tarball created this time, run:

```execute
tar tf saved.tar
```

You will see that the tarball consists of a series of subdirectories. Within these subdirectories there is a further tarball. These correspond to the layers in the original container image.

You will also see that the tarball contains a `manifest.json` file. This is the metadata for the container image, so that details such as the command and environment variables can be applied against the reconstructed container image.

To create the container image from this tarball, run:

```execute
cat saved.tar | podman load loaded
```

Run:

```execute
podman images
```

to verify the container image was created. Run:

```execute
podman history loaded
```

to verify that all the original layers are present. And:

```execute
podman inspect loaded
```

to verify that the metadata, including the command and environment variables are set.

You should now be able to run the container image as you did before:

```execute
podman run --rm loaded
```

This time we have been successful.

Before moving on, delete any stopped containers:

```execute
podman rm $(podman ps -aq)
```

and clean up the images which were created:

```execute
podman rmi hello imported loaded
```
