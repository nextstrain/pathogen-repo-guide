import os.path


class InvalidConfigError(Exception):
    pass


def resolve_config_path(path, wildcards=None):
    """
    Resolve a relative *path* given in a configuration value.

    Resolves *path* as relative to the workflow's ``defaults/`` directory (i.e.
    ``os.path.join(workflow.basedir, "defaults", path)``) if it doesn't exist
    in the workflow's analysis directory (i.e. the current working
    directory, or workdir, usually given by ``--directory`` (``-d``)).

    If *wildcards* are provided, then will further try to resolve *path* and
    the default path by expanding wildcards with Snakemake's `expand` functionality.

    This behaviour allows a default configuration value to point to a default
    auxiliary file while also letting the file used be overridden either by
    setting an alternate file path in the configuration or by creating a file
    with the conventional name in the workflow's analysis directory.
    """
    global workflow

    if os.path.exists(path):
        return path

    # Special-case defaults/… for backwards compatibility with older
    # configs.  We could achieve the same behaviour with a symlink
    # (defaults/defaults → .) but that seems less clear.
    if path.startswith("defaults/"):
        defaults_path = os.path.join(workflow.basedir, path)
    else:
        defaults_path = os.path.join(workflow.basedir, "defaults", path)

    if os.path.exists(defaults_path):
        return defaults_path

    error_message = f"""Unable to resolve config provided path.
    Checked for the following files:
        1. {path!r}
        2. {defaults_path!r}"""

    if wildcards:
        expanded_path = expand(path, **wildcards)[0]
        print(expanded_path)
        if os.path.exists(expanded_path):
            return expanded_path

        expanded_defaults_path = expand(defaults_path, **wildcards)[0]
        print(expanded_defaults_path)
        if os.path.exists(expanded_defaults_path):
            return expanded_defaults_path

        error_message += f"""
        3. {expanded_path!r}
        4. {expanded_defaults_path!r}
        """

    raise InvalidConfigError(error_message)
