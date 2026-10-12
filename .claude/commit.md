# Commit convention

style: conventional
body: when-non-obvious
granularity: atomic
issue-refs: never

## Changelog

path: CHANGELOG.json
tag-format: v{major}.{minor}.{patch}

### skill-users

who: People who install these skills into their projects and run them in Claude Code.
notices: new or removed skills, changed skill behaviour and outputs, new setup questions or config options, install/update script usage.
never: prose edits that leave behaviour unchanged, repo-internal docs (CLAUDE.md), .claude/skills symlinks.
categories: added, changed, fixed, removed
languages: en

## House rules

<!-- Project-specific rules; these override the skill. E.g. "scope = package name". -->
