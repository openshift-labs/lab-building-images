FROM fedora:31

COPY fix-permissions container-entrypoint container-usage /usr/bin/

RUN dnf install -y --setopt=tsflags=nodocs findutils procps which && \
    dnf clean -y --enablerepo='*' all && \
    sed -i.bak -e '1i auth requisite pam_deny.so' /etc/pam.d/su && \
    sed -i.bak -e 's/^%wheel/# %wheel/' /etc/sudoers && \
    useradd -u 1001 -g 0 -M -d /opt/app-root/src default && \
    mkdir -p /opt/app-root/src && \
    chown -R 1001:0 /opt/app-root && \
    fix-permissions /opt/app-root && \
    chmod g+w /etc/passwd

WORKDIR /opt/app-root/src

ENV HOME=/opt/app-root/src \
    PATH=/opt/app-root/src/bin:/opt/app-root/bin:$PATH

USER 1001

ENTRYPOINT [ "container-entrypoint" ]

CMD [ "container-usage" ]
