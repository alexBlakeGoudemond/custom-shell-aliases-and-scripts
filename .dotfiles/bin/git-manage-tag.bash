#!/usr/bin/env bash

# --------------------------------------------------------------------------------------------------------
# git-manage-tag: script ontop of 'git tag' to assist with
# creation, deletion and showing of tags
#
# "Usage:"
# "  -d <tagName>             Delete a tag locally AND on origin"
# "  -a <tagName> -m <msg>    Create annotated tag and push to origin"
# "  -s <tagName>             Show details for a tag"
#
# For fun, we named this little tool as `TaskSmith`
#
# Bash insights:
# - '$1' is argument 1
# - 'shift' moves the cursor right
# - 'remaining' retrieves the parameters
# - '$@' represents all arguments
# --------------------------------------------------------------------------------------------------------

set -e  # exit if anything fails

ALIAS_VERSION="1.0.0"

echo ""
echo "🏷️   TagMaster $ALIAS_VERSION — Git Tag Manager"
echo "───────────────────────────────────────────────────────────────"

usage() {
  echo "git-manage-tag - helper for creating, showing, and deleting git tags"
  echo
  echo "Usage:"
  echo "  -d <tagName>             Delete a tag locally AND on origin"
  echo "  -a <tagName> -m <msg>    Create annotated tag and push to origin"
  echo "  -s <tagName>             Show details for a tag"
  echo
  exit 1
}

delete_tag() {
  local tag="$1"

  echo "⚠️  Deleting local tag: $tag"
  git tag -d "$tag" || true

  echo "⚠️  Deleting remote tag: $tag"
  git push origin ":refs/tags/$tag"

  echo "✔️  Done."
}

create_tag() {
  local tag="$1"
  local msg="$2"

  echo "➡️  Creating annotated tag: $tag"
  git tag -a "$tag" -m "$msg"

  echo "⬆️  Pushing tag to origin: $tag"
  git push origin "$tag"

  echo "✔️  Done."
}

show_tag() {
  local tag="$1"
  git show "$tag"
}

show_finished(){
  echo ""
  echo "🏷️   TagMaster finished"
  echo "───────────────────────────────────────────────────────────────"
}

# --- Parse arguments ---

if [[ $# -eq 0 ]]; then
  usage
fi

delete=""
annotate=""
message=""
show=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -d)
      delete="$2"
      shift 2
      ;;
    -a)
      annotate="$2"
      shift 2
      ;;
    -m)
      message="$2"
      shift 2
      ;;
    -s)
      show="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1"
      usage
      ;;
  esac
done

# --- Execute actions ---

if [[ -n "$delete" ]]; then
  delete_tag "$delete"
  show_finished
  exit 0
fi

if [[ -n "$annotate" ]]; then
  if [[ -z "$message" ]]; then
    echo "❌ Error: -a requires -m <message>"
    show_finished
    exit 1
  fi
  create_tag "$annotate" "$message"
  show_finished
  exit 0
fi

if [[ -n "$show" ]]; then
  show_tag "$show"
  show_finished
  exit 0
fi

usage
