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

# Variables
PHP_VERSION="7.4"
WP_PATH="/var/www/wordpress"
PHP_FPM_CONF="/etc/php/${PHP_VERSION}/fpm/pool.d/www.conf"

# Download wp-cli if it doesn't exist
if [ ! -f /usr/local/bin/wp ]; then
    echo "Downloading wp-cli..."
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
    chmod +x /usr/local/bin/wp  # Make wp-cli executable
else
    echo "wp-cli already exists, skipping download."
fi

# Set up WordPress directory
echo "Setting up WordPress directory..."
mkdir -p "$WP_PATH"
chmod -R 755 "$WP_PATH"
chown -R www-data:www-data "$WP_PATH"

# Function to check if MariaDB is running
ping_mariadb() {
    nc -zv mariadb 3306 >/dev/null 2>&1
    return $?
}

start_time=$(date +%s)
end_time=$((start_time + 60))

# Wait for MariaDB to be ready
echo "Checking if MariaDB is running..."
while [ $(date +%s) -lt "$end_time" ]; do
    if ping_mariadb; then
        echo "MariaDB is running."
        break
    else
        echo "Waiting for MariaDB to start..."
        sleep 2
    fi
done

# Timeout if MariaDB does not start
if [ $(date +%s) -ge "$end_time" ]; then
    echo "MariaDB did not start within the expected time."
    exit 1
fi

# Install WordPress
cd "$WP_PATH"

# Download WordPress core files if not present
if [ ! -f wp-config.php ]; then
    echo "Downloading WordPress core files..."
    wp core download --allow-root
else
    echo "WordPress files already present, skipping download."
fi

# Configure wp-config.php if not present
if [ ! -f wp-config.php ]; then
    echo "Creating wp-config.php..."
    wp core config --dbhost=mariadb:3306 --dbname="$DB_NAME" --dbuser="$DB_USER" --dbpass="$DB_PASSWORD" --allow-root

    # Add WP_HOME and WP_SITEURL to wp-config.php
    wp config set WP_HOME "https://${DOMAIN_NAME}" --allow-root
    wp config set WP_SITEURL "https://${DOMAIN_NAME}" --allow-root
else
    echo "wp-config.php already exists, skipping configuration."
fi

# Install WordPress if it's not installed
if ! wp core is-installed --allow-root; then
    echo "Installing WordPress..."
    wp core install --url="https://${DOMAIN_NAME}" --title="$WP_TITLE" --admin_user="$WP_ADMIN_N" --admin_password="$WP_ADMIN_P" --admin_email="$WP_ADMIN_E" --allow-root
else
    echo "WordPress is already installed, skipping installation."
fi

# Update WordPress URLs in case the domain has changed
echo "Updating WordPress URLs..."
wp option update home "https://${DOMAIN_NAME}" --allow-root
wp option update siteurl "https://${DOMAIN_NAME}" --allow-root

# Create a new user if it doesn't exist
if ! wp user get "$WP_USER_NAME" --allow-root >/dev/null 2>&1; then
    echo "Creating WordPress user ${WP_USER_NAME}..."
    wp user create "$WP_USER_NAME" "$WP_USER_EMAIL" --user_pass="$WP_USER_PASS" --role="$WP_USER_ROLE" --allow-root
else
    echo "User ${WP_USER_NAME} already exists, skipping creation."
fi

# Configure PHP-FPM
echo "Configuring PHP-FPM..."

if [ -f "$PHP_FPM_CONF" ]; then
    sed -i 's@listen = /run/php/php7.4-fpm.sock@listen = 9000@' "$PHP_FPM_CONF"
    sed -i 's/^;*user = .*/user = www-data/' "$PHP_FPM_CONF"
    sed -i 's/^;*group = .*/group = www-data/' "$PHP_FPM_CONF"
else
    echo "PHP-FPM configuration file not found: $PHP_FPM_CONF"
    exit 1
fi

# Ensure the PHP run directory exists
mkdir -p /var/run/php

# Start PHP-FPM in the foreground
echo "Starting PHP-FPM..."
/usr/sbin/php-fpm"${PHP_VERSION}" -F
