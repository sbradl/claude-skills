# Code-smell lens

The 24 smells of Fowler, _Refactoring_ 2nd ed. ch. 3. Each: *what it is* → *how to fix*. Match against the diff; every hit is a labelled heuristic ("possible Feature Envy"), never a hard violation. Skip anything a linter already enforces.

- **Mysterious Name** — a name that doesn't reveal what the thing does or holds. → rename; if no honest name comes, the design is murky.
- **Duplicated Code** — the same logic shape in more than one hunk or file. → extract the shape, call it from both.
- **Long Function** — a function doing too much to hold in your head. → extract until each function is one intent at one level of abstraction.
- **Long Parameter List** — many parameters, or ones derivable from each other. → pass an object, replace a param with a query, or bundle a parameter object.
- **Global Data** — mutable state reachable from anywhere. → wrap it, narrow access, make it a parameter.
- **Mutable Data** — data updated in place where a caller didn't expect it. → prefer immutable values; isolate the mutation; separate query from update.
- **Divergent Change** — one module edited for several unrelated reasons. → split so each module changes for one reason.
- **Shotgun Surgery** — one logical change forces scattered edits across many files. → gather what changes together into one module.
- **Feature Envy** — a function reaching into another object's data more than its own. → move it onto the data it envies.
- **Data Clumps** — the same few fields/params travelling together everywhere. → bundle them into a type, pass that.
- **Primitive Obsession** — a primitive or string standing in for a domain concept. → give the concept its own small type.
- **Repeated Switches** — the same `switch`/`if`-cascade on the same type in several places. → polymorphism, or one shared map.
- **Loops** — a raw loop obscuring what it computes. → replace with a pipeline (filter/map/reduce).
- **Lazy Element** — a class/function that no longer earns its existence. → inline it.
- **Speculative Generality** — abstraction, params, or hooks for needs that don't exist yet. → delete; inline back until a real need shows.
- **Temporary Field** — a field set only in certain circumstances, empty otherwise. → extract the field and its logic into their own class.
- **Message Chains** — long `a.b().c().d()` navigation the caller shouldn't depend on. → hide the walk behind one method on the first object.
- **Middle Man** — a class/function that mostly just delegates onward. → cut it, call the real target direct.
- **Insider Trading** — modules trading too much private data through back channels. → move the shared feature together, or introduce an intermediary.
- **Large Class** — a class with too many fields/methods, doing several jobs. → extract class / subclass along the responsibilities.
- **Alternative Classes with Different Interfaces** — classes doing similar jobs with mismatched method names/signatures. → align the interfaces, then consider merging.
- **Data Class** — a class of fields with getters/setters and no behaviour. → move the behaviour that uses the data onto it.
- **Refused Bequest** — a subclass/implementer ignoring or overriding most of what it inherits. → drop the inheritance, use composition/delegation.
- **Comments** — a comment compensating for unclear code. → refactor so the code says it; keep comments for intent, warnings, and the genuinely non-obvious.

## Metric thresholds (tie-breakers only)

Use when deciding whether a borderline hunk is worth flagging — not as standalone findings, and never where tooling already reports them.

| Signal | Look harder past |
| --- | --- |
| Function length | ~15–20 lines |
| Cyclomatic complexity | ~10 |
| Parameters | 3 |
| Nesting depth | 3 |
| Methods / fields per class | ~10 methods, ~7 fields |
| Return points hidden in branches | more than a guard clause + one |
