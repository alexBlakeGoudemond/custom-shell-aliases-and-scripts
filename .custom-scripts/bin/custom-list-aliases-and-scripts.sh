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
echo "🔍   ToolShed $ALIAS_VERSION — Reveals Git Alias' and Custom Scripts"
echo "───────────────────────────────────────────────────────────────"

CUSTOM_SCRIPTS_DIR="$HOME/.custom-scripts"
GITCONFIG="$HOME/.gitconfig"

echo "========================================"
echo " Custom Scripts"
echo "========================================"

if [ -d "$CUSTOM_SCRIPTS_DIR" ]; then
    # List only files (not directories)
    for file in "$CUSTOM_SCRIPTS_DIR"/*; do
        [ -f "$file" ] && basename "$file"
    done | sort
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