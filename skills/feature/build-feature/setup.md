# Build-feature setup

Runs once per project: checks the prerequisites, asks how features are built here, and records it in `<repo-root>/.claude/build-feature.md`. Ask multiple-choice questions with `AskUserQuestion`, four per call; a detected value is the first option, marked `(Recommended)`.

## 1. Prerequisites

Both must exist: the rulebook, `<repo-root>/.claude/engineering-rules.md`, and a commit convention, `<repo-root>/.claude/commit.md` or `~/.claude/commit.md`. Either missing → tell the user to run `/engineering-rules` or `/commit` (its first run records the convention), write nothing, and stop.

## 2. Rulebook gaps

Fill these into the rulebook's Testing section when they are missing:

- **`Acceptance seam:`** — the entry point acceptance tests call, the fakes that stand in for the outside world, and what Then asserts on. Propose it from the existing acceptance tests and confirm in plain chat.
- **`E2E structure:`** — only when the rulebook has an e2e tool. Single-select: page objects `(Recommended)`, screenplay, direct calls.

## 3. Questions

- **Requirement sources** — detect spec documents (`SPEC*.md`, `docs/spec*`, `docs/requirements*`), `GLOSSARY.md` or `CONTEXT.md`, `docs/adr/`, and the issue tracker. Multi-select over what was found; the free-text answer adds more.
- **Feature folder** — `docs/agents/issue-tracker.md` exists → it defines the folder, tickets, and maps; skip. Missing → ask in plain chat where a feature's working folder goes (propose `.scratch/<feature-slug>/`) and how a ticket gets resolved.
- **App-wide design doc** — detect `docs/DESIGN.md`, `ARCHITECTURE.md`, `docs/architecture*`. Single-select: the doc found, or `none`.
- **Integration** — `main` (push to the default branch) or `branch` (one feature branch).
- **PR tool** — `branch` only. Detect from the `origin` URL and the installed CLIs: `gh`, `tea`, or `none` (the branch is pushed and merged by hand).
- **CI watch** — the preset for the rulebook's `CI:` platform, a custom command, or `none` (the skill asks the user after each push). A command waits for the CI run of commit `$SHA` and exits 0 when it is green. Credentials come from environment variables, never from the config.
  - GitHub Actions:
    `until id=$(gh run list --commit "$SHA" --limit 1 --json databaseId --jq '.[0].databaseId') && [ -n "$id" ]; do sleep 10; done; gh run watch "$id" --exit-status`
  - Gitea Actions — ask for `<owner>/<repo>`:
    `while :; do s=$(curl -fsS -H "Authorization: token $GITEA_TOKEN" "$GITEA_URL/api/v1/repos/<owner>/<repo>/commits/$SHA/status" | grep -o '"state":"[a-z]*"' | head -1); case $s in *success*) exit 0;; *failure*|*error*) exit 1;; esac; sleep 15; done`
  - Jenkins — ask for the job path (multibranch: `job/<repo>/job/<branch>`):
    `while :; do j=$(curl -fsS -u "$JENKINS_USER:$JENKINS_TOKEN" "$JENKINS_URL/<job path>/lastBuild/api/json"); case $j in *"$SHA"*'"building":false'*|*'"building":false'*"$SHA"*) break;; esac; sleep 15; done; case $j in *'"result":"SUCCESS"'*) exit 0;; *) exit 1;; esac`
- **Check mapping** — per task in the rulebook except `check`, `mutation`, and `fuzz` (gate 1 decides those per requirement): one multi-select with `slice done` and `feature end`; neither means the skill leaves it to CI. Recommend `slice done` for tasks the rulebook's enforcement runs in pre-commit or pre-push, `feature end` for the rest.
- **Translations** — `agent` (then ask in plain chat for the languages besides the source language) or `none` (only the source language; translation happens outside this skill).

## 4. Record

```markdown
# Build feature

Requirement sources: <paths>
Feature folder: docs/agents/issue-tracker.md | <path pattern>; tickets: <how they are resolved>
App-wide design: <path | none>
Integration: <main | branch> · PR: <gh | tea | none>
CI watch: <command | none>
Translations: <agent → <languages> | none>

| Task | slice done | feature end |
| --- | --- | --- |
```

Leave it uncommitted; the feature's first checkpoint takes it along.

## Done

`.claude/build-feature.md` holds every field above, and the rulebook's Testing section has an `Acceptance seam:` line — and an `E2E structure:` line when it has an e2e tool.
