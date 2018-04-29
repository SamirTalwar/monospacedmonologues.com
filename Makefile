SHELL := zsh -e -u

.PHONY: build
build:
	docker build --tag=samirtalwar/hugo services/hugo
	docker-compose build

.PHONY: push
push: build
	docker-compose push

.PHONY: run
run: build
	docker-compose up
