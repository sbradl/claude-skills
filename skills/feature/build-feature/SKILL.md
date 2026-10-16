---
name: build-feature
description: Build a feature end to end — requirements and design approved at gates, then one slice per requirement, each with its own test gate and build sub-agent, and a feature report.
disable-model-invocation: true
---

# Build a feature

The user names a feature (a ticket, a spec section, or a few words). Take it from agreed requirements to green code. The user owns the **gates** — requirements, design and build order, one test gate per slice, and the review of the finished product; everything between them is yours.

- **Gate** — present the artefact, stop, wait for explicit approval. Feedback reworks the artefact and the gate repeats. An approved artefact changes only through its gate; mid-build, that is a **mini-gate** showing only the change.
- **Requirement question** — anything about what the feature does — what the user sees, can do, or gets back — that no approved requirement states. Never assume one: ask it alone, a single-select with your recommendation and one line of why, never inside a list and never as a default to veto. The answer goes into the requirement's source and its block in `design.md`, as a checkpoint. Sub-agents report requirement questions; they never answer them.
- **Evidence** — a requirement question cites what shows its case occurs: a research file, a spec line, a real sample. A case nothing shows is an **unseen case**, never asked on its own: it falls under the feature's requirement for unexpected input (a damaged file gets a clear error) — none yet → that rule is one requirement question, asked once. Name the unseen cases in one line, so the user can raise one.
- **Technical choice** — how the feature is built. A real trade-off goes to the user one at a time, with a recommendation; the rest are the design's key decisions, reviewed with it.
- **Approval** covers what was shown and answered — never an assumption.
- **Plain names** — in every question, summary, and line to the user, name a requirement by what it says and a step by what it does: "opens GPX files", "the test gate". An id or step number may follow in parentheses, never stand alone — the user knows the feature, not your numbering.
- **Checkpoint** — stage the paths the work changed (`git add <paths>`, never `git add -A`: build output and other people's files stay out), then `git commit -m "checkpoint: <what>"` whenever work reaches a state worth keeping: a reworked artefact, an approved gate, a green test. A task run that leaves untracked output the repository does not ignore → add the ignore rule first. Checkpoints stay local; the close step squashes and pushes them.
- **Open rule** — a rulebook rule with no final decision. Violated → stop and ask: loosen it (the new value goes into the tool's config; the rule stays open), keep it (it becomes **final**), or suppress it at this one site with a comment giving the reason. Final rules are fixed, never suppressed.
- **Slice** — one requirement, built end to end: its test gate, then its build.
- **Walking skeleton** — the thinnest end-to-end path through every stack and boundary the architecture has (UI, bridges, core, storage, packaging): built, tested at the rulebook's levels, run by CI, and doing one trivial thing a user can see. The first feature in a project builds only the skeleton, so the first real feature only adds behaviour.
- **Fix slice** — a slice added to repair a defect: a `FIX-<n>` entry under `## Requirements` and in the build order, its test gate showing the regression test, then step 3 as for any slice.

Resolve `<skill-dir>` to this skill folder's absolute path. Read `<repo-root>/.claude/build-feature.md` (the **config**); missing → follow `<skill-dir>/setup.md`, then continue here. The **rulebook** is `<repo-root>/.claude/engineering-rules.md`.

A `Walking skeleton:` or `Review:` line missing from the config → ask `setup.md`'s question for it and record the answer. It says `needed` → tell the user the skeleton comes first, and build it as its own feature, `walking-skeleton`, through steps 1–6: its requirements are those that apply to every feature — platforms, boundaries, build, CI, packaging — plus the one thing it shows, asked as a requirement question. Then set `Walking skeleton: done` in the config and start the named feature. Its requirements the skeleton already meets show in its overview as met by the skeleton and stay out of scope.

Record every rule decision in the rulebook's `## Rule decisions` section, one row per rule, updated in place — create it on the first decision:

```markdown
| Rule | Tool | Setting | Final | Date | Reason |
| --- | --- | --- | --- | --- | --- |
```

Note `HEAD` as the feature's **base** before the first checkpoint. With `Integration: branch`, first create a branch named after the ticket (its id and slug), so `commit` finds the issue reference.

The feature's folder, `<feature-dir>`, is where `docs/agents/issue-tracker.md` (or the config) puts it. `<feature-dir>/design.md` holds the working state: requirements, texts, risks, requirement questions, open points, slices.

Sub-agents are `general-purpose`. Each gets its brief, `<skill-dir>/briefs/<brief>.md`, by absolute path, plus `<feature-dir>` and the inputs its step names. A sub-agent that stops for the user is resumed with `SendMessage` and the answer.

## 1. Requirements (gate 1)

Gather every requirement that applies to the feature from the config's requirement sources, including those that apply to every feature. Show an **overview**: a numbered list, one line per requirement — its id and a one-sentence summary — functional and non-functional (budgets, platforms, constraints) apart, then the related open points. Show no file names; the sources go into `design.md` only.

Then ask **which are out of scope**: multi-selects, four requirements per question, four questions per call; nothing ticked keeps them all. The free-text answer states changes to a requirement — each goes into its source first, as a checkpoint.

Then the **open facts** — facts the tests will rest on that no repo document holds (a file format's fields per version, real-world sizes, a platform's behaviour) — one at a time, each a single-select: `Research it` (only when the `mattpocock-skills:research` skill is available — a sub-agent (`general-purpose`, `model: sonnet`) following it writes `<feature-dir>/research/<fact>.md`), `I'll research it`, `I'll answer it` (record the answer in the same folder).

Write the in-scope requirements into `design.md` under `## Requirements`, one block each, in the format `briefs/tests.md` defines.

Done when the user has answered the scope questions, every open fact has a research file or a recorded answer, and the work is checkpointed.

## 2. Design and build order (gate 2)

A sub-agent with `briefs/design.md` writes the feature's design into `docs/design/<feature-slug>.md` and adds the design lines, risks, requirement questions, and open points to `design.md`. When a rulebook check reads the config's app-wide design doc (an architecture test), merge the parts it reads now; the rest waits for the close step.

Then write the **build order** — one slice per requirement, each depending only on earlier ones; a requirement whose e2e test needs another's platform piece comes after it:

```markdown
## Slices

1. REQ-12
2. REQ-13
```

Run `sh <skill-dir>/check-coverage.sh <feature-dir>/design.md` and checkpoint. Then, in this order:

1. Each requirement question the design raised, one at a time. An answer that changes the design → rework through the design sub-agent and checkpoint again.
2. Each technical trade-off, one at a time.
3. The gate: give the checkpoint's hash to review (`git show <hash>`). In chat, the design in at most five lines and the build order as its **phases** — each a run of slices, one line naming what it builds and why it comes there; the full order stays in the checkpoint. Then one single-select: `Approve design and build order` `(Recommended)` or `Change them`.

Done when every requirement maps to design elements, the script passes, every requirement question is answered, the user approves, and the work is checkpointed.

## 3. Slices

One at a time, in order. For each slice, note `HEAD` as its start, then:

1. **Choose the test levels.** Show the requirement, then one `AskUserQuestion` call:
   - **Test levels** — multi-select: `acceptance`, `unit`, `e2e`, `benchmark` (only when the rulebook has a benchmark tool). Recommend acceptance; add unit for logic over many variants (formats, rules, calculations), e2e for what needs the real UI, platform, or storage, benchmark for a performance budget.
   - **Fuzz** — only when the rulebook has a `fuzz` task: `On` or `Off`, recommending on when its code reads untrusted input (files, network, pasted data).

   More than one level picked → one single-select on **what goes where**: your proposed split `(Recommended)` — "acceptance: the main flows · unit: each format version" — the free-text answer states another. Record the answers in the requirement's `Levels:` line.
2. **Pick the tests.** A fresh **tests sub-agent** with `briefs/tests.md` gets the requirement. It stops first with any requirement question the requirement leaves open; ask each one alone, record the answer, and resume it with the answers. It stops again with its proposed tests. Ask them in **rounds**, one level at a time: multi-selects, four tests per question, four questions per call — label = the test's name, description = what it proves and, for a varied test, what varies (its examples, or the property every input keeps). A ticked test is in, an unticked one out; the free-text answer changes or adds tests. A level left with no picked test leaves the `Levels:` line. Resume the sub-agent with the picked tests; it writes them and their texts, and reports the slice's **test list** — each test's level, name, and file. Run `check-coverage.sh`.
3. **Review the tests — a gate: stop here.** Commit the tests and texts as a checkpoint (`checkpoint: <id> tests`) and give the user its hash to review (`git show <hash>`) — list no tests in chat. Then one single-select: `Approve the tests` `(Recommended)` or `Change them` — the free-text answer says what; rework through the tests sub-agent, commit the rework as a new checkpoint, and give its hash. Step 4 starts only after `Approve the tests`.
4. **Make them red.** Resume the tests sub-agent: it fills in every test and proves each one fails for the right reason. Check its report — every test's red failure line is its own assertion failing — and checkpoint (`checkpoint: <id> red`).
5. **Review the tests, before any code.** Run the rulebook's `lint` task first and send its findings (line length, import order, naming) back to the tests sub-agent: the reviewer judges what a test promises, not what a linter can check. Then a fresh **test reviewer** with `briefs/test-review.md` gets the test list and `git diff <slice start>..HEAD` of the tests and test helpers. Resume the tests sub-agent with the findings, checkpointing each round, until a review comes back clean. Note `HEAD` as the **reviewed tests**.
6. A fresh **slice sub-agent** (`model: sonnet`) with `briefs/slice.md` gets the requirement and its test list.
7. It stops for the user on a wrong or impossible test (a mini-gate shows the changed test and its requirement's lines), a requirement question (ask it alone), an open rule (record the decision), or an unavailable environment (ask the user to fix it). Resume it with the answer.
8. Check its report: every test of the requirement passes, `git diff <reviewed tests>..HEAD` of the test files changes nothing but removed skips and tags and what a mini-gate approved, `@wip` is gone from exactly its Gherkin scenarios and no `wip` skip is left in its stubs, each named test exists in the file it reports, every check the config maps to `slice done` is green, and `git status` is clean. Mark the slice done: append ` ✓` to its line in the build order.
9. Tell the user one line: `Slice 2/5 done — opens GPX files (REQ-13): 2 acceptance, 3 unit green; review clean.`

Done when, for every slice, the user approved its tests, each test failed for the right reason, its test review is clean, and its report checks out.

## 4. Feature checks

Run every check the config maps to `feature end`; the rulebook's `mutation` task, when it has one, with `MUTATE_FILES` set to the source files the feature changed (`git diff --name-only <base>..HEAD`, tests left out); and `fuzz <target>` for each fuzz target the slices reported, until coverage plateaus or the rulebook's time budget per target runs out. A crash or hang: save the input as a seed, tell the user in one plain line which input broke what, and make it a fix slice with that input as its regression test. Each surviving mutant goes to the user alone, in plain words — what was changed, where, and that no test noticed: `Add a test` `(Recommended)` makes it a fix slice; `Equivalent` — the change alters nothing observable — goes into the report. A violated open rule goes to the user; a violated final rule or a defect (a crash, a failing test) becomes a fix slice; an unavailable environment goes to the user to fix, then the check reruns. Done when every check passes.

## 5. Product review (gate)

The user reviews the real product before anything is pushed. Build it and start it the way the config's `Review:` line says — on this machine when it runs here, otherwise hand the user the steps (install on the device). Then give **what to try** — 3–5 flows as actions with the expected result, in plain words: the feature's user-facing behaviour first, flows touched by several slices, and what no e2e test proves; a feature without a UI gets the command or call that shows its outcome. Stop, then one single-select: `It works` `(Recommended)` or `Found a problem` — the free-text answer says what.

A defect becomes a fix slice; a change to what the feature does is a requirement change through gate 1's mini-gate, then a slice. Then the review repeats. Done when the user answers `It works`.

## 6. Close

1. **Report** — build it now, while `design.md` exists; show it last:
   - the requirements and fixes, each with its tests, ticked ✓ once its slice is done;
   - feature-check results — for budgets, measured against the limit;
   - the changes to the app-wide design doc as bullets, new or changed glossary terms with their definitions, new ADRs by number and title;
   - new open points;
2. **Merge** the feature design's "Merge into …" section into the config's app-wide design doc. Merge what the finished code does and what the requirement sources say; a sentence that promises a later feature or contradicts a source stays out (it is an open point).
3. **Delete** `design.md` and the research files; delete `docs/design/<feature-slug>.md` when the config names an app-wide design doc.
4. **Open points** — list them; one multi-select picks which become tickets, filed as `docs/agents/issue-tracker.md` defines.
5. **Ticket** — resolve it and update its map as `issue-tracker.md` defines. Started from free text → skip. The feature covers it only in part → ask: resolve, or leave open with a comment on what is done.
6. **Squash** — `git reset --soft <base>`, then invoke the `commit` skill. Push to `main` or the feature branch, per the config.
7. **CI** — run the config's CI-watch command with `SHA` set to the pushed commit; `none` → ask the user. Red → fix slice, then squash since the last push and push again.
8. **PR** — `Integration: branch` with a PR tool: open the PR (`gh pr create` or `tea pr create`), the body a short what and why, written with the `mattpocock-skills:pr` skill when available. `PR: none` → tell the user the branch is ready to merge.
9. Show the report.

## Done

The user confirmed the real product works, CI is green on the last pushed commit (with a PR tool: the PR is open), the ticket is resolved, the feature's working files are deleted, and the report has been shown.
