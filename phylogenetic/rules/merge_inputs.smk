"""
This part of the workflow merges inputs based on what is defined in the config.

The config dict is expected to have a top-level `inputs` list that defines the
separate inputs' name, metadata, and sequences. Optionally, the config can have
a top-level `additional-inputs` list that is used to define additional data that
are combined with the default inputs:

```yaml
inputs:
    - name: default
      metadata: <path-or-url>
      sequences: <path-or-url>

additional_inputs:
    - name: private
      metadata: <path-or-url>
      sequences: <path-or-url>
```

The inputs can then be accessed in any downstream rules with the functions
`input_metadata` and `input_sequences`.

Example:

    rule filter:
        input:
            metadata = input_metadata,
            sequences = input_sequences,

The supported compressions for the inputs will vary depending on the number of inputs defined.

1. For a single input source, the <path-or-url> will be directly referenced as
the input in downstream rules. As such, the <path-or-url> can use any compression
scheme that the downstream commands can handle.

2. Multiple input sources are merged via `augur merge` and thus <path-or-url>
can be compressed with any compression scheme which `augur merge` supports.
The merged files are stored uncompressed so there's no need to worry about the
compression support of downstream commands.


NOTE: The included `merge_*` rules are written for single build workflows such
as zika that do not use wildcards. You will need to edit the rules to support wildcards

1. If your workflow needs wildcards for both metadata and sequences,
e.g. serotypes for dengue, then you will need to edit the `output`, `log`, and
`benchmark` paths both the `merge_metadata` and `merge_sequences` rules.
The wildcards can then be directly used in the config for inputs:

```yaml
inputs:
    - name: default
      metadata: https://data.nextstrain.org/files/workflows/dengue/metadata_{serotype}.tsv.zst
      sequences: https://data.nextstrain.org/files/workflows/dengue/sequences_{serotype}.fasta.zst

```

2. If your workflow only needs wildcards for sequences, e.g. segments for influenza,
then you will only need to edit the paths for the `merge_sequences` rule.
The wildcards can then be directly used in the config for inputs:

```yaml
inputs:
    - name: default
      metadata: s3://nextstrain-data-private/files/workflows/avian-flu/metadata.tsv.zst
      sequences: s3://nextstrain-data-private/files/workflows/avian-flu/{segment}/sequences.fasta.zst
```
"""


def _gather_inputs():
    all_inputs = [*config['inputs'], *config.get('additional_inputs', [])]

    if len(all_inputs)==0:
        raise InvalidConfigError("Config must define at least one element in config.inputs or config.additional_inputs lists")
    if not all([isinstance(i, dict) for i in all_inputs]):
        raise InvalidConfigError("All of the elements in config.inputs and config.additional_inputs lists must be dictionaries"
            "If you've used a command line '--config' double check your quoting.")
    if len({i['name'] for i in all_inputs})!=len(all_inputs):
        raise InvalidConfigError("Names of inputs (config.inputs and config.additional_inputs) must be unique")
    if not all(['name' in i and ('sequences' in i or 'metadata' in i) for i in all_inputs]):
        raise InvalidConfigError("Each input (config.inputs and config.additional_inputs) must have a 'name' and 'metadata' and/or 'sequences'")

    available_keys = set(['name', 'metadata', 'sequences'])
    if any([len(set(el.keys())-available_keys)>0 for el in all_inputs]):
        raise InvalidConfigError(f"Each input (config.inputs and config.additional_inputs) can only include keys of {', '.join(available_keys)}")

    return {el['name']: {k:(v if k=='name' else path_or_url(v)) for k,v in el.items()} for el in all_inputs}

input_sources = _gather_inputs()

def input_metadata(wildcards):
    inputs = [info['metadata'] for info in input_sources.values() if info.get('metadata', None)]
    return inputs[0] if len(inputs)==1 else rules.merge_metadata.output.metadata

def input_sequences(wildcards):
    inputs = [info['sequences'] for info in input_sources.values() if info.get('sequences', None)]
    return inputs[0] if len(inputs)==1 else rules.merge_sequences.output.sequences

rule merge_metadata:
    """
    This rule should only be invoked if there are multiple defined metadata inputs
    (config.inputs + config.additional_inputs)
    """
    input:
        **{name: info['metadata'] for name,info in input_sources.items() if info.get('metadata', None)}
    params:
        metadata = lambda w, input: list(map("=".join, input.items())),
        id_field = config['strain_id_field'],
    output:
        metadata = "results/metadata_merged.tsv"
    log:
        "logs/merge_metadata.txt",
    benchmark:
        "benchmarks/merge_metadata.txt"
    shell:
        r"""
        exec &> >(tee {log:q})

        augur merge \
            --metadata {params.metadata:q} \
            --metadata-id-columns {params.id_field:q} \
            --output-metadata {output.metadata:q}
        """

rule merge_sequences:
    """
    This rule should only be invoked if there are multiple defined sequences inputs
    (config.inputs + config.additional_inputs)
    """
    input:
        **{name: info['sequences'] for name,info in input_sources.items() if info.get('sequences', None)}
    output:
        sequences = "results/sequences_merged.fasta"
    log:
        "logs/merge_sequences.txt",
    benchmark:
        "benchmarks/merge_sequences.txt"
    shell:
        r"""
        exec &> >(tee {log:q})

        augur merge \
            --sequences {input:q} \
            --output-sequences {output.sequences:q}
        """
