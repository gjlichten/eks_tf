SHELL := /bin/bash

TERRAFORM_IMAGE = hashicorp/terraform:0.12.18

DOCKER_OPTS = -v ~/.aws:/root/.aws \
  -v `pwd`:/terraform \
  -v `pwd`/..:/modules/istream_eks:ro \
  -w /terraform
TERRAFORM_COMMAND = docker run -it --rm ${DOCKER_OPTS} ${TERRAFORM_IMAGE}
DOCKER_SHELL = docker run -it --rm \
--entrypoint "/bin/sh" ${DOCKER_OPTS} ${TERRAFORM_IMAGE}

version:
	${TERRAFORM_COMMAND} version

shell: ## Terraform Shell

	${DOCKER_SHELL}

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
