# Changelog

## Upcoming

### Added

- New `build-feature` skill (group `feature`): takes a feature from
  requirements to pushed code. You tick what is out of scope and approve the
  design and build order; then each requirement becomes a slice — just before
  it is built, you choose how it is tested and approve its tests — built
  test-first by its own sub-agent with its tests linted and then reviewed by a
  fresh sub-agent, closing with a report. Needs the `commit` and `engineering`
  groups set up first.
- New `build-feature-auto` skill (group `feature`): builds one or more
  features hands-off with `build-feature`'s pipeline. It asks one round of
  questions up front — only what no evidence answers, and whether you review
  after each feature or after all — decides and logs everything else (one test
  proposal per feature, tests and their red proof in one pass per slice),
  parks a feature that needs you while the run goes on, and leaves each
  feature as one local commit for you to push. Runs are kept per project, and
  a second run in the same working tree needs its own worktree.
- `commit` can keep a roadmap — now / next / later, milestones, or quarters —
  in the changelog file under `planned`, rendered to `ROADMAP.md`. The commit
  that finishes an item takes it off the roadmap and turns it into that
  commit's changelog entries. Set it up by asking for a roadmap, or in the
  commit setup.
- `commit` ships a render script (needs `jq`) that prints the changelog per
  audience and language, one release's notes, or the roadmap as Markdown;
  setup can copy it into your project as `scripts/changelog.sh`.

### Changed

- The `engineering-rules` testing area offers fuzzing for stacks that read
  untrusted input, with a `fuzz <target>` task that runs one target until
  coverage plateaus or its time budget (10 minutes recommended) runs out; CI
  fuzzes each target for a minute on every push and with the full budget
  nightly.
- The `engineering-rules` testing area records what acceptance tests drive —
  entry point, fakes, what they assert on — and how end-to-end tests are
  structured, page objects recommended.
- The `acceptance` task that `engineering-rules` sets up skips Gherkin
  scenarios tagged `@wip`, so scenarios written before their code keep the
  suite green.
- The `engineering-rules` performance area offers instruction-count
  benchmarks: hardware-independent, so a 1% regression shows even on shared CI
  runners (Linux only).
- The `engineering-rules` enforcement area sets up CI on Gitea Actions and
  Jenkins too.
- The install and update scripts fetch the latest release instead of the
  development version on `main`; `--ref <tag>` (PowerShell: `-Ref`) installs a
  specific release, `--ref main` the development version.
- `engineering-rules` asks what your checks must catch instead of which tools
  you want, plus your developer platforms and allowed runtimes, then
  recommends one tool per outcome and stack as a table; swap any row, each
  alternative shown with its comparison — convention, strengths, weak spots,
  adoption, speed, license.
- `engineering-rules` picks the stack's built-in tool first, then its de facto
  standard, and only then a tool covering more ground — but a tool already in
  the set takes every outcome it covers, and a tool that runs the built-in one
  (golangci-lint runs `go vet`) counts as built-in, so the set stays small.
  Never a second tool for the same outcome; an installed tool duplicating
  another is marked for removal.
- The `engineering-rules` static-analysis area asks whether agents may write
  code comments; `names instead` adds a `Code comments` section to your
  `CLAUDE.md` telling agents to use better names and extracted functions
  instead, keeping only comments a tool requires.
- `engineering-rules` researches tools faster and with far fewer tokens:
  research runs on Sonnet, keeps four candidates per outcome, gathers GitHub
  facts in one call, researches setup details only for the tools you pick, and
  researches stack-independent tools (secret scanning, infrastructure, hooks,
  dependency updates) once for the repo.
- The `engineering-rules` enforcement area has tasks resolve their project
  directory from their own location instead of the git top level, so they work
  in monorepos and worktrees, and ignore every directory a task writes output
  into.

### Fixed

- `tdd-loop` squashes its checkpoints through the `commit` skill, so the
  squashed commit follows your project's commit convention and changelog
  instead of always being a Conventional Commit.
- `tdd-loop`'s mutation pass runs the `mutation` command from your project's
  `CLAUDE.md` Testing section, so it works in projects that don't use mise.

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
