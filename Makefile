GREEN := \033[0;32m
RED := \033[0;31m
YELLOW := \033[1;33m
NC := \033[0m
CHECKMARK := +
CROSSMARK := -

# Define the name of your Docker Compose project
PROJECT_NAME=inception

# Define the name of your Docker Compose file
DOCKER_COMPOSE_FILE=srcs/docker-compose.yml

# Define the name of the Docker Compose command to use
DOCKER_COMPOSE=docker compose -p $(PROJECT_NAME) -f $(DOCKER_COMPOSE_FILE)

# Define colors and symbols

# Define targets
.PHONY: all prepare build delete run stop remove rebuild

all: prepare run

prepare:
	@mkdir -p ~/data/mariadb 2>/dev/null && echo "$(GREEN)$(CHECKMARK) Created ~/data/mariadb$(NC)" || echo "$(RED)$(CROSSMARK) Failed to create ~/data/mariadb$(NC)"
	@mkdir -p ~/data/wordpress 2>/dev/null && echo "$(GREEN)$(CHECKMARK) Created ~/data/wordpress$(NC)" || echo "$(RED)$(CROSSMARK) Failed to create ~/data/wordpress$(NC)"
	@hostsed add 127.0.0.1 tde-sous.42.fr >/dev/null 2>&1 && echo "$(GREEN)$(CHECKMARK) Added 'tde-sous.42.fr' to hosts file$(NC)" || echo "$(RED)$(CROSSMARK) Failed to add 'tde-sous.42.fr' to hosts file$(NC)"

build:
	@echo "$(YELLOW)Building with Docker Compose...$(NC)"
	$(DOCKER_COMPOSE) build

delete:
	@echo "$(YELLOW)Deleting Docker containers and volumes...$(NC)"
	$(DOCKER_COMPOSE) down -v

run:
	@echo "$(YELLOW)Starting Docker containers...$(NC)"
	$(DOCKER_COMPOSE) up -d
	@echo "$(GREEN)$(CHECKMARK) Docker is up and running!$(NC)"

stop:
	@echo "$(YELLOW)Stopping Docker containers...$(NC)"
	$(DOCKER_COMPOSE) stop

remove:
	@echo "$(YELLOW)Removing Docker containers...$(NC)"
	$(DOCKER_COMPOSE) rm -f

rebuild: delete build run