#!/bin/bash
set -e

# Generate timestamp
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)

# Create metadata JSON
cat << EOF
{
  "timestamp": "${TIMESTAMP}",
  "image": "${IMAGE_NAME}:${IMAGE_TAG}"
}
EOF
