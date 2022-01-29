SHELL := /bin/bash
CONTAINER_NAME = fingerprint_finder

.PHONY: help
help: ## View help information
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: build
build: ## Build the container to run our commands within a container
	docker build -t $(CONTAINER_NAME) -f ./Dockerfile .

.PHONY: run
run: build ## Spit out the fingerprint for the root CA. Requires CLUSTER_OIDC_URL env variable
ifndef CLUSTER_OIDC_URL
	$(error CLUSTER_OIDC_URL is undefined)
endif
	docker run -e CLUSTER_OIDC_URL -it --rm $(CONTAINER_NAME)
