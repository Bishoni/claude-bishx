---
description: Create CLAUDE.md and AGENTS.md templates in the project root
---

Create project instruction files `CLAUDE.md` and `AGENTS.md` in the current working directory.

## Rules

1. If `CLAUDE.md` already exists — ask the user before overwriting
2. If `AGENTS.md` already exists — ask the user before overwriting
3. Replace all `<!-- bishx:placeholder -->` comments with real project data by scanning the codebase
4. If you can't determine a value — leave a short `TODO: ...` comment for the user
5. After writing, confirm what was created and list any TODOs that need manual input

## CLAUDE.md template

CLAUDE.md = **rules only**. Loaded every session → must be minimal. No catalogs, no lists of files/components, nothing that goes stale.

```markdown
# CLAUDE.md

Rules for the AI agent working with **{PROJECT_NAME}** — <!-- bishx:init:project_description_short -->

When changing stack or patterns — update `AGENTS.md`. Facts only. On task completion.

---

## Constraints

<!-- bishx:init:constraints — e.g. security requirements, compliance, network restrictions -->

- OWASP Top 10 — check always
- Secrets only in `.env`, never commit

## Stack

<!-- bishx:init:stack — one line per layer, compact -->

## Environment

<!-- bishx:init:environment — venv, runtime version, key paths -->

## Architecture

Don't break the foundation — patterns and structure in `AGENTS.md`.
<!-- bishx:init:architecture_notes — optional 1-2 line project-specific notes (e.g. UI style) -->

## Git

- Branch: `main`
- Conventional commits in English: `<type>: <subject>`
- Types: `feat|fix|refactor|perf|docs|test|build|ci|chore|style|revert|deps|security`
- Subject: past tense, no period, max 200 chars
- Co-Authored-By with actual model name (from system prompt) in every commit
- Atomic commits

​```bash
git pull --rebase origin main
git add -A
git commit -m "$(cat <<'EOF'
feat: added form validation

Co-Authored-By: Claude <MODEL> <noreply@anthropic.com>
EOF
)"
git push origin main
​```

> `<MODEL>` — substitute the real model name from system prompt (e.g. Opus 4.6, Sonnet 4.6, Haiku 4.5)

## bd (beads)

Local task tracking. `bd ready` → `bd update <id> --status in_progress` → work → commit+push → `bd close <id>` → `bd sync`.

In team mode: `bd close` and `bd sync` are done by Lead.

## Task completion (HARD GATE)

Task is NOT complete until:
1. `git push origin main` — succeeded
2. `git status --porcelain` — empty
3. `bd close` + `bd sync` — executed

Never say "ready to push". Agent pushes by itself.
```

## AGENTS.md template

AGENTS.md = **navigation map**. Loaded on demand → can be larger, but nothing that goes stale (no counts, no component lists, no route tables). Agent uses Glob/Grep to find specifics.

```markdown
# {PROJECT_NAME}

<!-- bishx:init:project_description_short -->

## Where things live

​```
<!-- bishx:init:directory_tree — key directories with one-line comments, not every file -->
​```

## How to add new things

<!-- bishx:init:recipes — pipeline recipes like: "Backend endpoint: model → DAO → schema → route → migration" -->

## Patterns (do not break)

<!-- bishx:init:patterns — immutable architectural rules, bullet list -->

## Terms

<!-- bishx:init:terms — domain glossary as markdown table, 3-7 key terms -->
```
