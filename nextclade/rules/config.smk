"""
This part of the workflow deals with configuration.

OUTPUTS:

    results/run_config.yaml

The output is represents the fully merged config dict that is used by Snakemake
during the workflow run. It should _not_ be manually edited because the
workflow will automatically overwrite it on every run.
"""

write_config("results/run_config.yaml")
