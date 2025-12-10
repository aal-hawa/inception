#!/bin/sh

mkdir -p /var/www/html/wordpress
cd /var/www/html/wordpress

if [ ! -f "wp-config.php" ] && [ ! -f "wp-config-sample.php" ]; then
    echo "Downloading WordPress..."
    php -d memory_limit=512M /usr/local/bin/wp --allow-root core download
    mv wp-config-sample.php wp-config.php
fi

chmod 777 -R /var/www/html/wordpress


WP_USER=$(grep "^WP_USER=" /run/secrets/CREDENTIALS | cut -d "=" -f 2)
WP_PASS=$(grep "^WP_PASS=" /run/secrets/CREDENTIALS | cut -d "=" -f 2)
WP_EMAIL=$(grep "^WP_EMAIL=" /run/secrets/CREDENTIALS | cut -d "=" -f 2)

WP_USER2=$(grep "^WP_USER2=" /run/secrets/CREDENTIALS | cut -d "=" -f 2)
WP_PASS2=$(grep "^WP_PASS2=" /run/secrets/CREDENTIALS | cut -d "=" -f 2)
WP_EMAIL2=$(grep "^WP_EMAIL2=" /run/secrets/CREDENTIALS | cut -d "=" -f 2)

DB_PASSWORD=$(cat /run/secrets/DB_PASSWORD)


sed -i "s/'database_name_here'/'$DB_NAME'/g" wp-config.php
sed -i "s/'username_here'/'$DB_USER'/g" wp-config.php
sed -i "s/'password_here'/'$DB_PASSWORD'/g" wp-config.php
sed -i "s/'localhost'/'$DB_HOST'/g" wp-config.php
sed -i "/<?php/a \\if ( isset( \$_SERVER['HTTP_HOST'] ) ) { \\n    \$site_url = 'https://' . \$_SERVER['HTTP_HOST']; \\n    define( 'WP_HOME', \$site_url ); \\n    define( 'WP_SITEURL', \$site_url ); \\n}" wp-config.php

if ! wp --allow-root --path=/var/www/html/wordpress core is-installed; then
    SITE_URL="https://${DOMAIN_NAME:-localhost}"
    
    wp --allow-root --path=/var/www/html/wordpress core install \
        --url="${SITE_URL}" --title='WordPress' \
        --skip-email --admin_email="$WP_EMAIL" \
        --admin_user="$WP_USER" \
        --admin_password="$WP_PASS"
fi

if ! wp --allow-root --path=/var/www/html/wordpress user list --field=user_login | grep -q "^$WP_USER2$"; then
    wp --allow-root --path=/var/www/html/wordpress user create \
        $WP_USER2 $WP_EMAIL2 --role=subscriber \
        --user_pass="$WP_PASS2"
fi



if [ -f /var/www/html/wordpress/wp-config.php ]; then
	php-fpm83 --nodaemonize
fi


