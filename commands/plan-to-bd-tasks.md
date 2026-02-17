---
description: Import bishx-plan into bd (beads) as Epic → Feature → Task hierarchy with dependencies. Handles existing tasks gracefully.
---

# bishx-bd: Import plan into bd

Read the plan file specified in `$ARGUMENTS` and create a task hierarchy in bd (beads), handling existing tasks gracefully.

## Algorithm

### Step 0: Inventory existing bd tasks (MANDATORY)

**This step runs FIRST, before reading the plan.**

```bash
bd status
bd list --type epic --limit 0
bd list --type feature --limit 0
bd list --limit 0 --pretty
```

Analyze the result:

**Scenario A — bd is empty (0 tasks):**
→ Go to Step 1, create everything from scratch (Epic → Feature → Task).

**Scenario B — bd already has an Epic for this project:**
→ Find existing Epic by name. Remember its ID.
→ Check its children: `bd children {EPIC_ID}`
→ Determine which phases/features already exist.
→ When creating new phases — add them as children of existing Epic.
→ Do NOT create a duplicate Epic.

**Scenario C — bd has tasks from a different project/plan:**
→ Ask the user:
  - "Create a separate Epic for the new plan?" (recommended)
  - "Add phases to existing Epic {name}?"

**Duplicate detection:**
Before creating each feature/task — check via `bd search "{title}"`.
If an open issue with a similar title is found:
- Show user: "Similar task found: {id} — {title}. Skip or create new?"
- Default: skip the duplicate.

### Step 1: Read the plan

Read the file from `$ARGUMENTS`. If file doesn't exist — tell user and stop.

### Step 2: Parse plan structure

bishx-plan generates plans in a standard format:

```
# Implementation Plan: {title}
## Requirements Summary
## Architecture Overview
  Phase 1: ...
    Feature N: ...
  Phase 2: ...
    Feature M: ...
## Tasks
### Task 1: {title}
**Files:** ...
**Depends on:** none | Task N, Task M
#### Implementation
...
#### Acceptance Criteria
- [ ] criterion 1
- [ ] criterion 2
```

Extract from the plan:
1. **Plan title** — from `# Implementation Plan: {title}`
2. **Phases** — from `## Architecture Overview` (blocks `Phase N: ...`)
3. **Task → Phase mapping** — which tasks belong to which phase (by Feature inside Phase)
4. **Tasks** — each `### Task N: {title}` with:
   - Title
   - Description (first paragraph or `#### Implementation` — brief 2-3 sentence summary)
   - Dependencies (`**Depends on:**`)
   - Acceptance criteria (`#### Acceptance Criteria` — all `- [ ]` items)
   - Files (`**Files:**`)
   - Labels (determine from content)

### Step 3: Determine labels

Each task gets labels from two sources:

1. **Phase** — always: `phase:N`
2. **Task context** — determine from content: which files are affected, which domain, which architecture layer. Use brief, meaningful labels reflecting the task's essence. 2-4 labels per task is enough.

If the project already has tasks in bd (Step 0), check which labels are already used (`bd list --limit 0`) and follow existing naming conventions.

### Step 4: Create hierarchy in bd

**Order matters — execute strictly sequentially:**

#### 4.1. Epic

If a suitable Epic was found in Step 0 — use its ID.
Otherwise create new:
```bash
EPIC=$(bd create "{plan title}" --type epic -d "{requirements summary}" --silent)
```

#### 4.2. Features (by phase)

For each Phase from the plan:
- Check: does a feature with this name already exist among Epic's children (from Step 0)?
- If yes — remember its ID, do NOT create duplicate.
- If no — create:
```bash
PH1=$(bd create "Phase 1: {name}" --type feature --parent $EPIC -p 1 -d "{phase description}" --labels "phase:1" --silent)
```

#### 4.3. Phase dependencies

Determine phase sequence from Architecture Overview and create dependencies.
Skip dependencies if both ends already existed (dependency likely already exists).
```bash
bd dep add $PH2 $PH1    # Phase 2 depends on Phase 1
```

#### 4.4. Tasks

For each task from the plan:
```bash
T1=$(bd create "{task title}" --type task --parent $PH1 -d "{description}" --acceptance "{criteria}" --labels "phase:1,backend" --silent)
```

**IMPORTANT**: save the mapping `plan_task_number → bd_id` in memory for wiring dependencies.

#### 4.5. Task dependencies

From `**Depends on:**` of each task. Support two types of references:
- Tasks from THIS plan: `Task N` → use mapping from 4.4
- Tasks from PREVIOUS plans (if dependency references an existing task): find via `bd search`

```bash
bd dep add $T2 $T1    # Task 2 depends on Task 1
```

### Step 5: Field format

**Description** (`-d`):
Brief task description (2-4 sentences):
- What we're doing
- Why (business context)
- Which files are affected
- "Out of scope:" block — 1-2 items that are NOT part of this task

**Acceptance criteria** (`--acceptance`):
Collect all `- [ ]` items from `#### Acceptance Criteria`. If there's a `#### Verify` with a command — include it.

Format: each criterion on a new line. Only concrete checks:
- "python -c 'from app.config...' — no errors"
- "file app/services/viral/social_proof.py created and importable"
- "alembic upgrade head — migration applies without errors"

**Do NOT write** abstract criteria ("works correctly"). Only specifics.

### Step 6: Verification

After creating all tasks:
```bash
bd epic status $EPIC
bd dep tree $EPIC
bd ready
```

Show user:
1. Summary: X new tasks created, Y skipped (duplicates), Z dependencies added
2. Dependency graph
3. Which tasks are available to start (`bd ready`)

## Important rules

1. **Do NOT invent tasks** — take exactly what's in the plan
2. **Do NOT skip tasks** — every `### Task N` must become a task (unless duplicate)
3. **Do NOT merge tasks** — one Task from plan = one task in bd
4. **Do NOT create duplicates** — check existing epic/feature before creating
5. **Preserve order** — tasks are created in the same order as in the plan
6. **Use `--silent`** for epic and feature to capture IDs
7. **All bd commands run sequentially** (each depends on previous ID)
8. **If bd create fails** — show error and ask user, don't continue silently
9. **When ambiguous** — ask user, don't decide yourself

## Arguments (required)

- `$ARGUMENTS` — path to plan file. **Must be specified.** If missing — ask the user for the path, do not proceed without it.
- Example: `/bishx:plan-to-bd-tasks .bishx-plan/plan-2026-02-16-153045.md`
