#!/bin/sh
# Checks the skill conventions CLAUDE.md states, plus build-feature's
# check-coverage.sh and commit's render.sh against their fixtures.
# Run from anywhere in the repo.
set -u
cd "$(git rev-parse --show-toplevel)" || exit 2
bad=0
fail() { echo "FAIL: $*"; bad=1; }

for skill in skills/*/*/SKILL.md; do
  dir=${skill%/SKILL.md}
  name=$(sed -n 's/^name: *//p' "$skill" | head -1)
  [ "$name" = "${dir##*/}" ] || fail "$skill: name '$name' does not match its directory"
  grep -q '^## Done' "$skill" || fail "$skill: no ## Done section"
  [ "$(readlink ".claude/skills/$name")" = "../../$dir" ] || fail ".claude/skills/$name: missing or not a link to ../../$dir"
  for f in "$dir"/*; do
    case $f in */SKILL.md) continue ;; esac
    [ -f "$f" ] && ! grep -rlF --include='*.md' "${f##*/}" "$dir" | grep -qvx "$f" && fail "$dir: no .md file mentions ${f##*/}"
  done
  for ref in $(grep -rhoE '<skill-dir>/[A-Za-z0-9_./-]+\.(md|sh)' "$dir" | sort -u); do
    [ -e "$dir/${ref#<skill-dir>/}" ] || fail "$dir: $ref does not exist"
  done
done

dupes=$(ls -d skills/*/*/ | awk -F/ '{print $3}' | sort | uniq -d)
[ -z "$dupes" ] || fail "skill names used in more than one group: $dupes"

cov=skills/feature/build-feature/check-coverage.sh
sh "$cov" tests/check-coverage/ok.md >/dev/null || fail "$cov rejects tests/check-coverage/ok.md"
for f in tests/check-coverage/bad-*.md; do
  want=$(sed -n '1s/^<!-- expect: \(.*\) -->$/\1/p' "$f")
  out=$(sh "$cov" "$f") && fail "$cov accepts $f"
  [ "$out" = "FAIL: $want" ] || fail "$cov on $f: want 'FAIL: $want', got '$out'"
done

render=skills/commit/commit/render.sh
fx=tests/render/CHANGELOG.json
sh "$render" -c $fx -p -l de | diff -u tests/render/ROADMAP.de.md - || fail "$render -p output differs from tests/render/ROADMAP.de.md"
[ "$(sh "$render" -c $fx -r v2.1.0 -a developers)" = "### Fixed

- \`GET /invoices/{id}\` rounds totals to cents." ] || fail "$render -r v2.1.0 -a developers: wrong release notes"
[ -z "$(sh "$render" -c $fx -r v2.1.0 -a end-users)" ] || fail "$render -r: a release without the audience's entries must print nothing, not Upcoming"
echo '{"upcoming": {}}' | sh "$render" -c - -a end-users >/dev/null || fail "$render fails without releases"

[ $bad -eq 0 ] && echo "ok: skills"
exit $bad
