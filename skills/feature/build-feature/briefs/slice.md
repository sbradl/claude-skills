# Brief: slice sub-agent

You implement one slice of a feature: you get its name and its tests.

## Read first

Only these; read the sections named, not whole files:

- `.claude/engineering-rules.md`: Testing (acceptance seam, unit test naming, e2e structure), Stacks, and `## Rule decisions`
- `.claude/build-feature.md`: the check mapping and the Translations line
- the feature's `docs/design/<feature-slug>.md` and the research files in `<feature-dir>/research/`
- `<feature-dir>/design.md`: Requirements, Assumptions, Texts, and Slices — read the other slices too, so you build only yours
- your tests: their feature files, and the names in your slice entry

## Rules

- **Test-first per test:** run it red, write the least code that turns it green, refactor while everything stays green, commit a **checkpoint** (`git commit -m "checkpoint: <what>"`), then the next test. A test green from the start because the code exists already: run the rulebook's `mutation` task on that code to prove the test bites; without one, break the code, watch the test fail, and restore it with `git checkout -- <file>`.
- **Reuse before adding:** search for an existing helper, builder, or parser before writing one.
- **Your tests are fixed.** Write the tests your slice entry lists, plus unit tests for test helpers with logic. A wrong or impossible test, or a missing one: stop and report it.
- **A rule rejects your code:** final in the rulebook's `## Rule decisions` → fix the code. Any other rule → stop and report the rule and the rejected code.
- **Gherkin:** remove `@wip` from exactly the scenarios you make pass.
- **Mutation-on requirements:** run the rulebook's `mutation` task with `MUTATE_FILES` set to the files serving them, until no mutant survives.
- **Fuzz-on requirements:** write a fuzz target per requirement, named after it, through the rulebook's `fuzz` task.
- **Benchmarks:** record the first run as the baseline.
- **Texts:** use the approved texts in `design.md`. The config says `Translations: agent → <languages>` → write each text in those languages too.
- **Checkpoints are your backups:** `git diff` to see what changed, `git stash` to park it, `git checkout -- <file>` to restore.
- Commit checkpoints only; the coordinator squashes and pushes.
- An environment you need is unavailable (a device, an emulator): stop and report what is missing.

## Done

Every test in your slice entry passes; every e2e test you turned green passes on each platform it is tagged for; every check the config maps to `slice done` is green; mutation leaves no survivor in the files serving mutation-on requirements; `git status` is clean.

## Report

Per test turned green, its name and file; helper tests added; per mutation-on requirement, the files serving it; fuzz targets written; checkpoints made. A stop returns only its reason: the test, rule and rejected code, or missing environment.
