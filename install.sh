#!/usr/bin/env sh
# Install the claude-skills into ./.claude/skills/ in the current directory.
# Usage:  curl -fsSL https://raw.githubusercontent.com/sbradl/claude-skills/main/install.sh | sh
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
cp -R "$src"/. "$DEST"/

echo "Installed skills into $DEST:"
ls -1 "$DEST"
