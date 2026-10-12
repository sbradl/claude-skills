#!/usr/bin/env sh
# Install the claude-skills into ./.claude/skills/ in the current directory.
# Usage:  curl -fsSL https://raw.githubusercontent.com/sbradl/claude-skills/main/install.sh | sh
#         curl -fsSL https://raw.githubusercontent.com/sbradl/claude-skills/main/install.sh | sh -s -- --ref v2.1.4 tdd craft-review
# Installs the latest release; --ref takes a release tag, or a branch (main for
# the development version). Arguments name skill groups (directories under
# skills/); none means pick from a checklist (or install all when there is no
# terminal to ask on).
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

# Checklist on the terminal: up/down (or k/j) move, space toggles, enter
# confirms. Prints the chosen groups. Reads keys from /dev/tty, since under
# `curl | sh` stdin is the script.
pick() {
  n=$#
  cur=1
  esc=$(printf '\033')
  old=$(stty -g </dev/tty)
  trap 'stty "$old" </dev/tty; printf "\033[?25h" >/dev/tty' EXIT
  trap 'exit 130' INT TERM
  stty -icanon -echo min 1 time 0 </dev/tty
  printf 'Select skill groups (up/down move, space toggles, enter confirms):\n\033[?25l' >/dev/tty
  i=1; for g; do eval "on$i=0"; i=$((i + 1)); done
  while :; do
    i=1
    for g; do
      eval "on=\$on$i"
      if [ "$i" -eq "$cur" ]; then mark='>'; else mark=' '; fi
      if [ "$on" = 1 ]; then box='[x]'; else box='[ ]'; fi
      printf '\r\033[K%s %s %s (%s)\n' "$mark" "$box" "$g" "$(echo $(ls "$src/$g"))"
      i=$((i + 1))
    done >/dev/tty
    key=$(dd bs=1 count=1 2>/dev/null </dev/tty)
    case $key in
      "$esc")
        key=$(dd bs=1 count=2 2>/dev/null </dev/tty)
        case $key in
          '[A'|OA) cur=$((cur > 1 ? cur - 1 : 1)) ;;
          '[B'|OB) cur=$((cur < n ? cur + 1 : n)) ;;
        esac ;;
      k) cur=$((cur > 1 ? cur - 1 : 1)) ;;
      j) cur=$((cur < n ? cur + 1 : n)) ;;
      ' ') eval "on$cur=\$((1 - on$cur))" ;;
      '') break ;;  # enter: $(...) strips the newline
    esac
    printf '\033[%dA' "$n" >/dev/tty
  done
  i=1
  for g; do
    if eval "[ \$on$i = 1 ]"; then echo "$g"; fi
    i=$((i + 1))
  done
}

if [ $# -eq 0 ]; then
  if (true </dev/tty) 2>/dev/null; then
    set -- $(pick $(ls "$src"))
    [ $# -gt 0 ] || { echo "Nothing selected."; exit 0; }
  else
    set -- $(ls "$src")
  fi
fi
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
