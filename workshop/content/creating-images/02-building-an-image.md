There are three principal ways of building a container image. These are:

* Interactively building an image by starting a container using an existing image, making changes in the container, and saving the result as a new container image.

* Creating a container image as a batch process using a set of scripted instructions in an input file. The canonical example of this is using a `Dockerfile` to build a container image.

* Creating a container image by importing a file system from a tarball.

In this workshop you will be learning about using a `Dockerfile` as input to creating a container image, but before we start on that, we will touch briefly on the other methods described above.
