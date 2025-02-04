FROM python:3.13-slim-bookworm

# Build arguments for repositories and commits
ARG RAAID_COMMIT
ARG RAAID_SWE_BENCH_COMMIT
ARG RAAID_REPO
ARG RAAID_SWE_BENCH_REPO

# Install git and build dependencies
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Create source directories
WORKDIR /app
RUN mkdir -p ra-aid swe-bench

# Copy local ra-aid if available, otherwise clone from repository
COPY docker/.assets/ra-aid ra-aid/ 2>/dev/null || true
RUN if [ ! -d "ra-aid/.git" ] && [ ! -f "ra-aid/pyproject.toml" ]; then \
    rm -rf ra-aid/* && \
    git clone ${RAAID_REPO} ra-aid && \
    cd ra-aid && \
    git checkout ${RAAID_COMMIT}; \
    fi

# Clone swe-bench repository
RUN git clone ${RAAID_SWE_BENCH_REPO} swe-bench && \
    cd swe-bench && \
    git checkout ${RAAID_SWE_BENCH_COMMIT}

# Install pip-tools for handling requirements
RUN pip install --no-cache-dir pip-tools

# Install RA.Aid and its development dependencies
RUN cd ra-aid && \
    pip install --no-cache-dir -r requirements-dev.txt && \
    pip install --no-cache-dir -e .

# Install SWE-bench
RUN cd swe-bench && \
    pip install --no-cache-dir -e .

# Set working directory to swe-bench as that's our primary project
WORKDIR /app/swe-bench