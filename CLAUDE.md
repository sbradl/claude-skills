# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A collection of **Claude Code skills** — prose instruction sets under `skills/<group>/<name>/SKILL.md`, plus supporting reference files in the same directory. A **group** (`feature`, `tdd`, `craft-review`, `commit`, `engineering`) is a unit of distribution only; Claude Code never sees it. There is no application code; the only code is the install/update scripts, the release and check tooling below, `commit`'s `render.sh` (sh and jq), and `build-feature`'s `check-coverage.sh` (POSIX sh and awk, so it runs in Git Bash on Windows too). "Working in this repo" means authoring and editing skill Markdown.

`install.sh` (POSIX sh) and `install.ps1` (PowerShell) are the distribution mechanism: they download the archive of the latest GitHub release — or of the tag or branch `--ref` (`-Ref`) names — and flatten `skills/<group>/*` into the caller's `./.claude/skills/` — the groups named as arguments, or else those picked from a checklist (`install.sh` installs every group when there is no terminal to ask on). `update.sh` / `update.ps1` are the same download but replace each skill directory wholesale (so renamed or deleted files inside a skill don't linger). Keep all four in lockstep — same repo slug, ref resolution, and archive handling; the sh and ps1 halves of each pair must match. Install and update differ in the copy step and in what no arguments means: install shows a checklist, update takes every group with at least one skill already installed.

`scripts/check-skills.sh` (`mise run check`) enforces the mechanical skill conventions — frontmatter `name`, `## Done`, symlinks, unique names, sibling files and `<skill-dir>/` references — and runs `check-coverage.sh` and `render.sh` against their fixtures in `tests/`. The pre-commit hook and the `check` workflow run it.

`CHANGELOG.md` is generated from `CHANGELOG.json` (the `skill-users` audience) by `commit`'s own `skills/commit/commit/render.sh` — edit the JSON, never `CHANGELOG.md`. The `.githooks/pre-commit` hook also regenerates and stages it whenever either file is staged; `mise run setup` installs `jq` and `gh` and enables the hook once per clone (`mise run changelog` regenerates by hand).

Release with `mise run release v{major}.{minor}.{patch}` (`scripts/release.sh`): it moves Upcoming into a release section, commits `chore(release): <tag>`, tags that commit, and pushes both. The tag push runs `.github/workflows/release.yml`, which fails if `CHANGELOG.md` is stale or the changelog doesn't record the tag, then publishes the section (`render.sh -r <tag>`) as the GitHub release notes. Never push a bare tag.

## Skill file conventions

- Each skill is a directory under `skills/<group>/`, with `SKILL.md` as the entry point. Skill names must be unique across groups — install flattens them into one directory.
- `.claude/skills/<name>` is a relative symlink to `../../skills/<group>/<name>` so the skills load when working in this repo — Claude Code only discovers `.claude/skills/<name>/SKILL.md`, never a nested group. Add one per new skill.
- `SKILL.md` starts with YAML frontmatter: `name`, `description` (when the skill triggers — write it as the recall cue), optional `disable-model-invocation: true` for skills only a human may start — no other skill can spawn them (`build-feature`, `build-feature-auto`, `craft-review`, `engineering-rules`).
- Sibling `.md` files are disclosed reference the `SKILL.md` points at by absolute path (`<skill-dir>/…`): `craft-review`'s lens checklists, `commit`'s `setup.md`, `changelog.md`, `roadmap.md`, and `styles/`, `engineering-rules`' `research.md` and `areas/`, `build-feature`'s `setup.md` and `briefs/`. Files handed to a sub-agent — the lens checklists, `research.md`, the briefs — load into a fresh context with no other repo knowledge; keep them self-contained.
- **Per-project decisions** live outside the skill directory, in `<repo-root>/.claude/<skill>.md` (`commit.md`, `engineering-rules.md`, `build-feature.md`), because the update scripts replace skill directories wholesale. The skill asks when the file is missing and writes it. `commit` also falls back to `~/.claude/commit.md` and keeps its setup in a disclosed `setup.md`; its option bodies sit in the skill directory (`styles/<value>.md`) so updates still improve them.
- House style: terse, imperative, second person. Bold term → em-dash → definition. The `## Done` section states the exact observable completion condition.

## Architecture: how the skills compose

Each `SKILL.md` explains its own design; these are the seams between skills.

- **TDD family** — `tdd-loop` drives `tdd-red` and `tdd-green` in separate sub-agents per slice and `tdd-refactor` in the main context per batch of five. Red hands green only its two artifacts (test file, runner transcript), never a summary.
- **`craft-review`** — five lenses, one isolated sub-agent each, no cross-lens reranking. It is user-invoked, so `tdd-loop` asks the user to run `/craft-review`; its findings are `tdd-refactor`'s mandate.
- **`build-feature`** — requires `commit`'s convention and the `engineering-rules` rulebook, and squashes through `commit`; `briefs/` is its sub-agents' whole context besides the repo.
- **`build-feature-auto`** — the hands-off variant: reuses `build-feature`'s `setup.md`, config, `briefs/`, and `check-coverage.sh` through `<skill-dir>/../build-feature/` (same group, so installed side by side), and replaces each gate with a logged decision. Keep the briefs free of who answers their stops — either skill's coordinator does — and mirror changes to `build-feature`'s steps (slice report checks, feature checks, close) in it.

## Editing guidance

- `build-feature` reads the rulebook's testing record, its `mutation`/`fuzz`/benchmark tasks, and the `@wip` exclusion the testing area wires into `acceptance`, and owns `## Rule decisions` (which `engineering-rules` leaves alone on revisit) — change both sides together. `design.md`'s `## Requirements` blocks (their `Levels:` lines) and `## Slices` build order are what `check-coverage.sh` parses; `briefs/tests.md` and `SKILL.md` step 2 define them.
- Changing a phase's inputs/outputs (the red→green artifact handoff, the refactor mandate) ripples across the other skills — check `tdd-loop` when touching any TDD phase skill.
- `engineering-rules`' testing area writes the project's `CLAUDE.md` `Testing` section, where `tdd-green` finds its coverage command and `tdd-loop` its `MUTATE_FILES`-aware `mutation` command — keep both when editing either side.
- `commit`'s changelog format (`changelog.md`: `upcoming`/`releases`, audience keys, entry `id`s; `roadmap.md`: `planned`) is what its `render.sh` and this repo's `scripts/release.sh` parse — change them together.
- Preserve the isolation rationale in edits — it is the reason these are separate skills and separate sub-agents, not one prompt.
