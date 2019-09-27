Lab - Building Images
=====================

This is a workshop on using and building container images using `podman`, including various opinionated best practices around constructing container images.

WARNING WARNING WARNING
-----------------------

Currently to run ``podman`` inside of OpenShift requires that it be run as `root` and inside of a `privileged` container. There is a risk that anyone doing the workshop could take advantage of this and break out of the container or affect the underlying nodes.

Only use this workshop on an expendable cluster which is going to be destroyed when the workshop is finished. Alternatively, only allow people to do the workshop who you trust not to do the wrong thing and try and break the cluster.

Deploying the Workshop
----------------------

To deploy the workshop, first clone this Git repository to your own machine. Use the command:

```
git clone --recurse-submodules https://github.com/openshift-labs/lab-building-images.git
```

The ``--recurse-submodules`` option ensures that Git submodules are checked out. If you forget to use this option, after having clone the repository, run:

```
git submodule update --recursive --remote
```

Next create a project in OpenShift into which the workshop is to be deployed.

```
oc new-project workshops
```

From within the top level of the Git repository, now run:

```
.workshop/scripts/deploy-spawner.sh
```

The name of the deployment will be ``lab-building-images``.

You can determine the hostname for the URL to access the workshop by running:

```
oc get route lab-building-images
```

When the URL for the workshop is accessed you will be prompted for a user name and password. Use your email address or some other unique identifier for the user name. This is only used to ensure you get a unique session and can attach to the same session from a different browser or computer if need be. The password you must supply is ``homeroom``.

Building the Workshop
---------------------

The deployment created above will use an image from ``quay.io`` for this workshop based on the ``master`` branch of the repository.

To make changes to the workshop content and test them, edit the files in the Git repository and then run:

```
.workshop/scripts/build-workshop.sh
```

This will replace the existing image used by the active deployment.

If you are running an existing instance of the workshop, from your web browser select "Restart Workshop" from the menu top right of the workshop environment dashboard.

When you are happy with your changes, push them back to the remote Git repository.

If you need to change the RBAC definitions, or what resources are created when a project is created, change the definitions in the ``templates`` directory. You can then re-run:

```
.workshop/scripts/deploy-spawner.sh
```

and it will update the active definitions.

Note that if you do this, you will need to re-run:

```
.workshop/scripts/build-workshop.sh
```

to have any local content changes be used once again as it will revert back to using the image on ``quay.io``.

Deleting the Workshop
---------------------

To delete the spawner and any active sessions, including projects, run:

```
.workshop/scripts/delete-spawner.sh
```

To delete the build configuration for the workshop image, run:

```
.workshop/scripts/delete-workshop.sh
```

To delete any global resources which may have been created, run:

```
.workshop/scripts/delete-resources.sh
```
