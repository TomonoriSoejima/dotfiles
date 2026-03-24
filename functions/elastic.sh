#!/bin/bash
# Elastic ticket workflow functions

# ny() - Download ticket feeds
# Usage: ny TICKET_NUMBER
# Example: ny 12345678
ny() {
    (cd $HOME/elastic/utilities/sfdc-case-downloader && python3 feed_downloader_simple.py "$@")
}

# open-case() - Open a case directory with standard workspace
# Usage: open-case <case-directory-or-number>
# Example: open-case 02057624
open-case() {
    local case_dir="$1"
    local tickets_base="$HOME/tickets"

    if [[ -z "$case_dir" ]]; then
        echo "Usage: open-case <case-directory-or-number>"
        return 1
    fi

    # If argument is just a number, find the matching directory
    if [[ ! -d "$case_dir" ]] && [[ "$case_dir" =~ ^[0-9]+$ ]]; then
        case_dir=$(find "$tickets_base" -maxdepth 1 -type d -name "${case_dir}*" | head -1)
        if [[ -z "$case_dir" ]]; then
            echo "No case directory found for: $1"
            return 1
        fi
    fi

    # Verify directory exists
    if [[ ! -d "$case_dir" ]]; then
        echo "Directory not found: $case_dir"
        return 1
    fi

    # Get absolute path
    case_dir=$(cd "$case_dir" && pwd)
    case_name=$(basename "$case_dir")

    # Open VS Code with just the case folder
    code "$case_dir"

    echo "Opened case: $case_name"
}
