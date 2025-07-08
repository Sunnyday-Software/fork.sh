#!/usr/bin/env bash

# Source utility functions
source "$(dirname "$0")/utils.sh"

##
# Move a file from source to target
# $1 - Source file path
# $2 - Target file path
# $3 - Working directory
##
fork_move() {
    local source="$1"
    local target_name="$2"
    local workdir="$3"

    if [[ -n "${target_name}" ]]; then
        local target="${workdir}/${target_name}/"
        local target_dir="$(dirname "${target}")/"

        fork_log "Move '${source}' to '${target}' from '${PWD}'"
        mv "${source}" "${target_dir}"
    else
        fork_log "Ignore move '${source}' due to missing destination."
    fi
}

# If script is executed directly, run the function with provided arguments
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    fork_move "$@"
fi
