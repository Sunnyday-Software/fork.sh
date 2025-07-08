#!/usr/bin/env bash

# Source utility functions
source "$(dirname "$0")/utils.sh"

##
# Merge a source file into a target file
# $1 - Source file path
# $2 - Target file path (optional, defaults to source path)
# $3 - Working directory
##
fork_merge() {
    local source="$1"
    local target_name="$2"
    local workdir="$3"

    # If target name is not provided, use source name
    [[ -z ${target_name} ]] && target_name=${source}

    # Construct target path
    local target="${workdir}/${target_name}"

    fork_log "Merging '${source}' to '${target}' from '${PWD}'"

    # Create temporary file for merge
    local tmp=$(mktemp -t merge-diff-XXXXXXXXXX)

    # Create target file if it doesn't exist
    [[ -f "${target}" ]] || touch "${target}"

    # Merge files
    diff --line-format %L "${target}" "${source}" > "${tmp}" || true
    cp "${tmp}" "${target}"
    rm "${tmp}"
}

# If script is executed directly, run the function with provided arguments
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    fork_merge "$@"
fi
