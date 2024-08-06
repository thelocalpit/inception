#!/bin/bash

# Scarica wp-cli
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod 755 wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

# Vai alla directory di WordPress
cd /var/www/wordpress

# Imposta i permessi della directory di WordPress
chmod -R 755 /var/www/wordpress/
chown -R www-data:www-data /var/www/wordpress
# chown -R root:root /var/www/wordpress

# #---------------------------------------------------ping mariadb---------------------------------------------------#
# # Funzione per controllare se MariaDB è in esecuzione
# check_mariadb() {
#     mysqladmin ping -h mariadb --silent
# }

# start_time=$(date +%s)
# end_time=$((start_time + 30))

# while [ $(date +%s) -lt $end_time ]; do
#     if check_mariadb; then
#         echo "[MARIADB IS UP"
#         break
#     else
#         echo "[WAITING...]"
#         sleep 2
#     fi
# done

# if [ $(date +%s) -ge $end_time ]; then
#     echo "[MARIADB IS NOT WORKING]"
#     exit 1
# fi

#---------------------------------------------------wp installation---------------------------------------------------#

# Se wp-config.php non esiste, significa che WordPress non è configurato
if [ ! -f wp-config.php ]; then

    # Scarica i file core di WordPress
    wp core download --allow-root

    # Crea il file wp-config.php con i dettagli del database
    wp core config --dbhost=mariadb:3306 --dbname="$DB_NAME" --dbuser="$DB_USER" --dbpass="$DB_PASS" --allow-root

    # Installa WordPress con il titolo, l'utente admin, la password e l'email forniti
    wp core install --url="$URL_DOMAIN_NAME" --title="$WP_TITLE" --admin_user="$WP_ADMIN_NAME" --admin_password="$WP_ADMIN_PASS" --admin_email="$WP_ADMIN_EMAIL" --allow-root

    echo "[WORDPRESS INSTALLED]"
else
    echo "[WORDPRESS IS ALREADY INSTALLED]"
fi

if wp user get "$WP_ADMIN_NAME" --allow-root; then
    echo "admin exist: "$WP_ADMIN_NAME""
else
    echo "admin doesn´t exixst"
fi

# Crea un nuovo utente se non esiste già
if ! wp user get "$WP_USER_NAME" --allow-root; then

    wp user create "$WP_USER_NAME" "$WP_USER_EMAIL" --user_pass="$WP_USER_PASS" --role="$WP_USER_ROLE" --allow-root

else
    echo "[USER $WP_USER_NAME ALREADY EXISTS]"
fi

#---------------------------------------------------php config---------------------------------------------------#

# Cambia la porta di ascolto dalla socket unix alla porta 9000
sed -i '36 s@/run/php/php7.4-fpm.sock@9000@' /etc/php/7.4/fpm/pool.d/www.conf

# Crea una directory per php-fpm
mkdir -p /run/php

# Avvia il servizio php-fpm in primo piano per mantenere il container in esecuzione
/usr/sbin/php-fpm7.4 -F
