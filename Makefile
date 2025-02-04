# Default values for build arguments
RAAID_COMMIT ?= master
RAAID_SWE_BENCH_COMMIT ?= master
RAAID_LOCAL_DIR ?=

# Docker image name
IMAGE_NAME = ra-aid-swe-bench
# Extract first 7 characters of each commit
RAAID_COMMIT_SHORT = $(if $(RAAID_LOCAL_DIR),local-$(shell find $(RAAID_LOCAL_DIR) -type f -exec sha256sum {} \; | sort | sha256sum | cut -c1-7),$(shell echo $(RAAID_COMMIT) | cut -c1-7))
RAAID_SWE_BENCH_COMMIT_SHORT = $(shell echo $(RAAID_SWE_BENCH_COMMIT) | cut -c1-7)
FULL_IMAGE_NAME = $(IMAGE_NAME):$(RAAID_COMMIT_SHORT)-$(RAAID_SWE_BENCH_COMMIT_SHORT)

# Directory for Docker build assets (created on the fly)
DOCKER_ASSETS_DIR = docker/.assets
RA_AID_ASSETS_DIR = $(DOCKER_ASSETS_DIR)/ra-aid

.PHONY: swe-bench-image clean-assets sync-local-ra-aid

clean-assets:
	rm -rf $(DOCKER_ASSETS_DIR)

sync-local-ra-aid:
ifneq ($(RAAID_LOCAL_DIR),)
	mkdir -p $(RA_AID_ASSETS_DIR)
	rsync -av --delete \
		--exclude '.git' \
		--exclude '__pycache__' \
		--exclude '*.pyc' \
		--exclude '*.pyo' \
		--exclude '*.pyd' \
		--exclude '.pytest_cache' \
		--exclude '*.egg-info' \
		$(RAAID_LOCAL_DIR)/ $(RA_AID_ASSETS_DIR)/
endif

swe-bench-image: clean-assets sync-local-ra-aid
	docker build \
		--build-arg RAAID_COMMIT=$(RAAID_COMMIT) \
		--build-arg RAAID_SWE_BENCH_COMMIT=$(RAAID_SWE_BENCH_COMMIT) \
		-t $(FULL_IMAGE_NAME) \
		-f docker/Dockerfile \
		.
	$(MAKE) clean-assets
