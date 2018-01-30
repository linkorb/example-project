.PHONY: help


help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

all: build test docker-login docker-build docker-push

.PHONY: clean
clean:
	@echo "Cleaning"
	@rm -rf ./vendor
	@rm -f .env
	@echo "Done!"

.env:
	@echo "Copying .env from .env.dist"
	@cp .env.dist .env

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

docker-run: docker-build ## Run application as docker imae
	docker run -it -e HELLO_NAME='Galaxy' --rm example-project

docker-push:
	docker push registry.linkorb.com/linkorb/example-project

test: build phpqa-phpunit phpqa-phpcs ## Run tests

phpqa-phpunit: ## Run phpunit tests
	phpunit

phpqa-phpcs: ## Run phpcs tests
	vendor/bin/phpcs --standard=PSR2 src/ tests/
