FROM quay.io/openshifthomeroom/workshop-dashboard:4.1.1

USER root

RUN yum install -y psmisc podman-docker && \
    yum -y clean all --enablerepo='*'

RUN sed -i.bak \
      -e 's/# events_logger = "journald"/events_logger = "file"/' \
      /etc/containers/libpod.conf && \
    touch /etc/containers/nodocker

COPY . /tmp/src

RUN rm -rf /tmp/src/.git* && \
    chown -R 1001 /tmp/src && \
    chgrp -R 0 /tmp/src && \
    chmod -R g+w /tmp/src

COPY sudoers.d/ /etc/sudoers.d/

RUN chmod 0440 /etc/sudoers.d/*

ENV TERMINAL_TAB=split

USER 1001

RUN /usr/libexec/s2i/assemble
