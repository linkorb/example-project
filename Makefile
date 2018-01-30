.PHONY: help


help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

all: build test

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

test: build phpqa-phpunit phpqa-phpcs ## Run tests

phpqa-phpunit: ## Run phpunit tests
	phpunit

phpqa-phpcs: ## Run phpcs tests
	vendor/bin/phpcs --standard=PSR2 src/ tests/
