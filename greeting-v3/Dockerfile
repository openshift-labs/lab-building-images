FROM fedora:30

RUN dnf install -y procps && \
    dnf clean -y --enablerepo='*' all

COPY hello goodbye /

CMD [ "/hello" ]
