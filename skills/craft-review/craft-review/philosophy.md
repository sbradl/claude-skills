# Philosophy of Software Design lens

From Ousterhout, _A Philosophy of Software Design_ 2nd ed. The job is to spot **complexity** entering the diff — anything that makes the system harder to understand or change. Symptoms: change amplification (one decision, many edits), high cognitive load, unknown unknowns (it's not obvious what you must know to change this safely). Every item is a judgement call.

## Red flags (Ousterhout's own list — match each against the diff)

- **Shallow module** — a class/function whose interface is nearly as complicated as its implementation; a method that just forwards arguments. → deepen it, or inline it into the caller.
- **Information leakage** — the same design decision (a file format, a protocol detail, a schema assumption) is baked into two or more places. → encapsulate it in one module; the others go through that module.
- **Temporal decomposition** — module/function structure mirrors the *order operations run in* (read, then modify, then write) rather than knowledge, so the same knowledge is spread across steps. → organise around what each unit *knows*, not when it runs.
- **Overexposure** — the API forces a caller to learn about a rarely-used feature to do the common case. → make the common case need nothing extra.
- **Pass-through method** — a method that does almost nothing except call another method with the same signature. → let the caller invoke the target directly, or genuinely add value here.
- **Pass-through variable** — a parameter threaded down through many layers that don't use it, just to reach a deep one. → context object, or share it another way.
- **Repetition** — a non-trivial code snippet appears again and again. → pull it into a method or a helper.
- **Special-general mixture** — a general-purpose mechanism contains code specific to one particular use. → lift the special case out to where it belongs.
- **Conjoined methods** — you can't understand one method without reading another, and back again. → restructure so each is understandable in isolation.
- **Comment repeats the code** — the comment restates what the next line plainly says. → delete it, or raise it to explain *why* / the higher-level intent.
- **Implementation documentation contaminates interface** — a doc comment on the interface exposes implementation details a caller shouldn't need. → split interface comments from implementation comments.
- **Vague name** — a variable/method name so generic (`data`, `handle`, `process`, `obj`, `count`) it carries no information. → a precise name; if none fits, the design may be muddled.
- **Hard to pick a name** — struggling to name a thing cleanly is a sign its purpose is unclear or it does more than one thing. → sharpen the abstraction until a name is obvious.
- **Hard to describe** — the doc comment has to be long and convoluted to capture the behaviour. → simplify the thing being described.
- **Nonobvious code** — a reader must study or execute the code to know what it does (implicit type coercion, a generic container whose real contents aren't clear, behaviour that violates reader expectations). → make it obvious, or add the comment that makes it obvious.

## Principles behind the flags

- **Deep modules** — value = functionality minus interface complexity. Prefer a few deep modules over many shallow ones; a new thin wrapper class is suspect.
- **Pull complexity downward** — it's better for the module to absorb the hard case than to push it onto every caller. A config knob that exists because the author couldn't decide is complexity pushed up.
- **Define errors out of existence** — new code that adds exceptions/special cases callers must handle: can the API be redefined so the condition is normal (clamp instead of throw, return empty instead of "not found")? Also: exception masking, exception aggregation.
- **Different layer, different abstraction** — if a method/variable in one layer has the same name and meaning as one in the layer it calls, the layer probably isn't adding value (see pass-through).
- **Better together or apart** — combine two pieces if they share information, are always used together, overlap conceptually, or one is hard to understand without the other. Otherwise keep them apart.
- **Comments describe what code can't** — precisely: the *why*, the invariants, the units, the things a reader can't deduce. Higher-level comments add intuition; lower-level ones add precision. Write them as part of designing, not after.
- **Consistency** — names, conventions, and patterns match what the surrounding code already does; a change that introduces a second way to do an existing thing raises cognitive load.
- **Strategic, not tactical** — the change invests a little to keep the design clean, rather than taking the fastest patch and leaving the structure slightly worse ("tactical tornado").
