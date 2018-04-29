SHELL := zsh -e -u

.PHONY: build
build:
	docker-compose build

.PHONY: push
push: build
	docker-compose push

.PHONY: run
run: build
	docker-compose up
