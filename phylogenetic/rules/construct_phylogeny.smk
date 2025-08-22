"""
This part of the workflow constructs the phylogenetic tree.

REQUIRED INPUTS:

    metadata            = input_metadata (defined by merge_inputs.smk)
    prepared_sequences  = results/prepared_sequences.fasta

OUTPUTS:

    tree            = results/tree.nwk
    branch_lengths  = results/branch_lengths.json

This part of the workflow usually includes the following steps:

    - augur tree
    - augur refine

See Augur's usage docs for these commands for more details.
"""
