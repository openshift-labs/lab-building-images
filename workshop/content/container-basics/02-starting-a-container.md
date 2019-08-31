To start an application inside of a container using `podman` or `docker`, you need to have a container image. The container image acts as a packaging mechanism for distributing an application, and includes the application software, operating system files, libraries and other software required by the application to run.

Prebuilt container images for applications, or a base container image upon which you may build your own container image, are distributed using image registries.

The two main hosted image registry services that exist are [Docker Hub](https://https://hub.docker.com/) and [Quay.io](https://quay.io). Support for hosting and distributing container images is also available from Git repository hosting services such as [GitHub](http://github.com/) and [GitLab](https://gitlab.com/).

To pull down and run an existing container image from an image registry using `podman` run:

```execute
podman run docker.io/busybox:latest date
```

The final output should be similar to:

```
Trying to pull docker.io/busybox:latest...Getting image source signatures
Copying blob ee153a04d683 done
Copying config db8ee88ad7 done
Writing manifest to image destination
Storing signatures
Sat Aug 31 09:29:04 UTC 2019
```

The command logs details about the steps taken to pull down the image to the local environment. Once that process is complete, a container is started from the container image and the `date` command specified on the command line is run inside of the container. Because the `date` command exits immediately, the container is shutdown straight away.

In this case the container image which was used was called `busybox`. This is a very minimal Linux container image. We specified that the `latest` version of the container image be used, and that it should be pulled from the Docker Hub image registry (`docker.io`).

If you run the command a second time:

```execute
podman run docker.io/busybox:latest date
```

you will see that it execute the `date` command immediately and does not log any details about needing to first pull down the container image. This is because the container image has been cached in the local environment and will be used on subsequent runs.

You can see what container images have been pulled down to the local environment by running:

```execute
podman images
```

This should output details similar to:

```
REPOSITORY                  TAG      IMAGE ID       CREATED       SIZE
docker.io/library/busybox   latest   db8ee88ad75f   6 weeks ago   1.44 MB
```

If necessary, `podman run` will pull down the container image the first time it is required. If you wanted to pull down images in advance of them being run, you can use the `podman pull` command:

```execute
podman pull docker.io/busybox:latest
```
