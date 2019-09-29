FROM fedora:30

COPY fix-permissions /usr/bin/

RUN dnf install -y --setopt=tsflags=nodocs findutils procps which && \
    dnf clean -y --enablerepo='*' all

RUN useradd -u 1001 -g 0 -M -d /opt/app-root/src default && \
    mkdir -p /opt/app-root/src && \
    chown -R 1001:0 /opt/app-root && \
    fix-permissions /opt/app-root

RUN chmod g+w /etc/passwd

COPY container-entrypoint /usr/bin/

ENTRYPOINT [ "container-entrypoint" ]

RUN sed -i.bak -e '1i auth requisite pam_deny.so' /etc/pam.d/su

RUN sed -i.bak -e 's/^%wheel/# %wheel/' /etc/sudoers

WORKDIR /opt/app-root/src

ENV HOME=/opt/app-root/src \
    PATH=/opt/app-root/src/bin:/opt/app-root/bin:$PATH

USER 1001

COPY --chown=1001:0 app.py requirements.txt ./

RUN pip3 install --no-cache-dir --user -r requirements.txt && \
    fix-permissions /opt/app-root

ENV PATH=$HOME/.local/bin:$PATH

EXPOSE 8080

CMD [ "env", "FLASK_APP=app.py", "flask", "run", "--host=0.0.0.0", "--port=8080" ]
