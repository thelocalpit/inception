curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod 755 wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

cd /var/www/wordpress

chmod -R 755 /var/www/wordpress/
chown -R www-data:www-data /var/www/wordpress


check_mariadb() {
    mysqladmin ping -h mariadb --silent
}

check_database() {
    mysql -h mariadb -u"$DB_USER" -p"$DB_PASS" -e "USE $DB_NAME;" > /dev/null 2>&1
}


start_time=$(date +%s)
end_time=$((start_time + 60))

while [ $(date +%s) -lt $end_time ]; do
    if check_mariadb && check_database; then
        break
    else
        sleep 2
    fi
done


if [ ! -f wp-config.php ]; then

    wp core download --allow-root

    wp core config --dbhost=mariadb:3306 --dbname="$DB_NAME" --dbuser="$DB_USER" --dbpass="$DB_PASS" --allow-root

    wp core install --url="$URL_DOMAIN_NAME" --title="$WP_TITLE" --admin_user="$WP_ADMIN_NAME" --admin_password="$WP_ADMIN_PASS" --admin_email="$WP_ADMIN_EMAIL" --allow-root

    echo "[WORDPRESS INSTALLED]"
else
    echo "[WORDPRESS IS ALREADY INSTALLED]"
fi


if ! wp user get "$WP_USER_NAME" --allow-root; then

    wp user create "$WP_USER_NAME" "$WP_USER_EMAIL" --user_pass="$WP_USER_PASS" --role="$WP_USER_ROLE" --allow-root

else
    echo "[USER $WP_USER_NAME ALREADY EXISTS]"
fi



sed -i '36 s@/run/php/php7.4-fpm.sock@9000@' /etc/php/7.4/fpm/pool.d/www.conf

mkdir -p /run/php

/usr/sbin/php-fpm7.4 -F
