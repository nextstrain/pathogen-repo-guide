"""
This part of the workflow handles fetching sequences and metadata from NCBI
and outputs them as a single NDJSON file that can be directly fed into the
curation pipeline.

There are three different approaches for fetching data from NCBI.
Choose the one that works best for the pathogen data and remove the rules related
to the other approaches.

1. Fetch from Entrez (https://www.ncbi.nlm.nih.gov/books/NBK25501/)
    - Returns all avaiable data via a GenBank file
    - Requires a custom script to parse the necessary fields from the GenBank file

2. Fetch from NCBI Virus (https://www.ncbi.nlm.nih.gov/labs/virus/vssi/#/)
    - Directly returns NDJSON without custom parsing
    - Can only be used for viral data, see https://www.ncbi.nlm.nih.gov/labs/virus/vssi/#/find-data/virus for supported taxon IDs
    - Only returns metadata fields that are avaiable through NCBI virus
    - Requires observation of network activity on the NCBI Virus site if you want to add custom fields and/or filtering

3. Fetch with NCBI Datasets (https://www.ncbi.nlm.nih.gov/datasets/)
    - Directly returns NDJSON without custom parsing
    - Fastest option for large datasets (e.g. SARS-CoV-2)
    - Only returns metadata fields that are avaiable through NCBI Datasets
    - Example is written for viral data, please see offical NCBI Datasets docs for other genomes
"""

###########################################################################
########################## 1. Fetch from Entrez ###########################
###########################################################################

rule fetch_from_ncbi_entrez:
    params:
        term = config["entrez_search_term"]
    output:
        genbank = "data/genbank.gb"
    # Allow retries in case of network errors
    retries: 5
    benchmark:
        "benchmarks/fetch_from_ncbi_entrez.txt"
    shell:
        """
        vendored/fetch-from-ncbi-entrez \
            --term {params.term:q} \
            --output {output.genbank}
        """


rule parse_genbank_to_ndjson:
    input:
        genbank = "data/genbank.gb"
    output:
        ndjson = "data/ncbi.ndjson"
    benchmark:
        "benchmarks/parse_genbank_to_ndjson.txt"
    shell:
        """
        # Add in custom script to parse needed fields from GenBank file to NDJSON file
        """


###########################################################################
######################## 2. Fetch from NCBI Virus #########################
###########################################################################

def _get_ncbi_virus_option(option_name: str, option_values: list) -> str:
    return " ".join(
        f"--{option_name}='{value}'"
        for value in option_values
    )


rule fetch_from_ncbi_virus:
    params:
        ncbi_taxon_id = config["ncbi_taxon_id"],
        # Replace <pathogen> with repo name
        github_repo = "nextstrain/<pathogen>",
        # Optional filters to filter records on the NCBI Virus server
        ncbi_virus_filters = _get_ncbi_virus_option("filter", config["ncbi_virus_filters"]),
        # Optional fields to add to the NDJSON output
        ncbi_virus_fields = _get_ncbi_virus_option("field", config["ncbi_virus_fields"]),
    output:
        ndjson = "data/ncbi.ndjson"
    # Allow retries in case of network errors
    retries: 5
    benchmark:
        "benchmarks/fetch_from_ncbi_virus.txt"
    shell:
        """
        vendored/fetch-from-ncbi-virus \
            {params.ncbi_virus_filters} \
            {params.ncbi_virus_fields} \
            {params.ncbi_taxon_id:q} \
            {params.github_repo:q} > {output.ndjson}
        """


###########################################################################
####################### 3. Fetch from NCBI Datasets #######################
###########################################################################

rule fetch_ncbi_dataset_package:
    params:
        ncbi_taxon_id = config["ncbi_taxon_id"],
    output:
        dataset_package = temp("data/ncbi_dataset.zip")
    # Allow retries in case of network errors
    retries: 5
    benchmark:
        "benchmarks/fetch_ncbi_dataset_package.txt"
    shell:
        """
        datasets download virus genome taxon {params.ncbi_taxon_id:q} \
            --no-progressbar \
            --filename {output.dataset_package}
        """


rule extract_ncbi_dataset_sequences:
    input:
        dataset_package = "data/ncbi_dataset.zip"
    output:
        ncbi_dataset_sequences = temp("data/ncbi_dataset_sequences.fasta")
    benchmark:
        "benchmarks/extract_ncbi_dataset_sequences.txt"
    shell:
        """
        unzip -jp {input.dataset_package} \
            ncbi_dataset/data/genomic.fna > {output.ncbi_dataset_sequences}
        """


def _get_ncbi_dataset_field_mnemonics(provided_fields: list) -> str:
    """
    Return list of NCBI Dataset report field mnemonics for fields that we want
    to parse out of the dataset report. The column names in the output TSV
    are different from the mnemonics.

    Additional *provided_fields* will be appended to the end of the list.

    See NCBI Dataset docs for full list of available fields and their column
    names in the output:
    https://www.ncbi.nlm.nih.gov/datasets/docs/v2/reference-docs/command-line/dataformat/tsv/dataformat_tsv_virus-genome/#fields
    """
    fields = [
        "accession",
        "sourcedb",
        "sra-accs",
        "isolate-lineage",
        "geo-region",
        "geo-location",
        "isolate-collection-date",
        "release-date",
        "update-date",
        "length",
        "host-name",
        "isolate-lineage-source",
        "biosample-acc",
        "submitter-names",
        "submitter-affiliation",
        "submitter-country",
    ]
    return ",".join(fields + provided_fields)


rule format_ncbi_dataset_report:
    input:
        dataset_package = "data/ncbi_dataset.zip"
    output:
        ncbi_dataset_tsv = temp("data/ncbi_dataset_report.tsv")
    params:
        fields_to_include = _get_ncbi_dataset_field_mnemonics(config["ncbi_dataset_fields"])
    benchmark:
        "benchmarks/format_ncbi_dataset_report.txt"
    shell:
        """
        dataformat tsv virus-genome \
            --package {input.dataset_package} \
            --fields {params.fields_to_include:q} \
            > {output.ncbi_dataset_tsv}
        """


# Technically you can bypass this step and directly provide FASTA and TSV files
# as input files for the curate pipeline.
# We do the formatting here to have a uniform NDJSON file format for the raw
# data that we host on data.nextstrain.org
rule format_ncbi_datasets_ndjson:
    input:
        ncbi_dataset_sequences = "data/ncbi_dataset_sequences.fasta",
        ncbi_dataset_tsv = "data/ncbi_dataset_report.tsv",
    output:
        ndjson = "data/ncbi.ndjson",
    log:
        "logs/format_ncbi_datasets_ndjson.txt"
    benchmark:
        "benchmarks/format_ncbi_datasets_ndjson.txt"
    shell:
        """
        augur curate passthru \
            --metadata {input.ncbi_dataset_tsv} \
            --fasta {input.ncbi_dataset_sequences} \
            --seq-id-column Accession \
            --seq-field sequence \
            --unmatched-reporting warn \
            --duplicate-reporting warn \
            2> {log} > {output.ndjson}
        """
