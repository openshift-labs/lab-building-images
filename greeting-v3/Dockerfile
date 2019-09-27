FROM fedora:30

RUN dnf install -y --setopt=tsflags=nodocs findutils procps && \
    dnf clean -y --enablerepo='*' all

COPY hello goodbye /

CMD [ "/hello" ]
