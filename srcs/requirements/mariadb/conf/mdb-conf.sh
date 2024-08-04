#--------------mariadb start--------------#
service mariadb start # start mariadb
sleep 5 # wait for mariadb to start

#--------------mariadb config--------------#
# Create database if not exists
mariadb -e "CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;"

# Create user if not exists
mariadb -e "CREATE USER IF NOT EXISTS \`${DB_USER}\`@'%' IDENTIFIED BY '${DB_PASS}';"

# Grant privileges to user
mariadb -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO \`${DB_USER}\`@'%';"

# Flush privileges to apply changes
mariadb -e "FLUSH PRIVILEGES;"

#--------------mariadb restart--------------#
# Shutdown mariadb to restart with new config
mysqladmin -u root -p$DB_ROOT_PASSWORD shutdown

# Restart mariadb with new config in the background to keep the container running
mysqld_safe --port=3306 --bind-address=0.0.0.0 --datadir='/var/lib/mysql'