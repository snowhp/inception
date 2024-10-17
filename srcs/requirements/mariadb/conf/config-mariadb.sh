#!/bin/sh

: "${DB_NAME:?Environment variable DB_NAME is not set.}"
: "${DB_USER:?Environment variable DB_USER is not set.}"
: "${DB_PASSWORD:?Environment variable DB_PASSWORD is not set.}"


echo "STARTING MARIA_DB named -> ${DB_NAME}"

service mariadb start

until mariadb -e "SELECT 1"; do
    echo "Waiting for MariaDB to start..."
    sleep 2
done

echo "Mariadb just started"

mariadb -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME};" || {
    echo "Error creating database ${DB_NAME}"
    exit 1
}

mariadb -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';"

mariadb -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';"


mariadb -e "FLUSH PRIVILEGES;"
sleep 5


echo "SHUTING DOWN MARIA_DB"

mysqladmin -u root shutdown


echo "RESTARTING MARIA_DB"

mysqld_safe --bind-address=0.0.0.0 --datadir='/var/lib/mysql'