The base images for the Linux distributions are minimal and will be missing various packages you may be used to having available.

Although you strictly only need to install additional system packages that your application needs to run, it is a good idea to include packages for tools you may need when debugging the operation of your application when running in a container.

Change location to the `~/greeting-v3` sub directory.

```execute
cd ~/greeting-v3
```

View the contents of the `Dockerfile` by running:

```execute
cat Dockerfile
```

This time you should see:

```
FROM fedora:31

RUN dnf install -y --setopt=tsflags=nodocs findutils procps which && \
    dnf clean -y --enablerepo='*' all

COPY hello goodbye /

CMD [ "/hello" ]
```

The `RUN` instruction allows you to run a command in the context of the container being used to create your image. In this case we are using the `dnf` package manager for Fedora to install the `findutils`, `procps` and `which` packages.

Although having basic UNIX utilities available is useful, you don't need to have documentation files for them. If the package manager for the Linux distribution you are using supports it, exclude installation of documentation files. This is what the `--setopt=tsflags=nodocs` option does when running `dnf install`.

Build the image by running:

```execute
podman build -t greeting .
```

List the layers of the container image created:

```execute
podman history greeting
```

You will see that the `RUN` instruction is reflected in the container image as it's own separate layer.

You can include as many `RUN` instructions as you want in a `Dockerfile`, but be mindful that each will result in a separate layer, and removing temporary files in a new `RUN` instruction which were created in a prior layer doesn't actually reclaim the space they used.

This is why in the example above, we concatenate two commands within the one `RUN` instruction. That is, the `dnf clean` command is run as part of the same instruction by using `&&` in the command. This ensures that any cache which is populated by `dnf`, but not required at runtime, is removed before the layer is committed thus reducing any unnecessary bloat in the size of the container image.

When we added this `RUN` command, you may also have noted that we did not add it at the end of the `Dockerfile`, and instead inserted it at the start.

This order was chosen to take advantage of how caching works when performing builds. To illustrate how caching works, run:

```execute
touch hello
```

and run the build again.

```execute
podman build -t greeting .
```

You should see output similar to:

```
STEP 1: FROM fedora:31
STEP 2: RUN dnf install -y findutils procps which &&     dnf clean -y --enablerepo='*' all
--> Using cache ec436ed2924bd57d82609bc5a4bc26a9f2d76cd0a764515b8b618a138aab68e5
STEP 3: COPY hello goodbye /
cdce36e0893f68baaa8d661a375cbde6c83fdf69f4027cac961a62f9d1722a33
STEP 4: CMD [ "/hello" ]
STEP 5: COMMIT greeting
907579d892d502a1daabb9fe5813906e21648381f39b38b49a72b6aa3c8a3162
```

Pay close attention and you will see that the command defined by the `RUN` instruction wasn't executed this time, and instead a cached copy of that layer was used. This is because nothing about the instruction had changed, nor had any base layers changed.

In contrast the `COPY` instruction and subsequent instructions were processed again. This is because we updated the modification time on the `hello` script file. The build is smart enough to know that because the script file was updated, that it needs to include a fresh copy in the container image. Subsequent instructions also had to be re-processed because the previous layers they built on, had changed.

Because of how caching works for layers when doing subsequent builds, it is common practice to include instructions which rarely change earlier in the `Dockerfile`. Installing system packages is one of the best examples of this.

In contrast, instructions related to a custom application would be included later in the `Dockerfile`. That way when making changes to your application, you only need to rebuild the layers corresponding to it, and you don't need to re-install system packages every time. This will speed up your builds.
