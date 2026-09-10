---
name: tdd-refactor
description: Refactor phase of TDD — improve green code's design without changing behaviour or any assertion. Use when the user asks to refactor, names a smell, or acts on a review finding, or when tdd-loop needs the refactor phase.
---

# The refactor phase of TDD

The refactor phase improves the design of code that already works, changing nothing about what it does. You start from a **green** bar and you finish green, with every assertion exactly as it was.

Both source and test files are writable here — you may rename a symbol through its tests, move a fixture, split a test file. The guard is a **check**, not a mount: the refactor stays **behaviour-preserving**, and step 4 proves it against the tests as they stood before you started.

## 1. Get the mandate

Everything already passes, so nothing forces this phase — it runs only on an explicit trigger. Proceed on one of:

- a direct instruction to refactor
- a named smell or design problem to fix
- a review finding — from step 2, or handed to you by a caller such as `tdd-loop`

Invoked at a green bar with none of these — nothing named, no review run — stop and say the code is green with nothing mandated to change. Do not invent a refactor.

## 2. Pin the reference points and baseline the design

Commit the green bar so the tree is clean. That commit is the **green commit** — step 4 checks behaviour against its tests. Its parent, the last commit before this red-green-refactor cycle, is the **cycle base**.

Then baseline the design: review the cycle-base-to-green-commit diff — the `code-review` skill yourself, or `/craft-review` via the user — with the cycle base as fixed point. Keep the findings: they are step 5's *before*, and any is a valid mandate for step 3. Skip only when a caller has already supplied both the findings and the cycle base — then use theirs.

## 3. Refactor in behaviour-preserving steps

One small transformation at a time — rename, extract, inline, move. Run the full suite after each; it stays green, or you revert that step and take a smaller one.

Leave every assertion untouched. Test-file edits are allowed only where they carry no behaviour: renaming a symbol the test calls, moving a helper, reformatting. Expected values, the conditions asserted, and the number of assertions stay as they were.

## 4. Prove behaviour was preserved

If you changed no test files, the green suite already *is* the green commit's tests against the new source — this step is done.

If you did change test files, run both checks:

- **Old tests, new source.** `git stash push -- <test-paths>` to drop your test edits, leaving the refactored source against the green commit's tests. Run the full suite, paste the output, then `git stash pop`. Green means the source refactor changed no behaviour those tests pin.
- **Assertion diff.** Read every hunk of `git diff <green-commit> -- <test-paths>`. Confirm no assertion was added, removed, weakened, or retargeted — only renames, moves, formatting.

If either check fails, the refactor broke behaviour or the tests were loosened to hide it. Reset to the green commit and start over with smaller steps.

## 5. Confirm the design improved

With a baseline review — your own from step 2 or a caller's: commit the refactor, then re-run it, **same base**. Fewer findings, or the same findings at lower severity, means the refactor earned its place. No better → reset to the green commit; a refactor that doesn't improve the design is churn.

## Done

The full suite passes, the green commit's tests pass against the new source, `git diff <green-commit> -- <test-paths>` shows no assertion change, and — if a baseline review exists — the *after* review is no worse than the *before*. Paste the deciding runner output into the conversation before calling it done.
