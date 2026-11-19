# User Documentation

## Overview

This document explains how to start, stop and access the Inception infrastructure.

The project runs three services in Docker containers:

- NGINX provides HTTPS access to the website.
- WordPress runs the website using PHP-FPM.
- MariaDB stores the WordPress database.

## Requirements

Before starting, ensure that the following are installed and configured in the Debian virtual machine:

- Docker Engine
- Docker Compose plugin
- The project repository
- The environment file at `srcs/.env`
- The required Docker Secret files in the `secrets/` directory

## Starting the project

Open a terminal in the root directory of the repository:

```bash
cd ~/Inception
```

Build the images:

```bash
make build
```

Start the services:

```bash
make
```

Check the status of the containers:

```bash
docker compose --env-file srcs/.env -f srcs/docker-compose.yml ps
```

The `mariadb`, `wordpress` and `nginx` services should be running.

## Accessing the website

Open the following address in a browser:

https://jnovoa-a.42.fr

The domain must resolve to the virtual machine where the project is running. The `/etc/hosts` file inside the virtual machine should contain:

```text
127.0.0.1 jnovoa-a.42.fr
```

The project uses a self-signed TLS certificate. A browser security warning may therefore appear during local testing.

## WordPress accounts

The initial WordPress administrator and second user are configured through the environment variables and Docker Secret files.

Use the credentials created for the project to sign in to the WordPress administration area:

https://jnovoa-a.42.fr/wp-admin/

Passwords are stored in local secret files and must not be committed to the repository.

## Stopping the project

To stop and remove the containers while retaining the named volumes, run:

```bash
make down
```

To start the project again:

```bash
make
```

## Checking service logs

To inspect the logs of a service, run:

```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
```

To check the current container status:

```bash
docker compose --env-file srcs/.env -f srcs/docker-compose.yml ps
```

## Data persistence

The project uses named volumes for the MariaDB database and WordPress website files.

The data is stored under:

```text
/home/jnovoa-a/data/mariadb
/home/jnovoa-a/data/wordpress
```

Removing containers does not normally remove these volumes. Avoid running cleanup commands that delete volumes unless you intentionally want to remove the stored data.

## Troubleshooting

### A service is not running

Check the container status and inspect the logs:

```bash
docker compose --env-file srcs/.env -f srcs/docker-compose.yml ps
docker logs nginx
docker logs wordpress
docker logs mariadb
```

### The website cannot be reached

Check that all three containers are running and that NGINX publishes port 443. Confirm that the domain resolves to the correct machine and that the HTTPS URL is being used.

### The browser displays a certificate warning

The project uses a self-signed certificate for local testing. This warning is expected unless the certificate has been explicitly trusted by the client.

### WordPress cannot connect to the database

Check that MariaDB is running and inspect its logs. Confirm that the database settings in `srcs/.env` and the corresponding secret files are correct.

## Security notes

- Do not share or commit secret files.
- Do not publish MariaDB or PHP-FPM ports directly to the host.
- Only expose the NGINX HTTPS port.
- Be careful when using cleanup commands that remove Docker volumes.
