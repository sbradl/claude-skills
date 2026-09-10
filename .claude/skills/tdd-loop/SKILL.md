---
name: tdd-loop
description: Runs the test-driven loop — drives tdd-red and tdd-green one slice at a time and, at each batch boundary, a craft-review-fed tdd-refactor pass. Use when the user wants to build a feature or fix a bug test-first, or says red-green-refactor.
---

# Test-driven development

TDD builds one behaviour at a time through a **loop**: red → green, slice after slice, with a refactor pass closing each batch. This skill runs the loop; each phase is its own skill.

## Slices

A **slice** is the smallest single behaviour a user of the code would recognise and name. One slice per lap, and never write several tests ahead — each slice responds to what the last one taught you. Before the first slice, agree with the user which public seam the tests drive, and note the current commit as the loop's base.

Two rules keep the suite from acquiring holes the loop should have closed:

- **A faked value gets triangulated next.** When green passes by returning a constant or hard-coding a branch (legitimate — see `tdd-green`), the very next slice is the example that fake cannot satisfy. Do not move to a fresh behaviour while the last one is still faked; the faked code is unpinned until a second example forces it general.
- **A boundary is two slices.** "Rewards at ten stamps" and "does not reward at nine" are separate slices, driven one after the other. One test on one side of a threshold leaves the other side, and the exact comparison, unspecified.

## Batches

Slices run in **batches of five**. Lap red → green through the batch, then run the refactor pass (it needs the user to drive `/craft-review`) and **stop**: report slices built and what of the requirement is left, and wait for the user before the next batch. An unattended multi-batch run buries the user in commits they never reviewed.

## The lap

Per slice, each phase ends on a **checkpoint** commit — made here once the phase returns, its message naming phase and slice — so the user can review the run one step at a time:

1. **`tdd-red`** in a sub-agent — writes one failing test, returns two **artifacts**: the test file path and the verbatim runner transcript. Commit the test.
2. **`tdd-green`** in a fresh sub-agent given *only* those artifacts — makes the suite pass through source, returns the passing transcript. Commit the source.

Red and green run isolated so the test file and transcript are the only channel between them.

## The refactor pass

Once per batch, at the boundary, with the suite green:

1. Ask the user to run **`/craft-review`** with the batch's base commit as the fixed point — `craft-review` is user-invoked, so you cannot spawn it. Its aggregated findings are the refactor **mandate**.
2. Invoke **`tdd-refactor`** in the main context, handing it those findings and the batch base as the cycle base. It refactors the batch's code behaviour-preservingly, re-runs the review via the user, and stops when the *after* review is no worse. Commit each change it makes.

A review that finds nothing → say so in the report and open no refactor. Do not invent one.

## The mutation pass

Once per batch, alongside the refactor pass, with the suite green: run mutation testing scoped to the batch's changed files (`MUTATE_FILES="<paths>" mise run mutation`). Never leave a survivor unexplained.

A survivor in code this batch wrote is a loop failure, and fixing it means fixing what the loop should have done — not bolting on a test:

- **Green over-coded.** The mutated construct — a branch, a guard, a comparison edge — was never forced by a failing assertion. Revert it; confirm the suite stays green without it. (Green's step-3 audit is meant to catch this before commit.)
- **A slice was skipped.** A boundary's other side, a faked value never triangulated. Add the red that should have existed, watch it fail for the right reason, then green it — the normal lap, run late.

Only a survivor in code that predates this batch gets a characterization test written on the spot, or an explicit note that the gap is pre-existing (say so in the report; do not touch code outside the batch to close it). A characterization test over this batch's own fresh code just pins whatever it happens to do, bugs included.

Two traps this catches that review alone won't:

- A correctness fix applied mid-batch outside red/green — a masking check, a guard added because it was "obviously needed" — has no test proving it. Mutation testing is often the only thing that notices. Give it a slice like anything else.
- A slice that mirrors an existing tested feature needs that feature's whole test list, not just its happy path — the existing feature's own default/unselected-state test is the one most often skipped for the new twin.

## Handoff

The handoff is an **artifact, not a summary**. A prose summary of red's work smuggles in the implementation its author pictured, and that coupling is what TDD exists to prevent — so green gets the test file and transcript, nothing else.

## Done

Stop at a batch boundary once nothing in the user's stated requirement is left unbuilt. By then the full suite passes and `git log` since the base shows a checkpoint commit per phase and, per batch, a refactor-pass commit or a logged "review clean", plus a mutation pass with every survivor resolved or explicitly logged as pre-existing.

## Squash

With the loop done, offer to squash its checkpoint commits into one. On acceptance, combine everything since the base into a single **conventional commit** — a `type(scope): summary` subject, a body naming what each slice added, and a footer for issue refs and `Co-Authored-By` trailers.
