.ONESHELL:
.PHONY: serve
serve:
	zola serve

.PHONY: build
build:
	zola build
	cp -r public/* ../galileilei.bitbucket.io/.
	cd ../galileilei.bitbucket.io && \
	git pull origin master && \
	git add . && \
	git commit -m "new version" && \
	git push -u origin master