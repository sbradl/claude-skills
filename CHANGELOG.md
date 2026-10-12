# Changelog

## v2.1.4 — 2026-10-12

### Changed

- The `engineering-rules` testing area creates tasks to run one test file or
  test, report coverage for one file, and mutate only given files, and writes
  all test commands into your project's `CLAUDE.md` — so the TDD skills need
  no manual setup.

## v2.1.3 — 2026-10-12

### Changed

- Running the update script without arguments updates only the skill groups
  you have installed, including skills newly added to them, instead of
  installing every group. Name a group to add it.

## v2.1.2 — 2026-10-12

### Changed

- The `commit` skill's setup shows an example commit message for every option,
  so you pick the style, body, granularity, issue references, and attribution
  by how your commits will look.
- The `commit` skill asks before putting several changes into one commit, and
  splits a file that mixes two changes into separate commits instead of filing
  it under one.

## v2.1.1 — 2026-10-12

### Added

- The `commit` skill releases too: ask it to release and it proposes the next
  version from the unreleased changes, then makes one release commit that
  moves them under that version, tags it, and pushes both — or runs your
  project's own release task when it has one.

## v2.1.0 — 2026-10-12

### Added

- New `commit` skill: commits your changes in your project's convention —
  Conventional Commits, Gitmoji, or plain subjects — asking once per project
  about message style, body, granularity, issue references, and Claude
  attribution, and optionally keeping a translated `CHANGELOG.json` for the
  audiences you pick or describe.
- The install and update scripts take skill group names (`tdd`,
  `craft-review`, `commit`) to install or update only those groups.
- Running the install script without arguments shows a checklist of skill
  groups to pick from (arrow keys move, space selects, enter confirms) instead
  of installing everything.
- New `engineering-rules` skill: sets up the checks your code must pass —
  static analysis, security scanning, testing strategy, enforcement in hooks
  and CI, accessibility, performance budgets, and logging conventions. It
  detects your stacks, researches freely usable tools for each, lets you pick
  tools and rulesets (strictest recommended), and wires every check as a task,
  offering to set up mise when the project doesn't use it.

## v2.0.0 — 2026-09-10

### Changed

- The green phase checks that everything it added is actually run by a test —
  unused lines and branches get reverted instead of shipped.
- Every construct in a green change must trace to a failing assertion. Faking
  a value to pass is allowed; the next test is what forces it to generalise.
- A faked value is pinned down on the following slice, and a behaviour
  boundary always gets two slices, one on each side.
- When mutation testing finds a survivor in batch code, the fix goes into the
  loop rather than a one-off patch.
- The refactor phase no longer adds new behaviour, even when it looks
  necessary.

## v1.0.0 — 2026-09-10

### Added

- TDD loop — builds a feature one behaviour at a time in batches of five, each
  batch closed by a refactor pass and a mutation-testing pass, pausing for
  your review. Red, green, and refactor each run in isolation so no imagined
  implementation leaks between phases.
- Red, green, and refactor phases usable on their own: write one failing test,
  make it pass with the smallest change, or improve a design without touching
  behaviour.
- Craft review — reviews a change through five independent lenses
  (Domain-Driven Design, Code Smells, Clean Code, Pragmatic Programmer,
  Philosophy of Software Design), reported separately with no lens overriding
  another. Its findings drive the TDD loop's refactor pass.
