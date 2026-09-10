# Pragmatic Programmer lens

Tips from Hunt & Thomas, _The Pragmatic Programmer_ 20th-anniversary ed. Each item: *what to look for in the diff* → *fix*. All are judgement calls; skip anything tooling already enforces.

## Duplication (DRY)

- **Imposed / inadvertent duplication** — the same knowledge expressed twice: a constant and a comment restating it, validation repeated in UI and model, a struct shape mirrored by hand-written accessors. → one authoritative source; derive the rest.
- **Copy-paste variant** — a hunk pasted and lightly edited into a second place. → extract the shape; parameterise the difference.
- **Docs repeating code** — a comment or doc block that will silently rot when the code below it changes. → delete it, or make the code the single source.

## Orthogonality & coupling

- **Shotgun coupling** — this change forced edits across several unrelated modules. → the modules know too much about each other; hide what varies behind one seam.
- **Global / singleton reach** — new code reads or writes module-level mutable state or a singleton. → pass it in; a dependency you can see is a dependency you can test.
- **Train wreck** — `a.getB().getC().doThing()`; the caller navigates someone else's structure. → tell, don't ask — one method on the first object.
- **Detail baked into code** — a URL, threshold, feature toggle, or tuning constant hard-coded in logic. → put abstractions in code, details in configuration/metadata.

## Design by Contract

- **Unstated precondition** — a function that silently misbehaves on input it doesn't accept (empty, negative, null, unsorted). → assert or reject the precondition at the top; state it.
- **Weak postcondition / broken invariant** — a method that can return a partially-built or invalid object, or leave its type's invariant violated. → validate before returning; enforce the invariant in one place.
- **Assertion used for real errors** — `assert` guarding conditions that *can* happen in production (user input, I/O, network). → assertions are for "this can never happen"; use normal error handling for the rest.

## Dead programs tell no lies

- **Swallowed error** — an exception caught and logged-and-continued, or an error return ignored, leaving the program running on bad state. → crash early; fail at the point of detection, not three layers later.
- **Catch-all** — `catch (Exception)` / bare `except` around a wide block. → catch the specific failure you can handle; let the rest propagate.
- **Unbalanced resource** — something acquired (lock, file, connection, transaction) with no guaranteed release on every path. → finish what you start — allocate and free in the same scope, use the language's scoped-cleanup construct.

## Programming deliberately

- **Programming by coincidence** — code that relies on undocumented behaviour, incidental ordering, an unguaranteed default, or "it works now". → rely only on documented contracts; make the assumption explicit or defensive.
- **Wizard / borrowed code not understood** — generated or pasted code the change can't fully explain. → understand every line you commit, or don't commit it.
- **Unproven assumption** — "select isn't broken": the diff blames the framework/DB/library rather than its own code. → prove the assumption with a test or a probe before building on it.

## Broken windows

- **Left-behind rot** — a `TODO`/`FIXME`/`HACK` added without a plan, a commented-out block, a known-wrong workaround shipped as-is. → fix it, or file it and link the issue; don't let the rot set a precedent.
- **Deferred refactor riding along** — the change works *around* a bad structure it sits right next to instead of fixing it. → refactor early, refactor often — while you're already in the code.

## Reversibility & flexibility

- **One-way door** — the change hard-wires a vendor, format, or schema assumption that will be expensive to undo. → isolate it behind an interface you own so the decision stays reversible.
- **Speculative flexibility** — configuration hooks, strategy interfaces, or generality added for a need that doesn't exist yet. → build for today's known requirements; add the seam when the second case arrives.

## Testing

- **Untestable by design** — new logic reachable only through I/O, time, randomness, or a network call with no seam to substitute them. → design to test — inject the dependency.
- **Test-state gap** — the diff adds a branch or error path with no test exercising that state. → cover the states, not just the lines.
- **Bug fix without a regression test** — a fix that doesn't add the test that would have caught it. → find bugs once.
