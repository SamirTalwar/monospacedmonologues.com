SHELL := zsh -e -u

TAG = samirtalwar/monospacedmonologues.com
PORT = 1313

.PHONY: build
build:
	docker build --tag=samirtalwar/hugo services/hugo
	docker build --tag=$(TAG) .

.PHONY: push
push: build
	docker push $(TAG)

.PHONY: run
run: build
	docker run \
		--rm \
		--interactive --tty \
		--publish=$(PORT):$(PORT) \
		--env=PORT=$(PORT) \
		$(TAG) \
		server --bind=0.0.0.0 --port=$(PORT)
