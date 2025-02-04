# RA.Aid Evals

This repository contains the evaluation framework and results for [RA.Aid](https://github.com/ai-christianson/RA.Aid) using SWE-bench.

## Building the SWE-Bench Evaluation Image

You can build the evaluation image either using local directories or remote repositories.

### Using Remote Repositories

```bash
# Build using default repositories and commits (master)
make swe-bench-image

# Build using custom repository URLs and commits
make swe-bench-image \
    RAAID_REPO=https://github.com/your-fork/RA.Aid.git \
    RAAID_COMMIT=your-branch-or-commit \
    RAAID_SWE_BENCH_REPO=https://github.com/your-fork/RA.Aid-swe-bench.git \
    RAAID_SWE_BENCH_COMMIT=your-branch-or-commit
```

Default repository URLs:
- RA.Aid: `https://github.com/ai-christianson/RA.Aid.git`
- SWE-bench: `https://github.com/ariel-frischer/RA.Aid-swe-bench.git`

### Using Local Directories

```bash
# Build using local RA.Aid and SWE-bench directories
make swe-bench-image \
    RAAID_LOCAL_DIR=/path/to/local/ra-aid \
    RAAID_SWE_BENCH_LOCAL_DIR=/path/to/local/swe-bench
```

## Running Evaluations

The Docker image includes all necessary dependencies to run the evaluations. Here's an example of how to run it:

```bash
docker run -t -i \
    -e ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY} \
    -e OPENAI_API_KEY=${OPENAI_API_KEY} \
    -e TAVILY_API_KEY=${TAVILY_API_KEY} \
    ra-aid-swe-bench:local-20250204-163516-local-20250204-163516 \
    /bin/bash -c 'python -m swe_lite_ra_aid.main'
```

**Note:** The environment variables shown above are just examples. Set the environment variables required for your specific evaluation configuration.
