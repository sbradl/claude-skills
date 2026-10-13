#!/usr/bin/env sh
# Print GitHub facts for tool candidates, one tab-separated line per repo:
# repo, license (SPDX), stars, archived, latest release tag, its date.
# A repo without releases prints "-" for both; check its tags instead.
# Usage:  sh repo-facts.sh owner/repo [owner/repo ...]
# Requires an authenticated gh.
set -u

command -v gh >/dev/null || { echo "error: gh is required" >&2; exit 1; }

for r in "$@"; do
  line=$(gh api graphql -F owner="${r%%/*}" -F name="${r#*/}" -f query='
    query($owner: String!, $name: String!) {
      repository(owner: $owner, name: $name) {
        nameWithOwner stargazerCount isArchived
        licenseInfo { spdxId }
        latestRelease { tagName publishedAt }
      }
    }' --jq '.data.repository | [.nameWithOwner, (.licenseInfo.spdxId // "none"), .stargazerCount, .isArchived,
      (.latestRelease.tagName // "-"), ((.latestRelease.publishedAt // "-") | .[0:10])] | @tsv' 2>/dev/null) \
    && echo "$line" || printf '%s\tnot found\n' "$r"
done
