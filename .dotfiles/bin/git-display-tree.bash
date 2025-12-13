#!/usr/bin/env bash
# --------------------------------------------------------------------------------------------------------
# git-display-tree:  recursively display directory structure like 'tree', ignoring .git/, with optional depth and colors
#
# Usage: git display-tree [--depth N] <pathToDirectory>
#
# For fun, we named this little tool as `TreeLens`
#
# Features:
#   - Ignores .git directories
#   - Optional --depth to limit recursion
#   - Colored directories for easier reading
#   - Fully portable across Linux, macOS, Windows (Git Bash / WSL)
# --------------------------------------------------------------------------------------------------------

# Exits on errors; Catches unset variables; Detects failures in pipelines
set -euo pipefail

ALIAS_VERSION="1.0.0"

echo ""
echo "🌲 🔎   TreeLens $ALIAS_VERSION — Show File Structure as a Tree"
echo "───────────────────────────────────────────────────────────────"

# Default depth: unlimited
MAX_DEPTH=0

# Parse optional --depth argument
while [[ $# -gt 0 ]]; do
    case "$1" in
        --depth)
            shift
            if [[ $# -eq 0 || "$1" =~ ^[^0-9]+$ ]]; then
                echo "Error: --depth requires a positive integer"
                exit 1
            fi
            MAX_DEPTH="$1"
            shift
            ;;
        -*)
            echo "Unknown option: $1"
            exit 1
            ;;
        *)
            ARG="${1%/}"  # remove trailing slash
            shift
            ;;
    esac
done

# Ensure inside a Git repo
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
    echo "Error: not inside a git repository"
    exit 1
}

# Resolve absolute path relative to user's cwd or GIT_PREFIX if available
if [ -n "${GIT_PREFIX:-}" ]; then
    TARGET="$(cd "$GIT_PREFIX/$ARG" 2>/dev/null && pwd -P)" || {
        echo "Error: directory not found: $ARG"
        exit 1
    }
else
    TARGET="$(cd "$ARG" 2>/dev/null && pwd -P)" || {
        echo "Error: directory not found: $ARG"
        exit 1
    }
fi

# Colors: directories blue, files default
DIR_COLOR='\033[1;34m'   # bold blue
RESET_COLOR='\033[0m'

# Recursive tree display function
display_tree() {
    local dir="$1"
    local indent="$2"
    local current_depth="$3"

    # Stop recursion if MAX_DEPTH is set
    if [[ $MAX_DEPTH -gt 0 && $current_depth -ge $MAX_DEPTH ]]; then
        return
    fi

    for file in "$dir"/*; do
        [ -e "$file" ] || continue

        # Ignore .git directories
        if [[ "$(basename "$file")" == ".git" ]]; then
            continue
        fi

        if [ -d "$file" ]; then
            printf "%*s|-- ${DIR_COLOR}%s${RESET_COLOR}/\n" "$indent" "" "$(basename "$file")"
            display_tree "$file" $((indent + 4)) $((current_depth + 1))
        elif [ -f "$file" ]; then
            printf "%*s|-- %s\n" "$indent" "" "$(basename "$file")"
        fi
    done
}

# Print root
echo -e "${DIR_COLOR}$(basename "$TARGET")${RESET_COLOR}/"
display_tree "$TARGET" 4 1

echo ""
echo "🌲 🔎   TreeLens finished"
echo "───────────────────────────────────────────────────────────────"