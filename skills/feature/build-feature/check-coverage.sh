#!/bin/sh
# Checks a build-feature design.md. Under "## Requirements", one "### <id> ..."
# block per requirement; once its test gate has run, a "Levels: a, b · ..." line
# and a "- <level>[ <feature file stem>]: <name>; <name>." line for every level.
# Under "## Slices", the build order: one "<n>. <id>" line per requirement.
# POSIX sh and awk, so it runs on Linux and in Git Bash.
# Usage: sh check-coverage.sh <design.md>

if [ $# -ne 1 ] || [ ! -f "$1" ]; then
  echo "usage: sh check-coverage.sh <design.md>" >&2
  exit 2
fi

awk '
function trim(s) { sub(/^[ \t]+/, "", s); sub(/[ \t\r]+$/, "", s); return s }
function fail(msg) { print "FAIL: " msg; bad = 1 }

BEGIN { valid["acceptance"]; valid["unit"]; valid["e2e"]; valid["benchmark"] }

/^## / { sec = trim(substr($0, 4)); req = ""; next }

sec == "Requirements" && /^### / {
  split(trim(substr($0, 5)), w, /[ \t]+/); req = w[1]
  if (req in known) fail("requirement " req " appears twice")
  known[req] = 1; order[++nreq] = req
  next
}
sec == "Requirements" && req != "" && /^Levels:/ {
  line = trim(substr($0, 8)); c = index(line, "·"); if (c) line = substr(line, 1, c - 1)
  n = split(line, lv, ","); haslevels[req] = 1
  for (i = 1; i <= n; i++) {
    l = trim(lv[i]); if (l == "") continue
    if (!(l in valid)) fail(req ": unknown level " l)
    want[req, l] = 1; wants[req] = wants[req] " " l
  }
  next
}
sec == "Requirements" && req != "" && /^- / {
  line = trim(substr($0, 3)); c = index(line, ":")
  if (c == 0) { fail(req ": no level in \"" $0 "\""); next }
  split(trim(substr(line, 1, c - 1)), h, /[ \t]+/); l = h[1]
  if (!(l in valid)) { fail(req ": unknown level " l " in \"" $0 "\""); next }
  rest = trim(substr(line, c + 1)); sub(/\.$/, "", rest)
  n = split(rest, names, ";"); k = 0
  for (i = 1; i <= n; i++) if (trim(names[i]) != "") k++
  if (k == 0) fail(req ": no test names in \"" $0 "\"")
  has[req, l] += k; tests[req] += k; total += k
  next
}
sec == "Slices" && /^[0-9]+\. / {
  split(trim($0), w, /[ \t]+/); id = w[2]
  nsl++; slices[id]++
  next
}

END {
  if (nreq == 0) fail("no requirements under ## Requirements")
  for (r = 1; r <= nreq; r++) {
    q = order[r]
    if (!haslevels[q]) { if (tests[q]) fail(q ": tests but no Levels: line"); continue }
    tested++
    n = split(trim(wants[q]), lv, " ")
    for (i = 1; i <= n; i++) if (!has[q, lv[i]]) fail(q ": no " lv[i] " tests")
    for (k in has) { split(k, p, SUBSEP); if (p[1] == q && !want[q, p[2]]) fail(q ": " p[2] " tests, but " p[2] " is not on its Levels: line") }
  }
  if (nsl > 0) {
    for (r = 1; r <= nreq; r++) {
      q = order[r]
      if (!slices[q]) fail(q ": not in the build order")
      else if (slices[q] > 1) fail(q ": " slices[q] " times in the build order")
    }
    for (id in slices) if (!(id in known)) fail("build order names " id ", which is no requirement")
  }
  if (bad) exit 1
  print "ok: " nreq " requirements, " tested + 0 " with tests (" total + 0 "), " nsl + 0 " slices"
}
' "$1"
