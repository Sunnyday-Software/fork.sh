#!/usr/bin/env bash

# Source utility functions
source "$(dirname "$0")/utils.sh"

##
# Create an empty file
# $1 - Target file path
# $2 - Working directory
##
fork_touch() {
    local target_name="$1"
    local workdir="$2"

    # Construct target path
    local target="${workdir}/${target_name}"
    local target_dir="$(dirname "${target}")"

    fork_log "Touch '${target}' from '${PWD}'"

    # Create target directory if it doesn't exist
    [[ -d "${target_dir}" ]] || mkdir -p "${target_dir}"

    # Create the file
    touch "${target}"
    chmod 777 "${target}"
}

# If script is executed directly, run the function with provided arguments
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    fork_touch "$@"
fi
