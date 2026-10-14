# Brief: tests sub-agent

You propose, then write, the tests for one requirement of a feature, Gherkin scenarios and **test stubs** — test functions with their final name and an empty body, skipped with the reason `wip`, so the suite stays green and the slice fills them in. No production code, no commits.

## Read first

Only these; read the sections named, not whole files:

- your requirement's block in `<feature-dir>/design.md` — its `Levels:` line says which levels you write and what goes where — and the Texts written so far
- the source section the requirement's `Source:` line names, and the glossary terms it uses
- the feature's `docs/design/<feature-slug>.md` and the research files in `<feature-dir>/research/`
- `.claude/engineering-rules.md`, Testing: the acceptance test format and seam, unit test naming, the e2e structure
- existing feature files and tests, to match their style

## Propose

First, find what the requirement leaves open about what the feature does — what the user sees, can do, or gets back — where a reasonable person could decide differently. Each is a **requirement question**: stop before proposing any test and report them all, each with your recommendation and one line of why. You are resumed with the answers, now in the requirement; assume none yourself.

Then propose the tests at every level the `Levels:` line names, split as it says. Cover behaviour and edge cases. Name each test in the domain's words, as behaviour: no UI or implementation detail (storage keys, file names, widget types).

**One behaviour, one test.** The same check over different inputs is one **varied test** — a Scenario Outline with Examples, a parameterised test, or a property-based test — named once, for the behaviour, and described by what varies: its examples, or the property every input keeps.

Stop and report the proposal, per level: each test's name, one line on what it proves, and for a varied test what varies. Write nothing yet. You are resumed with the tests the user picked, and any changes; write exactly those.

## Write

The picked tests, at their levels:

1. **Acceptance** — through the rulebook's acceptance seam: Given the state of the fakes, When calls on the entry point, Then what the user-facing result shows. Rulebook says `gherkin` (or `both`, for behaviour its split rule gives Gherkin) → scenarios in feature files next to the existing ones, one folder per feature (none yet → `features/<feature-slug>/`), each new scenario tagged `@wip`, a varied test as a Scenario Outline with its Examples. Otherwise → a test stub per test in the stack's acceptance test files, a varied test as a parameterised stub listing its examples.
2. **E2E** — what needs the real UI, platform, storage, or user-facing timing. Gherkin scenarios tagged `@wip` and with the platforms they run on (`@android`, `@desktop`), or test stubs carrying the platforms the way the e2e tool tags them. Keep them few: e2e is slow.
3. **Unit** — test stubs in the stack's test files, named in the rulebook's unit test naming; a varied test as a parameterised stub listing its examples, or a property-based stub stating its property in a one-line comment.
4. **Benchmark** — benchmark stubs: the hot path and the input size it runs on, sized from the research files.

Then in `<feature-dir>/design.md`:

- under your requirement, one line per level and feature file, `- <level> <feature file stem>: <name>; <name>.` for Gherkin scenarios, `- <level>: <name>; <name>.` for named tests:

  ```markdown
  ## Requirements

  ### REQ-12 Opens song files in versions 3–5; older versions get a clear message
  Source: SPEC §4.3
  Design: Library, SongReader
  Levels: acceptance, unit · Split: acceptance the main flows, unit each format version · Mutation: on · Fuzz: on
  - acceptance open-file: opens a file of every supported version; rejects a v2 file with a message.
  - unit: reads the header of every supported version (v3, v4, v5).
  ```

- **Texts**, under `## Texts`, headed by your requirement's id: every user-visible text your tests show, in the source language.

Done when every level on the `Levels:` line has a test line, every picked test exists as a scenario or stub, and the rulebook's `test` and `acceptance` tasks pass with the stubs reported as skipped. A contradictory or impossible requirement goes into your report, not into a test.

## Report

Files written, the test count per level, and anything in the requirement you could not cover. A stop returns only the requirement questions with your recommendations, or the proposal.
