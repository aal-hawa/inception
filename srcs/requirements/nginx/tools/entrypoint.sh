#!/bin/sh

if [ ! -f /etc/self-signed.crt ] || [ ! -f /etc/self-signed.key ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -subj "/CN=$DOMAIN_NAME" \
        -addext "subjectAltName=DNS:$DOMAIN_NAME" \
        -keyout /etc/self-signed.key -out /etc/self-signed.crt \
        -config <(printf "[req]\ndistinguished_name=req\n[req]\n[SAN]\nsubjectAltName=DNS:$DOMAIN_NAME\n")
fi

nginx

