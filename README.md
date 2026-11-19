*This project has been created as part of the 42 curriculum by jnovoa-a.*

# Inception

## Description

Inception is a system administration project from the 42 curriculum. The goal is to build a small infrastructure using Docker and Docker Compose, with each service running in its own dedicated container.

The infrastructure consists of three services:

- **NGINX:** acts as the web server and entry point, serving HTTPS with TLS 1.2 and TLS 1.3.
- **WordPress:** provides the website and runs PHP through PHP-FPM.
- **MariaDB:** stores the WordPress database.

The containers communicate through a dedicated Docker bridge network. Named volumes provide persistent storage for the database and website files.

The images are built from custom Dockerfiles based on Debian Bookworm.

### Project architecture

```text
                    Browser
                       |
                    HTTPS :443
                       |
                 +-----------+
                 |   NGINX   |
                 +-----------+
                       |
                 FastCGI :9000
                       |
                 +-----------+
                 | WordPress |
                 | PHP-FPM   |
                 +-----------+
                       |
                  MariaDB :3306
                       |
                 +-----------+
                 |  MariaDB  |
                 +-----------+
```

All three services run in separate containers on the `inception` Docker network. Only NGINX publishes a port on the host.

## Instructions

### Prerequisites

- A Debian virtual machine.
- Docker Engine.
- Docker Compose plugin.
- Git.
- A configured domain entry in `/etc/hosts`.

### Domain configuration

Add the following entry to `/etc/hosts` inside the virtual machine:

```text
127.0.0.1 jnovoa-a.42.fr
```

### Environment configuration

The Compose environment file is located at `srcs/.env`. It contains the domain name, data directory, database name, database user and WordPress configuration values.

Passwords are stored separately in Docker Secret source files, which must be created locally before starting the infrastructure:

```text
secrets/
├── db_password.txt
├── db_root_password.txt
├── wp_admin_password.txt
└── wp_user_password.txt
```

These files must not be committed to Git.

The data directories are located at:

```text
/home/jnovoa-a/data/
├── mariadb/
└── wordpress/
```

### Build and launch

From the root of the repository, run:

```bash
make build
make
```

The `make build` command builds the service images. The default `make` target starts the services in detached mode.

### Useful commands

Start the infrastructure:

```bash
make
```

Build the images:

```bash
make build
```

Stop and remove the containers:

```bash
make down
```

Rebuild and start the services:

```bash
make re
```

Inspect the container status:

```bash
docker compose --env-file srcs/.env -f srcs/docker-compose.yml ps
```

View NGINX logs:

```bash
docker logs nginx
```

View WordPress logs:

```bash
docker logs wordpress
```

View MariaDB logs:

```bash
docker logs mariadb
```

**Warning:** the `fclean` target removes Compose volumes and images. Use it carefully because deleting volumes may destroy persistent data.

### Accessing the website

Once the services are running, access the website at:

https://jnovoa-a.42.fr

The TLS certificate is self-signed, so a browser may display a security warning in this local development environment.

## Resources

### Docker

- [Docker documentation](https://docs.docker.com/)
- [Docker Compose documentation](https://docs.docker.com/compose/)
- [Docker volumes](https://docs.docker.com/engine/storage/volumes/)
- [Docker networking](https://docs.docker.com/engine/network/)

### Services

- [NGINX documentation](https://nginx.org/en/docs/)
- [WordPress documentation](https://wordpress.org/documentation/)
- [WP-CLI documentation](https://make.wordpress.org/cli/handbook/)
- [MariaDB documentation](https://mariadb.com/kb/en/documentation/)
- [OpenSSL documentation](https://docs.openssl.org/)

### Design choices

#### Virtual machines vs Docker

A virtual machine runs a complete guest operating system on virtualized hardware. Docker containers share the host kernel and isolate applications and their dependencies.

Docker was chosen for this project because it provides lightweight, reproducible service environments and allows each component to be built and managed independently. The virtual machine provides the required isolated development environment.

#### Docker Secrets vs environment variables

Environment variables are convenient for configuration values such as database names, usernames and domain names. However, passwords should not be stored directly in the environment file.

Docker Secrets provide a separate mechanism for supplying sensitive values to the containers that need them. This project uses secret files for database and WordPress passwords, while non-sensitive configuration is stored in `srcs/.env`.

#### Docker Network vs Host Network

A bridge network allows containers to communicate using service names without exposing every service directly on the host.

This project uses a dedicated Docker bridge network. NGINX communicates with WordPress through PHP-FPM, and WordPress connects to MariaDB. Only NGINX publishes port 443.

Using host networking would reduce network isolation and is unnecessary for this architecture.

#### Docker Volumes vs Bind Mounts

Bind mounts connect a container directly to a specific host path. They are useful when a container must access a known directory on the host.

Docker volumes provide managed persistent storage. This project defines named volumes for MariaDB and WordPress, with the local volume driver configured to store their data under `/home/jnovoa-a/data/`.

This combines named-volume management with the required host storage location and allows persistent data to survive container replacement.

### Use of AI

AI tools were used as an assistance resource during development to help understand Docker, Docker Compose, service configuration, shell scripts, troubleshooting and documentation.

The project configuration and commands were developed and reviewed iteratively. The author remains responsible for understanding, testing and validating the final implementation.

## Project structure

```text
Inception/
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── .gitignore
├── secrets/
└── srcs/
    ├── .env
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/
        ├── wordpress/
        └── nginx/