FROM python:3.12-slim-bookworm

# Build arguments for repositories and commits
ARG RAAID_COMMIT
ARG RAAID_SWE_BENCH_COMMIT
ARG RAAID_REPO
ARG RAAID_SWE_BENCH_REPO

# Install git and build dependencies
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    curl \
    ripgrep \
    fzf \
    awscli \
    jq \
    docker.io \
    && rm -rf /var/lib/apt/lists/*

RUN pip install uv
RUN curl -fsSL https://pyenv.run | bash

# Set up pyenv environment
ENV PYENV_ROOT="/root/.pyenv"
ENV PATH="$PYENV_ROOT/bin:$PATH"
RUN echo 'eval "$(pyenv init -)"' >> /root/.bashrc && \
    echo 'eval "$(pyenv virtualenv-init -)"' >> /root/.bashrc

# Create source directories
WORKDIR /app
RUN mkdir -p ra-aid swe-bench

# Copy local ra-aid if available, otherwise clone from repository
COPY .assets/ra-aid ra-aid/
RUN if [ ! -f "ra-aid/pyproject.toml" ]; then \
    rm -rf ra-aid/* && \
    git clone ${RAAID_REPO} ra-aid && \
    cd ra-aid && \
    git checkout ${RAAID_COMMIT}; \
    fi

# Copy local swe-bench if available, otherwise clone from repository
COPY .assets/swe-bench swe-bench/
RUN if [ ! -f "swe-bench/pyproject.toml" ]; then \
    rm -rf swe-bench/* && \
    git clone ${RAAID_SWE_BENCH_REPO} swe-bench && \
    cd swe-bench && \
    git checkout ${RAAID_SWE_BENCH_COMMIT}; \
    fi

# Install pip-tools for handling requirements
RUN pip install --no-cache-dir pip-tools

# Install RA.Aid and its development dependencies
RUN cd ra-aid && \
    pip install --no-cache-dir -r requirements-dev.txt && \
    pip install --no-cache-dir -e .

# Install SWE-bench
RUN cd swe-bench && \
    pip install --no-cache-dir -e .

RUN mkdir -p /app/swe-bench/predictions/ra_aid_predictions

# Create script for generating metadata
COPY scripts/generate_metadata.sh /usr/local/bin/generate_metadata
RUN chmod +x /usr/local/bin/generate_metadata

# Copy and make run script executable
COPY run.sh /app/
RUN chmod +x /app/run.sh

# Set working directory to swe-bench as that's our primary project
WORKDIR /app/swe-bench