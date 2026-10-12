#!/usr/bin/env sh
# Install the claude-skills into ./.claude/skills/ in the current directory.
# Usage:  curl -fsSL https://raw.githubusercontent.com/sbradl/claude-skills/main/install.sh | sh
#         curl -fsSL https://raw.githubusercontent.com/sbradl/claude-skills/main/install.sh | sh -s -- tdd craft-review
# Arguments name skill groups (directories under skills/); none means pick from
# a checklist (or install all when there is no terminal to ask on).
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
