#!/bin/bash

set -e

# Setup cleanup trap
cleanup() {
    echo "Cleaning up..."
    if pgrep dockerd > /dev/null; then
        echo "Shutting down Docker daemon..."
        pkill dockerd
        sleep 3  # Give Docker daemon time to shutdown gracefully
    fi
}
trap cleanup EXIT

# Initialize pyenv
export PYENV_ROOT="/root/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# Check S3 configuration if enabled
if [ "${S3_ENABLED}" = "true" ]; then
    if [ -z "${S3_BUCKET_NAME}" ] || [ -z "${S3_ENDPOINT_URL}" ]; then
        echo "Error: S3_BUCKET_NAME and S3_ENDPOINT_URL must be set when S3_ENABLED is true"
        exit 1
    fi

    # Set default path prefix if not provided
    S3_PATH_PREFIX=${S3_PATH_PREFIX:-"evals"}
    
    # Configure AWS CLI retry behavior (optional, as it has good defaults)
    export AWS_RETRY_MODE=standard
    export AWS_MAX_ATTEMPTS=3
fi

# Generate timestamp and run directory path
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
RUN_DIR="${S3_PATH_PREFIX}/runs/${IMAGE_TAG}-${TIMESTAMP}"

# Create metadata file
generate_metadata > metadata.json

# Create a temporary directory for logs
mkdir -p logs
mkdir -p predictions

# Run prediction and capture output
echo "Running predictions..."
python -m swe_lite_ra_aid.main 2>&1 | tee output-predict.log

# Upload predictions immediately if S3 is enabled
if [ "${S3_ENABLED}" = "true" ]; then
    echo "Uploading predictions to S3..."
    
    # Upload metadata and predictions first
    aws s3 cp --endpoint-url "${S3_ENDPOINT_URL}" \
        metadata.json "s3://${S3_BUCKET_NAME}/${RUN_DIR}/metadata.json" || echo "Warning: Failed to upload metadata.json"
    
    # Upload predictions directory
    aws s3 sync --endpoint-url "${S3_ENDPOINT_URL}" \
        predictions/ "s3://${S3_BUCKET_NAME}/${RUN_DIR}/predictions/" || echo "Warning: Failed to upload predictions"
    
    # Upload prediction output log
    aws s3 cp --endpoint-url "${S3_ENDPOINT_URL}" \
        output-predict.log "s3://${S3_BUCKET_NAME}/${RUN_DIR}/output-predict.log" || echo "Warning: Failed to upload prediction log"
    
    echo "Predictions upload completed"
fi

# Run evaluation and capture output
echo "Running evaluation..."
python -m swe_lite_ra_aid.report /app/swe-bench/predictions/ra_aid_predictions 2>&1 | tee output-eval.log

# Upload to S3 if enabled
if [ "${S3_ENABLED}" = "true" ]; then
    echo "Uploading remaining files to S3..."
    
    # Upload logs directory
    aws s3 sync --endpoint-url "${S3_ENDPOINT_URL}" \
        logs/ "s3://${S3_BUCKET_NAME}/${RUN_DIR}/logs/"
    
    # Upload evaluation output log
    aws s3 cp --endpoint-url "${S3_ENDPOINT_URL}" \
        output-eval.log "s3://${S3_BUCKET_NAME}/${RUN_DIR}/output-eval.log"

    # Sync predictions directory
    aws s3 sync --endpoint-url "${S3_ENDPOINT_URL}" \
        predictions/ "s3://${S3_BUCKET_NAME}/${RUN_DIR}/predictions/" || echo "Warning: Failed to upload predictions"
    
    echo "S3 upload completed successfully"
fi