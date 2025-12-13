#!/usr/bin/env bash

# --------------------------------------------------------------------------------------------------------
# git-display-tree:  iterate through directories and use indentation to mimic the tree structure seen
# in powershell and linux systems
#
# Usage: git display-tree <pathToDirectory>
# For fun, we named this little tool as `xxx`
#
# --------------------------------------------------------------------------------------------------------

# Exits on errors; Catches unset variables; Detects failures in pipelines
set -euo pipefail

ALIAS_VERSION="1.0.0"

display_tree() {
  local dir="$1"
  local indent="${2:-0}"
  for file in "$dir"/*; do
    [ -e "$file" ] || continue
    if [ -d "$file" ]; then
      printf "%*s|-- %s/\n" "$indent" "" "$(basename "$file")"
      display_tree "$file" $((indent + 4))
    elif [ -f "$file" ]; then
      printf "%*s|-- %s\n" "$indent" "" "$(basename "$file")"
    fi
  done
}

if [ $# -eq 0 ]; then
  echo "Usage: git display-tree <path>"
  exit 1
fi

# Strip trailing slash
ARG="${1%/}"

# Ensure inside a git repo
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
    echo "Error: not inside a git repository"
    exit 1
}

# Resolve path exactly as typed by user
# Use "$GIT_PREFIX" if set (Git sets it when calling subcommands from subdirectories)
if [ -n "${GIT_PREFIX:-}" ]; then
    # GIT_PREFIX is relative path from repo root to original cwd
    TARGET="$(cd "$GIT_PREFIX/$ARG" 2>/dev/null && pwd -P)" || {
        echo "Error: directory not found: $ARG"
        exit 1
    }
else
    # fallback: resolve relative to current PWD
    TARGET="$(cd "$ARG" 2>/dev/null && pwd -P)" || {
        echo "Error: directory not found: $ARG"
        exit 1
    }
fi

echo "Showing the file structure for '$TARGET':"
echo "$(basename "$TARGET")/"
display_tree "$TARGET" 4
