#!/usr/bin/env sh
# Install the claude-skills into ./.claude/skills/ in the current directory.
# Usage:  curl -fsSL https://raw.githubusercontent.com/sbradl/claude-skills/main/install.sh | sh
#         curl -fsSL https://raw.githubusercontent.com/sbradl/claude-skills/main/install.sh | sh -s -- tdd craft-review
# Arguments name skill groups (directories under skills/); none means all.
set -eu

REPO="sbradl/claude-skills"
BRANCH="main"
DEST="./.claude/skills"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

echo "Downloading $REPO@$BRANCH ..."
curl -fsSL "https://github.com/$REPO/archive/refs/heads/$BRANCH.tar.gz" \
  | tar -xz -C "$tmp"

src="$tmp/claude-skills-$BRANCH/skills"
[ -d "$src" ] || { echo "error: skills directory not found in archive" >&2; exit 1; }

[ $# -gt 0 ] || set -- $(ls "$src")
for group in "$@"; do
  [ -d "$src/$group" ] || {
    echo "error: no skill group '$group' (available: $(echo $(ls "$src")))" >&2
    exit 1
  }
done

mkdir -p "$DEST"
for group in "$@"; do
  cp -R "$src/$group"/. "$DEST"/
done

echo "Installed skills into $DEST:"
ls -1 "$DEST"
