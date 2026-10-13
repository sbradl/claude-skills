# Static analysis and linting

Checks that read the code without running it: linters, formatters, type checkers, analyzers, architecture and dead-code checks. Task: `lint`.

## Outcomes

- **Bug patterns and bad practices** — linter rules (ESLint with typescript-eslint, Roslyn analyzers, Ruff, Clippy).
- **Inconsistent formatting** — one canonical layout (Prettier, Biome, `dotnet format`, Ruff format, rustfmt).
- **Type errors the compiler lets through** — the compiler's or type checker's strict modes (`tsconfig` `strict`, `<Nullable>enable</Nullable>`, `TreatWarningsAsErrors`, `mypy --strict`).
- **Over-complex or duplicated code** — complexity limits per function, copy-paste detection.
- **Forbidden dependencies between layers** — allowed dependencies between modules and layers, no cycles (dependency-cruiser, ArchUnitNET, NetArchTest, import-linter).
- **Unused code and dependencies** — unreferenced exports, files, and packages (knip, deptry).
- **Broken API specs** — only when the stack ships an OpenAPI or AsyncAPI spec (Spectral).

## Rulesets

Presets and rule packs; strictest = the broadest set.

## Questions

**Code comments** — single-select, a guideline for agents, not a lint rule:

- **`allowed`** — agents comment as they see fit.
- **`names instead`** — agents write no comments: when code needs explaining, a better name or an extracted, well-named function carries it. Comments a tool requires stay — a suppression's reason, API docs a linter demands, license headers.

## Record

```markdown
| Stack | Outcome | Tool | Ruleset |
| --- | --- | --- | --- |

Layers: <layer> → <layers it may depend on>, one line each   (architecture rules)
Code comments: <allowed | names instead>
Run: `<lint task command>`
```

## Apply

- **Formatters** run in check mode only; reformatting the whole repo is the user's call.
- **Type strictness** lives in the project files (`tsconfig.json`, `Directory.Build.props`), not a separate tool config.
- **`CLAUDE.md`** — `names instead` → write a `Code comments` section into the project's `CLAUDE.md` (replace an existing one): "Write no comments in code. When code needs explaining, rename it or extract a well-named function or variable. Keep only comments a tool requires: a suppression's reason, API docs a linter demands, license headers." `allowed` → remove that section if it exists.
- **Architecture rules** start with the generic ones — no cycles, no orphaned modules. Layer rules encode the user's intent, so propose the layering you read from the directory structure and ask the user to confirm or correct it in plain chat before writing them; a tool that expresses rules as tests (ArchUnitNET) gets them as one test file.
