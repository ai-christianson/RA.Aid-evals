#!/bin/bash

set -x
set -e

python -m swe_lite_ra_aid.main
python -m swe_lite_ra_aid.report /app/swe-bench/predictions/ra_aid_predictions