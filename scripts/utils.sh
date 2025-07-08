#!/usr/bin/env bash

##
# Utility functions for fork.sh
##

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
