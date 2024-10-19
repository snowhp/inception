FROM debian:11

RUN apt-get -y update
RUN apt-get -y upgrade
RUN apt-get clean

RUN apt-get install -y --no-install-recommends curl \
    php php7.4-fpm php7.4-mysql \
    netcat ca-certificates

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

RUN chmod +x wp-cli.phar

RUN rm -rf /var/lib/apt/lists/*

COPY ./conf/config-wordpress.sh /config-wordpress.sh

RUN chmod +x config-wordpress.sh