# Testing strategy

How the project proves its behaviour: which kinds of test exist, how each is written, and how strictly the suite itself is held to account. Tasks: `test`, `coverage`, `acceptance`, `mutation`, `fuzz`, `e2e`, `contract`.

## Before research

**Acceptance tests** — single-select:

- **`gherkin`** — feature files in Given/When/Then, readable by non-developers, bound to step definitions.
- **`coded`** — acceptance tests written in the test framework itself, named after the behaviour they prove.
- **`both`** — each for a different kind of behaviour. Then ask which behaviour goes where: single-select with `Gherkin for behaviour agreed with stakeholders, coded for the rest` and `Gherkin for user-facing behaviour, coded for technical and integration behaviour`; the free-text answer states another split.

## Outcomes

- **Unit tests** — the stack's runner and assertion library (xUnit, NUnit, Vitest, pytest).
- **Untested lines and branches** — coverage with a failing threshold (coverlet, Vitest's v8 provider, coverage.py).
- **Tests that miss broken code** — mutation testing: mutates the code and checks the suite notices (Stryker.NET, StrykerJS, mutmut, PIT, cargo-mutants).
- **Invariants broken by unusual inputs** — property-based testing: generated inputs against stated invariants (fast-check, CsCheck, FsCheck, Hypothesis).
- **Crashes and hangs on malformed input** — only for stacks that read untrusted input (files, network protocols): coverage-guided fuzzing until no new paths turn up (cargo-fuzz, SharpFuzz, Jazzer.js, Atheris).
- **Broken flows in the running app** — only for stacks with a UI or an HTTP API: end-to-end tests drive the running app (Playwright).
- **Broken contracts with other services** — only for stacks that call or serve other services: consumer-driven contracts (Pact).

Acceptance tests `gherkin` or `both` → research also covers a **Gherkin runner**: runs `.feature` files against step definitions in this stack's test runner (Reqnroll for .NET, Cucumber.js, playwright-bdd, QuickPickle for Vitest).

## Rulesets

Mostly thresholds — strictest = the highest: coverage `100% lines and branches` `(Recommended)` then `90%`, `80%`; mutation score break threshold likewise. For end-to-end, the ruleset is the browser matrix: all engines the tool supports `(Recommended)`, then Chromium only. For fuzzing, it is the time budget per target — the run stops at the budget or when coverage plateaus, whichever comes first: `10 minutes` `(Recommended)`, `30 minutes`, `60 minutes`; here the shortest is recommended, since the run gates every feature.

## Questions

**Unit test naming** — single-select:

- **Behaviour sentence** `(Recommended)` — what a user of the code can do or expect, in their vocabulary: `customer earns a free coffee after ten stamps`.
- **`Method_Scenario_Expected`** — `AddStamp_TenthStamp_GrantsReward`.
- **Given/When/Then** — `Given_nine_stamps_When_stamped_Then_reward_granted`.

**Acceptance seam** — ask in plain chat what acceptance tests drive: the entry point they call, the fakes that stand in for the outside world, and what Then asserts on. Propose it from the code: the outermost layer the app's UI or API calls, with every gateway faked.

**E2E structure** — when an end-to-end tool is picked, single-select: page objects `(Recommended)` — one object per screen holds its locators and actions, so tests read as user steps; screenplay — actors performing tasks; direct calls — locators in the tests.

**Property-based testing** — when a library is picked, ask where it is required: single-select with `Pure functions with a stateable invariant (round-trips, ordering, idempotence)` `(Recommended)` and `Wherever a test would otherwise list example inputs`; the free-text answer states another rule.

## Record

```markdown
| Stack | Outcome | Tool | Ruleset |
| --- | --- | --- | --- |

Unit test names: <convention>
Acceptance tests: <gherkin | coded | both>; split: <rule>        (both)
Acceptance seam: <entry point; fakes; what Then asserts on>
E2E structure: <page objects | screenplay | direct calls>
Property-based tests required for: <rule>
Run: `test [filter]` · `coverage <file>` · `acceptance` · `MUTATE_FILES="<paths>" mutation` · `[FUZZ_TIME=<duration>] fuzz <target>` · `e2e` · `contract`
```

## Apply

- **`test`** runs the unit tests with the coverage threshold enforced; given an argument, only the tests it matches — a test file or a test name — without the threshold, which only a full run can meet.
- **`coverage`** takes one source file and reports its line and branch coverage under the full suite; a report, no threshold.
- **`acceptance`** — `gherkin` or `both`: install the runner and run every scenario except those tagged `@wip` (written before their code) — the runner's tag filter, e.g. `--tags "not @wip"`, or `--filter "Category!=wip"` for Reqnroll; `coded`: run the acceptance tests by the test runner's filter for them (category, folder, or name pattern), and record that filter. Add no example tests or features; the rulebook records the convention, the next feature's tests follow it.
- **`mutation`** runs with the picked break threshold; with `MUTATE_FILES` set (space-separated paths), it mutates only those files. A full run can take long — report its duration with the score.
- **`fuzz`** takes one target name and runs it until coverage plateaus or the picked budget runs out; `FUZZ_TIME=<duration>` overrides the budget. It keeps its corpus and any crashing input in the repo, and the seeds run with the ordinary `test` task. Add no targets; the first feature that reads untrusted input writes its own.
- **`e2e`** configures the tool to start the app itself where it can (Playwright's `webServer`); otherwise it needs a running app.
- **`contract`** — install the library and wire the task; contracts come from the first consumer test written against it. A contract broker is a server — note it in the rulebook if the user wants one; set none up.
- **`CLAUDE.md`** — write a `Testing` section into the project's `CLAUDE.md` (replace an existing one) naming the exact commands to run the full suite, one test file or test by name, coverage for one file, mutation testing scoped by `MUTATE_FILES`, and fuzzing one target — agents look for test commands there.
