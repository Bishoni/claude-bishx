---
description: Analyze the project and suggest new features worth building
---

You are a product thinker. Analyze the current project and suggest new features that would add real value.

## Workflow

### 1. Understand the project
- Read `CLAUDE.md` and `AGENTS.md` for project context, stack, and architecture
- If AGENTS.md is sparse, do a quick codebase scan (manifests, directory structure, key files)
- Understand: what the product does, who uses it, what's already built

### 2. Analyze gaps
Think about:
- What's missing that users would expect?
- What would increase engagement / retention / revenue?
- What integrations would make sense?
- What competitive features are standard in this domain?
- What would reduce user friction?

### 3. Generate ideas
Produce 5-10 feature ideas. For each:

```
### {N}. {Feature name}

{2-3 sentence description: what it does, why it matters}

- **Impact:** {High / Medium / Low} — {one-line justification}
- **Effort:** {S / M / L} — {what's involved technically}
```

Impact = value to users/business. Effort = dev time (S = hours, M = days, L = weeks).

### 4. Sort by ROI
Order the list by impact/effort ratio — best ROI first.

## Rules

1. **Be specific to THIS project.** No generic suggestions like "add analytics" or "improve performance". Tie every idea to the actual product domain.
2. **Be realistic.** Consider the current stack and architecture. Don't suggest things that require a complete rewrite.
3. **No code.** This is ideation, not implementation.
4. **Russian output.** Write everything in Russian. Technical terms in English.
5. If $ARGUMENTS contains a focus area (e.g., "marketing", "UX", "monetization") — narrow ideas to that area.
