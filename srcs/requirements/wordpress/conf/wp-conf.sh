#!/bin/bash

curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
# wp-cli permission
chmod +x wp-cli.phar
# wp-cli move to bin
mv wp-cli.phar /usr/local/bin/wp
# go to wordpress directory
cd /var/www/wordpress
# give permission to wordpress directory
chmod -R 755 /var/www/wordpress/
# change owner of wordpress directory to www-data
chown -R www-data:www-data /var/www/wordpress

#---------------------------------------------------ping mariadb---------------------------------------------------#
# Funzione per controllare se MariaDB è in esecuzione
check_mariadb() {
    mysqladmin ping -h mariadb --silent
}

start_time=$(date +%s) 
end_time=$((start_time + 30)) 

while [ $(date +%s) -lt $end_time ]; do
    if check_mariadb; then
        echo "[========MARIADB IS UP AND RUNNING========]"
        break
    else
        echo "[========WAITING FOR MARIADB TO START...========]"
        sleep 2 
    fi
done

if [ $(date +%s) -ge $end_time ]; then
    echo "[========MARIADB IS NOT RESPONDING========]"
    exit 1 
fi

#---------------------------------------------------wp installation---------------------------------------------------#

# download wordpress core files
wp core download --allow-root
# create wp-config.php file with database details
wp core config --dbhost=mariadb:3306 --dbname="$DB_NAME" --dbuser="$DB_USER" --dbpass="$DB_PASS" --allow-root
# install wordpress with the given title, admin username, password and email
wp core install --url="$URL_DOMAIN_NAME" --title="$WP_TITLE" --admin_user="$WP_ADMIN_NAME" --admin_password="$WP_ADMIN_PASS" --admin_email="$WP_ADMIN_EMAIL" --allow-root

# Crea un nuovo utente
echo "Creating user with:"
echo "Username: $WP_USER_NAME"
echo "Email: $WP_USER_EMAIL"
echo "Role: $WP_USER_ROLE"

wp user create "$WP_USER_NAME" "$WP_USER_EMAIL" --user_pass="$WP_USER_PASS" --role="$WP_USER_ROLE" --allow-root --debug

# Controlla la creazione dell'utente
if [ $? -ne 0 ]; then
    echo "[ERROR] User creation failed."
    exit 1
fi
# #create a new user with the given username, email, password and role
# wp user create "$WP_USER_NAME" "$WP_USER_EMAIL" --user_pass="$WP_USER_PASS" --role="$WP_USER_ROLE" --allow-root --debug

#---------------------------------------------------php config---------------------------------------------------#

# change listen port from unix socket to 9000
sed -i '36 s@/run/php/php7.4-fpm.sock@9000@' /etc/php/7.4/fpm/pool.d/www.conf
# create a directory for php-fpm
mkdir -p /run/php

# start php-fpm service in the foreground to keep the container running
/usr/sbin/php-fpm7.4 -F


