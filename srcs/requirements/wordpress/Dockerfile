FROM debian:bullseye

RUN apt-get update && apt-get upgrade -y

RUN apt-get install -y curl php php7.4-fpm php-mysql mariadb-client 

COPY ./conf/wp-conf.sh /

RUN  chmod 755 wp-conf.sh

ENTRYPOINT ["/bin/bash", "./wp-conf.sh"]