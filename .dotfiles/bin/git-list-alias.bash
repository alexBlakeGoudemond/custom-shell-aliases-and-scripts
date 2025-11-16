#!/usr/bin/env bash

# --------------------------------------------------------------------------------------------------------
# git-list-alias: list all of the alias' currently defined on your machine
# Usage: git list-alias
# For fun, we named this little tool as `ToolShed`
# --------------------------------------------------------------------------------------------------------

set -e  # exit if anything fails

# Try to read TaskSmith version from Git tags in the dotfiles repo
TOOL_SHED_VERSION=$(git -C "$(dirname "$0")/.." describe --tags --abbrev=0 2>/dev/null || echo "1.0.0")

echo ""
echo "🔍  ToolShed $TOOL_SHED_VERSION — Reveals Git Alias'"
echo "───────────────────────────────────────────────────────────────"

git config --get-regexp ^alias\.

echo ""
echo "🔍  ToolShed finished"
echo "───────────────────────────────────────────────────────────────"
