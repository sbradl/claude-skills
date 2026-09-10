---
name: tdd-red
description: Red phase of TDD — one failing test, proven to fail for the right reason. Use when the user wants a failing test first, or when tdd-loop needs the red phase.
---

# The red phase of TDD

The red phase produces one failing test and proves it fails **for the right reason** — the behaviour is missing, not the test is broken. A test that fails for the wrong reason is no evidence it will catch the bug it targets.

One test per run. Edit test files only; read source to learn the interface, never edit it. Making the test pass is green's job.

## 1. Name the requirement

State the one behaviour under test as a sentence about what a user of the code can do or expect, in their vocabulary, not the code's. That sentence is the test name.

- "customer earns a free coffee after ten stamps" — not "loyaltyService returns reward when count == 10"
- "rejects a transfer that would overdraw the account" — not "throws InsufficientFundsError"

If `CONTEXT.md` exists, match its domain language.

## 2. Write one test

- **Arrange, Act, Assert** — three blocks in that order, separated by blank lines: set up the world, perform the one action, assert the one outcome.
- **Reads non-technical.** Someone who doesn't know the implementation should read the test and recognise the requirement. Push construction detail into helpers or fixtures; keep the body about the behaviour.
- **One outcome** — a single logical assertion, the one thing this requirement promises.
- Test at the same public interface the rest of the suite uses. No mocking internal collaborators.

## 3. Run it and paste the output

Run the single new test. Paste the test-runner output verbatim into the conversation.

## 4. Check the failure for the right reason

Decide from the transcript, not from intent. All of these must hold:

- **Non-zero exit.** The run failed.
- **The new test is the named failure.** The transcript reports *this* test failing — not a different test, and not an error raised before any test ran (collection, import, parse).
- **The reason is an assertion or a missing symbol.** The transcript contains either an assertion failure (expected vs actual) or an error that the symbol under test is undefined — and names no other cause.

Any check fails → the test is not trustworthy. Fix the test, never the source, and return to step 3. Wrong-reason failures: a syntax or parse error, an import error from a wrong path, a crash in shared setup or fixtures, a compile error about any symbol other than the one under test.

## Done

The test file and the verbatim runner transcript are both in the conversation. The transcript shows a non-zero exit, the new test as the named failure, and an assertion or missing-symbol reason. These two **artifacts** — not a description of them — are the handoff to green.
