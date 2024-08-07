service mariadb start
sleep 5

mariadb -e "CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;"
mariadb -e "CREATE USER IF NOT EXISTS \`${DB_USER}\`@'%' IDENTIFIED BY '${DB_PASS}';"
mariadb -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO \`${DB_USER}\`@'%';"
mariadb -e "FLUSH PRIVILEGES;"


echo "[mysqld]" >> /etc/mysql/my.cnf
echo "port = 3306" >> /etc/mysql/my.cnf
echo "bind-address = 0.0.0.0" >> /etc/mysql/my.cnf
echo "datadir = /var/lib/mysql" >> /etc/mysql/my.cnf

mysqladmin -u root -p$DB_ROOT_PASSWORD shutdown
mysqld_safe 
# --port=3306 --bind-address=0.0.0.0 --datadir='/var/lib/mysql'