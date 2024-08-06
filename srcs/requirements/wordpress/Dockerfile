FROM debian:bullseye

RUN apt-get update && apt-get upgrade -y

RUN apt-get install -y curl \
    php8.1 \
    php8.1-fpm \
    php8.1-mysql \
    mariadb-client

COPY ./conf/wp-conf.sh /

RUN  chmod 755 wp-conf.sh

ENTRYPOINT ["/bin/bash", "./wp-conf.sh"]