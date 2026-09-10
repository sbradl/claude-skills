# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A collection of **Claude Code skills** — prose instruction sets under `.claude/skills/<name>/SKILL.md`, plus supporting reference files in the same directory. There is no application code, build, lint, or test tooling. "Working in this repo" means authoring and editing skill Markdown.

`install.sh` (POSIX sh) and `install.ps1` (PowerShell) are the distribution mechanism: they download the GitHub branch archive and copy `.claude/skills/` into the caller's current directory. `update.sh` / `update.ps1` are the same download but replace each skill directory wholesale (so renamed or deleted files inside a skill don't linger). Keep all four in lockstep — same repo slug, branch, and archive handling; the sh and ps1 halves of each pair must match, and install vs. update differ only in the copy step.

## Skill file conventions

- Each skill is a directory under `.claude/skills/`, with `SKILL.md` as the entry point.
- `SKILL.md` starts with YAML frontmatter: `name` (matches the directory), `description` (when the skill triggers — write it as the recall cue), optional `disable-model-invocation: true` for skills only a human or another skill may start (e.g. `craft-review`).
- Sibling `.md` files (`ddd.md`, `smells.md`, `clean-code.md`, `pragmatic.md`, `philosophy.md` in `craft-review/`) are checklists the SKILL tells a sub-agent to read by absolute path (`<skill-dir>/…`). Keep them self-contained — they load into a fresh context with no other repo knowledge.
- House style: terse, imperative, second person. Bold term → em-dash → definition. Each skill ends with a `## Done` section stating the exact observable completion condition.

## Architecture: how the skills compose

Two families that interlock.

### TDD family — `tdd-loop` orchestrates `tdd-red`, `tdd-green`, `tdd-refactor`

The central design constraint is **context isolation between phases**. `tdd-loop` runs slices (one named behaviour) in batches of five:

- **`tdd-red`** runs in a sub-agent, edits test files only, and returns two *artifacts*: the test file path and the verbatim runner transcript.
- **`tdd-green`** runs in a *fresh* sub-agent given **only those artifacts** — never a prose summary, because a summary smuggles in the author's imagined implementation and that coupling is what TDD prevents. It edits source only (the mount enforces read-only tests) and picks the change via the Transformation Priority Premise.
- **`tdd-refactor`** runs in the main context at each batch boundary, driven by review findings as its mandate. It proves behaviour preservation against the pinned "green commit" and confirms the design improved via a before/after review.

Each phase commits a checkpoint. `tdd-loop` also runs a mutation pass per batch (`MUTATE_FILES="<paths>" mise run mutation`) and stops at every batch boundary for user review.

### Craft-review family — `craft-review`

A diff reviewed through **five lenses, each in its own parallel `general-purpose` sub-agent**: DDD, Code Smells, Clean Code, Pragmatic Programmer, Philosophy of Software Design. Isolation is deliberate — a clean bill on one lens must not mask a failure on another, and overlapping findings (primitive obsession, Law of Demeter) must not be deduped away. Results are presented per-lens with **no cross-lens reranking**; head-to-head contradictions resolve by the precedence DDD → Pragmatic → Clean Code → Smells → Philosophy.

### The seam between them

`tdd-loop`'s refactor pass consumes `craft-review`'s aggregated findings as the refactor mandate. `craft-review` is user-invoked (`disable-model-invocation`), so `tdd-loop` cannot spawn it — it asks the user to run `/craft-review` and waits.

## Editing guidance

- Changing a phase's inputs/outputs (the red→green artifact handoff, the refactor mandate) ripples across the other skills — check `tdd-loop` when touching any TDD phase skill.
- The `craft-review` reference `.md` files are cited by name in `SKILL.md` step 3; keep the list and the filenames in sync.
- Preserve the isolation rationale in edits — it is the reason these are separate skills and separate sub-agents, not one prompt.
