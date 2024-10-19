FROM debian:11

RUN apt-get -y update
RUN apt-get -y upgrade
RUN apt-get clean

RUN apt-get install -y --no-install-recommends nginx openssl

RUN apt-get clean

RUN mkdir -p /etc/nginx/ssl

RUN openssl req -x509 -nodes -out /etc/nginx/ssl/inception.crt \
    -keyout /etc/nginx/ssl/inception.key \
    -subj "/C=${COUNTRY}/ST=${STATE}/L=${LOCALITY}/O=${ORGANIZATION}/OU=${ORGANIZATION}/CN=${DOMAIN_NAME}/UID=${NAME}"
COPY ./conf/nginx.conf /etc/nginx/nginx.conf

RUN mkdir -p /var/www/wordpress
RUN chown -R www-data:www-data /var/www/wordpress
RUN chmod 755 /var/www/wordpress

# Run as foreground. Outputs are displayed on the screen
CMD ["nginx", "-g", "daemon off;"]