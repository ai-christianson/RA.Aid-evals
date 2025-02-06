from datasets import load_dataset
import pandas as pd

# Load the SWE-bench Lite dataset
ds = load_dataset("princeton-nlp/SWE-bench_Lite")

# Convert the dataset to a pandas DataFrame
df = ds['test'].to_pandas()

# Select a random subset of 50 tasks
subset = df.sample(n=50, random_state=42)

# Display the subset
print(subset)