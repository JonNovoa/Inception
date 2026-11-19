# Developer Documentation

## 1. Project Overview

Inception is a Docker-based infrastructure project running inside a virtual machine. It uses Docker Compose to manage three separate services:

- **NGINX:** provides HTTPS access to the website.
- **WordPress:** runs WordPress using PHP-FPM.
- **MariaDB:** stores the WordPress database.

Each service has its own custom Dockerfile and is built locally from Debian. The containers communicate through a dedicated Docker bridge network.

## 2. Project Structure

```text
Inception/
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── secrets/
│   ├── db_password.txt
│   ├── db_root_password.txt
│   ├── wp_admin_password.txt
│   └── wp_user_password.txt
└── srcs/
    ├── .env
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   ├── conf/
        │   │   └── 50-server.cnf
        │   └── tools/
        │       └── init.sh
        ├── wordpress/
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── www.conf
        │   └── tools/
        │       └── setup.sh
        └── nginx/
            ├── Dockerfile
            ├── conf/
            │   └── nginx.conf
            └── tools/
                └── generate-certificate.sh
```

## 3. Services and Dockerfiles

### NGINX

The NGINX image is built using its own Dockerfile. It installs NGINX and OpenSSL, copies the NGINX configuration and certificate-generation script, and starts NGINX in the foreground.

NGINX:
- Listens on port 443.
- Supports TLSv1.2 and TLSv1.3.
- Uses a self-signed certificate generated at container startup.
- Forwards PHP requests to the WordPress PHP-FPM service.
- Shares the WordPress website volume in read-only mode.

### WordPress

The WordPress image installs PHP-FPM and the PHP extensions required by WordPress. It downloads WordPress and WP-CLI, then copies the PHP-FPM configuration and setup script.

The setup script:
- Reads database and WordPress passwords from Docker secrets.
- Waits for MariaDB to become available.
- Creates the WordPress configuration when needed.
- Installs WordPress and creates the second user on first installation.
- Starts PHP-FPM in the foreground.

WordPress does not run NGINX in its container.

### MariaDB

The MariaDB image installs the MariaDB server and copies its configuration and initialization script.

The initialization script:
- Reads database passwords from Docker secrets.
- Initializes the database directory when necessary.
- Creates the WordPress database and database user on first initialization.
- Starts MariaDB in the foreground.

MariaDB does not run NGINX in its container.

## 4. Docker Compose

The file `srcs/docker-compose.yml` defines the services, builds their images, configures their network, attaches persistent storage, and provides secrets.

The services use restart policies so Docker can restart them after a failure.

Only NGINX publishes a port on the host:

- `443:443` — HTTPS access.

MariaDB and WordPress are accessible to other containers through the Docker network and do not publish their service ports to the host.

## 5. Environment Variables and Secrets

The file `srcs/.env` stores non-sensitive configuration, including:

- `DOMAIN_NAME`
- `DATA_PATH`
- `MYSQL_DATABASE`
- `MYSQL_USER`
- `WP_TITLE`
- WordPress usernames and email addresses

Passwords are stored in separate files under `secrets/` and passed to the relevant containers using Docker Compose secrets.

Do not commit passwords or other confidential information to Git. The `secrets/` directory is excluded through `.gitignore`.

## 6. Persistent Storage

Two named Docker volumes are configured:

- `mariadb_data`: stores the MariaDB database files.
- `wordpress_data`: stores the WordPress website files.

The volumes use local storage backed by these directories on the host:

```text
/home/jnovoa-a/data/mariadb
/home/jnovoa-a/data/wordpress
```

The WordPress volume is shared with NGINX as read-only storage. This allows NGINX to serve website files without modifying them.

Persistent storage allows database and website files to survive ordinary container restarts and container recreation.

**Warning:** Removing the volumes can permanently delete persistent project data.

## 7. Network Architecture

The Compose configuration creates a dedicated bridge network named `inception`.

Containers use their Compose service names to communicate:

- WordPress connects to MariaDB using the hostname `mariadb`.
- NGINX forwards PHP requests to `wordpress:9000`.

Host networking and legacy container links are not used.

## 8. Build and Management Commands

Run these commands from the project root directory:

```bash
make
```

Starts the services in detached mode.

```bash
make build
```

Builds the service images.

```bash
make down
```

Stops and removes the Compose containers and network.

```bash
make re
```

Rebuilds the images and starts the services.

```bash
make fclean
```

Stops the services and removes the Compose volumes and images. **Use this command carefully because removing volumes can delete persistent data.**

To inspect the running services:

```bash
docker compose --env-file srcs/.env -f srcs/docker-compose.yml ps
```

To view logs:

```bash
docker compose --env-file srcs/.env -f srcs/docker-compose.yml logs
```

To view logs for one service:

```bash
docker compose --env-file srcs/.env -f srcs/docker-compose.yml logs nginx
```

Replace `nginx` with `wordpress` or `mariadb` to inspect another service.

## 9. Configuration Validation

Before starting the infrastructure, validate the Compose configuration:

```bash
docker compose --env-file srcs/.env -f srcs/docker-compose.yml config --quiet
```

If the command completes without errors, the Compose configuration has passed this validation.

After starting the services, check their status and logs to identify startup or configuration problems.

## 10. Security Considerations

- Only NGINX publishes a host port, port 443.
- HTTPS is configured to use TLSv1.2 and TLSv1.3.
- Passwords are kept out of Dockerfiles and the `.env` file.
- Secrets must not be committed to Git.
- MariaDB and WordPress communicate through the private Compose network.
- The WordPress volume is mounted read-only in NGINX.
- The generated self-signed certificate is suitable for local project testing; browsers may display a certificate warning.

## 11. Maintenance

When changing a service configuration or Dockerfile, rebuild the affected image and recreate the service as necessary.

For example:

```bash
docker compose --env-file srcs/.env -f srcs/docker-compose.yml up -d --build
```

Back up the database and website data before performing destructive maintenance. Avoid removing persistent volumes unless data deletion is intentional.
