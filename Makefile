# Default values for build arguments
RAAID_COMMIT ?= master
RAAID_SWE_BENCH_COMMIT ?= master

# Docker image name
IMAGE_NAME = ra-aid-evals
# Extract first 7 characters of each commit
RAAID_COMMIT_SHORT = $(shell echo $(RAAID_COMMIT) | cut -c1-7)
RAAID_SWE_BENCH_COMMIT_SHORT = $(shell echo $(RAAID_SWE_BENCH_COMMIT) | cut -c1-7)
FULL_IMAGE_NAME = $(IMAGE_NAME):$(RAAID_COMMIT_SHORT)-$(RAAID_SWE_BENCH_COMMIT_SHORT)

.PHONY: image

image:
	docker build \
		--build-arg RAAID_COMMIT=$(RAAID_COMMIT) \
		--build-arg RAAID_SWE_BENCH_COMMIT=$(RAAID_SWE_BENCH_COMMIT) \
		-t $(FULL_IMAGE_NAME) \
		-f docker/Dockerfile \
		.
