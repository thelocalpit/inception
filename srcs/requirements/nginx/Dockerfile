FROM debian:bullseye

RUN apt-get update && apt-get upgrade -y

RUN apt-get install -y nginx openssl

RUN mkdir -p /etc/nginx/ssl

RUN openssl req -x509 -nodes -days 365 -out /etc/nginx/ssl/inception_pfalasch.crt -keyout \
    /etc/nginx/ssl/inception_pfalasch.key -subj "/C=IT/ST=RM/L=RM/O=42/OU=42/CN=pfalasch.42.fr/UID=pfalasch"

COPY ./conf/nginx.conf /etc/nginx/nginx.conf

RUN mkdir -p /var/www/wordpress

RUN chown -R www-data:www-data /var/www/wordpress

ENTRYPOINT ["nginx", "-g", "daemon off;"]