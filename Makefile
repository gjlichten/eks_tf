SHELL := /bin/bash
.DEFAULT_GOAL := help

usage: ## Generate and write USAGE.md

	docker run --rm \
  -v `pwd`:/data \
  cytopia/terraform-docs \
  terraform-docs-012 \
	md . > USAGE.md

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
