#!/usr/bin/env bash

# Source utility functions
source "$(dirname "$0")/utils.sh"

# Get the directory of this script
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

##
# Parse a Forkfile and execute the appropriate commands
# $1 - Kind of source (LOCAL or REMOTE)
# $2 - Source identifier (current path for LOCAL, repository FROM for REMOTE)
# $3 - Working directory to process the parsing
# $4 - Trace file path
# $5 - Hard flag (1 for hard copy)
# $6 - Verbose flag (1 for verbose output)
# $7 - Local from repository (optional)
# $8 - Local branch (optional)
##
fork_parse() {
    local kind="$1"
    local source_id="$2"
    local workdir="$3"
    local trace="$4"
    local hard="$5"
    local verbose="$6"
    local local_from="$7"
    local local_branch="$8"

    cd "$workdir"
    local temp_pwd="${PWD}"

    if [[ -e Forkfile ]]; then
        local row=0
        local forkfile=$(mk_tmp_file "forkfile")
        export Forkfile_from=rbn
        envsubst < Forkfile > "${forkfile}"

        while IFS= read line || [[ -n "${line}" ]]; do
            ((row=row+1))
            [[ -z "${line}" ]] && continue
            [[ "${line::1}" == "#" ]] && continue

            instruction=$(echo ${line} | cut -d" " -f1)
            case "${kind}_${instruction}" in
                LOCAL_DUMP|REMOTE_DUMP)
                    fork_log "DUMP" "${@}"
                    printenv | grep -E '^Forkfile_' | sort
                    ;;
                LOCAL_DEBUG|REMOTE_DEBUG)
                    fork_log "${line:6}"
                    ;;
                LOCAL_FROM)
                    temp_pwd="${PWD}"
                    if [[ -z "${local_from}" ]]; then
                        local cloned_repo="$("${SCRIPT_DIR}/clone.sh" "${line:5}" "" "${trace}" "${verbose}")"
                        cd "${cloned_repo}"
                        "${SCRIPT_DIR}/parse.sh" "REMOTE" "${line:5}" "${cloned_repo}" "${trace}" "${hard}" "${verbose}"
                    else
                        fork_log "Ignore LOCAL FROM due to command line '--from' option."
                        local cloned_repo="$("${SCRIPT_DIR}/clone.sh" "${local_from}" "${local_branch}" "${trace}" "${verbose}")"
                        cd "${cloned_repo}"
                        "${SCRIPT_DIR}/parse.sh" "REMOTE" "${local_from}" "${cloned_repo}" "${trace}" "${hard}" "${verbose}"
                    fi
                    cd "${temp_pwd}"
                    ;;
                REMOTE_FROM)
                    temp_pwd="${PWD}"
                    local cloned_repo="$("${SCRIPT_DIR}/clone.sh" "${line:5}" "" "${trace}" "${verbose}")"
                    cd "${cloned_repo}"
                    "${SCRIPT_DIR}/parse.sh" "REMOTE" "${line:5}" "${cloned_repo}" "${trace}" "${hard}" "${verbose}"
                    cd "${temp_pwd}"
                    ;;
                LOCAL_COPY)
                    fork_log "Skip COPY in LOCAL Forkfile line ${row}"
                    ;;
                REMOTE_COPY)
                    "${SCRIPT_DIR}/copy.sh" ${line:5} "" "${workdir}" "${trace}" "${hard}"
                    ;;
                LOCAL_DIRCOPY)
                    fork_log "Skip DIRCOPY in LOCAL Forkfile line ${row}"
                    ;;
                REMOTE_DIRCOPY)
                    "${SCRIPT_DIR}/dircopy.sh" ${line:8} "" "${workdir}" "${trace}" "${hard}"
                    ;;
                LOCAL_TOUCH)
                    fork_log "Skip TOUCH in LOCAL Forkfile line ${row}"
                    ;;
                REMOTE_TOUCH)
                    "${SCRIPT_DIR}/touch.sh" ${line:6} "${workdir}"
                    ;;
                LOCAL_MERGE)
                    fork_log "Skip MERGE in LOCAL Forkfile line ${row}"
                    ;;
                REMOTE_MERGE)
                    "${SCRIPT_DIR}/merge.sh" ${line:6} "" "${workdir}"
                    ;;
                LOCAL_PROTOTYPE)
                    fork_log "Skip PROTOTYPE in LOCAL Forkfile line ${row}"
                    ;;
                REMOTE_PROTOTYPE)
                    "${SCRIPT_DIR}/prototype.sh" ${line:10} "" "${workdir}" "${trace}" "${hard}"
                    ;;
                LOCAL_SOURCE)
                    fork_log "Skip SOURCE in LOCAL Forkfile line ${row}"
                    ;;
                REMOTE_SOURCE)
                    "${SCRIPT_DIR}/source.sh" ${line:7} "${workdir}"
                    ;;
                *)
                    fork_error "Forkfile parse error line ${row}: unknown instruction: ${instruction} on '${source_id}'"
                    ;;
            esac
        done < "${forkfile}"

        [[ -f "${forkfile}" ]] && rm "${forkfile}"
    elif [[ "${kind}" == "LOCAL" ]] && [[ ! -z "${local_from}" ]]; then
        fork_info "Creating Forkfile on ${PWD}"
        echo "FROM ${local_from} ${local_branch}" > Forkfile
        temp_pwd="${PWD}"
        local cloned_repo="$("${SCRIPT_DIR}/clone.sh" "${local_from}" "${local_branch}" "${trace}" "${verbose}")"
        cd "${cloned_repo}"
        "${SCRIPT_DIR}/parse.sh" "REMOTE" "${local_from}" "${cloned_repo}" "${trace}" "${hard}" "${verbose}"
        cd "${temp_pwd}"
    else
        fork_log "Missing 'Forkfile' in '${workdir}'."
    fi
}

# If script is executed directly, run the function with provided arguments
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    fork_parse "$@"
fi
