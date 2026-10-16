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

- **Test-first per test:** every test is written, reviewed, and fails for the right reason already, skipped as `wip`. Lift its skip — `@wip` in Gherkin — write the least code that turns it green — the declarations' zero values are yours to replace — refactor while everything stays green, commit a **checkpoint** (`git commit -m "checkpoint: <what>"`), then the next test. A test green once its skip is lifted, because earlier code covers it — a slice may have no production code to write: break that code one change at a time, watch the test fail, and restore it with `git checkout -- <file>`; report per test the break that made it fail, and stop on a test no break fails.
- **Reuse before adding:** search for an existing helper, builder, or parser before writing one.
- **`manual` requirement:** you get no tests. Build it, keep every other test green, and name in your report what to look at in the running app.
- **Slow suites:** run only the test files of your requirement, in the background with output to a log, and read the log's last 20 lines; after a failure rerun only the failed test. An e2e test runs on one platform and size it is tagged for; the feature-end e2e check runs the rest.
- **Your tests are fixed** — names, bodies, examples, step definitions, and test helpers. A wrong or impossible test, or a missing one: stop and report it. Behaviour neither the requirement nor a test states: stop and report it as a requirement question with its evidence — decide nothing about what the feature does. A case nothing shows occurs takes the feature's path for unexpected input.
- **A rule rejects your code:** final in the rulebook's `## Rule decisions` → fix the code. Any other rule → stop and report the rule and the rejected code.
- **Skips:** remove the `wip` skip or `@wip` tag from exactly the tests you make pass.
- **Fuzz on:** write a fuzz target named after your requirement, with seed inputs from your tests and the research files; the seeds run with the ordinary tests. The target is fuzzed at the feature's end, not here.
- **Benchmarks:** record the first run as the baseline.
- **Texts:** use the approved texts in `design.md`. The config says `Translations: agent → <languages>` → write each text in those languages too.
- **Checkpoints are your backups:** `git diff` to see what changed, `git stash` to park it, `git checkout -- <file>` to restore.
- Commit checkpoints only, staging the paths you changed (`git add <paths>`, never `git add -A`); the coordinator squashes and pushes.
- An environment you need is unavailable (a device, an emulator): stop and report what is missing.

## Done

Every test of your requirement passes; every e2e test you turned green passes on one platform it is tagged for; every check the config maps to `slice done` is green; `git status` is clean.

## Report

At most 15 lines. Per test turned green, its name and file; helper tests added; the fuzz target and its seeds; checkpoints made. A stop returns only its reason: the test, the requirement question with your recommendation, the rule and rejected code, or the missing environment.
