# claude-skills

A small collection of [Claude Code](https://claude.com/claude-code) skills for disciplined, test-driven development and deep code review.

Skills are prose instruction sets Claude loads on demand. These two families interlock: the TDD loop builds a feature one behaviour at a time, and the craft review supplies the findings that drive each refactor pass.

## Installing

Run one command from the directory you want the skills in. It downloads the latest archive from GitHub and drops every skill into `./.claude/skills/`.

**Linux / macOS**

```sh
curl -fsSL https://raw.githubusercontent.com/sbradl/claude-skills/main/install.sh | sh
```

**Windows (PowerShell)**

```powershell
irm https://raw.githubusercontent.com/sbradl/claude-skills/main/install.ps1 | iex
```

For an all-projects install, run it from your home directory so the skills land in `~/.claude/skills/`.

Claude picks a skill up automatically when the task matches its description, or you can invoke one directly with `/tdd-loop`, `/craft-review`, and so on.

## Configure your project

Put your project's **test, build, and mutation-testing commands in the project's `CLAUDE.md`** (and how to run a single test). The TDD skills run the suite on every red and green phase — without those commands recorded, each phase re-discovers them by searching the repo. One line in `CLAUDE.md` removes that overhead for the whole loop.

Paste this prompt into Claude Code once, after installing, to have it work them out and write them down:

```text
Inspect this project's tooling and add a "Testing" section to CLAUDE.md with the
exact commands to: run the full test suite, run a single test file or test by
name, build/typecheck, and run mutation testing (MUTATE_FILES="<paths>" mise run
mutation if configured). Only list commands you have verified exist in this repo.
```

## The skills

### TDD

| Skill | Role |
| --- | --- |
| **`tdd-loop`** | Orchestrator. Drives red → green slice by slice, in batches of five, with a refactor pass and a mutation pass closing each batch. |
| **`tdd-red`** | Writes one failing test and proves it fails for the *right* reason. Edits test files only. |
| **`tdd-green`** | Makes the suite pass with the smallest source change (Transformation Priority Premise). Edits source only. |
| **`tdd-refactor`** | Improves the design of working code without changing behaviour or any assertion. |

The phases run in **isolated sub-agents**. Red hands green two artifacts — the test file and the verbatim runner transcript — and nothing else: a prose summary would smuggle in an imagined implementation, and that coupling is exactly what TDD exists to prevent.

Each phase ends on a checkpoint commit, so the run can be reviewed one step at a time. `tdd-loop` stops at every batch boundary and waits for you.

### Craft review

**`craft-review`** reviews a diff through five lenses, each in its own parallel sub-agent:

- **Domain-Driven Design** — is this the right model?
- **Code Smells** — is the structure decaying? *(Fowler, Refactoring 2nd ed.)*
- **Clean Code** — is it readable at the line? *(Martin, Clean Code)*
- **Pragmatic Programmer** — is it built deliberately and kept flexible? *(Hunt & Thomas)*
- **Philosophy of Software Design** — is complexity leaking in? *(Ousterhout)*

The lenses stay separate on purpose. A clean bill on one must not mask a failure on another, and overlapping findings (primitive obsession, Law of Demeter) must not be deduped away. Findings are reported per lens with no cross-lens reranking.

Run it with `/craft-review [fixed-point]` — a SHA, branch, tag, or `main`. With no argument it reviews everything not on `main` plus uncommitted work.

## How they fit together

```
tdd-loop
  │
  ├── per slice:  tdd-red ──artifacts──▶ tdd-green ──▶ commit
  │
  └── per batch:  /craft-review ──findings──▶ tdd-refactor ──▶ commit
                  mutation pass ──survivors──▶ characterization tests
```

`craft-review` is user-invoked, so `tdd-loop` can't start it — it asks you to run `/craft-review` and feeds the aggregated findings into the refactor pass as its mandate.

## Repository layout

```
.claude/skills/
  tdd-loop/SKILL.md
  tdd-red/SKILL.md
  tdd-green/SKILL.md
  tdd-refactor/SKILL.md
  craft-review/
    SKILL.md
    ddd.md  smells.md  clean-code.md  pragmatic.md  philosophy.md
```

The `craft-review` reference files are per-lens checklists, each loaded into a fresh sub-agent context by absolute path.
