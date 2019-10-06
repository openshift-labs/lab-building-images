Various tools are available to help you run applications in containers. The most well known tool is called `docker`.

In this workshop, we will be not be using `docker`, but will instead be using an application called `podman`.

The `podman` application is an alternative to `docker`. It is able to produce container images compatible with what `docker` produces, as both build [OCI compliant container images](https://www.opencontainers.org/). To build the images `podman` relies on the `buildah` application.

![Buildah/Podman](buildah-podman-logo.png)

The `podman` application accepts the same sub commands that `docker` accepts. All the `podman` commands you run in this workshop, you can use with `docker` by replacing `podman` with `docker` in the command line. We are using `podman` rather than `docker` as it isn't safe to enable the use of the `docker` daemon within this workshop environment.

For more information on how `podman` compares to `docker`, check out [Podman and Buildah for Docker users](https://developers.redhat.com/blog/2019/02/21/podman-and-buildah-for-docker-users/).
