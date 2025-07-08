#!/usr/bin/env bash

# Source utility functions
source "$(dirname "$0")/utils.sh"

##
# Copy a directory from source to target
# $1 - Source directory path
# $2 - Target directory path (optional, defaults to source path)
# $3 - Working directory
# $4 - Trace file path
# $5 - Hard flag (1 for hard copy)
##
fork_dircopy() {
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

    # Check if directory should be overridden
    local override=$(grep -e "^DIRCOPY ${source}$" "${trace}") && true

    if [[ ! -d "${target}" ]] || [[ -n "${override}" ]] || [[ -n "${hard}" ]]; then
        fork_log "Coping directory '${source}' to '${target}' from '${PWD}'"
        fork_trace "DIRCOPY ${source}" "${trace}"

        # Create target directory if it doesn't exist
        [[ -d "${target_dir}" ]] || mkdir -p "${target_dir}"

        # Copy the directory
        [[ -d "${target}" ]] && cp -TRf "${source}" "${target}" || cp -Rf "${source}" "${target}"
        chmod 777 "${target}"
    else
        fork_log "Ignoring copy '${source}', use '--hard' if you require it."
    fi
}

# If script is executed directly, run the function with provided arguments
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    fork_dircopy "$@"
fi
