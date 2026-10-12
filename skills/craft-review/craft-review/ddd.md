# DDD lens

Each item: *what to look for in the diff* → *fix*. All are judgement calls.

## Strategic

- **Ubiquitous language drift** — a name in the code (class, method, field, test) that isn't the term `CONTEXT.md` uses, or is a synonym the glossary avoids. → rename to the glossary term; if the concept isn't in the glossary, note the gap.
- **Bounded-context leak** — code in one context imports models, tables, or internals of another; a shared mutable model straddling two contexts. → integrate through a published contract or an anti-corruption layer; keep each context's model private.
- **Missing anti-corruption layer** — external API shapes (DTOs, vendor enums, JSON) flowing straight into the domain. → translate at the boundary into domain types.
- **ADR contradiction** — the change contradicts a decision in `docs/adr/`. → surface it explicitly ("Contradicts ADR-NNNN — worth reopening because…"), don't silently override.

## Tactical

- **Anemic domain model** — entities are field bags; the business rules live in services, controllers, or handlers. → move the rule onto the entity or value object that owns the data.
- **Logic in the wrong layer** — domain rules in infrastructure/persistence/application code, or persistence concerns inside domain types. → push rules down into the domain layer; keep the domain layer free of framework and I/O.
- **Aggregate boundary unclear** — no obvious aggregate root; an invariant spanning several objects with nothing enforcing it; one transaction mutating multiple aggregates. → name the root, enforce the invariant inside its boundary, mutate one aggregate per transaction.
- **Aggregate referenced by object, not ID** — one aggregate holds a direct reference to another aggregate root. → reference by identifier; load through a repository when needed.
- **Entity / value object confused** — a concept with no meaningful identity modelled as an entity, or an identity-bearing concept compared by value; a value object that is mutable. → value objects are immutable and compared by value; entities have identity and a lifecycle.
- **Primitive obsession on a domain concept** — `string`/`int`/`Map` standing in for Money, EmailAddress, a status, an identifier. → give the concept its own small type that guards its own validity.
- **Repository smell** — a repository not scoped to an aggregate root; returning rows/DTOs instead of domain objects; exposing query-builder or ORM internals to callers. → one repository per aggregate root, returning fully-formed domain objects.
- **Domain service that should be a method** — logic placed in a domain service that actually belongs to a single entity or value object. → move it onto that type; keep domain services for logic that genuinely spans several.
- **Invalid object constructible** — a constructor or setter that can produce an entity/aggregate violating its invariants. → validate in the constructor or a factory; no partially-built domain objects escape.
- **Cross-aggregate consistency done synchronously** — one aggregate directly updating another to stay consistent. → raise a domain event; let the other side react.
- **Command leaks a query / hidden side effect** — a domain method named as a question that mutates state, or a getter with side effects. → separate command from query.
