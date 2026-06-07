#!/usr/bin/env bash

# --------------------------------------------------------------------------------------------------------
# git-manage-tag: script ontop of 'git tag' to assist with
# creation, deletion and showing of tags
#
# "Usage:"
# "  -d <tagName>             Delete a tag locally AND on origin"
# "  -a <tagName> -m <msg>    Create annotated tag and push to origin"
# "  -s <tagName>             Show details for a tag"
# "  -l                       List all tags"
# "  -r <oldName> <newName>   Rename a tag, retaining its message, and push"
#
# For fun, we named this little tool as `TagMaster`
#
# Bash insights:
# - '$1' is argument 1
# - 'shift' moves the cursor right
# - 'remaining' retrieves the parameters
# - '$@' represents all arguments
# --------------------------------------------------------------------------------------------------------

set -e  # exit if anything fails

ALIAS_VERSION="1.1.1"

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
  echo "  -l                       List all tags"
  echo "  -r <oldName> <newName>   Rename a tag, retaining its message, and push"
  echo
  exit 1
}

list_tags() {
  echo "➡️  Listing all tags:"
  # List tags with their messages (up to 500 chars), sorted in natural/version order (1, 2, 3, ..., 10, 11, ...)
  git tag -n500 --sort=version:refname
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

rename_tag() {
  local old_tag="$1"
  local new_tag="$2"

  # Retrieve the message from the old tag (works for annotated tags)
  local msg
  msg=$(git tag -l --format='%(contents)' "$old_tag")

  if [[ -z "$msg" ]]; then
    echo "⚠️  Warning: '$old_tag' has no annotation message (may be a lightweight tag). Proceeding with empty message."
  fi

  #  git rev-list -n 1 "$old_tag" resolves the old tag to its raw commit SHA - pointing to same place as before!
  echo "➡️  Creating new annotated tag '$new_tag' with message from '$old_tag'"
  git tag -a "$new_tag" -m "$msg" "$(git rev-list -n 1 "$old_tag")"

  echo "⬆️  Pushing new tag '$new_tag' to origin"
  git push origin "$new_tag"

  echo "⚠️  Deleting old local tag: $old_tag"
  git tag -d "$old_tag" || true

  echo "⚠️  Deleting old remote tag: $old_tag"
  git push origin ":refs/tags/$old_tag"

  echo "✔️  Done. Renamed '$old_tag' → '$new_tag'"
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
list=""
rename_old=""
rename_new=""

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
    -l)
      list="true"
      shift
      ;;
    -r)
      rename_old="$2"
      rename_new="$3"
      shift 3
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

if [[ "$list" == "true" ]]; then
  list_tags
  show_finished
  exit 0
fi

if [[ -n "$rename_old" ]]; then
  if [[ -z "$rename_new" ]]; then
    echo "❌ Error: -r requires both <oldName> and <newName>"
    show_finished
    exit 1
  fi
  rename_tag "$rename_old" "$rename_new"
  show_finished
  exit 0
fi

usage
