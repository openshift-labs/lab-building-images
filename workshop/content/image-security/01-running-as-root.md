We are done with our recap of what containers are, how to create them and how to build container images.

You might be hoping we will now jump into various best practices around building container images for the {{ PROGRAMMING_LANGUAGE }} programming language. Before we do that though, we are going to look at an issue which is often overlooked, or is looked at too late in the development process, making it hard to go back and retrospectively implement best practices.

This issue is running containers in a way that applies good security principles.

We are going to deal with this now, because steps in building a container image to apply some good security principles will have an effect on how we do some things later.

To illustrate the key issue we want to address, run the `greeting` container image with the `id` command.

```execute
podman run --rm greeting id
```

The result will be:

```
uid=0(root) gid=0(root) groups=0(root)
```

What this indicates is that when the container is being run, any processes running inside of the container are being run as the `root` user with `uid` of 0.

If we were running an application service directly on a host we would always aim to run it as a non privileged user and not as the `root` user. If we run it as the `root` user and it is an application which is exposed to the network, a bad actor could use a remote exploit via the application, to become `root` on the host and compromise it.

To reduce the risk of compromise, it is good practice to design in layers of security. In this case, one layer can be to not run the application as `root` to begin with. This ensures that even if the application is compromised, any access an attacker is able to gain, is as a non privileged user, thus limiting the potential damage they can do.

When using containers, although a sandbox is created in which your application processes run, a vulnerability in the container runtime might one day be found. If you run application processes inside of the container as `root`, and an attacker is able to escape the container, they would also be `root` on the host.

Rather than seeing containers as a firewall which will protect you, allowing you to run application processes as `root`, it is better to view them as just another security layer.

Best practice therefore is not to run application processes as `root`, even when in a container.

When running containers using `podman run`, you can override the user ID that a container is run as using the `-u` option. To run as the user `nobody` defined by Fedora, you can use:

```execute
podman run --rm -u nobody greeting id
```

This will produce:

```
uid=65534(nobody) gid=65534(nobody) groups=65534(nobody)
```

Although no longer running as the `root` user, this required the user to be specified to the container runtime when starting the container. If this step were forgotten, it would default back to running the container as the `root` user.

A better practice than relying on the user to be set via the container runtime, is to setup the container image to always run as a non privileged user.
