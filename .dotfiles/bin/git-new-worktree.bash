#!/usr/bin/env bash

# --------------------------------------------------------------------------------------------------------
# git-new-worktree: create a worktree, then leverage other alias 'git-new' to create a branch for it
# Usage: git new-worktree feature my cool thing
# For fun, we named this little tool as `TreeForge`
#
# Bash insights:
# - 'git tag --sort=v:refname' lists all tags in semantic version order (v1.0.1 > v1.0.0)
# - '$1' is argument 1
# - 'basename' extracts final directory name
# --------------------------------------------------------------------------------------------------------

set -e  # exit if anything fails

ALIAS_VERSION="1.0.1"

echo ""
echo "🌳  TreeForge ALIAS_VERSION — Git Worktree Crafter"
echo "───────────────────────────────────────────────────────────────"

if [ -z "$1" ]; then
    echo "Usage: git new-worktree [type] <branch-name>"
    echo "Examples:"
      echo "  git new-worktree task add login endpoint"
      echo "  git new-worktree feature dark mode toggle"
      echo "  git new-worktree fix broken tests"
      echo "  git new-worktree my-branch                               # defaults to task/my-branch in that worktree"
      echo "  git new-worktree refactor customer service abc-123       # abc-123 would be the JIRA ticket number"
    exit 1
fi

allArguments=("$@")

# Current repository name
repo_base_name=$(basename "$(git rev-parse --show-toplevel)")
worktree_name=$(echo "${allArguments[*]}" | tr ' ' '-')

# Worktree directory
worktree_dir="../worktrees/${repo_base_name}-${worktree_name}/"

# Ensure worktree folder does not already exist
if [ -d "$worktree_dir" ]; then
    echo "❌ Error: Worktree '$worktree_dir' already exists."
    exit 1
fi

# Create the parent worktrees folder if it doesn't exist
mkdir -p "$(dirname "$worktree_dir")"

# Create the worktree
echo "➡️  Creating worktree at $worktree_dir"
git worktree add "$worktree_dir" HEAD || { echo "Failed to add worktree"; exit 1; }

# Use your existing 'git new' alias inside the worktree
cd "$worktree_dir"
git new "${allArguments[@]}"

echo "✔️  Worktree created at $worktree_dir"

echo ""
echo "🌳  TreeForge finished"
echo "───────────────────────────────────────────────────────────────"