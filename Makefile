SHELL := bash -e -u

INPUT_FILES := $(wildcard archetypes/**/* content/**/* layouts/**/* resources/**/* static/**/* themes/**/*)

.PHONY: build
build: assets public

assets:
	aws s3 sync s3://assets.monospacedmonologues.com assets

public: $(INPUT_FILES)
	HUGO_ENV=production hugo --cleanDestinationDir --buildFuture
	touch $@

.PHONY: serve
serve:
	hugo server --buildFuture

.PHONY: deploy
deploy: deploy-site deploy-assets

.PHONY: hardware
hardware:
	terraform init
	terraform apply

.PHONY: deploy-site
deploy-site: hardware public
	aws s3 sync public s3://monospacedmonologues.com --acl=public-read --delete

.PHONY: deploy-assets
deploy-assets: hardware assets
	aws s3 sync assets s3://assets.monospacedmonologues.com --acl=public-read --delete
