#!/bin/bash

# Ensure required environment variables are set
: "${DB_NAME:?Environment variable DB_NAME is not set.}"
: "${DB_USER:?Environment variable DB_USER is not set.}"
: "${DB_PASSWORD:?Environment variable DB_PASSWORD is not set.}"
: "${DOMAIN_NAME:?Environment variable DOMAIN_NAME is not set.}"
: "${WP_TITLE:?Environment variable WP_TITLE is not set.}"
: "${WP_ADMIN_N:?Environment variable WP_ADMIN_N is not set.}"
: "${WP_ADMIN_P:?Environment variable WP_ADMIN_P is not set.}"
: "${WP_ADMIN_E:?Environment variable WP_ADMIN_E is not set.}"
: "${WP_USER_NAME:?Environment variable WP_USER_NAME is not set.}"
: "${WP_USER_EMAIL:?Environment variable WP_USER_EMAIL is not set.}"
: "${WP_USER_PASS:?Environment variable WP_USER_PASS is not set.}"
: "${WP_USER_ROLE:?Environment variable WP_USER_ROLE is not set.}"

# Download wp-cli if it doesn't exist. Double check
if [ ! -f /usr/local/bin/wp ]; then
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
    chmod +x /usr/local/bin/wp  # Make wp-cli executable
fi

# Wordpress folder setup
mkdir -p /var/www/wordpress
chmod -R 755 /var/www/wordpress

# Change ownership to the www-data user, the default user for nginx
chown -R www-data:www-data /var/www/wordpress

# Function to ping MariaDB to check if it's running on port 3306
ping_mariadb() {
    nc -zv mariadb 3306
    return $?
}

start_time=$(date +%s) # Current time in seconds
end_time=$((start_time + 60)) # Allow up to 60 seconds for MariaDB to start

# Check if MariaDB is running
while [ $(date +%s) -lt $end_time ]; do
    ping_mariadb
    if [ $? -eq 0 ]; then
        echo "MariaDB is running"
        break
    else
        echo "Waiting for MariaDB to start..."
        sleep 2
    fi
done

# If the timeout is reached, exit with an error
if [ $(date +%s) -ge $end_time ]; then
    echo "MariaDB did not start within the expected time."
    exit 1
fi

# Install WordPress
cd /var/www/wordpress

# Download WordPress
wp core download --allow-root

# Create wp-config.php
wp core config --dbhost=mariadb:3306 --dbname="$DB_NAME" --dbuser="$DB_USER" --dbpass="$DB_PASSWORD" --allow-root

# Install WordPress
wp core install --url="$DOMAIN_NAME" --title="$WP_TITLE" --admin_user="$WP_ADMIN_N" --admin_password="$WP_ADMIN_P" --admin_email="$WP_ADMIN_E" --allow-root

# Create a new user
wp user create "$WP_USER_NAME" "$WP_USER_EMAIL" --user_pass="$WP_USER_PASS" --role="$WP_USER_ROLE" --allow-root

# Configure PHP
# Change listen port from unix socket to 9000 so Nginx can communicate with PHP
sed -i 's@listen = /run/php/php7.4-fpm.sock@listen = 9000@; s/^;*user = .*/user = www-data/; s/^;*group = .*/group = www-data/' /etc/php/7.4/fpm/pool.d/www.conf

# Ensure the PHP run directory exists
mkdir -p /var/run/php

# Start PHP-FPM in the foreground
/usr/sbin/php-fpm7.4 -F
