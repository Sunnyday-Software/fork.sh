#!/usr/bin/env bash

##
# Utility functions for fork.sh
##
TEMP_DIR=".runtime/fork/tmp"
##
# Create a temporary directory
# $1 - Prefix for the directory name (optional)
# Returns the path to the created directory
##
mk_tmp_dir() {
    local prefix="${1:-fork-tmp}"
    local random_suffix=$(LC_ALL=C tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c 10)
    local tmp_dir="${TEMP_DIR}/${prefix}-${random_suffix}"

    mkdir -p "$tmp_dir"
    echo "$tmp_dir"
}

##
# Create a temporary file
# $1 - Prefix for the file name (optional)
# Returns the path to the created file
##
mk_tmp_file() {
    local prefix="${1:-fork-tmp}"
    local random_suffix=$(LC_ALL=C tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c 10)
    local tmp_file="${TEMP_DIR}/${prefix}-${random_suffix}"

    touch "$tmp_file"
    echo "$tmp_file"
}

##
# Print log message
# $1 - Message to log
##
fork_log() {
    echo " ---> $*"
}

##
# Print error message and exit
# $1 - Message to log
##
fork_error() {
    local escape='\e'
    if [[ "$(uname -s)" == Darwin* ]]; then
        escape='\x1B'
    fi
    echo -e "${escape}[1m${escape}[31m[ERROR]${escape}[0m $*"
    exit 1
}

##
# Print debug message
# $1 - Message to log
##
fork_debug() {
    local escape='\e'
    if [[ "$(uname -s)" == Darwin* ]]; then
        escape='\x1B'
    fi
    echo -e "${escape}[1m${escape}[33mDEBUG>${escape}[0m $*"
}

##
# Print info message
# $1 - Message to log
##
fork_info() {
    echo "$1"
}

##
# Print error message and exit with specific code
# $1 - Exit code
# $2 - Error message
##
fork_exit() {
    echo "$2" >&2
    exit "$1"
}

##
# Write to trace file
# $1 - Message to trace
# $2 - Trace file path
##
fork_trace() {
    echo "$1" >> "$2"
}
