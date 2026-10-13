# Roadmap

The convention's `## Roadmap` section turns on the **roadmap**: the work still to come, ordered by priority, in the changelog file's `planned` key. An item leaves it in the commit that finishes it and becomes that commit's changelog entries — planned, then `upcoming`, then a release.

## Format

```json
"planned": {
  "title": { "en": "Roadmap", "de": "Roadmap" },
  "sections": [
    {
      "key": "now",
      "title": { "en": "Now", "de": "Jetzt" },
      "items": [
        {
          "id": "password-reset-by-email",
          "en": "Reset your password from the login screen.",
          "de": "Passwort direkt im Anmeldebildschirm zurücksetzen."
        }
      ]
    },
    { "key": "next", "title": { "en": "Next", "de": "Als Nächstes" }, "items": [] },
    { "key": "later", "title": { "en": "Later", "de": "Später" }, "items": [] }
  ]
}
```

- **`sections`** — in the `structure`'s order. `now-next-later`: exactly `now`, `next`, `later`. `milestones`: one per target version in `tag-format`, oldest first. `quarters`: `2026-Q4` and on, oldest first.
- **`title`** — the heading per language, on `planned` and on each section; without one the heading is `Roadmap`, or the section's key. `now-next-later` sections carry a title in every language; a version or quarter key reads the same in all of them.
- **`items`** — highest priority first. An item's `id` follows the entry `id` rules in `changelog.md`.
- **Text** — one sentence per language in the roadmap's `languages`: what its readers will get, in their words, never how it is built.

## Past sections

With `milestones` or `quarters`, before any roadmap change: a **past section** — its version tagged, or its quarter over — that still holds items → ask, one single-select per section, which section its items move to, the next one first and `(Recommended)`. Remove the emptied section.

## Requests

- **Add** — write the item; it goes into the section the user names, at the position they name, else ask one single-select over the sections, the last one first and `(Recommended)`, and append it there.
- **Move, reorder, reword** — apply it, keeping the id. Reworded → retranslate every language.
- **Drop** — the user abandons an item: remove it.
- **What's planned** — answer from the file, highest section and priority first; change nothing.

Render, and leave the files uncommitted.

## Ship — for each commit group, before its changelog entries

Name each item the group finishes and remove it from `planned`; a partly done item stays. Its changelog entries take its id — entries for several audiences take `<id>-<audience key>`. Render, and stage the roadmap files with the group.

## Render

After every change to `planned`, render `ROADMAP.md` beside the changelog file in the roadmap's first language, and `ROADMAP.<lang>.md` for each further one:

```sh
sh <skill-dir>/render.sh -c <path> -p -l <lang> > ROADMAP.<lang>.md
```

It fails on an item missing the language; add the translation and render again.

## Done

The changelog file parses as JSON with `planned` in the format above, every item carries every roadmap language, every `ROADMAP` Markdown file is `render.sh -p`'s current output for its language, and the requested change — or each item the commit group finishes — is in it.
