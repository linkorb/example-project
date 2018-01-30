.PHONY: help


help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

all: build test

clean: ## Cleanup
	rm -rf ./vendor
	rm -f .env

.env:
	cp .env.dist .env

build: .env vendor ## Build it
	@echo "Building"

composer.lock: ## Generate composer.lock
	composer update

vendor: composer.lock ## Install vendor libraries
	composer install
	touch vendor/

docker-login:
	docker login -u "${DOCKER_USERNAME}" -p "${DOCKER_PASSWORD}" registry.linkorb.com

docker-build: ## Build docker image
	docker build -t registry.linkorb.com/linkorb/example-project .

docker-run: ## Run application as docker image
	docker run -it -e HELLO_NAME='Galaxy' --rm example-project

docker-push:
	docker push registry.linkorb.com/linkorb/example-project

docker-publish: docker-login docker-build docker-push ## Build and publish docker image to registry

test: build phpqa-phpunit phpqa-phpcs ## Run tests

phpqa-phpunit: ## Run phpunit tests
	phpunit

phpqa-phpcs: ## Run phpcs tests
	vendor/bin/phpcs --standard=PSR2 src/ tests/
