# claude-skills

A small collection of [Claude Code](https://claude.com/claude-code) skills for disciplined, test-driven development, deep code review, and convention-following commits.

Skills are prose instruction sets Claude loads on demand. These two families interlock: the TDD loop builds a feature one behaviour at a time, and the craft review supplies the findings that drive each refactor pass.

## Installing

Run one command from the directory you want the skills in. It downloads the latest archive from GitHub, shows a checklist of skill groups (`tdd`, `craft-review`, `commit`) — arrow keys move, space selects, enter confirms — and drops the chosen skills into `./.claude/skills/`.

**Linux / macOS**

```sh
curl -fsSL https://raw.githubusercontent.com/sbradl/claude-skills/main/install.sh | sh
```

**Windows (PowerShell)**

```powershell
irm https://raw.githubusercontent.com/sbradl/claude-skills/main/install.ps1 | iex
```

For an all-projects install, run it from your home directory so the skills land in `~/.claude/skills/`.

To skip the checklist, name the groups to install:

```sh
curl -fsSL https://raw.githubusercontent.com/sbradl/claude-skills/main/install.sh | sh -s -- tdd
```

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/sbradl/claude-skills/main/install.ps1))) tdd
```

`tdd-loop` feeds on `craft-review`'s findings, so install both groups to run the full loop. The update scripts take the same arguments.

Claude picks a skill up automatically when the task matches its description, or you can invoke one directly with `/tdd-loop`, `/craft-review`, and so on.

## Updating

Run one command from the directory you installed into. It fetches the latest archive and replaces every skill in `./.claude/skills/`, leaving the rest of `./.claude/` alone. See [`news.md`](news.md) for what changed.

**Linux / macOS**

```sh
curl -fsSL https://raw.githubusercontent.com/sbradl/claude-skills/main/update.sh | sh
```

**Windows (PowerShell)**

```powershell
irm https://raw.githubusercontent.com/sbradl/claude-skills/main/update.ps1 | iex
```

## Configure your project

Put your project's **test, build, coverage, and mutation-testing commands in the project's `CLAUDE.md`** (and how to run a single test, and coverage scoped to one file). The TDD skills run the suite on every red and green phase, check per-file coverage in the green audit, and run mutation testing at each batch boundary — without those commands recorded, each phase re-discovers them by searching the repo. A few lines in `CLAUDE.md` remove that overhead for the whole loop.

Paste this prompt into Claude Code once, after installing, to have it work them out and write them down:

```text
Inspect this project's tooling and add a "Testing" section to CLAUDE.md with the
exact commands to: run the full test suite, run a single test file or test by
name, build/typecheck, report test coverage for a single file, and run mutation
testing. Only list commands you have verified exist in this repo.
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

### Commit

**`commit`** turns your changes into commits that follow the project's convention. The first time it runs in a project it asks four questions and records the answers in `.claude/commit.md`:

- **Style** — Conventional Commits, Gitmoji, or plain imperative subjects
- **Body** — always, only when the reason isn't obvious, or never
- **Granularity** — one commit per logical change, or one for everything
- **Issue references** — required, added when the branch name carries one, or never

It can also keep a changelog, `CHANGELOG.json`, written for the **audiences** you pick during setup — end users, developers, operators, plugin authors, whoever reads it. Setup drafts a short brief for each audience it spots in the repo (who they are, what they notice, what never reaches them, which categories they get); you pick, correct, or describe your own, then choose the languages to translate into. Every commit is measured against each brief, so one change can get an entry for several audiences, each in their own words. One JSON file holds every audience's entries with all translations side by side — a single source of truth you edit in one place and can generate Markdown, HTML, or release notes from. Entries land in an **Upcoming** section in the same commit as the change. Versions come from your release tags: setup reads the tag format from the repo (and asks when there are none or several). The first commit after you tag a release moves the Upcoming entries under that version.

Edit the file or add house rules (they override the style) at any time. Move it to `~/.claude/commit.md` to use it for every project without its own, or delete it to be asked again. Updates leave it alone.

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
skills/
  tdd/
    tdd-loop/SKILL.md
    tdd-red/SKILL.md
    tdd-green/SKILL.md
    tdd-refactor/SKILL.md
  craft-review/
    craft-review/
      SKILL.md
      ddd.md  smells.md  clean-code.md  pragmatic.md  philosophy.md
  commit/
    commit/
      SKILL.md  setup.md  changelog.md
      styles/conventional.md  gitmoji.md  plain.md
.claude/skills/   symlinks into skills/, so the skills load while working on this repo
```

Skills are grouped by family under `skills/`; installing flattens the groups into `./.claude/skills/`, since Claude Code only discovers skills one level deep.

The `craft-review` reference files are per-lens checklists, each loaded into a fresh sub-agent context by absolute path.
