FROM python-base:latest

ONBUILD COPY --chown=1001:0 . /opt/app-root/

ONBUILD RUN assemble-image

ONBUILD CMD [ "start-container" ]

ONBUILD EXPOSE 8080
