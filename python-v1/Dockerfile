FROM common-base:latest

USER root

RUN HOME=/root && \
    dnf install -y --setopt=tsflags=nodocs python3-devel httpd-devel && \
    dnf clean -y --enablerepo='*' all

USER 1001
