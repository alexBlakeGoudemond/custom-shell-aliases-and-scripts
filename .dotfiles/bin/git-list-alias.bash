#!/usr/bin/env bash

# --------------------------------------------------------------------------------------------------------
# git-list-alias: list all of the alias' currently defined on your machine
# Usage: git list-alias
# For fun, we named this little tool as `ToolShed`
# Bash Insights:
# - 'git tag --sort=v:refname' lists all tags in semantic version order (v1.0.1 > v1.0.0)
# --------------------------------------------------------------------------------------------------------

set -e  # exit if anything fails

# Read the Most Recent Tag version from Git
NEWEST_TAG_VERSION=$(git tag --sort=v:refname | tail -n 1 2>/dev/null || echo "1.0.0")

echo ""
echo "🔍  ToolShed $NEWEST_TAG_VERSION — Reveals Git Alias'"
echo "───────────────────────────────────────────────────────────────"

git config --get-regexp ^alias\.

echo ""
echo "🔍  ToolShed finished"
echo "───────────────────────────────────────────────────────────────"
