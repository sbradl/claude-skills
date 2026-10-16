#!/bin/sh
# Checks a build-feature design.md. Under "## Requirements", one "### <id> ..."
# block per requirement; once its test levels are chosen, a "Levels: a, b · ..."
# line naming known levels. Under "## Slices", the build order: one "<n>. <id>"
# line per requirement.
# POSIX sh and awk, so it runs on Linux and in Git Bash.
# Usage: sh check-coverage.sh <design.md>

if [ $# -ne 1 ] || [ ! -f "$1" ]; then
  echo "usage: sh check-coverage.sh <design.md>" >&2
  exit 2
fi

awk '
function trim(s) { sub(/^[ \t]+/, "", s); sub(/[ \t\r]+$/, "", s); return s }
function fail(msg) { print "FAIL: " msg; bad = 1 }

BEGIN { valid["acceptance"]; valid["unit"]; valid["e2e"]; valid["benchmark"]; valid["manual"] }

/^## / { sec = trim(substr($0, 4)); req = ""; next }

sec == "Requirements" && /^### / {
  split(trim(substr($0, 5)), w, /[ \t]+/); req = w[1]
  if (req in known) fail("requirement " req " appears twice")
  known[req] = 1; order[++nreq] = req
  next
}
sec == "Requirements" && req != "" && /^Levels:/ {
  line = trim(substr($0, 8)); c = index(line, "·"); if (c) line = substr(line, 1, c - 1)
  n = split(line, lv, ","); leveled++
  for (i = 1; i <= n; i++) {
    l = trim(lv[i]); if (l == "") continue
    if (!(l in valid)) fail(req ": unknown level " l)
  }
  next
}
sec == "Slices" && /^[0-9]+\. / {
  split(trim($0), w, /[ \t]+/); id = w[2]
  nsl++; slices[id]++
  next
}

END {
  if (nreq == 0) fail("no requirements under ## Requirements")
  if (nsl > 0) {
    for (r = 1; r <= nreq; r++) {
      q = order[r]
      if (!slices[q]) fail(q ": not in the build order")
      else if (slices[q] > 1) fail(q ": " slices[q] " times in the build order")
    }
    for (id in slices) if (!(id in known)) fail("build order names " id ", which is no requirement")
  }
  if (bad) exit 1
  print "ok: " nreq " requirements, " leveled + 0 " with test levels, " nsl + 0 " slices"
}
' "$1"
