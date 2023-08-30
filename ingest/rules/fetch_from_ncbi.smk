"""
This part of the workflow handles fetching sequences and metadata from NCBI
and outputs them as a single NDJSON file that can be directly fed into the
curation pipeline.

There are three different approaches for fetching data from NCBI.
Choose the one that works best for the pathogen data and remove the rules related
to the other approaches.
"""
