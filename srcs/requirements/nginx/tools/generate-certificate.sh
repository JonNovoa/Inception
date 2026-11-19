#!/bin/bash
set -e

# Create the directory for TLS certificates
mkdir -p /etc/nginx/ssl

# Generate a self-signed certificate if it does not exist
if [ ! -f /etc/nginx/ssl/inception.crt ] || [ ! -f /etc/nginx/ssl/inception.key ]; then
    openssl req -x509 -nodes -days 365 \
        -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/inception.key \
        -out /etc/nginx/ssl/inception.crt \
        -subj "/CN=jnovoa-a.42.fr"
fi

# Validate the NGINX configuration
nginx -t

# Start NGINX in the foreground
exec nginx -g "daemon off;"
