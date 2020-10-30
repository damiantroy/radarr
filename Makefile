APP_NAME ?= radarr

.PHONY: help
help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
.DEFAULT_GOAL := help

.PHONY: all
all: build test ## Build and test the container.

.PHONY: build
build: ## Build the container.
	podman build -t "${APP_NAME}" .

.PHONY: build-nc
build-nc: ## Build the container without cache.
	podman build --no-cache -t "${APP_NAME}" .

.PHONY: test
test: ## Test the container.
	podman run -it --rm --name "${APP_NAME}" "${APP_NAME}" \
		bash -c "/usr/bin/mono --debug /opt/Radarr/Radarr.exe -nobrowser & \
			   test.sh -t 30 -u http://localhost:7878/ -e Radarr"

.PHONY: clean
clean: ## Clean the generated files/images.
	podman rmi "${APP_NAME}"
