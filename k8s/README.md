# Kubernetes Deployment for RA.Aid Evaluations

This directory contains the necessary files to run RA.Aid evaluations as Kubernetes jobs.

## Prerequisites

1. A Kubernetes cluster with access configured via `kubectl`
2. Ansible installed with the `kubernetes.core` collection
3. Required API keys:
   - Anthropic API key
   - OpenAI API key
   - Tavily API key
4. The RA.Aid evaluation Docker image built and accessible to your cluster

## Setup

1. Copy the example values file:
   ```bash
   cp values.example.yaml values.yaml
   ```

2. Edit `values.yaml` to match your requirements:
   - Adjust resource requests/limits
   - Set the correct image repository and tag
   - Modify job settings if needed

3. Ensure your API keys are set in your environment:
   ```bash
   export ANTHROPIC_API_KEY='your-key-here'
   export OPENAI_API_KEY='your-key-here'
   export TAVILY_API_KEY='your-key-here'
   ```

## Running the Evaluation

1. Deploy the job:
   ```bash
   ansible-playbook deploy.yml
   ```

   To use a different values file:
   ```bash
   ansible-playbook deploy.yml -e values_file=my-values.yaml
   ```

2. Monitor the job:
   ```bash
   kubectl -n ra-aid-evals get jobs
   kubectl -n ra-aid-evals get pods
   kubectl -n ra-aid-evals logs -f <pod-name>
   ```

## Cleanup

Jobs will automatically be cleaned up after completion based on the `ttlSecondsAfterFinished` setting (default: 1 hour).

To manually delete a job:
```bash
kubectl -n ra-aid-evals delete job <job-name>
```

## Troubleshooting

1. Check job status:
   ```bash
   kubectl -n ra-aid-evals describe job <job-name>
   ```

2. Check pod status and logs:
   ```bash
   kubectl -n ra-aid-evals describe pod <pod-name>
   kubectl -n ra-aid-evals logs <pod-name>
   ```

3. Common issues:
   - Missing API keys: Ensure all required environment variables are set
   - Resource constraints: Check if the pod is pending due to insufficient resources
   - Image pull errors: Verify image repository and tag are correct
