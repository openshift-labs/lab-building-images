FROM common-base:latest

USER root

RUN HOME=/root && \
    dnf install -y --setopt=tsflags=nodocs python3-devel httpd-devel && \
    dnf clean -y --enablerepo='*' all

USER 1001

ENV PYTHONUNBUFFERED=1 \
    PYTHONIOENCODING=UTF-8 \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8
