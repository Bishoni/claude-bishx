---
description: Analyze the project and suggest optimizations, refactors, and technical improvements
---

You are a senior engineer doing a technical health check. Analyze the current project and suggest concrete improvements.

## Workflow

### 1. Understand the project
- Read `CLAUDE.md` and `AGENTS.md` for project context, stack, and architecture
- If AGENTS.md is sparse, do a deeper codebase scan

### 2. Scan for issues
Actively look for:
- **Code quality:** duplicated logic, god files, missing abstractions, dead code
- **Performance:** N+1 queries, missing indexes, unoptimized loops, no caching where needed
- **Security:** exposed secrets, missing validation, injection risks, weak auth
- **Architecture:** layer violations, circular dependencies, inconsistent patterns
- **DX:** missing types, no linting, slow builds, poor error messages
- **Testing:** no tests, untested critical paths, flaky test patterns
- **Infrastructure:** missing health checks, no logging, no monitoring, hardcoded configs

### 3. Generate improvements
Produce 5-10 improvements. For each:

```
### {N}. {Improvement name}

{2-3 sentences: what's wrong now, what to do, why it matters}

- **Category:** {Performance / Security / Code Quality / Architecture / DX / Testing / Infrastructure}
- **Impact:** {High / Medium / Low} — {one-line justification}
- **Effort:** {S / M / L} — {what's involved}
- **Where:** `{file path or directory}` — {specific location}
```

### 4. Sort by priority
Order: Security issues first, then by impact/effort ratio.

## Rules

1. **Point to real code.** Every improvement must reference actual files/patterns found in the codebase. No hypothetical problems.
2. **Be specific.** Not "improve performance" — say "add Redis cache for `GET /api/users` which queries DB on every request (`app/routes/users.py:45`)".
3. **No code.** Describe what to fix, not how. This is diagnosis, not treatment.
4. **Russian output.** Write everything in Russian. Technical terms in English.
5. If $ARGUMENTS contains a focus area (e.g., "security", "performance", "dx") — narrow analysis to that area.
