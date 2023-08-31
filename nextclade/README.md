# Nextclade

Previously, all "official" Nextclade workflows lived in a [central GitHub repository](https://github.com/neherlab/nextclade_data_workflows).
The new standard would be to include the Nextclade workflow within the pathogen repo.

This workflow is used to create the Nextclade datasets available in [nextclade_datasets](../nextclade_datasets/).

## Config

The config directory contains all of the default configurations for the Nextclade workflow.

[config/defaults.yaml](config/defaults.yaml) contains all of the default configuration parameters
used for the Nextclade workflow. Use Snakemake's `--configfile`/`--config`
options to override these default values.
