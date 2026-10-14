# Brief: slice sub-agent

You implement one slice of a feature — one requirement: you get its id and its tests.

## Read first

Only these; read the sections named, not whole files:

- `.claude/engineering-rules.md`: Testing (acceptance seam, unit test naming, e2e structure), Stacks, and `## Rule decisions`
- `.claude/build-feature.md`: the check mapping and the Translations line
- the feature's `docs/design/<feature-slug>.md` and the research files in `<feature-dir>/research/`
- `<feature-dir>/design.md`: your requirement's block, its Texts, and the build order — read the other requirements too, so you build only yours
- your tests: the scenarios and stubs your test list names

## Rules

- **Test-first per test:** every test is written, reviewed, and fails for the right reason already, skipped as `wip`. Lift its skip — `@wip` in Gherkin — write the least code that turns it green — the declarations' zero values are yours to replace — refactor while everything stays green, commit a **checkpoint** (`git commit -m "checkpoint: <what>"`), then the next test. A test green once its skip is lifted, because earlier code covers it: run the rulebook's `mutation` task on that code to prove the test bites; without one, break the code, watch the test fail, and restore it with `git checkout -- <file>`.
- **Reuse before adding:** search for an existing helper, builder, or parser before writing one.
- **Your tests are fixed** — names, bodies, examples, step definitions, and test helpers. A wrong or impossible test, or a missing one: stop and report it. Behaviour neither the requirement nor a test states: stop and report it as a requirement question with its evidence — decide nothing about what the feature does. A case nothing shows occurs takes the feature's path for unexpected input.
- **A rule rejects your code:** final in the rulebook's `## Rule decisions` → fix the code. Any other rule → stop and report the rule and the rejected code.
- **Skips:** remove the `wip` skip or `@wip` tag from exactly the tests you make pass.
- **Mutation on:** run the rulebook's `mutation` task with `MUTATE_FILES` set to the files serving your requirement, until no mutant survives.
- **Fuzz on:** write a fuzz target named after your requirement, run through the rulebook's `fuzz` task.
- **Benchmarks:** record the first run as the baseline.
- **Texts:** use the approved texts in `design.md`. The config says `Translations: agent → <languages>` → write each text in those languages too.
- **Checkpoints are your backups:** `git diff` to see what changed, `git stash` to park it, `git checkout -- <file>` to restore.
- Commit checkpoints only; the coordinator squashes and pushes.
- An environment you need is unavailable (a device, an emulator): stop and report what is missing.

## Done

Every test of your requirement passes; every e2e test you turned green passes on each platform it is tagged for; every check the config maps to `slice done` is green; with mutation on, no mutant survives in the files serving your requirement; `git status` is clean.

## Report

Per test turned green, its name and file; helper tests added; with mutation on, the files serving your requirement; the fuzz target written; checkpoints made. A stop returns only its reason: the test, the requirement question with your recommendation, the rule and rejected code, or the missing environment.
