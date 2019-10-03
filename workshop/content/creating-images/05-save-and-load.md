The last of the methods described for building a container image was by importing a copy of the file system to be used for the container image from a tarball.

Rather than being a way of creating a container image from scratch, this method is usually used when you want to share a container image, but can't do it via an image registry.

The `podman` application implements the commands `save` and `load` for this purpose. Note that there are two similar commands called `export` and `import`. These latter commands do not do what is required, use `save` and `load`.

First run:

```execute
podman save -o saved.tar greeting
```

We need to use the name of the container image, not the name or ID of a stopped container.

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

If needing to distribute a container image without using an image registry, you should therefore use `save` and `load`. Although `export` and `import` sound like they might be relevant, they don't provide a complete solution.

Before moving on, delete any stopped containers:

```execute
podman rm $(podman ps -aq)
```

and clean up the images which were created:

```execute
podman rmi greeting loaded
```
