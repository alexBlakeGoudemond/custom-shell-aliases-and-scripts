#!/usr/bin/env bash

# -------------------------------------------------------
# git-new: create and push a new branch with conventions
# -------------------------------------------------------

set -e  # exit if anything fails

# Try to read Tasksmith version from Git tags in the dotfiles repo
TASKSMITH_VERSION=$(git -C "$(dirname "$0")/.." describe --tags --abbrev=0 2>/dev/null || echo "1.0.0")

echo ""
echo "🛠️  Tasksmith $TASKSMITH_VERSION — Git Branch Crafter"
echo "───────────────────────────────────────────────────────"

# Show usage if no args given
if [ -z "$1" ]; then 
  echo "Usage: git new [type] <branch-name>"
  echo "Examples:"
  echo "  git new task add-login-endpoint"
  echo "  git new feature dark-mode-toggle"
  echo "  git new fix broken-tests"
  echo "  git new my-branch        # defaults to task/my-branch"
  exit 1
fi

first="$1"
shift
type="task"
jira_key=""
remaining=()

# Detect if first arg is a known type or JIRA key
if [[ "$first" =~ ^(feature|bugfix|hotfix|release)$ ]]; then
  type="$first"
elif [[ "$first" =~ ^[A-Za-z]+-[0-9]+$ ]]; then
  jira_key=$(echo "$first" | tr '[:lower:]' '[:upper:]')
else
  remaining+=("$first")
fi

# Scan the rest of the args for a JIRA key
if [ -z "$jira_key" ]; then
  for arg in "$@"; do
    if [[ "$arg" =~ ^[A-Za-z]+-[0-9]+$ ]]; then
      jira_key=$(echo "$arg" | tr '[:lower:]' '[:upper:]')
    else
      remaining+=("$arg")
    fi
  done
else
  remaining+=("$@")
fi

# Build the branch name
if [[ -n "$jira_key" ]]; then
  branch="$type/$jira_key/${remaining[*]}"
else
  branch="$type/${remaining[*]}"
fi

# Replace spaces with dashes
branch=$(echo "$branch" | tr ' ' '-')

# Sanity check
if [ -z "$branch" ]; then
  echo "❌ Error: Branch name could not be determined."
  exit 1
fi

echo "➡️  Creating and pushing branch: $branch"

git switch -c "$branch"
git push -u origin "$branch"
