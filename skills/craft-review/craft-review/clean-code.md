# Clean Code lens

Rules from Martin, _Clean Code_ 2nd ed. Match against the diff; each is a judgement call. Skip formatting rules a formatter enforces.

## Names

- Intention-revealing: the name says why it exists and how it's used.
- No disinformation: don't call it a `list` if it isn't; avoid names differing by a letter or two.
- Searchable: no bare magic numbers or single-letter names outside tiny scopes.
- No encodings: no Hungarian notation, no `m_`/`I` prefixes.
- Class = noun phrase, method = verb phrase. One word per concept (don't mix `fetch`/`get`/`retrieve`).
- Names sized to scope: short for short scopes, descriptive for long ones.

## Functions

- Small; then smaller. Does one thing at one level of abstraction.
- Reads top-down as a narrative; nested blocks are one line (a call).
- Arguments: 0–2 ideal, 3 needs a reason, more wants a parameter object.
- No flag arguments — split into two functions.
- No hidden side effects; command-query separation (do something *or* answer something).
- Prefer exceptions to returned error codes; extract try/catch bodies into their own functions.
- DRY — no duplicated logic.

## Comments

- Good: legal notices, intent, clarification of something you can't rename, warnings, `TODO`, amplification of importance, public-API docs.
- Bad: redundant restatement of the code, mandated ceremony comments, commented-out code, journal/changelog comments, noise, a comment that should have been a better name.

## Objects and data structures

- Objects hide data behind operations; data structures expose data and have no behaviour — don't build hybrids.
- Law of Demeter: a method talks to its own fields, its parameters, objects it creates — not to objects returned by other calls (`a.getB().getC().doThing()`).
- Don't expose internals through accessors "just in case".

## Error handling

- Exceptions, not return codes. Provide context (what failed, why) in the message.
- Don't return `null`; don't pass `null`. Prefer empty collections / optional types.
- Define exception classes around the caller's needs (how it's caught), not the source.
- Error handling is one thing — a function that handles errors does nothing else.

## Boundaries

- Wrap third-party APIs behind an interface you own; don't let their types spread through the code.
- Learning tests for third-party behaviour you rely on.

## Tests

- F.I.R.S.T — Fast, Independent, Repeatable, Self-validating, Timely.
- One assert / one concept per test; a descriptive test name.
- Test code held to the same standard as production code — no copy-paste setup rot.

## Classes

- Small; measured by responsibilities, not lines. Single Responsibility — one reason to change.
- High cohesion — methods and fields depend on each other.
- Depend on abstractions, not concretions; isolate volatility (frameworks, I/O, external services) behind interfaces.
- Organised so change touches one place (Open-Closed).

## Emergence (the four rules)

1. All tests pass.
2. No duplication.
3. Expresses the intent of the author.
4. Minimises the number of classes and methods — but only after 2 and 3.
