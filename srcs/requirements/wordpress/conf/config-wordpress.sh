#!/bin/bash
# Instalação do wp-cli -> Isto é a linha de comando do wordpress, para
# manipularmos o wordpress sem ter que usar o web browser
#curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
# Movemos o ficheiro wp-cli.phar para um local facilmente acedido.
# O comando mv, modifica o nome do ficheiro para "wp"
mv wp-cli.phar /usr/local/bin/wp

# Wordpress folder
mkdir -p /var/www/wordpress
chmod -R 755 /var/www/wordpress

# Modifica o utilizador da pasta para o www-data, usuario padrão do nginx
chown -R www-data:www-data /var/www/wordpress

# Ping mariadb to check if it's running in 3306 port
# Flag -z -> Tells netcat to operate without input or output, just check if the port
# is open
# Flags -v -> netcat ira ter um out put detalhado das informacoes que recolhe quando tenta
# conectar com a porta.
ping_mariadb()
{
    nc -zv mariadb 3306
    return $? #Return the exit status of the ping command
}
start_time=$(date +%s) # current time in seconds
end_time=$((start_time + 20)) # start_time plus 20 sec
# As long as the current time is less than(-lt) $endtime
# -eq -> equal
while [ $(date +%s) -lt $end_time ]; do
    ping_mariadb
    if [ $? -eq 0 ]; then
        echo "Exit code from NETCAT $?";
        echo "mariadb is running"
        break;
    else
        echo "Exit code from NETCAT $?";
        echo "waiting for mariadb to start"
        sleep 2
    fi
done
# greater
if [ $(date +%s) -ge $end_time ]; then
    echo "mariadb is not responding"
fi
# Installing wordpress
cd /var/www/wordpress
# download wordpress
# --allow-root -> Ignora avisos que o wp possa fazer ao usar o usuario
wp core download --allow-root

# Criar wp-config.php
wp core config --dbhost=mariadb:3306 --dbname="$DB_NAME" --dbuser="$DB_USER" --dbpass="$DB_PASSWORD" --allow-root
wp core install --url="$DOMAIN_NAME" --title="$WP_TITLE" --admin_user="$WP_ADMIN_N" --admin_password="$WP_ADMIN_P" --admin_email="$WP_ADMIN_E" --allow-root
wp user create "$WP_USER_NAME" "$WP_USER_EMAIL" --user_pass="$WP_USER_PASS" --role="$WP_USER_ROLE" --allow-root

# Configuração de php
# change listen port from unix socket to 9000 so the NGINX conatiner can communicate with
#php.
#sed -i '36 s@/run/php/php7.4-fpm.sock@9000@' /etc/php/7.4/fpm/pool.d/www.conf
sed -i 's@listen = /run/php/php7.4-fpm.sock@listen = 9000@; s/^;*user = .*/user = www-data/; s/^;*group = .*/group = www-data/' /etc/php/7.4/fpm/pool.d/www.conf
# PHP expects this directory exists to save files in it.
mkdir -p /var/run/php
# FLAG -F -> Makes the php-fpm7.4 run in first plan, so docker keeps the container running.
/usr/sbin/php-fpm7.4 -F