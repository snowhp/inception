# Define the name of your Docker Compose project
PROJECT_NAME=inception

# Define the name of your Docker Compose file
DOCKER_COMPOSE_FILE=docker-compose.yml

# Define the name of the Docker Compose command to use
DOCKER_COMPOSE=docker compose -p $(PROJECT_NAME) -f $(DOCKER_COMPOSE_FILE)

# Define the name of the Docker image to build
DOCKER_IMAGE=my-image

# Define the tag to use for the Docker image
DOCKER_TAG=my-tag

# Define the name of the Docker container to run
DOCKER_CONTAINER=my-container

# Define the target to build the Docker image
build:
	$(DOCKER_COMPOSE) build

# Define the target to delete the Docker container and volumes
delete:
	$(DOCKER_COMPOSE) down -v

# Define the target to run the Docker container
run:
	$(DOCKER_COMPOSE) up -d

# Define the target to stop the Docker container
stop:
	$(DOCKER_COMPOSE) stop

# Define the target to remove the Docker container
remove:
	$(DOCKER_COMPOSE) rm -f

# Define the target to rebuild the Docker container
rebuild: delete build run

# Define the target to tag the Docker image
tag:
	docker tag $(DOCKER_IMAGE) $(DOCKER_IMAGE):$(DOCKER_TAG)