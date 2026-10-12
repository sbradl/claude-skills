---
name: engineering-rules
description: Set up a project's engineering rules — static analysis, security, testing strategy, enforcement, accessibility, performance budgets, observability — by asking what the checks must catch, researching free tools per stack, and recommending the smallest tool set, then its rulesets.
disable-model-invocation: true
---

# Engineering rules

Sets up the checks a project's code must pass and records them in `<repo-root>/.claude/engineering-rules.md` — the **rulebook** agents and skills read to know which checks gate a change. Each **area** is a file in `<skill-dir>/areas/`; its `#` heading is its name, its first paragraph says what it covers.

Resolve `<skill-dir>` to this skill folder's absolute path.

## 1. Load the rulebook

Exists → read it, then ask (multi-select) which of its areas to revisit and whether to add areas it lacks; everything else stays as recorded. Missing → start fresh.

## 2. Pin the stacks

A **stack** is one language and its toolchain in one part of the repo: language and version, framework, test runner, package manager, path, and whether it has a UI or serves HTTP. Detect them from manifests — `*.sln`/`*.csproj`/`global.json`, `package.json` with its lockfile and `tsconfig.json` (test runner from `devDependencies`), `pyproject.toml`, `go.mod`, `Cargo.toml`, `pom.xml`/`build.gradle*`. Infrastructure the repo ships — `Dockerfile`, Compose files, `*.tf`, Helm charts, Kubernetes manifests — is a stack too; the security area scans it.

Ask one multi-select question: one option per detected stack, labelled like `dotnet 9 · xunit · src/Api`, the description naming the evidence file. The free-text answer adds or corrects a stack. Nothing detected → ask for the stacks in plain chat.

## 3. Pin the task runner

Every check runs as a **task** — one per tool, plus one per area that runs all of the area's tool tasks.

- The repo uses mise (`mise.toml`, `.mise.toml`, `.config/mise.toml`, `mise/config.toml`, or `.tool-versions`) → mise.
- Otherwise ask one single-select question: **Set up mise** `(Recommended)` — one runner for every stack, pins standalone tools like Trivy and Gitleaks, gives every developer the same versions — or **Use the stacks' own runners** (`package.json` scripts, a `Makefile`).

## 4. Pin the constraints

Every recommended tool must satisfy them. Recorded → keep them. Otherwise two multi-select questions:

- **Developer platforms** — Linux, macOS, Windows; this machine's marked `(Recommended)`. A tool missing one runs in CI only, or is replaced.
- **Allowed runtimes** — Docker, JVM, Python, Node; the stacks' own runtimes are always allowed. A tool needing another is not recommended.

## 5. Pick the areas and outcomes

Fresh start → multi-select, one option per file in `<skill-dir>/areas/`: label = its heading, description = its first paragraph; four options per question, as many questions as the areas need. Revisit → step 1's answer is the pick.

Per picked area, first its **Before research** questions, if it has them. Then one multi-select over its **outcomes** — what the checks must catch — leaving out those that apply to no stack: label = the outcome, description = its text without the tool names, plus "on" for outcomes the rulebook records. More than four outcomes → as many questions as they need.

## 6. Research

One message, one `Agent` call (`general-purpose`) per stack × area with a picked outcome that applies to the stack — all in parallel. Each prompt carries:

- "Read `<skill-dir>/research.md` and follow it."
- the stack, with every field from step 2;
- the constraints;
- the area's name and its picked outcomes, verbatim from the area file — plus any research a Before research answer adds.

The reports are the tool catalogue; recommend tools only from them.

## 7. Recommend the tool set

Build the smallest set that covers every picked outcome on every stack it applies to. Per outcome and stack, choose from the reports' candidates that meet the constraints, in this order: `official`, then `de facto standard`, then the rest; within a tier, a tool already in the set — installed, or chosen for another row — or covering more outcomes and stacks. Tools the rulebook records stay in their rows, marked `installed`; two installed tools checking the same thing get "overlaps row N".

Print the set as a numbered table — `#`, outcome, stacks, tool, why (its convention and what else it covers) — then one single-select question: **Accept the set** `(Recommended)` or **Change rows**, naming the rows in the free-text answer. Per named row, one single-select: the chosen tool `(Recommended)` and up to three alternatives from the reports, each option's `preview` holding its comparison — convention, strengths, weak spots, adoption, speed, license, latest release. Rebuild the set after the swaps, merging rows a swapped-in tool also covers, and ask again until the set is accepted.

## 8. Run each area

Areas run in the order picked — except an area whose file says it runs last. Read `<skill-dir>/areas/<area>.md` and follow it: its **Rulesets** and its **Questions**.

**Rulesets.** For each tool in the set whose report lists two or more rulesets — presets, rule packs, severity thresholds, score thresholds: one single-select question, strictest first and marked `(Recommended)`, each option's `preview` stating what it adds over the next-looser ruleset. The area file may rank an outcome differently; it says so. Tools with a single ruleset, and installed tools, skip this. Pack four questions per call.

## 9. Record

Write the rulebook; on revisit, replace only the revisited areas' sections. Leave `## Rule decisions` as it is — `build-feature` records there whether the user loosened or kept a rule.

```markdown
# Engineering rules

Task runner: <mise | the stacks' own runners>
Developer platforms: <Linux, macOS, Windows>
Allowed runtimes: <Docker, JVM, Python, Node>

## Stacks

- **<stack key>** — <language and version> · <framework> · <test runner> · <package manager> · `<path>`

## <Area heading>

Outcomes: <the picked outcomes>

<the area file's record section, filled in>
```

## 10. Apply

**Mise** — chosen in step 3 but not yet in the repo → create `mise.toml` with the stacks' runtimes in `[tools]` and a `setup` task running `mise install`, then run `mise trust` and `mise install`.

For each tool in the set, from its report — the area file's Apply section overrides these steps where it differs:

1. **Install** — dev dependency of its stack; a standalone binary goes in mise's `[tools]`, pinned to the reported version, or — without mise — gets its install command recorded in the rulebook.
2. **Configure** — write its config with the picked ruleset.
3. **Wire** — a task per tool, named `<area task>:<tool>` (`lint:eslint`, `security:trivy`), and the area's task depending on all of them. An area naming several tasks (testing: `test`, `mutation`, …) puts each tool under the task it serves. In mise: `[tasks."lint:eslint"]` entries and `[tasks.lint] depends = [...]`. Without mise: the same names in the stack's runner. Each task checks without modifying files and exits non-zero on any finding.
4. **Remove** — an installed tool swapped out in step 7: delete its task, config, and dev dependency or `[tools]` entry.
5. **Run** each area task once. Findings in existing code are expected under the strictest rulesets: report the count per tool and fix nothing. A tool with baseline support → offer to record a baseline so only new findings fail. A task that needs a running app it cannot start itself → report it as not run, and what it needs.

Leave everything uncommitted for the user to review.

## Done

The rulebook names the task runner and the constraints, lists the confirmed stacks, and has a section per picked area with its outcomes; every picked outcome is covered on every stack it applies to by a tool in the accepted set; every tool in the set is installed, configured with its picked ruleset, wired as its own task under its area's task, and run once with its finding count reported — or reported as not run with what it needs; every installed tool swapped out is gone from the repo.
