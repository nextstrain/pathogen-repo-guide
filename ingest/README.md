# Ingest

This workflow ingests public data from NCBI and outputs curated metadata and
sequences that can be used as input for the phylogenetic workflow.

If you have another data source or private data that needs to be formatted for
the phylogenetic workflow, then you can use a similar workflow to curate your
own data.

## Config

The config directory contains all of the default configurations for the ingest workflow.

[config/defaults.yaml](config/defaults.yaml) contains all of the default configuration parameters
used for the ingest workflow. Use Snakemake's `--configfile`/`--config`
options to override these default values.
