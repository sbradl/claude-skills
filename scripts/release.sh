#!/usr/bin/env sh
# Cut a release: move CHANGELOG.json's Upcoming entries into a release section
# for <version>, commit it, tag that commit, and push both. The tag push
# triggers the release workflow, which publishes the section as release notes.
# Usage:  scripts/release.sh v2.2.0        (or: mise run release v2.2.0)
# Requires jq.
set -eu

fail() { echo "error: $*" >&2; exit 1; }

version="${1:-}"
echo "$version" | grep -Eq '^v[0-9]+\.[0-9]+\.[0-9]+$' \
  || fail "usage: scripts/release.sh v<major>.<minor>.<patch>"

root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"

[ -z "$(git status --porcelain)" ] || fail "working tree is not clean"
[ "$(git branch --show-current)" = main ] || fail "release from main"
git fetch -q origin main --tags
[ "$(git rev-parse HEAD)" = "$(git rev-parse origin/main)" ] \
  || fail "main is not in sync with origin/main"
git rev-parse -q --verify "refs/tags/$version" >/dev/null && fail "tag $version already exists"
newest="$(git tag -l 'v*' --sort=-v:refname | head -n 1)"
[ -z "$newest" ] || [ "$(printf '%s\n%s\n' "$newest" "$version" | sort -V | tail -n 1)" = "$version" ] \
  && [ "$newest" != "$version" ] || fail "$version is not newer than $newest"
jq -e '[.upcoming[][][]] | length > 0' CHANGELOG.json >/dev/null \
  || fail "nothing in Upcoming to release"

jq --indent 2 --arg v "$version" --arg d "$(date -u +%F)" \
  '.releases = [{version: $v, date: $d} + .upcoming] + .releases | .upcoming = {}' \
  CHANGELOG.json > CHANGELOG.json.tmp && mv CHANGELOG.json.tmp CHANGELOG.json
scripts/changelog.sh > CHANGELOG.md.tmp && mv CHANGELOG.md.tmp CHANGELOG.md

git add CHANGELOG.json CHANGELOG.md
git commit -q -m "chore(release): $version"
git tag -a "$version" -m "$version"
git push -q --atomic origin main "$version"
echo "Released $version — the release workflow publishes it."
