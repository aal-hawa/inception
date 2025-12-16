FROM alpine:3.22

RUN apk update && apk add nginx openssl

COPY conf/nginx.conf /etc/nginx/nginx.conf

COPY tools/entrypoint.sh /entrypoint.sh


RUN chmod +x /entrypoint.sh

CMD [ "/entrypoint.sh" ]

