#!/bin/bash
set -e

: "${MYSQL_DATABASE:?MYSQL_DATABASE no está definida}"
: "${MYSQL_USER:?MYSQL_USER no está definida}"

DB_ROOT_PASSWORD="$(cat /run/secrets/db_root_password)"
DB_PASSWORD="$(cat /run/secrets/db_password)"

mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld
chown -R mysql:mysql /var/lib/mysql

if [ ! -d /var/lib/mysql/mysql ]; then
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql
fi

if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
    mariadbd --user=mysql --bootstrap <<SQL
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
SQL
fi

unset DB_ROOT_PASSWORD DB_PASSWORD

exec mariadbd --user=mysql
