#!/bin/bash
# Support ticket functions

ny() {
    # Download SFDC case data and set up Copilot instructions
    (cd /Users/surfer/elastic/utilities/sfdc-case-downloader && python3 feed_downloader_simple.py "$@")
    
    if [[ -n "$1" ]]; then
        local ticket_dir=$(ls -d ~/tickets/"$1"* 2>/dev/null | head -1)
        if [[ -n "$ticket_dir" && -d "$ticket_dir" ]]; then
            mkdir -p "$ticket_dir/.github"
            rm -f "$ticket_dir/.github/copilot-instructions.md"
            ln -s ~/support-templates/copilot-instructions.md "$ticket_dir/.github/copilot-instructions.md"
            echo "✓ Copilot instructions symlinked"
        fi
    fi
}
