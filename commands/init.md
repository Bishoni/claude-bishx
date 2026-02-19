---
description: Create CLAUDE.md and AGENTS.md templates in the project root
---

Create project instruction files `CLAUDE.md` and `AGENTS.md` in the current working directory.

## Rules

1. If `CLAUDE.md` already exists — ask the user before overwriting
2. If `AGENTS.md` already exists — ask the user before overwriting
3. Write both files with the **exact** content specified below (no modifications)
4. After writing, confirm what was created

## CLAUDE.md

```markdown
# CLAUDE.md

Instructions for the AI agent (Claude Code) when working with this repository.

When changing the stack, patterns, or architecture — update `AGENTS.md`. Facts only: stack, versions, patterns. No reasoning or recommendations.

---

## Project

<!-- bishx:init:project_description -->

## Stack

<!-- bishx:init:stack -->

## Security

- OWASP Top 10 — mandatory check on every change
- Secrets only via `.env` / environment variables, never commit
- Do not expose sensitive data in logs or API responses
- Validate input at system boundaries (API endpoints, external sources)

---

## Task tracking with bd (beads)

The project uses `bd` for local task tracking. Before starting work — check available tasks. After completion — close the task and sync.

### Commands

​```bash
bd onboard              # initial setup
bd ready                # show available tasks
bd show <id>            # task details
bd update <id> --status in_progress  # take task in progress
bd close <id>           # close task
bd sync                 # sync state
​```

### Workflow with bd (solo mode)

1. `bd ready` — check available tasks
2. `bd update <id> --status in_progress` — take a task
3. Do the work
4. Commit and push (see below)
5. `bd close <id>` — close task
6. `bd sync` — sync state

**In team mode (Agent Teams):** `bd close` and `bd sync` are done by **Lead**, NOT the dev agent. Dev only commits, pushes, and notifies Lead.

---

## Git

### Rules

- All work is done on `main`
- Conventional commits: `<type>: <subject>`
- Types: `feat|fix|refactor|perf|docs|test|build|ci|chore|style|revert|deps|security`
- Subject: past tense, no period, up to 200 characters
- Co-Authored-By in every commit
- Small atomic commits over large diffs

### Commit

​```bash
git pull --rebase origin main
git add -A
git commit -m "$(cat <<'EOF'
feat: added form validation

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
git push origin main
# If push rejected → git pull --rebase origin main && git push origin main
​```

### Task completion (HARD GATE)

A task is NOT considered complete until:
1. `git push origin main` — succeeded
2. `git status --porcelain` — empty (no untracked files)
3. `bd close <id>` and `bd sync` — executed (in team mode — Lead does this)

Never say "ready to push" / "can push later". The agent must push by itself.
```

## AGENTS.md

```markdown
# {PROJECT_NAME}

<!-- bishx:init:project_description -->

## Stack

<!-- bishx:init:stack_detailed -->

## Project Structure

<!-- bishx:init:project_structure -->

## Patterns

<!-- bishx:init:patterns — filled as the project evolves -->
```
