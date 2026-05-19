#!/usr/bin/env bash

# --------------------------------------------------------------------------------------------------------
# list-git-aliases-and-custom-scripts: Quickly describe your custom scripts and git aliases in one place
# Usage: toolshed
#
# For fun, we named this little tool as `ToolShed`
# --------------------------------------------------------------------------------------------------------

set -e  # exit if anything fails

ALIAS_VERSION="1.0.2"

echo ""
echo "🔍   ToolShed $ALIAS_VERSION — Reveals Git Alias' and Custom Scripts"
echo "───────────────────────────────────────────────────────────────"

detect_home() {
    # WSL
    if grep -qi microsoft /proc/version 2>/dev/null; then
        echo "$(wslpath "$(cmd.exe /c echo %USERPROFILE% 2>/dev/null | tr -d '\r')")"
        return
    fi

    # MSYS / Git Bash on Windows
    if [[ "$(uname -s)" == MINGW* || "$(uname -s)" == MSYS* ]]; then
        echo "$USERPROFILE"
        return
    fi

    # Normal Linux/macOS
    echo "$HOME"
}

HOME_DIR="$(detect_home)"
CUSTOM_SCRIPTS_DIR="$HOME_DIR/.custom-scripts"

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

git.exe config --show-origin --get-regexp '^alias\.' || echo "No aliases found"

echo ""
echo "🔍   ToolShed finished"
echo "───────────────────────────────────────────────────────────────"