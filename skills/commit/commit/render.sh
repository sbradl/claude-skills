#!/usr/bin/env sh
# Render the commit skill's changelog JSON as Markdown on stdout: the
# changelog for one audience, one release's notes, or the roadmap.
# Usage:  sh render.sh [-c changelog] [-r tag | -p] [-a audience] [-l lang]
#   -c  changelog to read; - reads stdin       (default: CHANGELOG.json)
#   -r  print only the notes for release <tag>: its release section, or
#       Upcoming when the changelog hasn't recorded the release yet
#   -p  print the roadmap (`planned`) instead of the changelog
#   -a  audience; optional when the changelog has only one
#   -l  language                               (default: en)
# Without -r or -p prints the whole changelog:  sh render.sh > CHANGELOG.md
# Requires jq.
set -eu

changelog="CHANGELOG.json"
release=""
planned=false
audience=""
lang="en"

while getopts c:r:pa:l: opt; do
  case $opt in
    c) changelog="$OPTARG" ;;
    r) release="$OPTARG" ;;
    p) planned=true ;;
    a) audience="$OPTARG" ;;
    l) lang="$OPTARG" ;;
    *) exit 2 ;;
  esac
done

command -v jq >/dev/null || {
  echo "error: jq is required (mise use jq, or your package manager)" >&2
  exit 1
}

[ "$changelog" = - ] || exec <"$changelog"

jq -r --arg audience "$audience" --arg lang "$lang" --arg release "$release" --argjson planned "$planned" '
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
    (.[$lang] // error("\(.id) has no \($lang) text"))
    | wrap(76) | "- " + .[0] + (.[1:] | map("\n  " + .) | join(""));

  # One audience'"'"'s categories, as ### sections.
  def categories:
    . as $cats
    | (order + (keys - order | sort))
    | map(select(($cats[.] // []) | length > 0))
    | map("### \(title)\n\n" + ($cats[.] | map(bullet) | join("\n")) + "\n\n")
    | join("");

  def section($heading): if length > 0 then "## \($heading)\n\n" + categories else "" end;

  def roadmap:
    "<!-- Generated from the changelog JSON by the commit skill. Edit the JSON. -->\n"
    + "# \(.title[$lang]? // "Roadmap")\n\n"
    + (.sections | map("## \(.title[$lang]? // .key)\n\n"
        + (if (.items | length) > 0 then .items | map(bullet) | join("\n") else "—" end)
        + "\n\n") | join(""));

  if $planned then
    (.planned // error("the changelog has no planned section")) | roadmap
  else
    (if $audience != "" then $audience else
      ([.upcoming, .releases[]] | map(keys) | add // [] | unique - ["version", "date"]) as $all
      | if ($all | length) == 1 then $all[0]
        else error("name the audience with -a: \($all | join(", "))") end
    end) as $audience
    | if $release != "" then
        (first(.releases[] | select(.version == $release) | .[$audience]) // .upcoming[$audience] // {})
        | categories
      else
        "# Changelog\n\n"
        + (.upcoming[$audience] // {} | section("Upcoming"))
        + (.releases | map(.[$audience] as $cats | "\(.version) — \(.date)" as $h
             | $cats // {} | section($h)) | join(""))
      end
  end
  | sub("\n+$"; "")
'
