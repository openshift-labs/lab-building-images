To get started, lets pull down the `busybox` image:

```execute
podman pull busybox
```

Review the list of images:

```execute
podman images
```

Now run the image:

```execute
podman run --rm -it busybox sh
```

You should be presented with a command line prompt for the shell running inside of the busybox container.

Run:

```execute
busybox | head -1
```

You should see output similar to:

```
BusyBox v1.31.0 (2019-07-16 01:13:11 UTC) multi-call binary.
```

Run:

```execute
exit
```

to exit the container.

Now lets build our own image.

Change to the `poc-v1` directory.

```execute
cd poc-v1
```

Look at what files are in the directory:

```execute
ls -las
```

You should see a `Dockerfile`. This includes the instructions to build the image.

```execute
cat Dockerfile
```

To build the image run:

```execute
podman build -t poc-v1 .
```

Review the list of images:

```execute
podman images
```

With the image built, run it:

```execute
podman run --rm -it poc-v1 sh
```

Verify that the file `/tmp/helloworld` exists.

```execute
ls -las /tmp
```

Exit from the container:

```execute
exit
```

Lets tag this image:

```execute
podman tag poc-v1 docker-registry.default.svc:5000/%project_namespace%/poc-v1:latest
```

Login to the OpenShift internal registry:

```execute
podman login -u default -p `oc whoami -t` docker-registry.default.svc:5000
```

Push the image to the registry:

```execute
podman push docker-registry.default.svc:5000/%project_namespace%/poc-v1:latest
```

Verify the image is uploaded:

```execute
oc get is
```

Deploy the image from the registry:

```execute
oc new-app poc-v1:latest
```

Watch it being deployed:

```execute
oc rollout status dc/poc-v1
```
