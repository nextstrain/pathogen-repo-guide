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

## Snakefile and rules

The rules directory contains separate Snakefiles (`*.smk`) as modules of the core ingest workflow.
The modules of the workflow are in separate files to keep the main ingest [Snakefile](Snakefile) succinct and organized.
Modules are all [included](https://snakemake.readthedocs.io/en/stable/snakefiles/modularization.html#includes)
in the main Snakefile in the order that they are expected to run.

## Vendored

This repository uses [`git subrepo`](https://github.com/ingydotnet/git-subrepo)
to manage copies of ingest scripts in [vendored](vendored), from [nextstrain/ingest](https://github.com/nextstrain/ingest).

To pull new changes from the central ingest repository, first install `git subrepo`,
then from the top level directory of the repo run:

```sh
git subrepo pull ingest/vendored
```

Changes should not be pushed using `git subrepo push`.

1. For pathogen-specific changes, make them in this repository via a pull request.
2. For pathogen-agnostic changes, make them on [nextstrain/ingest](https://github.com/nextstrain/ingest)
   via pull request there, then use `git subrepo pull` to add those changes to this repository.
