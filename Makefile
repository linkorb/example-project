.PHONY: help

GIT_COMMIT=$(shell git rev-parse --verify HEAD --short)



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
	composer update -q --prefer-dist

vendor: composer.lock ## Install vendor libraries
	composer install -q --prefer-dist
	touch vendor/

docker-login:
	docker login -u "${DOCKER_USERNAME}" -p "${DOCKER_PASSWORD}" registry.linkorb.com

docker-build: ## Build docker image
	docker build -t registry.linkorb.com/linkorb/example-project .

docker-run: ## Run application as docker image
	docker run -it -e HELLO_NAME='Galaxy' --rm example-project

docker-publish: docker-login ## Build and publish docker image to registry
	docker build -t registry.linkorb.com/linkorb/example-project:$(GIT_COMMIT) .
	docker tag registry.linkorb.com/linkorb/example-project:$(GIT_COMMIT) registry.linkorb.com/linkorb/example-project:latest
ifdef TRAVIS_BUILD_NUMBER
	docker tag registry.linkorb.com/linkorb/example-project:$(GIT_COMMIT) registry.linkorb.com/linkorb/example-project:travis-$(TRAVIS_BUILD_NUMBER)
endif
ifdef CIRCLE_BUILD_NUM
	docker tag registry.linkorb.com/linkorb/example-project:$(GIT_COMMIT) registry.linkorb.com/linkorb/example-project:circleci-$(CIRCLE_BUILD_NUM)
endif
	docker push registry.linkorb.com/linkorb/example-project

test: build phpqa-phpunit phpqa-phpcs ## Run tests

phpqa-phpunit: ## Run phpunit tests
	vendor/bin/phpunit

phpqa-phpcs: ## Run phpcs tests
	vendor/bin/phpcs --standard=PSR2 src/ tests/
