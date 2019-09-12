The last of the methods described for building a container image was by importing a copy of the file system to be used for the container image from a tarball.

Rather than being a way of creating a container image from scratch, this method is usually used when you want to share a container image, but can't do it via an image registry.

To export the file system from the stopped container run:

```execute
podman export -o exported.tar interactive
````

You can view the contents of the tarball by running:

```execute
tar tf exported.tar
```

To create a container image from this tarball run:

```execute
cat exported.tar | podman import - imported
```

To see that a new container image has been created run:

```execute
podman images
```

Now run:

```execute
podman history imported
```

You will see that the container image has only a single layer. This is because the tarball was a copy of the composite view of the layers in the original container image, with changes applied which were made in the container while running.

If you run:

```execute
podman inspect imported
````

you may also see additional differences. That is, information about the container image we want, such as the command to run, and the environment variables have been lost. This means we can't actually run this container image like we did before, without further work to update the container image metadata.

The `export` and `import` commands aren't therefore particularly useful by themselves. The point of showing it though was so you would know this is actually the wrong thing to use.

If you want to transfer a container image without going through an image registry, it is actually `save` and `load` that you need to use. That there are two sets of commands can be confusing. But then, the likelihood of needing either of these is probably low anyway.
