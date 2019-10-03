FROM fedora:31

RUN dnf install -y --setopt=tsflags=nodocs findutils procps which && \
    dnf clean -y --enablerepo='*' all

COPY hello goodbye /

CMD [ "/hello" ]
