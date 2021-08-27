APP_NAME ?= damiantroy/radarr
CONTAINER_RUNTIME := $(shell command -v podman 2> /dev/null || echo docker)

.PHONY: help
help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
.DEFAULT_GOAL := help

.PHONY: all
all: build test ## Build and test the container.

.PHONY: build
build: ## Build the container.
	$(CONTAINER_RUNTIME) build -t "${APP_NAME}" .

.PHONY: build-nc
build-nc: ## Build the container without cache.
	$(CONTAINER_RUNTIME) build --no-cache -t "${APP_NAME}" .

.PHONY: test
test: ## Test the container.
	$(CONTAINER_RUNTIME) run -it --rm "${APP_NAME}" \
		bash -c "/opt/Radarr/Radarr -nobrowser -data=/config & \
			   test.sh -t 30 -u http://localhost:7878/ -e Radarr"

.PHONY: shell
shell: ## Launce a shell in the container.
	$(CONTAINER_RUNTIME) run -it --rm \
		"${APP_NAME}" bash

.PHONY: clean
clean: ## Clean the generated files/images.
	$(CONTAINER_RUNTIME) rmi "${APP_NAME}"
