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
