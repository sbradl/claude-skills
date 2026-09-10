---
name: craft-review
description: Deep code-craft review of a diff across five lenses — domain-driven design, code smells, Clean Code, Pragmatic Programmer, and Philosophy of Software Design — each run in its own parallel sub-agent, then aggregated without cross-lens reranking.
disable-model-invocation: true
---

A craft review of one diff through five **lenses**, each in an isolated sub-agent, aggregated without reranking across lenses.

- **Domain-Driven Design** — is this the right model?
- **Code Smells** — is the structure decaying? (Fowler, _Refactoring_ 2nd ed., ch. 3)
- **Clean Code** — is it readable at the line? (Martin, _Clean Code_ 2nd ed.)
- **Pragmatic Programmer** — is it built deliberately and kept flexible? (Hunt & Thomas, 20th-anniversary ed.)
- **Philosophy of Software Design** — is complexity leaking in? (Ousterhout, 2nd ed.)

Isolated contexts stop a clean bill on one lens from masking a failure on another, and stop the lenses' overlapping items (primitive obsession, Law of Demeter) from being deduped away.

## Process

### 1. Pin the diff

Fixed point = whatever the user named (SHA, branch, tag, `main`, `HEAD~3`). Default when unspecified: everything not on `main` plus uncommitted work — `git diff $(git merge-base HEAD main)...HEAD` and `git diff HEAD`.

Capture the diff command(s) and `git log <fixed-point>..HEAD --oneline` once. Confirm the ref resolves and the diff is non-empty before spawning anything — a bad ref or empty diff fails here, not inside five sub-agents.

Within that diff, skip paths no lens has anything to say about: lockfiles (`package-lock.json`, `yarn.lock`, `Cargo.lock`, …), anything under a directory literally named `generated`/`dist`/`build`/`vendor`, and binary assets (images, fonts, audio). A repo's own docs (read in step 2) may name further repo-specific exclusions — e.g. a vendored third-party export living under `docs/` — those take precedence over this generic list.

### 2. Gather shared context

Read the project's domain model if present — `CONTEXT.md` (or the `CONTEXT-MAP.md` contexts touching the changed files) and any `docs/adr/` entries covering the changed area. Note any repo-documented coding standard (`CLAUDE.md`, `AGENTS.md`, `CODING_STANDARDS.md`, `CONTRIBUTING.md`, etc.) — including any review-scope note it gives (paths that aren't authored application code). Proceed silently if none exist.

This context is pasted to every sub-agent so a documented standard or ADR can override a lens heuristic.

### 3. Spawn five sub-agents in parallel

One message, five `Agent` calls, `general-purpose` for each. Resolve `<skill-dir>` to this skill folder's absolute path.

Every prompt includes:

- The diff command(s) and commit list from step 1.
- The shared context from step 2.
- The brief: "A documented repo standard or ADR overrides any heuristic in your checklist. Every finding is a judgement call — label it so. Skip anything tooling already enforces. For each finding: name the item, quote the offending hunk, give the fix in one line. Under 500 words."

Per lens, add:

- **DDD sub-agent**: "Read `<skill-dir>/ddd.md`. Check the diff against every item. Also flag drift from the `CONTEXT.md` ubiquitous language and any contradiction with an ADR."
- **Smells sub-agent**: "Read `<skill-dir>/smells.md`. Check the diff against every smell. Use the metric thresholds only as tie-breakers."
- **Clean Code sub-agent**: "Read `<skill-dir>/clean-code.md`. Check the diff against every rule."
- **Pragmatic Programmer sub-agent**: "Read `<skill-dir>/pragmatic.md`. Check the diff against every item."
- **Philosophy of Software Design sub-agent**: "Read `<skill-dir>/philosophy.md`. Check the diff against every red flag, then the principles behind them."

### 4. Aggregate

Present the five reports verbatim (or lightly cleaned) under `## Domain-Driven Design`, `## Code Smells`, `## Clean Code`, `## Pragmatic Programmer`, `## Philosophy of Software Design`. Do not merge or rerank across lenses — a hunk flagged by two lenses is signal; report it under both.

When two lenses **directly contradict** — one says do X, another says do not-X on the same hunk — keep both findings but mark the losing one "overridden by <lens>", following this precedence: **DDD → Pragmatic Programmer → Clean Code → Code Smells → Philosophy of Software Design**. This resolves head-to-head conflicts only; it is not licence to rerank non-conflicting findings by lens.

End with one line per lens: finding count and the worst finding within that lens. No single cross-lens winner — that reranking is what the separation exists to prevent.
