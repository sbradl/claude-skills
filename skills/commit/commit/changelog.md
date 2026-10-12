# Changelog

Keeps the changelog named in the convention's `## Changelog` section, in the same commits as the changes it describes. The changelog is one JSON file holding every audience's entries in every language — the **single source of truth** the user edits and generates other formats from.

## Audiences

Each `###` block in the convention's `## Changelog` section is an **audience**: its heading is the key, its fields the **brief** — `who`, `notices`, `never`, `categories`, `languages`. The brief is the yardstick: a change gets an entry for an audience when it touches what they `notice` and nothing in `never` rules it out.

- Write each entry for its `who`: their vocabulary, at the level of detail they act on. Name the exact identifier for readers who work with code; describe the visible effect for readers who don't.
- A `breaking` entry carries the migration step; a `deprecated` entry names the replacement.
- One change can earn an entry for several audiences, each written for its reader. A change no audience notices gets no entry.

## Format

```json
{
  "upcoming": {
    "end-users": {
      "added": [
        {
          "id": "password-reset-by-email",
          "en": "Reset your password from the login screen.",
          "de": "Passwort direkt im Anmeldebildschirm zurücksetzen."
        }
      ]
    },
    "plugin-authors": {
      "added": [
        {
          "id": "on-password-reset-hook",
          "en": "New `onPasswordReset(user)` hook fires after a reset link is sent."
        }
      ]
    }
  },
  "releases": [
    {
      "version": "v1.2.0",
      "date": "2026-10-01",
      "end-users": {
        "fixed": [
          {
            "id": "invoice-currency",
            "en": "Invoices show the right currency again.",
            "de": "Rechnungen zeigen wieder die richtige Währung."
          }
        ]
      }
    }
  ]
}
```

- **`upcoming`** — always present, holds what no release tag contains yet.
- **`releases`** — newest first; `version` is the tag.
- **Audience keys** — one per audience in the convention; an audience with no entries is left out of `upcoming` or a release.
- **`id`** — a kebab-case slug, unique across the whole file, never changed once written. Rollover finds an entry's origin by it.
- Every entry carries every language in its audience's `languages`. Empty categories are left out; 2-space indent.

## 1. Release rollover — once, before the first commit

Files `upcoming` entries under the release tags cut since the changelog last recorded one.

1. **Release tags** — `git tag -l --sort=-v:refname`, kept when they match `tag-format`, minus pre-releases (a suffix such as `-rc.1`, `-beta`).
2. **Pending tags** — release tags newer than the newest entry in `releases`; all release tags when it is empty. None pending → skip to step 2.
3. For each `upcoming` entry, its origin is the oldest commit that added its id: `git log --reverse --format=%H -S'"id": "<id>"' -- <file> | head -1`. The entry belongs to the oldest pending tag where `git merge-base --is-ancestor <origin> <tag>` succeeds, under the same audience and category. Entries with no origin yet, or that no tag contains, stay in `upcoming`.
4. Add a release for each pending tag that received entries — `date` = `git log -1 --format=%as <tag>` — in version order. A tag that received nothing gets no release.
5. Commit the changelog file alone: subject per the style file, stating the changelog records release `<tag>`; subject only, no issue reference.

## 2. Entries — for each commit group, before committing it

1. Measure the group's diff against every audience's brief: which audiences get an entry, and in which of their categories.
2. `upcoming` already describes the thing this group touches for that audience → rewrite that entry's text, keeping its id. A fix to something that exists only in `upcoming` gets no `fixed` entry: no released version had the bug.
3. Write the text in the audience's first language, then translate it into each of their other languages in the same entry.
4. Stage the changelog file with the group's files, so the entry lands in the commit it describes.

## Done

Every release tag that contains an `upcoming` entry has its release; each committed group has an entry in `upcoming` for every audience whose brief it meets, in every language configured for that audience; the file parses as JSON.
