FROM alpine:3.22

RUN apk update && apk add php php83 php83-fpm php83-mysqli php83-mbstring php83-gd php83-opcache php83-phar php83-xml mariadb-client wget tar

COPY tools/entrypoint.sh /entrypoint.sh

COPY tools/wp-cli.phar /usr/local/bin/wp

RUN chmod +x /usr/local/bin/wp

COPY conf/www.conf /etc/php83/php-fpm.d/www.conf

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]