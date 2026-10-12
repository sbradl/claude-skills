# Accessibility

Checks that a UI is usable with assistive technology and meets WCAG. UI stacks only. Task: `a11y`.

## Outcomes

- **Accessibility mistakes in component code** — UI stacks only: missing labels, roles, and alt texts flagged in the source (eslint-plugin-jsx-a11y, eslint-plugin-vuejs-accessibility, angular-eslint template rules). The rules join the `lint` task's linter config.
- **WCAG violations on rendered pages** — UI stacks only: pages checked against WCAG in a browser (axe-core with its Playwright or Vitest integration, Pa11y).

## Rulesets

For WCAG violations, the ruleset is the conformance target: AAA plus axe best practices `(Recommended)`, then AA, then A.

## Record

```markdown
| Stack | Outcome | Tool | Ruleset |
| --- | --- | --- | --- |

WCAG target: <level>
Pages checked: <how the task finds them>
Run: `<a11y task command>`
```

## Apply

Static rules go into the existing linter config, so `lint` enforces them. The `a11y` task checks every route the app exposes — read them from the router or a sitemap, and record how — starting the app itself where the tool can, as `e2e` does.
