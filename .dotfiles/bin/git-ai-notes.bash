#!/usr/bin/env bash

# --------------------------------------------------------------------------------------------------------
# git-ai-notes: Display git log with AI notes attached via refs/notes/ai
# Usage: git ai-notes
# --------------------------------------------------------------------------------------------------------

set -e  # exit if anything fails

ALIAS_VERSION="1.0.0"

echo ""
echo "🤖 📝  AI Notes $ALIAS_VERSION — Git Log with AI Notes"
echo "───────────────────────────────────────────────────────────────"
echo ""

git log --show-notes=refs/notes/ai

echo ""
echo "🤖 📝  AI Notes finished"
echo "───────────────────────────────────────────────────────────────"
