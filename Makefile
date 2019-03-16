SHELL := zsh -e -u

assets:
	aws s3 sync s3://assets.monospacedmonologues.com assets

.PHONY: build
build:
	docker-compose build

.PHONY: deploy
deploy: deploy-site deploy-assets

.PHONY: hardware
hardware:
	terraform init
	terraform apply

.PHONY: deploy-site
deploy-site: hardware build
	docker-compose push
	git push

.PHONY: deploy-assets
deploy-assets: hardware assets
	aws s3 sync assets s3://assets.monospacedmonologues.com --acl=public-read --delete

.PHONY: run
run: build
	docker-compose up
