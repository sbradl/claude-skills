#!/usr/bin/env sh
# Update the claude-skills in ./.claude/skills/ to the latest release.
# Replaces the skill directories in place; leaves the rest of ./.claude alone.
# Usage:  curl -fsSL https://raw.githubusercontent.com/sbradl/claude-skills/main/update.sh | sh
#         curl -fsSL https://raw.githubusercontent.com/sbradl/claude-skills/main/update.sh | sh -s -- --ref v2.1.4 tdd craft-review
# --ref takes a release tag, or a branch (main for the development version).
# Arguments name skill groups (directories under skills/); none means every
# group with at least one skill already installed.
set -eu

REPO="sbradl/claude-skills"
DEST="./.claude/skills"

REF=""
groups=""
while [ $# -gt 0 ]; do
  case $1 in
    --ref) [ $# -ge 2 ] || { echo "error: --ref needs a tag or branch" >&2; exit 1; }
           REF=$2; shift 2 ;;
    --ref=*) REF=${1#--ref=}; shift ;;
    *) groups="$groups $1"; shift ;;
  esac
done
set -- $groups

if [ -z "$REF" ]; then
  REF=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" \
    | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p')
  [ -n "$REF" ] || { echo "error: no release found; pass --ref main for the development version" >&2; exit 1; }
fi

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

echo "Downloading $REPO@$REF ..."
curl -fsSL "https://github.com/$REPO/archive/$REF.tar.gz" \
  | tar -xz -C "$tmp"

# The archive holds one top-level directory, named after the repo and ref.
src=$(echo "$tmp"/*/skills)
[ -d "$src" ] || { echo "error: skills directory not found in archive" >&2; exit 1; }

if [ $# -eq 0 ]; then
  for group in $(ls "$src"); do
    for d in "$src/$group"/*/; do
      if [ -d "$DEST/$(basename "$d")" ]; then set -- "$@" "$group"; break; fi
    done
  done
  [ $# -gt 0 ] || {
    echo "error: no installed skill groups in $DEST; run install.sh first" >&2
    exit 1
  }
fi
for group in "$@"; do
  [ -d "$src/$group" ] || {
    echo "error: no skill group '$group' (available: $(echo $(ls "$src")))" >&2
    exit 1
  }
done

mkdir -p "$DEST"
for group in "$@"; do
  # Replace each skill directory wholesale so renamed or deleted files inside
  # it don't linger.
  for d in "$src/$group"/*/; do
    name="$(basename "$d")"
    rm -rf "$DEST/$name"
  done
  cp -R "$src/$group"/. "$DEST"/
done

echo "Updated skills in $DEST:"
ls -1 "$DEST"
