# Security analysis

Checks for insecure code, vulnerable or non-compliant dependencies, misconfigured infrastructure, leaked secrets, and attackable running apps. Task: `security`; `dast` for the running-app scan.

## Outcomes

- **Insecure code patterns** — static application security testing. Include Opengrep and the rule packs available to it.
- **Vulnerable dependencies** — known CVEs in direct and transitive dependencies. Include Trivy (`trivy fs`) and the stack's native audit (`npm audit`, `dotnet list package --vulnerable`).
- **Dependency licenses outside an allow-list** — Include Trivy's license scanner.
- **A software bill of materials** — an SBOM as a build artifact. Include Syft and Trivy.
- **Misconfigured infrastructure** — infrastructure stacks only: Dockerfiles, Compose, Terraform, Helm, Kubernetes. Include Trivy (`trivy config`).
- **Vulnerable container images** — infrastructure stacks with a Dockerfile: the built image's OS packages and layers. Include Trivy (`trivy image`) and Grype.
- **Leaked secrets** — credentials in the working tree and the git history. Include Gitleaks, TruffleHog, and Trivy's secret scanner.
- **Attacks on the running app** — stacks serving HTTP only: dynamic testing from outside. Include ZAP.

## Rulesets

Mostly rule packs (strictest = the broadest set) and severity thresholds (strictest = fail on the lowest severity). Two outcomes rank differently:

- **Dependency licenses** — the allow-list: permissive only (MIT, Apache-2.0, BSD, ISC) `(Recommended)`, then adding weak copyleft (LGPL, MPL), then adding strong copyleft (GPL, AGPL).
- **SBOM** — not a check, so the ruleset is the format: CycloneDX `(Recommended)` or SPDX.

## Record

```markdown
| Stack | Outcome | Tool | Ruleset |
| --- | --- | --- | --- |

License allow-list: <SPDX ids>
SBOM: <format> → `<output path>`
Run: `<security task command>`; `<dast task command>` against a running app
```

## Apply

- **Secret scanning** runs once over the full git history as well as the working tree. A secret found anywhere → tell the user at once, naming file and commit: the secret is compromised and must be rotated; rewriting history does not un-leak it.
- **SBOM** joins the `security` task as an artifact step: it writes the file and never fails the task.
- **Container image scanning** builds the image in the task, then scans it.
- **DAST** gets its own `dast` task taking the target URL, because it needs a running app. Its strictest ruleset (ZAP's full active scan) attacks the target — the task must refuse any URL but a local or staging one the user names.
