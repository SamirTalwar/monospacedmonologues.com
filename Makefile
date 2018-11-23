SHELL := zsh -e -u

assets:
	aws s3 sync s3://monospacedmonologues.com assets

.PHONY: build
build:
	docker-compose build

.PHONY: pushable
pushable:
	@ [[ -z "$$(git status --porcelain)" ]] || { echo >&2 "Cannot push with a dirty working tree."; exit 1; }

.PHONY: push
push: pushable push-assets build
	docker-compose push
	git push

.PHONY: push-assets
push-assets: pushable
	aws s3 sync assets s3://monospacedmonologues.com

.PHONY: run
run: build
	docker-compose up
