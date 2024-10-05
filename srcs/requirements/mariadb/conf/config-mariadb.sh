#!/bin/sh
# Start MariaDB
# Inicia o serviço MariaDB no container
echo "STARTING MARIA_DB named -> ${DB_NAME}"

# O comando service é usado para iniciar serviços em sistemas linux.
service mariadb start

# -e -> Executa os comandos diretamente na command line
until mariadb -e "SELECT 1"; do
    echo "Waiting for MariaDB to start..."
    sleep 2
done
echo "Mariadb just started"

# Create database if not exists
# A flag -e indica um comando sql que será executado diretamente.

# CHECKAR SE CORRE NA 2X OU DA ERRO
mariadb -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME};" || {
    echo "Error creating database ${DB_NAME}"
    exit 1
}

# Create user if not exists
# O '@'%'' Permite que o usuário se conecte de qualquer endereço de ip
mariadb -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';"

# Grant privileges to user
mariadb -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';"

#mariadb -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${DB_PASSWORD_ROOT}');"

# Flush privileges to apply changes
# Isto força mariadb a recarregar as tabelas de permições, fazendo com que
# as mudanças em cima sejam imediatamente aplicadas.
mariadb -e "FLUSH PRIVILEGES;"
sleep 5

# Restart MariaDB
# Shutdown to restart with the config above
echo "SHUTING DOWN MARIA_DB"

#mysqladmin -u root -p${DB_PASSWORD_ROOT} shutdown
mysqladmin -u root shutdown

# Restart MariaDB, with the new configs, in the backgroundso it keeps running
echo "RESTARTING MARIA_DB"

# Reinicia mariadb em modo seguro
# Configura para abrir a porta 3306
# Configura para aceitar conexões de qualquer IP
# A pasta dos dados será a /var/lib/mysql
#mysqld_safe --port=3306 --bind-address=0.0.0.0 --datadir='/var/lib/mysql'
mysqld_safe --bind-address=0.0.0.0 --datadir='/var/lib/mysql'