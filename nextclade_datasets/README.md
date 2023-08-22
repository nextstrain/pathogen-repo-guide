# Nextclade Datasets

Previously, all "official" Nextclade datasets lived in a [central GitHub repository](https://github.com/nextstrain/nextclade_data)
and were deployed to a central AWS S3 bucket that has a AWS Cloudfront distribution.

The new standard would be to host these within the corresponding pathogen repo,
while still mirroring files on AWS S3.

## Organization

Pathogens can potentially have multiple datasets for different subcategories (e.g. seasonal flu subtypes),
where datasets for each subcategory is organized within a single directory.

Each subcategory directory should then have the same file organization:

```
nextclade_datsets/
└── <pathogen_subcategory>/
    ├── references/
    │   └── <reference_accession>/
    │       ├── versions/
    │       │   └── <version>/
    │       │       └── files/
    │       │           ├── genemap.gff
    │       │           ├── primers.csv
    │       │           ├── qc.json
    │       │           ├── reference.fasta
    │       │           ├── sequences.fasta
    │       │           ├── tag.json
    │       │           ├── tree.json
    │       │           └── virus_properties.json
    │       └── datasetRef.json
    └── dataset.json
```

See [Nextclade docs](https://docs.nextstrain.org/projects/nextclade/en/stable/user/input-files.html) for more details on the file formats.
