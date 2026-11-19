#!/bin/bash
set -e

# Stop if required environment variables are missing
: "${MYSQL_DATABASE:?MYSQL_DATABASE is not set}"
: "${MYSQL_USER:?MYSQL_USER is not set}"
: "${DOMAIN_NAME:?DOMAIN_NAME is not set}"
: "${WP_TITLE:?WP_TITLE is not set}"
: "${WP_ADMIN_USER:?WP_ADMIN_USER is not set}"
: "${WP_ADMIN_EMAIL:?WP_ADMIN_EMAIL is not set}"
: "${WP_USER:?WP_USER is not set}"
: "${WP_USER_EMAIL:?WP_USER_EMAIL is not set}"

# Read passwords from Docker Secrets
DB_PASSWORD="$(cat /run/secrets/db_password)"
WP_ADMIN_PASSWORD="$(cat /run/secrets/wp_admin_password)"
WP_USER_PASSWORD="$(cat /run/secrets/wp_user_password)"

# Wait for MariaDB to become available, with a maximum of 30 attempts
attempt=1
until php -r '
mysqli_report(MYSQLI_REPORT_OFF);
$db = @new mysqli(
    "mariadb",
    getenv("MYSQL_USER"),
    trim(file_get_contents("/run/secrets/db_password")),
    getenv("MYSQL_DATABASE")
);
exit($db->connect_errno ? 1 : 0);
'; do
    if [ "$attempt" -ge 30 ]; then
        echo "MariaDB did not become available in time." >&2
        exit 1
    fi

    echo "Waiting for MariaDB (attempt ${attempt}/30)..."
    attempt=$((attempt + 1))
    sleep 2
done

# Create the WordPress configuration if it does not exist
if [ ! -f /var/www/html/wp-config.php ]; then
    wp config create \
        --path=/var/www/html \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$DB_PASSWORD" \
        --dbhost=mariadb \
        --dbprefix=wp_ \
        --allow-root
fi

# Install WordPress and create the initial users only once
if ! wp core is-installed --path=/var/www/html --allow-root; then
    wp core install \
        --path=/var/www/html \
        --url="https://${DOMAIN_NAME}" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --skip-email \
        --allow-root

    wp user create "$WP_USER" "$WP_USER_EMAIL" \
        --role=author \
        --user_pass="$WP_USER_PASSWORD" \
        --path=/var/www/html \
        --allow-root
fi

# Remove password variables from the shell
unset DB_PASSWORD WP_ADMIN_PASSWORD WP_USER_PASSWORD

# Start PHP-FPM in the foreground
exec php-fpm8.2 -F
