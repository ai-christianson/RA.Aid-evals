# Default values for build arguments
RAAID_COMMIT ?= master
RAAID_SWE_BENCH_COMMIT ?= master

# Docker image name
IMAGE_NAME = ra-aid-evals

.PHONY: build

build:
	docker build \
		--build-arg RAAID_COMMIT=$(RAAID_COMMIT) \
		--build-arg RAAID_SWE_BENCH_COMMIT=$(RAAID_SWE_BENCH_COMMIT) \
		-t $(IMAGE_NAME) \
		-f docker/Dockerfile \
		.
