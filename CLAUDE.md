# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A collection of **Claude Code skills** — prose instruction sets under `skills/<group>/<name>/SKILL.md`, plus supporting reference files in the same directory. A **group** (`feature`, `tdd`, `craft-review`, `commit`, `engineering`) is a unit of distribution only; Claude Code never sees it. There is no application code and no build, lint, or test tooling; the only code is the install/update scripts, the changelog and release tooling below, and `build-feature`'s `check-coverage.sh` (POSIX sh and awk, so it runs in Git Bash on Windows too). "Working in this repo" means authoring and editing skill Markdown.

`install.sh` (POSIX sh) and `install.ps1` (PowerShell) are the distribution mechanism: they download the GitHub branch archive and flatten `skills/<group>/*` into the caller's `./.claude/skills/` — the groups named as arguments, or else those picked from a checklist (`install.sh` installs every group when there is no terminal to ask on). `update.sh` / `update.ps1` are the same download but replace each skill directory wholesale (so renamed or deleted files inside a skill don't linger). Keep all four in lockstep — same repo slug, branch, and archive handling; the sh and ps1 halves of each pair must match. Install and update differ in the copy step and in what no arguments means: install shows a checklist, update takes every group with at least one skill already installed.

`CHANGELOG.md` is generated from `CHANGELOG.json` (the `skill-users` audience) by `scripts/changelog.sh` — edit the JSON, never `CHANGELOG.md`. The `.githooks/pre-commit` hook regenerates and stages it whenever either file is staged; `mise run setup` installs `jq` and `gh` and enables the hook once per clone (`mise run changelog` regenerates by hand).

Release with `mise run release v{major}.{minor}.{patch}` (`scripts/release.sh`): it moves Upcoming into a release section, commits `chore(release): <tag>`, tags that commit, and pushes both. The tag push runs `.github/workflows/release.yml`, which fails if `CHANGELOG.md` is stale or the changelog doesn't record the tag, then publishes the section (`scripts/changelog.sh -r <tag>`) as the GitHub release notes. Never push a bare tag.

## Skill file conventions

- Each skill is a directory under `skills/<group>/`, with `SKILL.md` as the entry point. Skill names must be unique across groups — install flattens them into one directory.
- `.claude/skills/<name>` is a relative symlink to `../../skills/<group>/<name>` so the skills load when working in this repo — Claude Code only discovers `.claude/skills/<name>/SKILL.md`, never a nested group. Add one per new skill.
- `SKILL.md` starts with YAML frontmatter: `name` (matches the directory), `description` (when the skill triggers — write it as the recall cue), optional `disable-model-invocation: true` for skills only a human may start — no other skill can spawn them (`build-feature`, `craft-review`, `engineering-rules`).
- Sibling `.md` files are disclosed reference the `SKILL.md` points at by absolute path (`<skill-dir>/…`): `craft-review`'s lens checklists, `commit`'s `setup.md`, `changelog.md`, and `styles/`, `engineering-rules`' `research.md` and `areas/`, `build-feature`'s `setup.md` and `briefs/`. Files handed to a sub-agent — the lens checklists, `research.md`, the briefs — load into a fresh context with no other repo knowledge; keep them self-contained.
- **Per-project decisions** live outside the skill directory, in `<repo-root>/.claude/<skill>.md` (`commit.md`, `engineering-rules.md`, `build-feature.md`), because the update scripts replace skill directories wholesale. The skill asks when the file is missing and writes it. `commit` also falls back to `~/.claude/commit.md` and keeps its setup in a disclosed `setup.md`; its option bodies sit in the skill directory (`styles/<value>.md`) so updates still improve them.
- House style: terse, imperative, second person. Bold term → em-dash → definition. Each skill ends with a `## Done` section stating the exact observable completion condition.

## Architecture: how the skills compose

Two families that interlock, the standalone `commit` and `engineering-rules` skills, and `build-feature`, which builds on those two.

### TDD family — `tdd-loop` orchestrates `tdd-red`, `tdd-green`, `tdd-refactor`

The central design constraint is **context isolation between phases**. `tdd-loop` runs slices (one named behaviour) in batches of five:

- **`tdd-red`** runs in a sub-agent, edits test files only, and returns two *artifacts*: the test file path and the verbatim runner transcript.
- **`tdd-green`** runs in a *fresh* sub-agent given **only those artifacts** — never a prose summary, because a summary smuggles in the author's imagined implementation and that coupling is what TDD prevents. It edits source only (the mount enforces read-only tests) and picks the change via the Transformation Priority Premise.
- **`tdd-refactor`** runs in the main context at each batch boundary, driven by review findings as its mandate. It proves behaviour preservation against the pinned "green commit" and confirms the design improved via a before/after review.

Each phase commits a checkpoint. `tdd-loop` also runs a mutation pass per batch (`MUTATE_FILES="<paths>" mise run mutation`) and stops at every batch boundary for user review.

### Craft-review family — `craft-review`

A diff reviewed through **five lenses, each in its own parallel `general-purpose` sub-agent**: DDD, Code Smells, Clean Code, Pragmatic Programmer, Philosophy of Software Design. Isolation is deliberate — a clean bill on one lens must not mask a failure on another, and overlapping findings (primitive obsession, Law of Demeter) must not be deduped away. Results are presented per-lens with **no cross-lens reranking**; head-to-head contradictions resolve by the precedence DDD → Pragmatic → Clean Code → Smells → Philosophy.

### Build feature — `build-feature`

Three user gates (requirements, tests, design and slices), then one **slice sub-agent** per slice and a fresh **test reviewer** per slice. The briefs in `briefs/` are the sub-agents' whole context besides the repo. Approved artefacts change only through their gate (a mini-gate mid-build); checkpoints stay local until the close step squashes them through `commit` and pushes.

It requires `commit`'s convention and the `engineering-rules` rulebook, and reads from the rulebook: the testing record (acceptance format and seam, unit naming, e2e structure), the `mutation`, `fuzz`, and benchmark tasks, and the `## Rule decisions` section it writes itself (open vs final rules).

### The seam between them

`tdd-loop`'s refactor pass consumes `craft-review`'s aggregated findings as the refactor mandate. `craft-review` is user-invoked (`disable-model-invocation`), so `tdd-loop` cannot spawn it — it asks the user to run `/craft-review` and waits.

## Editing guidance

- `build-feature` reads the rulebook's testing record, its `mutation`/`fuzz`/benchmark tasks, and the `@wip` exclusion the testing area wires into `acceptance`, and owns `## Rule decisions` (which `engineering-rules` leaves alone on revisit) — change both sides together. `design.md`'s `## Requirements` and `## Slices` line format is what `check-coverage.sh` parses; `briefs/tests.md` and `SKILL.md` step 3 define it.
- Changing a phase's inputs/outputs (the red→green artifact handoff, the refactor mandate) ripples across the other skills — check `tdd-loop` when touching any TDD phase skill.
- The `craft-review` reference `.md` files are cited by name in `SKILL.md` step 3; keep the list and the filenames in sync.
- `engineering-rules`' testing area writes the project's `CLAUDE.md` `Testing` section, where `tdd-green` finds its coverage command, and the `MUTATE_FILES`-aware `mutation` task `tdd-loop` calls — keep both when editing either side.
- `commit`'s changelog format (`changelog.md`: `upcoming`/`releases`, audience keys, entry `id`s) is also what this repo's `scripts/changelog.sh` and `scripts/release.sh` parse — change them together.
- Preserve the isolation rationale in edits — it is the reason these are separate skills and separate sub-agents, not one prompt.
