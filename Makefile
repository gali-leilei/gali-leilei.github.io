.ONESHELL:

.PHONY: serve
# local testing
serve:
	zola serve

.PHONY: build
# build the site
build:
	zola build