#!/bin/bash

cat << EOF

This is a common base image designed to be portable to different container
platforms and runtimes. Replace the "/opt/app-root/etc/run.sh" script file
in a derived image with your own script to start your application.

The environment variables set for this container are:

`env`

The identity of the user that the container is running as is:

`id`

EOF

exit 1
