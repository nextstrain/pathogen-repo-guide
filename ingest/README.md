# Ingest

This workflow ingests public data from NCBI and outputs curated metadata and
sequences that can be used as input for the phylogenetic workflow.

If you have another data source or private data that needs to be formatted for
the phylogenetic workflow, then you can use a similar workflow to curate your
own data.

## Run

From within the `ingest` directory, run the workflow with:

```
nextstrain build .
```

This produces a `results` directory with the following outputs:
- sequences.fasta
- metadata.tsv

## Config

The config directory contains all of the default configurations for the ingest workflow.

[config/defaults.yaml](config/defaults.yaml) contains all of the default configuration parameters
used for the ingest workflow. Use Snakemake's `--configfile`/`--config`
options to override these default values.

## Snakefile and rules

The rules directory contains separate Snakefiles (`*.smk`) as modules of the core ingest workflow.
The modules of the workflow are in separate files to keep the main ingest [Snakefile](Snakefile) succinct and organized.
Modules are all [included](https://snakemake.readthedocs.io/en/stable/snakefiles/modularization.html#includes)
in the main Snakefile in the order that they are expected to run.

## Profiles

The profiles directory contains custom configs and rules that override and/or
extend the default workflow.

- [nextstrain_automation](profiles/nextstrain_automation/) - profile for the internal automated Nextstrain builds.


## Vendored

This repository uses [`git subrepo`](https://github.com/ingydotnet/git-subrepo)
to manage copies of ingest scripts in [vendored](vendored), from [nextstrain/ingest](https://github.com/nextstrain/ingest).

See [vendored/README.md](vendored/README.md#vendoring) for instructions on how to update
the vendored scripts.
