# Phylogenetic

This workflow uses metadata and sequences to produce one or multiple [Nextstrain datasets][]
that can be visualized in Auspice.

## Data Requirements

The core phylogenetic workflow will use metadata values as-is, so please do any
desired data formatting and curations as part of the [ingest](../ingest/) workflow.

1. The metadata must include an ID column that can be used as as exact match for
   the sequence ID present in the FASTA headers.
2. The `date` column in the metadata must be in ISO 8601 date format (i.e. YYYY-MM-DD).
3. Ambiguous dates should be masked with `XX` (e.g. 2023-01-XX).



[Nextstrain datasets]: https://docs.nextstrain.org/en/latest/reference/glossary.html#term-dataset
