FROM debian:bookworm

# Install PHP-FPM and the extensions required by WordPress
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        php-fpm \
        php-mysql \
        php-curl \
        php-gd \
        php-mbstring \
        php-xml \
        php-zip \
        php-intl \
        curl \
        ca-certificates \
        tar \
    && rm -rf /var/lib/apt/lists/*

# Download and extract the WordPress files
RUN mkdir -p /var/www/html \
    && curl -fsSL https://wordpress.org/latest.tar.gz \
       | tar -xz --strip-components=1 -C /var/www/html \
    && chown -R www-data:www-data /var/www/html

# Install WP-CLI to configure WordPress from the command line
RUN curl -fsSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    -o /usr/local/bin/wp \
    && chmod +x /usr/local/bin/wp

# Copy the PHP-FPM pool configuration
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

# Copy the WordPress setup script into the image
COPY tools/setup.sh /usr/local/bin/setup.sh

# Make the setup script executable
RUN chmod 755 /usr/local/bin/setup.sh

# Document the internal port used by PHP-FPM
EXPOSE 9000

# Configure WordPress and start PHP-FPM when the container launches
ENTRYPOINT ["/usr/local/bin/setup.sh"]
