FROM python-base:latest

COPY --chown=1001:0 . /opt/app-root/

RUN /opt/app-root/etc/assemble.sh

EXPOSE 8080
