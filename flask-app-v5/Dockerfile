FROM python-base:latest

COPY --chown=1001:0 . /opt/app-root/

RUN assemble-image

CMD [ "start-container" ]

EXPOSE 8080
