# claude-skills

[Claude Code](https://claude.com/claude-code) skills for building features end to end, test-driven development, deep code review, convention-following commits and releases, and project engineering rules.

## Skills

| Skill | What it does | Group | Starts |
| --- | --- | --- | --- |
| **`build-feature`** | Builds a feature end to end: requirements, tests, and design, each approved by you, then one sub-agent per slice and a closing report | `feature` | `/build-feature` only |
| **`tdd-loop`** | Builds a feature or fixes a bug test-first: red → green one behaviour at a time, with a refactor and a mutation-testing pass after every five | `tdd` | automatically, or `/tdd-loop` |
| **`tdd-red`** | Writes one failing test and proves it fails for the right reason | `tdd` | automatically, or `/tdd-red` |
| **`tdd-green`** | Makes a failing test pass with the smallest source change | `tdd` | automatically, or `/tdd-green` |
| **`tdd-refactor`** | Improves the design of working code without changing behaviour | `tdd` | automatically, or `/tdd-refactor` |
| **`craft-review`** | Reviews a diff through five lenses — DDD, code smells, Clean Code, Pragmatic Programmer, Philosophy of Software Design — each in its own sub-agent | `craft-review` | `/craft-review` only |
| **`commit`** | Commits in your project's convention, keeps a translated changelog per audience, and cuts releases | `commit` | automatically, or `/commit` |
| **`engineering-rules`** | Sets up the checks your code must pass — static analysis, security scanning, testing strategy, hooks and CI, accessibility, performance budgets, logging conventions | `engineering` | `/engineering-rules` only |

*Automatically* means Claude starts the skill when your request matches it. The group is what you pick when installing. `tdd-loop` feeds on `craft-review`'s findings, so install both groups to run the full loop. Details on each skill are [below](#skill-details).

## Installing

Run one command from the directory you want the skills in. It downloads the latest archive from GitHub, shows a checklist of skill groups (`feature`, `tdd`, `craft-review`, `commit`, `engineering`) — arrow keys move, space selects, enter confirms — and drops the chosen skills into `./.claude/skills/`.

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

The update scripts take the same arguments.

## Updating

Run one command from the directory you installed into. It fetches the latest archive and replaces the skills of every group you have installed — a group gains skills added to it since, and files removed from a skill don't linger. Groups you never installed stay out, and the rest of `./.claude/` is left alone. Name groups to update only those, or to add one. See [`CHANGELOG.md`](CHANGELOG.md) for what changed.

**Linux / macOS**

```sh
curl -fsSL https://raw.githubusercontent.com/sbradl/claude-skills/main/update.sh | sh
```

**Windows (PowerShell)**

```powershell
irm https://raw.githubusercontent.com/sbradl/claude-skills/main/update.ps1 | iex
```

## Setting up a project

What each skill needs before it works, and when you set it up:

| Skill | Needs | Set up |
| --- | --- | --- |
| `build-feature` | the `commit` and `engineering` groups, a commit convention, and a rulebook | once per project — run `/engineering-rules` and `/commit` first; the first `/build-feature` checks both, asks how features are built here, and records it in `.claude/build-feature.md` |
| `tdd-*` | `test`, `coverage`, and `mutation` tasks | once per project, before the first loop — run `/engineering-rules` with the **Testing strategy** area |
| `commit` | the project's commit convention | nothing to do — the first commit asks and records it in `.claude/commit.md` |
| `engineering-rules` | — | it is the setup; run it once, and again to revisit an area |
| `craft-review` | — | nothing |

**TDD.** The phases run single tests, check per-file coverage, and mutate the files each batch changed. `/engineering-rules` creates the tasks for that — `test [filter]`, `coverage <file>`, and a `mutation` task that honours `MUTATE_FILES` — and writes them into the project's `CLAUDE.md` for you. Pick mise as its task runner: `tdd-loop` calls `MUTATE_FILES="<paths>" mise run mutation`.

Without `engineering-rules`, record the commands in `CLAUDE.md` instead and add the mise `mutation` task yourself. Paste this prompt into Claude Code once to have it do both:

```text
Inspect this project's tooling and add a "Testing" section to CLAUDE.md with the
exact commands to: run the full test suite, run a single test file or test by
name, build/typecheck, and report test coverage for a single file. Only list
commands you have verified exist in this repo. Then add a `mutation` task to
mise.toml that runs mutation testing on only the files listed in the
MUTATE_FILES environment variable.
```

## Skill details

### Build feature

**`build-feature`** takes a feature from a ticket, a spec section, or a few words to green, pushed code. You approve three **gates**; everything between them runs on its own:

1. **Requirements** — gathered from your spec, tickets, glossary, and ADRs, each with a one-line summary and how it gets tested: acceptance tests by default, or a mix with unit, e2e, and benchmark tests; mutation testing and fuzzing per requirement. Facts no document holds are researched, or you answer them.
2. **Tests** — Gherkin scenarios and test names for every requirement, the assumptions to decide, and every user-visible text.
3. **Design and slices** — a short feature design (names, not shapes, at most 150 lines), then vertical slices of at most six acceptance and e2e tests each.

Each slice is built test-first by its own sub-agent, then a fresh reviewer checks that every test keeps the promise of its name. When a check fails on a rule you haven't settled, you decide: loosen it, or keep it — and a kept rule is final, fixed without asking from then on. At the end, the checks you reserved for it run once, the checkpoints are squashed through `commit` and pushed, CI is watched (GitHub, Gitea, or Jenkins), a PR is opened if you use them, and a report shows what was built and what to try by hand.

### TDD

| Skill | Role |
| --- | --- |
| **`tdd-loop`** | Orchestrator. Drives red → green slice by slice, in batches of five, with a refactor pass and a mutation pass closing each batch. |
| **`tdd-red`** | Writes one failing test and proves it fails for the *right* reason. Edits test files only. |
| **`tdd-green`** | Makes the suite pass with the smallest source change (Transformation Priority Premise). Edits source only. |
| **`tdd-refactor`** | Improves the design of working code without changing behaviour or any assertion. |

The TDD family and the craft review interlock: the loop builds a feature one behaviour at a time, and the craft review supplies the findings that drive each refactor pass.

Red and green run in **isolated sub-agents**; refactor runs in the main conversation, since it needs you to drive `/craft-review`. Red hands green two artifacts — the test file and the verbatim runner transcript — and nothing else: a prose summary would smuggle in an imagined implementation, and that coupling is exactly what TDD exists to prevent.

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

**`commit`** turns your changes into commits that follow the project's convention. The first time it runs in a project it sets up the convention and records it in `.claude/commit.md` — five questions on the messages, each option previewed as an example commit, then the changelog questions below:

- **Style** — how the subject line looks:

  | Style | Example |
  | --- | --- |
  | Conventional Commits | `feat(auth): add password reset via email` |
  | Gitmoji | `✨ Add password reset via email` |
  | Plain | `Add password reset via email` |

- **Body** — always, only when the reason isn't obvious, or never
- **Granularity** — one commit per logical change, or one for everything; either way it asks before putting several changes into one commit
- **Issue references** — required, added when the branch name carries one, or never
- **Attribution** — keep Claude's `Co-Authored-By` trailer, or leave Claude attribution out

It can also keep a changelog, `CHANGELOG.json`, written for the **audiences** you pick during setup — end users, developers, operators, plugin authors, whoever reads it. Setup drafts a short brief for each audience it spots in the repo (who they are, what they notice, what never reaches them, which categories they get); you pick, correct, or describe your own, then choose the languages to translate into. Every commit is measured against each brief, so one change can get an entry for several audiences, each in their own words. One JSON file holds every audience's entries with all translations side by side — a single source of truth you edit in one place and can generate Markdown, HTML, or release notes from. Entries land in an **Upcoming** section in the same commit as the change. Versions come from your release tags: setup reads the tag format from the repo (and asks when there are none or several). Ask it to **release** and it proposes the next version from what Upcoming holds (breaking or removed → major, added → minor, else patch), then makes one release commit that moves Upcoming under that version, tags it, and pushes both — or runs your project's own release task when there is one. A tag made elsewhere gets its entries filed on the next commit.

Edit the file or add house rules (they override every rule of the skill) at any time. Move it to `~/.claude/commit.md` to use it for every project without its own, or delete it to be asked again. Updates leave it alone.

### Engineering rules

**`engineering-rules`** sets up the checks your code must pass. Run it with `/engineering-rules`. It detects your stacks (e.g. .NET with xUnit, TypeScript with Vitest) and lets you confirm them, then works through each area you pick:

- **Static analysis and linting** — linters, formatters, type strictness, complexity and duplication, architecture rules, dead code, API spec linting
- **Security analysis** — SAST (e.g. Opengrep), dependency vulnerabilities, license compliance, SBOM, infrastructure and container image scanning (e.g. Trivy), secret scanning (e.g. Gitleaks), DAST (e.g. ZAP)
- **Testing strategy** — unit test framework and naming, coverage and mutation thresholds, property-based tests, fuzzing, acceptance tests in Gherkin, in code, or both, end-to-end tests with page objects, contract tests
- **Enforcement** — which checks run in pre-commit and pre-push hooks and in CI (GitHub Actions, Gitea Actions, GitLab CI, Azure Pipelines, Jenkins), SARIF upload to code scanning, automated dependency updates
- **Accessibility** — accessibility lint rules and runtime WCAG checks for UI stacks
- **Performance budgets** — page scores, bundle size, benchmarks, hardware-independent instruction-count benchmarks, load tests
- **Logging and observability** — structured logging, tracing, log levels, and the lint rules that enforce them

For each area a research sub-agent per stack finds freely usable tools. You pick tools first, then each tool's ruleset — the strictest is recommended. The skill installs and configures them, runs each once, and records everything in `.claude/engineering-rules.md` for agents to follow. Every check becomes a task — in mise when the project uses it (the skill offers to set mise up when it doesn't), otherwise in the stack's own runner — grouped under one task per area (`lint`, `security`, `test`, …). The Enforcement area adds a `check` task that runs them all, and the hooks and CI that run it.

