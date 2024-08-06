#!/bin/bash

LOG_FILE=/var/log/wp-setup.log
echo "Starting script..." >> $LOG_FILE

# Scarica wp-cli
echo "Downloading wp-cli..." >> $LOG_FILE
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod 755 wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp
echo "wp-cli downloaded and moved to /usr/local/bin/wp" >> $LOG_FILE

# Vai alla directory di WordPress
echo "Navigating to WordPress directory..." >> $LOG_FILE
cd /var/www/wordpress

# Imposta i permessi della directory di WordPress
echo "Setting permissions for WordPress directory..." >> $LOG_FILE
chmod -R 755 /var/www/wordpress/
chown -R www-data:www-data /var/www/wordpress
echo "Permissions set." >> $LOG_FILE

# Funzione per controllare se MariaDB è in esecuzione
check_mariadb() {
    mysqladmin ping -h mariadb --silent
}

# Funzione per controllare se il database è stato creato
check_database() {
    mysql -h mariadb -u"$DB_USER" -p"$DB_PASS" -e "USE $DB_NAME;" > /dev/null 2>&1
}

# Attesa per MariaDB
start_time=$(date +%s)
end_time=$((start_time + 60)) # Aumenta il tempo di attesa a 60 secondi

while [ $(date +%s) -lt $end_time ]; do
    if check_mariadb; then
        echo "[MARIADB IS UP]" >> $LOG_FILE
        break
    else
        echo "[WAITING FOR MARIADB...]" >> $LOG_FILE
        sleep 2
    fi
done

if [ $(date +%s) -ge $end_time ]; then
    echo "[MARIADB IS NOT WORKING]" >> $LOG_FILE
    exit 1
fi

# Attesa per la creazione del database
while [ $(date +%s) -lt $end_time ]; do
    if check_database; then
        echo "[DATABASE $DB_NAME IS READY]" >> $LOG_FILE
        break
    else
        echo "[WAITING FOR DATABASE $DB_NAME TO BE CREATED...]" >> $LOG_FILE
        sleep 2
    fi
done

if [ $(date +%s) -ge $end_time ]; then
    echo "[DATABASE $DB_NAME IS NOT READY]" >> $LOG_FILE
    exit 1
fi

# Installazione di WordPress
if [ ! -f wp-config.php ]; then
    echo "Downloading WordPress core files..." >> $LOG_FILE
    wp core download --allow-root

    echo "Creating wp-config.php with database details..." >> $LOG_FILE
    wp core config --dbhost=mariadb:3306 --dbname="$DB_NAME" --dbuser="$DB_USER" --dbpass="$DB_PASS" --allow-root

    if [ -f wp-config.php ]; then
        echo "Installing WordPress..." >> $LOG_FILE
        wp core install --url="$URL_DOMAIN_NAME" --title="$WP_TITLE" --admin_user="$WP_ADMIN_NAME" --admin_password="$WP_ADMIN_PASS" --admin_email="$WP_ADMIN_EMAIL" --allow-root
        echo "[WORDPRESS INSTALLED]" >> $LOG_FILE
    else
        echo "[FAILED TO CREATE wp-config.php]" >> $LOG_FILE
        exit 1
    fi
else
    echo "[WORDPRESS IS ALREADY INSTALLED]" >> $LOG_FILE
fi

# Crea un nuovo utente se non esiste già
if ! wp user get "$WP_USER_NAME" --allow-root; then
    echo "Creating new user $WP_USER_NAME..." >> $LOG_FILE
    wp user create "$WP_USER_NAME" "$WP_USER_EMAIL" --user_pass="$WP_USER_PASS" --role="$WP_USER_ROLE" --allow-root
else
    echo "[USER $WP_USER_NAME ALREADY EXISTS]" >> $LOG_FILE
fi

# Configurazione PHP
echo "Configuring PHP..." >> $LOG_FILE
sed -i '36 s@/run/php/php7.4-fpm.sock@9000@' /etc/php/7.4/fpm/pool.d/www.conf
mkdir -p /run/php
echo "Starting php-fpm..." >> $LOG_FILE
/usr/sbin/php-fpm7.4 -F >> $LOG_FILE 2>&1
