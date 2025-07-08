#!/usr/bin/env bash

# Source utility functions
source "$(dirname "$0")/utils.sh"

##
# Copy a file from source to target
# $1 - Source file path
# $2 - Target file path (optional, defaults to source path)
# $3 - Working directory
# $4 - Trace file path
# $5 - Hard flag (1 for hard copy)
##
fork_copy() {
    local source="$1"
    local target_name="$2"
    local workdir="$3"
    local trace="$4"
    local hard="$5"

    # If target name is not provided, use source name
    [[ -z ${target_name} ]] && target_name=${source}

    # Construct target path
    local target="${workdir}/${target_name}"
    local target_dir="$(dirname "${target}")"

    # Check if file should be overridden
    local override=$(grep -e "^COPY ${source}$" "${trace}") && true

    if [[ ! -f "${target}" ]] || [[ -n "${override}" ]] || [[ -n "${hard}" ]]; then
        fork_log "Coping '${source}' to '${target}' from '${PWD}'"
        fork_trace "COPY ${source}" "${trace}"

        # Create target directory if it doesn't exist
        [[ -d "${target_dir}" ]] || mkdir -p "${target_dir}"

        # Copy the file
        cp -R "${source}" "${target}"
        chmod 777 "${target}"
    else
        fork_log "Ignoring copy '${source}', use '--hard' if you require it."
    fi
}

# If script is executed directly, run the function with provided arguments
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    fork_copy "$@"
fi
