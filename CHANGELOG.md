# Changelog

## Upcoming

### Added

- New `commit` skill: commits your changes in your project's convention —
  Conventional Commits, Gitmoji, or plain subjects — asking once per project
  about message style, body, granularity, and issue references, and optionally
  keeping a translated `CHANGELOG.json` for the audiences you pick or
  describe.
- The install and update scripts take skill group names (`tdd`,
  `craft-review`, `commit`) to install or update only those groups.
- Running the install script without arguments shows a checklist of skill
  groups to pick from (arrow keys move, space selects, enter confirms) instead
  of installing everything.

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
