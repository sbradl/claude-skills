# Brief: design sub-agent

You fit one feature into the app's design. Documents only: no code, no commits.

## Read first

Only these; read the sections named, not whole files:

- the app-wide design doc you were given, if any: its overview and the sections of the modules the feature touches
- `.claude/engineering-rules.md`: Stacks, and the static-analysis record (its `Layers:` lines)
- the ADRs and glossary terms the feature touches
- the research files in `<feature-dir>/research/`
- the in-scope requirements in `<feature-dir>/design.md`
- the `mattpocock-skills:domain-modeling` skill, when available, for the glossary and ADR format; otherwise match the existing files

## Write

1. **`docs/design/<feature-slug>.md`** — the feature's **architecture**, 60–80 lines including the diagram. Every element by name with one line of purpose. It holds:
   - the modules it touches and each one's responsibility, in one diagram
   - the main entities and use cases
   - the boundaries between stacks or processes it crosses (a Go core and a Kotlin UI) — what passes each one
   - the main data flow
   - a relation between two classes only when the design hinges on it — one line, no class diagram
   - the key decisions with their reasons
   - **Merge into <app-wide doc>** — every change to the app-wide design, merged once the feature is complete. Only when you were given an app-wide doc.

   Everything below that level emerges in the slices: classes, types, signatures, file paths, library choices, byte and file formats, constants and tuning numbers, build tooling, CI steps, and test setup.
2. **`<feature-dir>/design.md`** — under each requirement a `Design: <element>, <element>` line naming the design elements that serve it; a **Risks** section, each risk with its mitigation; an **Open points** section, each with your recommendation.
3. New domain terms go into the glossary. A choice that is hard to reverse, surprising, and a real trade-off gets an ADR, numbered after the last one.

Interfaces fit today's caller (YAGNI); forward constraints the requirements state are the only exception. The rulebook binds the design: its layers, its licence allow-list, and the names its lint rules accept. A requirement the design cannot meet becomes an open point; the requirements stay as approved.

Done when every requirement has a `Design:` line and the design doc is at most 80 lines.

## Report

Files changed, an outline of the design, new modules and why, ADRs, glossary terms, the open points with your recommendations, and any requirement without a design element.