## How they fit together

```
tdd-loop
  │
  ├── per slice:  tdd-red ──▶ commit ──artifacts──▶ tdd-green ──▶ commit
  │
  └── per batch:  /craft-review ──findings──▶ tdd-refactor ──▶ commit
                  mutation pass ──survivors──▶ in batch code:  fixed in the loop (revert, or a new slice)
                                               in older code:  characterization test
```

`craft-review` is user-invoked, so `tdd-loop` can't start it — it asks you to run `/craft-review` and feeds the aggregated findings into the refactor pass as its mandate.

## Repository layout

```
skills/
  feature/
    build-feature/
      SKILL.md  setup.md  check-coverage.sh
      briefs/tests.md  design.md  slice.md  test-review.md
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
  engineering/
    engineering-rules/
      SKILL.md  research.md
      areas/static-analysis.md  security.md  testing.md  enforcement.md
            accessibility.md  performance.md  observability.md
.claude/skills/        symlinks into skills/, so the skills load while working on this repo
install.sh  install.ps1  update.sh  update.ps1
CHANGELOG.json         the changelog's source of truth
CHANGELOG.md           generated from it by scripts/changelog.sh
scripts/release.sh     cuts a release: release commit, tag, push
.githooks/pre-commit   regenerates CHANGELOG.md when CHANGELOG.json is staged
.github/workflows/     publishes a GitHub release for each version tag
mise.toml              pins jq and gh; tasks setup, changelog, release
```

Skills are grouped by family under `skills/`; installing flattens the groups into `./.claude/skills/`, since Claude Code only discovers skills one level deep.

The `craft-review` reference files are per-lens checklists, each loaded into a fresh sub-agent context by absolute path.

## Working on this repo

Run `mise run setup` once per clone: it installs `jq` and `gh` and enables the pre-commit hook. Record changes in `CHANGELOG.json`, never `CHANGELOG.md`. Release with `mise run release v<major>.<minor>.<patch>`.
