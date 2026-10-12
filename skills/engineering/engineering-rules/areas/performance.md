# Performance budgets

Numbers the app must stay within — page speed, bundle size, hot-path timing, behaviour under load — checked so a regression fails instead of drifting in. Task: `perf`.

## Research categories

- **Web page budgets** — UI stacks only: Lighthouse scores and Core Web Vitals per page (Lighthouse CI).
- **Bundle size** — UI stacks only: shipped JavaScript and CSS per entry point (size-limit, bundlesize).
- **Benchmarks** — timing of hot code paths, compared against a stored baseline (BenchmarkDotNet, Vitest bench, pytest-benchmark).
- **Instruction-count benchmarks** — hot code paths measured in executed instructions under a CPU simulator (Valgrind's Cachegrind or Callgrind), compared against a stored baseline. Hardware-independent and deterministic, so a regression of 1% shows even on shared CI runners; blind to I/O, syscalls, and parallelism. Linux only (Gungraun, formerly iai-callgrind, for Rust).
- **Load testing** — stacks serving HTTP: throughput and latency under concurrent load (k6, NBomber, Locust).

## Rounds

Both rounds. Rulesets here are budget levels — strictest first: Lighthouse `100` in every category `(Recommended)`, then `90`, then `75`; benchmarks fail on any regression beyond noise `(Recommended)`, then beyond 10%, then beyond 25%; instruction-count benchmarks fail on any increase `(Recommended)`, then beyond 1%, then beyond 5%.

## Questions

Bundle-size limits and load-test targets are numbers only the user knows. Measure the current values first, then ask in plain chat for each limit, proposing the measured value as the starting budget so nothing fails on day one and nothing may grow unnoticed.

## Record

```markdown
| Stack | Category | Tool | Budget |
| --- | --- | --- | --- |

Run: `<perf task command>`; load tests: `<command>` against a running app
```

## Apply

Benchmarks record their first run as the baseline; instruction-count benchmarks run as their own subtask, `perf:instructions`, since they need Linux. Load tests get their own command taking the target URL, which must be a local or staging environment the user names — never production. Page budgets and load tests need a running app; start it from the task where the tool can.
