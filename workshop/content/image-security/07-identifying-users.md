We have a solution for how you can set the permissions of directories and files so that when a container is run as a random user ID, it can create and/or modify files. Time to address the issues arising from the user ID a container runs as not having an entry in the `/etc/passwd` file.

As we saw, this isn't actually an issue if using `podman run` as it automatically injects an entry into the `/etc/passwd` file when none exists for the user ID the container is run as. This is not done when using `docker run` though so we need to cater for that.

There are two solutions one could use to solve this.

The first solution is to use a package called the [nss_wrapper](https://cwrap.org/nss_wrapper.html) library. This consists of a shared library that can be pre-loaded into all application process, and which intercepts C API calls to lookup users.

This solution only works where C API calls are used to lookup users and not where an application may process the `/etc/passwd` file directly.

Injecting a shared library into processes can be done by setting the `LD_PRELOAD` environment variable, with other environment variables used to point the shared library at a modified `/etc/passwd` file. A problem with this solution is that environment variables can often be stripped by applications when they manage or use other applications as sub processes. This approach can therefore be a bit fragile.

The second solution is to make the existing `/etc/passwd` file writable so that it can be modified, and a new entry added for the user ID, when the container is started.

This solution sounds simple enough, but there are some traps inherent in using it. Extra steps are required to lock things down so that an unprivileged user can't become `root`.

Although it sounds like it may be a dangerous solution, we will use the second approach. Just ensure that you apply all the steps that will be described.
