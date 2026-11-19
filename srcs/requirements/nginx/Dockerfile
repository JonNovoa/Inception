FROM debian:bookworm

# Install NGINX and OpenSSL
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        nginx \
        openssl \
    && rm -rf /var/lib/apt/lists/*

# Copy the NGINX configuration
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Copy the TLS certificate generation script
COPY tools/generate-certificate.sh /usr/local/bin/generate-certificate.sh

# Make the certificate script executable
RUN chmod 755 /usr/local/bin/generate-certificate.sh

# Expose HTTPS inside the Docker network
EXPOSE 443

# Generate the certificate and start NGINX
ENTRYPOINT ["/usr/local/bin/generate-certificate.sh"]
