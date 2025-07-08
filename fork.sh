#!/usr/bin/env bash

##
# FORK.SH
#
# Maintenance strategy for prototype-based projects.
#
# Copyright (c) 2020 Francesco Bianco <bianco@javanile.org>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
##

[[ -z "${LCOV_DEBUG}" ]] || set -x

set -ef

VERSION="0.4.0"

# Get the directory of this script
SCRIPT_DIR="$(dirname "$(realpath "$0")")/scripts"

# Source utility functions
source "${SCRIPT_DIR}/utils.sh"

# Default values
workdir=${PWD}
hard=
verbose=
local_from=
local_branch=
local_update=

# Parse command-line options
case "$(uname -s)" in
    Darwin*)
        getdep=''
        getopt='/opt/local/bin/getopt'
        ;;
    Linux|*)
        [ -x /bin/getopt ] && getopt=/bin/getopt || getopt=/usr/bin/getopt
        ;;
esac

package=^[A-Za-z_\.-]+/[A-Za-z_\.-]+$
options=$(${getopt} -n fork.sh -o f:u:b:hv -l from:,update:,branch:,hard,verbose,version,help -- "$@")

eval set -- "${options}"

while true; do
    case "$1" in
        -f|--from) shift; local_from=$1 ;;
        -u|--update) shift; local_update=$1 ;;
        -b|--branch) shift; local_branch=$1 ;;
        -h|--hard) hard=1 ;;
        -v|--verbose) verbose=1 ;;
        --version) echo "FORK.SH version ${VERSION}"; exit ;;
        --help) "${SCRIPT_DIR}/usage.sh"; exit ;;
        --) shift; break ;;
    esac
    shift
done

if [[ $# -ne 0 ]]; then
    echo "fork.sh: unrecognized option '$*'"
    "${SCRIPT_DIR}/usage.sh"
fi

##
# Main function
##
main() {
    # Check for required commands
    if [[ -z "$(command -v git)" ]]; then
        fork_exit 1 "Missing git command on your system."
    fi
    if [[ -z "$(command -v envsubst)" ]]; then
        fork_exit 1 "Missing envsubst command on your system."
    fi

    # Handle update option
    if [[ -n "${local_update}" ]]; then
        workdir="$(mktemp -d -t fork-update-dir-XXXXXXXXXX)/UPDATE"
        git clone -q "${local_update}" "${workdir}" || true
        [[ -d "${workdir}" ]] || fork_error "Problem while creating: ${local_update}"
    fi

    # Check if current directory is a git repository
    if [[ ! -d ${workdir}/.git ]]; then
        fork_exit 1 "This directory does not appear to be a git repository"
    fi

    # Get remote origin URL
    local=$(git config --get remote.origin.url)

    # Set local_from by default if local_branch is provided but local_from is not
    if [[ -n "${local_branch}" ]] && [[ -z "${local_from}" ]]; then
        fork_debug "set local_from by default"
        local_from=${local}
    fi

    # Check if Forkfile exists
    if [[ ! -f Forkfile ]] && [[ ! -f Forkfile.conf ]] && [[ -z "${local_from}" ]]; then
        fork_exit 1 "Could not find Forkfile or Forkfile.conf in this directory"
    fi

    # Create trace file
    trace=$(mktemp -t fork-trace-XXXXXXXXXX)
    echo "START ${workdir}" > "${trace}"

    # Commit any changes
    git add . > /dev/null 2>&1 && true
    git commit -am "Forkfile: init" > /dev/null 2>&1 && true

    # Set environment variables
    export Forkfile_workdir=${workdir}
    export Forkfile_dirname=$(dirname "${workdir}")
    export Forkfile_name=$(basename "${workdir}")
    export FORK_NAME="$(basename "${workdir}")"

    # Parse Forkfile
    "${SCRIPT_DIR}/parse.sh" "LOCAL" "${local}" "${workdir}" "${trace}" "${hard}" "${verbose}" "${local_from}" "${local_branch}"

    # Commit changes
    git add . > /dev/null 2>&1 && true
    git commit -am "Forkfile: done" > /dev/null 2>&1 && true

    # Handle update option
    if [[ -n "${local_update}" ]]; then
        git push --force
        rm -fr "${workdir}"
    fi

    # Clean up
    rm "${trace}"

    echo "Done."
}

# Entry-point
main
