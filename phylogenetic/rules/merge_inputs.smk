
# Use module to include `merge_inputs` so that the rules' filepaths can be edited
module merge_inputs:
    snakefile: "../../shared/vendored/snakemake/merge_inputs.smk"
    config: config

use rule * from merge_inputs
input_metadata = merge_inputs.input_metadata
input_sequences = merge_inputs.input_sequences

use rule merge_metadata from merge_inputs with:
    output:
        metadata = "results/{type}/metadata_merged.tsv"
    log:
        "logs/{type}/merge_metadata.txt"
    benchmark:
        "benchmarks/{type}/merge_metadata.txt"

use rule merge_sequences from merge_inputs with:
    output:
        sequences = "results/{type}/sequences_merged.fasta"
    log:
        "logs/{type}/merge_sequences.txt",
    benchmark:
        "benchmarks/{type}/merge_sequences.txt"
