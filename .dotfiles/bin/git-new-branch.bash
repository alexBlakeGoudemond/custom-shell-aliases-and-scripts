#!/usr/bin/env bash

# --------------------------------------------------------------------------------------------------------
# git-new-branch: create and push a new branch with some naming conventions
# Usage: git new-branch feature my cool thing
# For fun, we named this little tool as `TaskSmith`
#
# Bash insights:
# - '$1' is argument 1
# - 'shift' moves the cursor right
# - 'remaining' retrieves the parameters
# - '$@' represents all arguments
# --------------------------------------------------------------------------------------------------------

set -e  # exit if anything fails

ALIAS_VERSION="1.0.1"

echo ""
echo "🛠️   TaskSmith $ALIAS_VERSION — Git Branch Crafter"
echo "───────────────────────────────────────────────────────────────"

# Show usage if no args given
if [ -z "$1" ]; then 
  echo "Usage: git new [type] <branch-name>"
  echo "Examples:"
  echo "  git new task add login endpoint"
  echo "  git new feature dark mode toggle"
  echo "  git new fix broken tests"
  echo "  git new my-branch                               # defaults to task/my-branch"
  echo "  git new refactor customer service abc-123       # abc-123 would be the JIRA ticket number"
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

echo "➡️ Preparing branch: $branch"

# Check if branch exists locally
if git show-ref --verify --quiet "refs/heads/$branch"; then
    echo "⚠️  Branch '$branch' already exists locally."
    echo "   → Switching to it..."
    git switch "$branch"
# Check if branch exists on remote
elif git ls-remote --exit-code --heads origin "$branch" >/dev/null 2>&1; then
    echo "⚠️  Branch '$branch' exists on remote."
    echo "   → Fetching and switching to it..."
    git fetch origin "$branch" && git switch "$branch"
# Branch does not exist locally or remotely
else
    echo "✔️  Creating and pushing new branch: $branch"
    git switch -c "$branch" && git push -u origin "$branch"
fi

echo ""
echo "🛠️   TaskSmith finished"
echo "───────────────────────────────────────────────────────────────"