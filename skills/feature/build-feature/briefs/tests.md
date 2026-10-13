# Brief: tests sub-agent

You write the tests for one requirement of a feature, as documents: Gherkin scenarios and test names. No code, no commits.

## Read first

Only these; read the sections named, not whole files:

- your requirement's block in `<feature-dir>/design.md` — its `Levels:` line says which levels you write and what goes where — and the Assumptions and Texts written so far
- the source section the requirement's `Source:` line names, and the glossary terms it uses
- the feature's `docs/design/<feature-slug>.md` and the research files in `<feature-dir>/research/`
- `.claude/engineering-rules.md`, Testing: the acceptance test format and seam, unit test naming, the e2e structure
- existing feature files and tests, to match their style

## Write

The tests at every level the `Levels:` line names, split as it says. Cover behaviour and edge cases. Name each test in the domain's words, as behaviour: no UI or implementation detail (storage keys, file names, widget types).

1. **Acceptance** — through the rulebook's acceptance seam: Given the state of the fakes, When calls on the entry point, Then what the user-facing result shows. Rulebook says `gherkin` (or `both`, for behaviour its split rule gives Gherkin) → scenarios in feature files next to the existing ones, one folder per feature (none yet → `features/<feature-slug>/`), each new scenario tagged `@wip`. Otherwise → names only.
2. **E2E** — what needs the real UI, platform, storage, or user-facing timing. Gherkin scenarios tagged `@wip` and with the platforms they run on (`@android`, `@desktop`), or names followed by the platforms in parentheses. Keep them few: e2e is slow.
3. **Unit** — names only, in the rulebook's unit test naming.
4. **Benchmark** — names only: the hot path and the input size it runs on, sized from the research files.

Then in `<feature-dir>/design.md`:

- under your requirement, one line per level and feature file, `- <level> <feature file stem>: <name>; <name>.` for Gherkin scenarios, `- <level>: <name>; <name>.` for named tests:

  ```markdown
  ## Requirements

  ### REQ-12 Opens song files in versions 3–5; older versions get a clear message
  Source: SPEC §4.3
  Design: Library, SongReader
  Levels: acceptance, unit · Split: acceptance the main flows, unit each format version · Mutation: on · Fuzz: on
  - acceptance open-file: opens a v4 file; opens a v5 file; rejects a v2 file with a message.
  - unit: reads v3 header; reads v4 header; reads v5 header.
  ```

- **Assumptions**, under `## Assumptions`, headed by your requirement's id, in two lists. *Decisions*: what the requirement leaves open and a reasonable person could decide differently — each with your recommendation and one line of why. *Defaults*: the obvious choices, one line each, for the user to veto.
- **Texts**, under `## Texts`, headed by your requirement's id: every user-visible text your tests show, in the source language.

Done when every level on the `Levels:` line has a test line and, for Gherkin, the rulebook's `acceptance` task passes. A contradictory or impossible requirement goes into your report, not into a test.

## Report

Files written, the test count per level, both assumption lists verbatim, and anything in the requirement you could not cover.
