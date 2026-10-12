#!/bin/sh
# Checks a build-feature design.md: every requirement under "## Requirements"
# has tests; once "## Slices" exists, every test sits in exactly one slice and
# no slice holds more than 6 acceptance and e2e tests (unit tests and
# benchmarks ride along). POSIX sh and awk, so it runs on Linux and in Git Bash.
# Usage: sh check-coverage.sh <design.md>

if [ $# -ne 1 ] || [ ! -f "$1" ]; then
  echo "usage: sh check-coverage.sh <design.md>" >&2
  exit 2
fi

awk '
function trim(s) { sub(/^[ \t]+/, "", s); sub(/[ \t\r]+$/, "", s); return s }
function fail(msg) { print "FAIL: " msg; bad = 1 }
function show(k,   p) { split(k, p, SUBSEP); return p[1] ": " p[2] }
function rides(g) { return g == "unit" || g == "benchmark" }

/^## / { sec = trim(substr($0, 4)); item = ""; next }
/^### / {
  item = trim(substr($0, 5))
  if (sec == "Requirements") { nreq++; req[nreq] = item; rtests[nreq] = 0 }
  else if (sec == "Slices") { nsl++; sl[nsl] = item; cap[nsl] = 0 }
  next
}
/^- / && item != "" && (sec == "Requirements" || sec == "Slices") {
  line = trim(substr($0, 3)); sub(/\.$/, "", line)
  c = index(line, ":")
  if (c == 0) { fail("no group in \"" $0 "\" under " item); next }
  group = trim(substr(line, 1, c - 1)); rest = trim(substr(line, c + 1))
  if (sec == "Slices" && rest ~ /^all [0-9]+$/) {
    ne++; es[ne] = nsl; eg[ne] = group; en[ne] = ""; eall[ne] = substr(rest, 5) + 0
    next
  }
  n = split(rest, names, ";")
  for (i = 1; i <= n; i++) {
    nm = trim(names[i]); if (nm == "") continue
    if (sec == "Requirements") {
      rtests[nreq]++; k = group SUBSEP nm
      if (!(k in known)) { known[k] = 1; ngroup[group]++ }
    } else { ne++; es[ne] = nsl; eg[ne] = group; en[ne] = nm }
  }
}

END {
  if (nreq == 0) fail("no requirements under ## Requirements")
  for (r = 1; r <= nreq; r++) if (rtests[r] == 0) fail("no tests for requirement " req[r])
  if (nsl > 0) {
    for (e = 1; e <= ne; e++) {
      s = es[e]; g = eg[e]
      if (en[e] == "") {
        if (ngroup[g] != eall[e]) fail("slice " sl[s] " says " g ": all " eall[e] ", requirements list " ngroup[g] + 0)
        for (k in known) {
          split(k, p, SUBSEP)
          if (p[1] == g) { owners[k]++; owner[k] = owner[k] " [" sl[s] "]"; if (!rides(g)) cap[s]++ }
        }
      } else {
        k = g SUBSEP en[e]
        if (!(k in known)) { fail("slice " sl[s] " lists " show(k) ", which no requirement has"); continue }
        owners[k]++; owner[k] = owner[k] " [" sl[s] "]"; if (!rides(g)) cap[s]++
      }
    }
    for (k in known) {
      if (owners[k] == 0) fail("no slice for " show(k))
      else if (owners[k] > 1) fail(show(k) " is in " owners[k] " slices:" owner[k])
    }
    for (s = 1; s <= nsl; s++) if (cap[s] > 6) fail("slice " sl[s] " has " cap[s] " acceptance and e2e tests, at most 6")
  }
  if (bad) exit 1
  t = 0; for (k in known) t++
  print "ok: " nreq " requirements, " t " tests, " nsl + 0 " slices"
}
' "$1"
