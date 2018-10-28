SHELL := zsh -e -u

assets:
	aws s3 sync s3://monospacedmonologues.com assets

.PHONY: build
build:
	docker-compose build

.PHONY: push
push: push-assets build
	docker-compose push

.PHONY: push-assets
push-assets:
	aws s3 sync assets s3://monospacedmonologues.com

.PHONY: run
run: build
	docker-compose up
