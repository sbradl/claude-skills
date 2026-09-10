---
name: tdd-green
description: Green phase of TDD — the smallest source change that makes a failing test pass. Use when the user has a red test and wants it green, or when tdd-loop needs the green phase.
---

# The green phase of TDD

The green phase takes one failing test to a **green** bar with the smallest source change that gets there. You start from a red test written in the red phase; you finish when the whole suite passes.

You edit source only. Test files are read-only and the mount enforces it — the bar goes green through source, every time. A test that looks like it needs to change is telling you the implementation is wrong: change the source instead.

## 1. Read the artifacts

Red hands you two **artifacts**: the failing test file and the runner transcript. Read the test and run it yourself — work from those, not from anyone's description of what the test needs.

From the transcript, name the exact gap — the missing symbol, or the assertion's expected-vs-actual. That gap is what the next source change closes, and nothing more.

## 2. Make the smallest change that could work

Choose the change by the **Transformation Priority Premise**: apply the transformation highest on this list that turns the current red green.

1. `{} → nil` — code where there was none, returning nothing
2. `nil → constant`
3. `constant → constant+` — a more elaborate constant
4. `constant → scalar` — a constant becomes a variable or argument
5. `statement → statements` — add unconditional code
6. `unconditional → if` — split the path with a condition
7. `scalar → array`
8. `array → container`
9. `statement → recursion`
10. `if → while`
11. `expression → function` — extract an expression into a named computation
12. `variable → assignment` — reassign an existing variable

Higher is simpler and safer. Faking it — returning the literal the test expects (`nil → constant`) — is legitimate green; a later test forces the code more generic.

Write only what a currently-failing assertion demands: no unused branches, no speculative parameters, no handling for inputs nothing asserts.

## 3. Run the full suite

Run every test, not just the one you started from. Paste the runner output verbatim into the conversation.

## Done

The pasted transcript shows the full suite passing — zero failures, zero errors — and `git diff --name-only` lists no path under the test directory. Both hold → stop. Refactoring is the next phase, not this one.
