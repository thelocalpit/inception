FROM debian:bullseye

RUN apt-get update && apt-get upgrade -y

RUN apt-get install -y nginx openssl

RUN mkdir -p /etc/nginx/ssl

# generate the ssl certificate
RUN openssl req -x509 -nodes -days 365 -out /etc/nginx/ssl/inception_pfalasch.crt -keyout \
    /etc/nginx/ssl/inception_pfalasch.key -subj "/C=IT/ST=RM/L=RM/O=42/OU=42/CN=pfalasch.42.fr/UID=admin_name"

# copy the nginx configuration file
COPY ./conf/nginx.conf /etc/nginx/nginx.conf

# create the wordpress directory
RUN mkdir -p /var/www/wordpress

# change the owner of the wordpress directory to www-data
RUN chown -R www-data:www-data /var/www/wordpress

# define the command to run when the container starts
CMD ["nginx", "-g", "daemon off;"]