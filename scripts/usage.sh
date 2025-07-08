#!/usr/bin/env bash

##
# Print-out usage message and exit
# $1 - Version number
##
fork_usage() {
    echo "Usage: ./fork.sh [OPTION]..."
    echo ""
    echo "Parse Forkfile to align other files by a remote source"
    echo ""
    echo "List of available options"
    echo "  -f, --from REPOSITORY    Set REPOSITORY as remote source"
    echo "  -u, --update REPOSITORY  Update REPOSITORY instead current directory"
    echo "  -b, --branch BRANCH      Set BRANCH for remote source instead of default"
    echo "  -h, --hard               Display current version"
    echo "  -v, --verbose            Display current version"
    echo "  --version                Display current version"
    echo "  --help                   Display this help and exit"
    echo ""
    echo "Documentation can be found at https://github.com/javanile/fork.sh"
    exit 1
}
