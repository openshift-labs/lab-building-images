FROM fedora:30

COPY fix-permissions container-entrypoint /usr/bin/

RUN dnf install -y --setopt=tsflags=nodocs findutils procps && \
    dnf clean -y --enablerepo='*' all

RUN useradd -u 1001 -g 0 -M -d /opt/app-root/src default && \
    mkdir -p /opt/app-root/src && \
    chown -R 1001:0 /opt/app-root && \
    fix-permissions /opt/app-root

RUN chmod g+w /etc/passwd

RUN sed -i.bak -e '1i auth requisite pam_deny.so' /etc/pam.d/su

WORKDIR /opt/app-root/src

ENV HOME=/opt/app-root/src \
    PATH=/opt/app-root/src/bin:/opt/app-root/bin:$PATH

COPY --chown=1001:0 hello goodbye party bin/

RUN fix-permissions /opt/app-root

USER 1001

ENTRYPOINT [ "container-entrypoint" ]

CMD [ "hello" ]
