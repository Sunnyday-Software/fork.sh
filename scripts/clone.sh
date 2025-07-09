#!/usr/bin/env bash

# Source utility functions
source "$(dirname "$0")/utils.sh"

##
# Clone a repository
# $1 - Repository URL or GitHub repository (format: username/repository?branch)
# $2 - Branch name (optional, overrides branch in repository URL)
# $3 - Trace file path
# $4 - Verbose flag (1 for verbose output)
##
fork_clone() {
    local repository_with_branch="$1"
    local branch_override="$2"
    local trace="$3"
    local verbose="$4"

    # Extract branch from repository URL if present
    local branch="$(echo "$repository_with_branch?" | cut -d'?' -f2)"
    local repository="$(echo "$repository_with_branch?" | cut -d'?' -f1)"

    # Override branch if provided
    [[ -n "$branch_override" ]] && branch="$branch_override"

    # Convert GitHub repository format to URL if needed
    local package=^[A-Za-z_\.-]+/[A-Za-z_\.-]+$
    [[ "${repository}" =~ ${package} ]] && repository=https://github.com/${repository}

    # Set branch info for display
    local branch_info="'${branch}'"
    local branch_option="-b ${branch}"
    [[ -z "${branch}" ]] && branch_info="default" && branch_option=""

    fork_log "Check '${repository}' due to integrity."

    # Show verbose output if requested
    if [[ -n "${verbose}" ]]; then
        echo -n "Refs: " && git ls-remote ${repository} | grep "${branch}" | tr '\t' ' '
    fi

    fork_log "Fetch '${repository}' from ${branch_info} branch."

    # Create temporary directory for cloning
    local tmpdir=$(mk_tmp_dir "fork-clone-dir")
    cd ${tmpdir}

    # Clone the repository
    git clone -q ${branch_option} "${repository}" LOCAL || true

    # Check if clone was successful
    if [[ -d "${tmpdir}/LOCAL" ]]; then
        # Return to the calling script with the path to the cloned repository
        echo "${tmpdir}/LOCAL"
    else
        fork_error "Problem while creating: ${tmpdir}/LOCAL"
    fi
}

# If script is executed directly, run the function with provided arguments
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    fork_clone "$@"
fi
