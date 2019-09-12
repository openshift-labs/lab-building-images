The correct method to export a container image to get a tarball that can be subsequently used to reconstruct the original container image is therefore to run:

```execute
podman save -o saved.tar hello
```

This time we are using the name of the container image, rather than a stopped container.

To view the contents of the tarball created this time, run:

```execute
tar tf saved.tar
```

You will see that the tarball consists of a series of subdirectories. Within these subdirectories there is a further tarball. These correspond to the base layers in the original container image.

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

Before we move on, cleanup all the stopped container images.

```execute
podman rm $(podman ps -aq)
```

Let's also delete some of those images we no longer require. You can do this using:

```execute
podman rmi hello imported loaded
```

When running this command, you can list more than one image at a time.
