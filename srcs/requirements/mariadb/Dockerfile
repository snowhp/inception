FROM debian:11

RUN apt-get -y update
RUN apt-get -y upgrade
RUN apt-get clean

RUN apt-get install -y --no-install-recommends mariadb-server

COPY ./conf/config-mariadb.sh /config-mariadb.sh

RUN chmod +x /config-mariadb.sh

ENTRYPOINT [ "/config-mariadb.sh" ]
