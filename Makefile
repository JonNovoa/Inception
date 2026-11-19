NAME = inception
COMPOSE_FILE = srcs/docker-compose.yml
ENV_FILE = srcs/.env
COMPOSE = docker compose --env-file $(ENV_FILE) -f $(COMPOSE_FILE)

all:
	$(COMPOSE) up -d --build

build:
	$(COMPOSE) build

down:
	$(COMPOSE) down

clean:
	$(COMPOSE) down

fclean:
	$(COMPOSE) down --volumes --rmi all

re:
	$(COMPOSE) up -d --build

.PHONY: all build down clean fclean re
