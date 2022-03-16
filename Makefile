REMOTE_PATH=/var/www/k8x.in
REMOTE_HOST=k8x@alpha.k8x.in
REMOTE_LOCATION=$(REMOTE_HOST):$(REMOTE_PATH)/

.PHONY: push
push: build
	rsync -avz site/* $(REMOTE_LOCATION)

.PHONY: build
build:
	mkdocs build
