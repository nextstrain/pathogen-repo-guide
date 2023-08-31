"""
This part of the workflow prepares sequences for constructing the reference tree
of the Nextclade dataset.

This usually includes the following steps:

    - filtering
    - subsampling
    - indexing
    - aligning
    - masking

This part of the workflow expects a metadata and FASTA file as inputs
and will produce a FASTA file of prepared sequences as an output.
"""
