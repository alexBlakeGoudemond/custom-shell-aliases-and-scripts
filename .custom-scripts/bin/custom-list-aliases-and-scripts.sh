#!/usr/bin/env bash

# --------------------------------------------------------------------------------------------------------
# custom-list-alias: Quickly describe your custom scripts and git aliases in one place
# Usage: toolshed
#
# For fun, we named this little tool as `ToolShed`
# --------------------------------------------------------------------------------------------------------

set -e  # exit if anything fails

ALIAS_VERSION="1.0.2"

echo ""
echo "🔍   ToolShed $ALIAS_VERSION — Reveals Git Alias'"
echo "───────────────────────────────────────────────────────────────"

# Directory containing your custom scripts
CUSTOM_SCRIPTS_DIR="/c/Users/alexander.goudemond/.custom-scripts"

# Git config location
GITCONFIG="/c/Users/alexander.goudemond/.gitconfig"

echo "========================================"
echo " Custom Scripts"
echo "========================================"

if [ -d "$CUSTOM_SCRIPTS_DIR" ]; then
    # List only files (not directories)
    find "$CUSTOM_SCRIPTS_DIR" -maxdepth 1 -type f -printf "%f\n" | sort
else
    echo "Custom scripts directory not found:"
    echo "$CUSTOM_SCRIPTS_DIR"
fi

echo
echo "========================================"
echo " Git Aliases"
echo "========================================"

if [ -f "$GITCONFIG" ]; then
    git config --get-regexp ^alias\.
else
    echo ".gitconfig not found:"
    echo "$GITCONFIG"
fi

echo ""
echo "🔍   ToolShed finished"
echo "───────────────────────────────────────────────────────────────"