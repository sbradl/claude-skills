---
name: build-feature
description: Build a feature end to end — requirements, tests, and design, each approved at a gate, then one sub-agent per slice and a feature report.
disable-model-invocation: true
---

# Build a feature

The user names a feature (a ticket, a spec section, or a few words). Take it from agreed requirements to green code. The user owns three **gates**; everything between them is yours.

- **Gate** — present the artefact, stop, wait for explicit approval. Feedback reworks the artefact and the gate repeats. An approved artefact changes only through its gate; mid-build, that is a **mini-gate** showing only the change.
- **Decisions** — at a gate, a real trade-off goes to the user one at a time, with a recommendation; obvious defaults go as one list to veto.
- **Checkpoint** — `git commit -m "checkpoint: <what>"` whenever work reaches a state worth keeping: a reworked artefact, an approved gate, a green test. Checkpoints stay local; the close step squashes and pushes them.
- **Open rule** — a rulebook rule with no final decision. Violated → stop and ask: loosen it (the new value goes into the tool's config; the rule stays open), keep it (it becomes **final**), or suppress it at this one site with a comment giving the reason. Final rules are fixed, never suppressed.
- **Fix slice** — a slice added to repair a defect: a mini-gate shows its regression test and slice entry, then it runs through step 4.

Resolve `<skill-dir>` to this skill folder's absolute path. Read `<repo-root>/.claude/build-feature.md` (the **config**); missing → follow `<skill-dir>/setup.md`, then continue here. The **rulebook** is `<repo-root>/.claude/engineering-rules.md`.

Record every rule decision in the rulebook's `## Rule decisions` section, one row per rule, updated in place — create it on the first decision:

```markdown
| Rule | Tool | Setting | Final | Date | Reason |
| --- | --- | --- | --- | --- | --- |
```

Note `HEAD` as the feature's **base** before the first checkpoint. With `Integration: branch`, first create a branch named after the ticket (its id and slug), so `commit` finds the issue reference.

The feature's folder, `<feature-dir>`, is where `docs/agents/issue-tracker.md` (or the config) puts it. `<feature-dir>/design.md` holds the working state: requirements, assumptions, texts, risks, open points, slices.

Sub-agents are `general-purpose`. Each gets its brief, `<skill-dir>/briefs/<brief>.md`, by absolute path, plus `<feature-dir>` and the inputs its step names. A sub-agent that stops for the user is resumed with `SendMessage` and the answer.

## 1. Requirements (gate 1)

Gather every requirement that applies to the feature from the config's requirement sources, including those that apply to every feature. Show an **overview**: a numbered list, one line per requirement — its id and a one-sentence summary — functional and non-functional (budgets, platforms, constraints) apart, then the related open points. Show no file names; the sources go into `design.md` only.

Then **walk** the requirements, one at a time: show its id and what it demands, then one `AskUserQuestion` call.

- **In scope** — `Yes`, `Change it` (the free-text answer states the change; it goes into the requirement's source first, as a checkpoint), `Drop it`.
- **Test levels** — multi-select: `acceptance`, `unit`, `e2e`, `benchmark` (only when the rulebook has a benchmark tool). Recommend acceptance; add unit for logic over many variants (formats, rules, calculations), e2e for what needs the real UI, platform, or storage, benchmark for a performance budget.
- **Mutation** — only when the rulebook has a `mutation` task: `On` or `Off`, recommending on when the recommended levels include unit.
- **Fuzz** — only when the rulebook has a `fuzz` task: `On` or `Off`, recommending on when its code reads untrusted input (files, network, pasted data).

More than one level picked → one single-select on **what goes where**: your proposed split `(Recommended)` — "acceptance: the main flows · unit: each format version" — the free-text answer states another.

Then the **open facts** — facts the tests will rest on that no repo document holds (a file format's fields per version, real-world sizes, a platform's behaviour) — one at a time, each a single-select: `Research it` (only when the `mattpocock-skills:research` skill is available — a sub-agent following it writes `<feature-dir>/research/<fact>.md`), `I'll research it`, `I'll answer it` (record the answer in the same folder).

Last, a compact summary — per requirement its levels, split, and flags — for the user to confirm. Write the confirmed requirements into `design.md` under `## Requirements`, in the format `briefs/tests.md` defines.

Done when every requirement and open fact is answered, every open fact has a research file or a recorded answer, the user confirms the summary, and the work is checkpointed.

## 2. Tests (gate 2)

A sub-agent with `briefs/tests.md` gets the confirmed lists, the research files, and the decisions so far. It writes the Gherkin feature files and every other test's name, the assumptions, and the user-visible texts in the source language. Then run `sh <skill-dir>/check-coverage.sh <feature-dir>/design.md`.

Present the tests, the assumptions, and the texts. Done when every requirement has tests at each level of its split, the script passes, every assumption is decided, the user approves, and the work is checkpointed.

## 3. Design and slices (gate 3)

A sub-agent with `briefs/design.md` writes the feature's design into `docs/design/<feature-slug>.md` and adds the design lines, risks, and open points to `design.md`. When a rulebook check reads the config's app-wide design doc (an architecture test), merge the parts it reads now; the rest waits for the close step.

Then cut the feature into **vertical slices** in `design.md`:

- Each slice makes a named set of tests pass end to end, fits one sub-agent, and depends only on earlier slices. At most 6 acceptance and e2e tests; unit tests and benchmarks ride along with the requirement they serve.
- Every test belongs to exactly one slice. An e2e test tagged for several platforms belongs to the slice where it passes on all of them; an earlier slice may run it by name on one, in its prose, not its list.

```markdown
## Slices

### Slice 2: Open supported formats
- open-file: opens a v4 file; opens a v5 file.
- unit: reads v4 header; reads v5 header.
Runs by name: shows the song on desktop (slice 4 owns it).
```

A line lists one group — a feature file's stem, or `acceptance`, `e2e`, `unit`, `benchmark` for named tests — as `- <group>: <name>; <name>.`, or `- <stem>: all N.` for every scenario of a feature file.

Present design and slices together. Done when every requirement maps to design elements, `check-coverage.sh` passes, the user approves, and the work is checkpointed.

## 4. Slices

One at a time, in order. For each slice, note `HEAD` as its start, then:

1. A fresh **slice sub-agent** with `briefs/slice.md` gets the slice's name and its tests.
2. It stops for the user on a wrong or impossible test (a mini-gate shows the changed test and its requirement's lines), an open rule (record the decision), or an unavailable environment (ask the user to fix it). Resume it with the answer.
3. Check its report: every test in its entry passes, `@wip` is gone from exactly its Gherkin scenarios, each named test exists in the file it reports, every check the config maps to `slice done` is green, mutation is clean on the files it reports for requirements marked mutation-on, and `git status` is clean. Mark the slice done: append ` ✓` to its heading in `design.md`.
4. A fresh **test reviewer** with `briefs/test-review.md` gets the slice's test names and `git diff <slice start>..HEAD` of its tests and test helpers. Resume the slice sub-agent with the findings until a review comes back clean.
5. Tell the user one line: `Slice 2/5 done: 4 acceptance, 3 unit green; review clean.`

Done when every slice's report checks out and its test review is clean.

## 5. Feature checks

Run every check the config maps to `feature end`, and `fuzz <target>` until plateau for each fuzz target the slices reported. A violated open rule goes to the user; a violated final rule or a defect (a crash, a failing test) becomes a fix slice; an unavailable environment goes to the user to fix, then the check reruns. Done when every check passes.

## 6. Close

1. **Report** — build it now, while `design.md` exists; show it last:
   - the requirements, each test ticked ✓ — its slice is done;
   - feature-check results — for budgets, measured against the limit;
   - the changes to the app-wide design doc as bullets, new or changed glossary terms with their definitions, new ADRs by number and title;
   - new open points;
   - **what to try by hand** — 3–5 flows as actions with the expected result: user-facing, touched by several slices, or proven without e2e. None for a feature without user-facing behaviour.
2. **Merge** the feature design's "Merge into …" section into the config's app-wide design doc.
3. **Delete** `design.md` and the research files; delete `docs/design/<feature-slug>.md` when the config names an app-wide design doc.
4. **Open points** — list them; one multi-select picks which become tickets, filed as `docs/agents/issue-tracker.md` defines.
5. **Ticket** — resolve it and update its map as `issue-tracker.md` defines. Started from free text → skip. The feature covers it only in part → ask: resolve, or leave open with a comment on what is done.
6. **Squash** — `git reset --soft <base>`, then invoke the `commit` skill. Push to `main` or the feature branch, per the config.
7. **CI** — run the config's CI-watch command with `SHA` set to the pushed commit; `none` → ask the user. Red → fix slice, then squash since the last push and push again.
8. **PR** — `Integration: branch` with a PR tool: open the PR (`gh pr create` or `tea pr create`), the body a short what and why, written with the `mattpocock-skills:pr` skill when available. `PR: none` → tell the user the branch is ready to merge.
9. Show the report.

## Done

CI is green on the last pushed commit (with a PR tool: the PR is open), the ticket is resolved, the feature's working files are deleted, and the report has been shown.
