When we installed the Python packages required for the Flask application, we installed them into the per user site packages directory. This is a location under the home directory of the user which Python will automatically search.

There are three choices where we could have installed the Python packages.

The first was to install them into the system Python installation directly. Because the system Python installation is owned by `root`, this would have to be done as the `root` user.

The second is the per user site packages directory under the users home directory. This is what we have used so far.

The third and final option is to create a Python virtual environment, install the Python packages into it, then activate the Python virtual environment when we run the Python application.

There is some belief that because the application is being run in a container, and only that application, that one can install packages into the system Python installation.

As it turns out, installing into either the system Python installation or the per user site packages directory can result in issues when using some Linux distributions. The problem is that because it is the system Python directory, the operating system itself may have installed Python packages required by applications which are used in the operating system. These will be Python packages which are packaged as system packages.

When you try and install Python packages into the system Python installation using `pip` from the Python package index, you may need a version of a Python package which conflicts with one which is already installed by the operating system. You cannot therefore install the version you need, or if you force it, you can break the application which is part of the operating system.

Using a per user site packages directory doesn't help avoid this problem, because it is only layered on top of the system Python installation packages. You still can't install a package into a per user site packages directory which conflicts with that already installed into the system Python installation.

A longer explanation of the problem can be found in the blog post [Python virtual environments and Docker](http://blog.dscpl.com.au/2016/01/python-virtual-environments-and-docker.html). In short, even though you are creating a container image specific to your application, you should still use a Python virtual environment. Do not use the system Python installation, or per user site packages directory when installing extra Python packages.

In using a Python virtual environment, we have a few steps we need to do.

The first is to create the Python virtual environment.

The second is to ensure that Python packages required by the Python application are installed into this virtual environment.

The third is that we need to ensure that the Python virtual environment is activated for the Python application.

And a fourth, is that the Python virtual environment is also activated for any application run separately in the container using `podman exec`.

The first three of these are easy enough, but the fourth is harder than it looks especially if for some reason you need to use a non system Python installation, such as that from the Software Collections Library (SCL) packages for RHEL and CentOS.

We could ignore this issue since we are using a system Python installation, but well go through how to handle it in case you want to apply the type of structure used in this workshop to a different Linux and Python distribution.

The solution gives us a nice way of handling any sort of setup of the user environment for the main application, separate applications, or interactive sessions, so it is a worthwhile exercise anyway.
