FROM debian:11

RUN apt-get -y update
RUN apt-get -y upgrade
RUN apt-get clean

# Install nginx
# We dont need to specifie the version of NGINX, beacouse we are specifying
#the SO version, and it will have always the same version of the programs to
#install.
RUN apt-get install -y --no-install-recommends nginx openssl

# Install openssl
#RUN apt-get install -y --no-install-recommends openssl
RUN apt-get clean

# Create directory to ssl
# -p flag ensures that no error is desplay if the directory already exists.
# That ensures that the creation does not stop.
RUN mkdir -p /etc/nginx/ssl

# Create ssl certificate
RUN openssl req -x509 -nodes -out /etc/nginx/ssl/inception.crt \
    -keyout /etc/nginx/ssl/inception.key \
    -subj "/C=${COUNTRY}/ST=${STATE}/L=${LOCALITY}/O=${ORGANIZATION}/OU=${ORGANIZATION}/CN=${DOMAIN_NAME}/UID=${NAME}"
COPY ./conf/nginx.conf /etc/nginx/nginx.conf

# Creating directory to webfiles
RUN mkdir -p /var/www/wordpress
RUN chmod 755 /var/www/wordpress
RUN chown -R www-data:www-data /var/www/wordpress

# -g -> To pass a directive to NGINX directly from command line.
# deamon off tells NGINX to run in foreground, not in background as is default.
# By default, NGINX run as a deamon, it detaches from the terminal and runs in the background
CMD ["nginx", "-g", "daemon off;"]