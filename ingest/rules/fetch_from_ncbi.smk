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
