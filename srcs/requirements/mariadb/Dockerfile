FROM alpine:3.21

RUN apk update

RUN apk add mariadb mariadb-client openrc

RUN mkdir -p /run/openrc && touch /run/openrc/softlevel

COPY conf/mariadb-server.cnf /etc/my.cnf.d/mariadb-server.cnf

COPY tools/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
