#!/usr/bin/env sh
# Render CHANGELOG.json as Markdown on stdout.
# Usage:  scripts/changelog.sh [-c changelog] [-r tag] [-a audience] [-l lang]
#   -c  changelog to read; - reads stdin       (default: CHANGELOG.json)
#   -r  print only the notes for release <tag>: its release section, or
#       Upcoming when the changelog hasn't recorded the release yet
#   -a  audience                               (default: skill-users)
#   -l  language                               (default: en)
# Without -r prints the whole changelog:  scripts/changelog.sh > CHANGELOG.md
# Requires jq.
set -eu

root="$(cd "$(dirname "$0")/.." && pwd)"
changelog="$root/CHANGELOG.json"
release=""
audience="skill-users"
lang="en"

while getopts c:r:a:l: opt; do
  case $opt in
    c) changelog="$OPTARG" ;;
    r) release="$OPTARG" ;;
    a) audience="$OPTARG" ;;
    l) lang="$OPTARG" ;;
    *) exit 2 ;;
  esac
done

command -v jq >/dev/null || {
  echo "error: jq is required (mise install, or your package manager)" >&2
  exit 1
}

[ "$changelog" = - ] || exec <"$changelog"

jq -r --arg audience "$audience" --arg lang "$lang" --arg release "$release" '
  # Category order; categories not listed follow, alphabetically.
  def order: ["breaking", "added", "changed", "deprecated", "removed", "fixed", "security"];
  def title: (.[0:1] | ascii_upcase) + .[1:];

  # Greedy word wrap to $w columns.
  def wrap($w):
    reduce (split(" ")[]) as $word ({lines: [], cur: ""};
      if .cur == "" then .cur = $word
      elif (.cur | length) + 1 + ($word | length) <= $w then .cur += " " + $word
      else .lines += [.cur] | .cur = $word end)
    | .lines + [.cur];

  def bullet:
    (.[$lang] // error("entry \(.id) has no \($lang) text"))
    | wrap(76) | "- " + .[0] + (.[1:] | map("\n  " + .) | join(""));

  # One audience'"'"'s categories, as ### sections.
  def categories:
    . as $cats
    | (order + (keys - order | sort))
    | map(select(($cats[.] // []) | length > 0))
    | map("### \(title)\n\n" + ($cats[.] | map(bullet) | join("\n")) + "\n\n")
    | join("");

  def section($heading): if length > 0 then "## \($heading)\n\n" + categories else "" end;

  if $release != "" then
    (first(.releases[] | select(.version == $release) | .[$audience]) // .upcoming[$audience] // {})
    | categories
  else
    "# Changelog\n\n"
    + (.upcoming[$audience] // {} | section("Upcoming"))
    + (.releases | map(.[$audience] as $cats | "\(.version) — \(.date)" as $h
         | $cats // {} | section($h)) | join(""))
  end
  | sub("\n+$"; "")
'
