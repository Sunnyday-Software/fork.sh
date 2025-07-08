#!/usr/bin/env bash

# Source utility functions
source "$(dirname "$0")/utils.sh"

##
# Source a file to set environment variables
# $1 - Source file path
# $2 - Working directory
##
fork_source() {
    local source_file="$1"
    local workdir="$2"

    # Construct source path
    local source_path="${workdir}/${source_file}"

    if [[ -f "${source_path}" ]]; then
        fork_log "Sourcing '${source_path}'."

        # Source the file
        source "${source_path}"

        # Export all variables from the file
        export $(cut -d= -f1 "${source_path}")
    else
        fork_log "Ignore source '${source_path}'."
    fi
}

# If script is executed directly, run the function with provided arguments
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    fork_source "$@"
fi
