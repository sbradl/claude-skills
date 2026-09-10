#!/usr/bin/env sh
# Update the claude-skills in ./.claude/skills/ to the latest version.
# Replaces the skill directories in place; leaves the rest of ./.claude alone.
# Usage:  curl -fsSL https://raw.githubusercontent.com/sbradl/claude-skills/main/update.sh | sh
set -eu

REPO="sbradl/claude-skills"
BRANCH="main"
DEST="./.claude/skills"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

echo "Downloading $REPO@$BRANCH ..."
curl -fsSL "https://github.com/$REPO/archive/refs/heads/$BRANCH.tar.gz" \
  | tar -xz -C "$tmp"

src="$tmp/claude-skills-$BRANCH/.claude/skills"
[ -d "$src" ] || { echo "error: skills directory not found in archive" >&2; exit 1; }

mkdir -p "$DEST"
# Replace each skill directory wholesale so renamed or deleted files inside it
# don't linger.
for d in "$src"/*/; do
  name="$(basename "$d")"
  rm -rf "$DEST/$name"
done
cp -R "$src"/. "$DEST"/

echo "Updated skills in $DEST:"
ls -1 "$DEST"
