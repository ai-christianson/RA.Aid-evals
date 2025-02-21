# Default values for build arguments
RAAID_COMMIT ?= master
RAAID_SWE_BENCH_COMMIT ?= master
RAAID_LOCAL_DIR ?=
RAAID_SWE_BENCH_LOCAL_DIR ?=

# Repository URLs
RAAID_REPO ?= https://github.com/ai-christianson/RA.Aid.git
RAAID_SWE_BENCH_REPO ?= https://github.com/ariel-frischer/RA.Aid-swe-bench.git

# Docker image name
IMAGE_NAME = ra-aid-swe-bench
# Extract first 7 characters of each commit
RAAID_COMMIT_SHORT = $(if $(RAAID_LOCAL_DIR),local-$(shell date +%Y%m%d-%H%M%S),$(shell echo $(RAAID_COMMIT) | cut -c1-7))
RAAID_SWE_BENCH_COMMIT_SHORT = $(if $(RAAID_SWE_BENCH_LOCAL_DIR),local-$(shell date +%Y%m%d-%H%M%S),$(shell echo $(RAAID_SWE_BENCH_COMMIT) | cut -c1-7))
FULL_IMAGE_NAME = $(IMAGE_NAME):$(RAAID_COMMIT_SHORT)-$(RAAID_SWE_BENCH_COMMIT_SHORT)

# Directory for Docker build assets (created on the fly)
DOCKER_ASSETS_DIR = docker/.assets
RA_AID_ASSETS_DIR = $(DOCKER_ASSETS_DIR)/ra-aid
SWE_BENCH_ASSETS_DIR = $(DOCKER_ASSETS_DIR)/swe-bench

.PHONY: swe-bench-image clean-assets sync-local-ra-aid sync-local-swe-bench patch-swe-bench-pyproject

clean-assets:
	rm -rf $(DOCKER_ASSETS_DIR)

sync-local-ra-aid: clean-assets
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
		--exclude 'logs/*' \
		--exclude 'predictions/' \
		--exclude 'ra-aid-model.ra_aid_eval.json' \
		--exclude '.venv' \
		--exclude 'htmlcov' \
		$(RAAID_LOCAL_DIR)/ $(RA_AID_ASSETS_DIR)/
	mkdir -p $(RA_AID_ASSETS_DIR)/logs
endif

sync-local-swe-bench: clean-assets
ifneq ($(RAAID_SWE_BENCH_LOCAL_DIR),)
	mkdir -p $(SWE_BENCH_ASSETS_DIR)
	rsync -av --delete \
		--exclude '.git' \
		--exclude '__pycache__' \
		--exclude '*.pyc' \
		--exclude '*.pyo' \
		--exclude '*.pyd' \
		--exclude '.pytest_cache' \
		--exclude '*.egg-info' \
		--exclude 'logs/*' \
		--exclude 'predictions/' \
		--exclude 'ra-aid-model.ra_aid_eval.json' \
		--exclude '.venv' \
		--exclude 'repos' \
		--exclude 'repos/*' \
		$(RAAID_SWE_BENCH_LOCAL_DIR)/ $(SWE_BENCH_ASSETS_DIR)/
	mkdir -p $(SWE_BENCH_ASSETS_DIR)/logs
endif

patch-swe-bench-pyproject:
	@if [ -f "$(SWE_BENCH_ASSETS_DIR)/pyproject.toml" ]; then \
		sed -i '/^ra-aid = /c\ra-aid = { path = "/app/ra-aid", develop = true }' $(SWE_BENCH_ASSETS_DIR)/pyproject.toml; \
	fi

swe-bench-image: clean-assets sync-local-ra-aid sync-local-swe-bench patch-swe-bench-pyproject
	docker build \
		--build-arg RAAID_COMMIT=$(RAAID_COMMIT) \
		--build-arg RAAID_SWE_BENCH_COMMIT=$(RAAID_SWE_BENCH_COMMIT) \
		--build-arg RAAID_REPO=$(RAAID_REPO) \
		--build-arg RAAID_SWE_BENCH_REPO=$(RAAID_SWE_BENCH_REPO) \
		-t $(FULL_IMAGE_NAME) \
		-f docker/Dockerfile \
		docker/
	$(MAKE) clean-assets
