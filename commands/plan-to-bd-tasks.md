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
bd list --type epic --limit 0 --json
bd list --type feature --limit 0 --json
```

Analyze the result:

**Scenario A — bd is empty (0 tasks):**
→ Go to Step 1, create everything from scratch (Epic → Feature → Task).

**Scenario B — bd already has an Epic for this project:**
→ Find existing Epic by name. Remember its ID.
→ Check its children: `bd list --parent {EPIC_ID} --limit 0 --json`
→ Determine which waves/features already exist (match by `wave:N` label, not title).
→ When creating new waves — add them as children of existing Epic.
→ Do NOT create a duplicate Epic.

**Scenario C — bd has tasks from a different project/plan:**
→ Ask the user:
  - "Create a separate Epic for the new plan?" (recommended)
  - "Add waves to existing Epic {name}?"

**Resume detection:**
Check if `{directory of $ARGUMENTS}/bd-import.json` exists (i.e., the same directory that contains the plan file).
If it exists — read the mapping, verify IDs still exist in bd via `bd show {id}`. On resume, still execute Steps 1-3 (read and parse the plan fully). Then in Steps 4.1-4.5, check the progress log before each `bd create` / `bd dep add` and skip items already recorded.

### Step 1: Read the plan and CONTEXT.md

Read the plan file from `$ARGUMENTS`. If file doesn't exist — tell user and stop.

**IMPORTANT: The plan file (APPROVED_PLAN.md) is SELF-CONTAINED.** It has all 20 tasks with full details. Do NOT read iteration files (`iterations/01/PLAN.md`, etc.), do NOT read previous plan versions, do NOT read report files. Only read TWO files:
1. The plan file from `$ARGUMENTS`
2. `CONTEXT.md` from the same directory

If the plan file is too large to read at once, read it in sequential chunks using `offset` and `limit` parameters (e.g., first 500 lines, then 500-1000, etc.). Stay within the single file — do NOT jump to other files.

Also read `CONTEXT.md` from the same directory as the plan file (e.g., if plan is `.bishx-plan/2026-02-20_18-42/APPROVED_PLAN.md`, read `.bishx-plan/2026-02-20_18-42/CONTEXT.md`). If CONTEXT.md doesn't exist — warn user but continue (Epic will have a shorter description).

### Step 2: Parse plan structure

Read the entire plan and identify its structure by scanning headings, bold fields, and sections. Do NOT assume fixed heading levels or exact section names — plans may vary between bishx-plan iterations.

**What to extract:**

1. **Plan title** — the top-level `#` heading. Strip prefixes like "APPROVED" if present.

2. **Summary / requirements** — a section describing what the plan achieves (look for headings containing "Requirements", "Summary", or similar).

3. **Pre-requisites / setup** — a section with environment dependencies, migrations, etc. (look for "Pre-requisites", "Setup", "Prerequisites"). Include in Epic description.

4. **Advisory notes** — non-blocking notes from dry-run or reviewers (look for "Advisory", "Notes for Implementer"). Include in Epic description.

5. **Dependency graph / waves** — a section showing execution order and parallelism (look for "Dependency Graph", "Execution Order", "Waves"). Each Wave becomes a Feature in bd.

6. **Tasks** — identified by headings matching the pattern `Task {ID}: {title}` (e.g., `## Task T01: ...`, `### Task 1: ...`). For each task, extract:

   **Structured fields** (bold key-value pairs at the top of the task):
   - `**Files:**` — list of file paths to modify/create
   - `**Depends on:**` — dependency references (task IDs, ranges, or "none")
   - `**Complexity:**` — S/M/L (map to estimate)
   - `**Risk:**` — LOW/MEDIUM/HIGH (map to label)
   - `**Input:**` / `**Output:**` — what the task receives/produces
   - `**Rollback:**` — how to undo

   **Content sections** (identified by sub-headings within the task):
   - Implementation details (look for "What to do", "Implementation", "Steps") → `--design`
   - TDD / test content (look for "TDD", "Tests to write", "RED phase") → append to `--design`
   - Verification command (look for "Verify", "Verification") → append to `--acceptance`
   - Acceptance criteria (look for "Acceptance Criteria", checkboxes `- [ ]`) → `--acceptance`

   If a field is missing — skip it, don't invent content.

7. **Risk register** — table of risks with impact/mitigation. Not mapped to bd (already captured per-task).

**Edge cases:**
- **0 tasks in plan** — create Epic only, warn user.
- **No dependency graph / waves** — create a single Feature "Core" under Epic, attach all tasks.
- **Tasks with no TDD section** (migrations, docs) — normal, design will only contain implementation steps.
- **Tasks with empty acceptance criteria** — create without `--acceptance`, warn user.
- **Dependency ranges** like `T01-T07` — expand to individual deps.

### Step 3: Determine labels

Each task gets labels from these sources:

1. **Wave** — `wave:N` (from dependency graph wave assignment)
2. **Task ID** — `tid:{ID}` (preserves original plan task ID, e.g., `tid:T01`)
3. **Risk level** — from `**Risk:**`: `risk:low`, `risk:medium`, `risk:high`
4. **Task context** (agent-derived) — pick from standard taxonomy:
   - Architecture layer: `backend`, `frontend`, `api`, `db`, `infra`, `config`
   - Activity type: `test`, `migration`, `refactor`, `docs`
   - Domain-specific: derive from file paths (e.g., `auth`, `payments`)

Sources 1-3 are taken from the plan. Source 4 is agent-derived. Use 3-6 labels per task.
If the project already has tasks in bd (Step 0), check existing labels via `bd list --limit 0 --json` and follow naming conventions.

### Step 4: Create hierarchy in bd

**Order matters — execute strictly sequentially.**

#### Shell escaping rules (CRITICAL)

All multi-line string arguments (`-d`, `--acceptance`, `--design`, `--notes`) MUST use heredoc with unique terminators:

```bash
T01=$(bd create "Task title" --type task --parent "$W1" \
  -d "$(cat <<'__EOF_DESC__'
Multi-line description here.
Can contain "quotes", $variables, `backticks` safely.
__EOF_DESC__
)" \
  --acceptance "$(cat <<'__EOF_AC__'
- criterion 1
- criterion 2
__EOF_AC__
)" \
  --labels "wave:1,tid:T01,risk:low,backend" --silent) || { echo "FAILED to create task: $?"; }
```

For simple single-line values without special characters, direct quoting is OK.

**Rules:**
- If the value contains newlines, quotes, or shell metacharacters → always use heredoc
- Use unique terminators (`__EOF_DESC__`, `__EOF_AC__`, `__EOF_DESIGN__`) to avoid collision with plan content
- The heredoc terminator MUST appear on a line by itself with NO leading whitespace

#### Error handling (CRITICAL)

After EVERY `bd create --silent`, verify the result:
```bash
T01=$(bd create ... --silent) || { echo "ERROR: bd create failed with exit code $?"; }
if [ -z "$T01" ]; then echo "ERROR: bd create returned empty ID"; fi
```

If any `bd create` fails — stop, show the error, save progress log (Step 7), and ask the user how to proceed.

#### 4.1. Epic

If a suitable Epic was found in Step 0 — use its ID.
Otherwise create new. **Epic description must contain the full feature context** so that Dev/QA downstream can understand the big picture by reading `bd show {EPIC_ID}`.

```bash
EPIC=$(bd create "{plan title}" --type epic \
  -d "$(cat <<'__EOF_DESC__'
{requirements/summary section from plan}

## User Stories
{user stories / scenarios from CONTEXT.md, if present}

## Scope
### In Scope
{in-scope items from CONTEXT.md}

### Out of Scope
{out-of-scope items from CONTEXT.md, if present}

### Anti-Requirements (Must NOT Do)
{anti-requirements from CONTEXT.md, if present}

## Decisions
{key decisions with rationale from CONTEXT.md, if present}

## Assumptions
{explicit assumptions from CONTEXT.md, if present}

## Constraints (Frozen)
{frozen constraints from CONTEXT.md, if present}

## Trade-offs
{recorded choices with reasoning from CONTEXT.md, if present}

## Risks
{risks with likelihood/impact/mitigation from CONTEXT.md, if present}

## Stakeholders & Dependencies
{who is affected, external dependencies from CONTEXT.md, if present}

## Success Criteria
{success criteria / definition of done from CONTEXT.md, if present}

## Priority Map
{priority ordering from CONTEXT.md, if present}

## Pre-requisites
{pre-requisites section content, if present}

## Advisory Notes
{advisory notes section content, if present}
__EOF_DESC__
)" \
  --external-ref "plan:${ARGUMENTS}" \
  --silent) || { echo "FAILED to create Epic"; }
```

**Rules for Epic description:**
- Include ALL key sections from CONTEXT.md that exist. Skip sections that are absent.
- Do NOT include the full interview transcript or resolution matrix — only the distilled sections.
- Keep section headings (`## User Stories`, `## Scope`, etc.) so Dev/QA can quickly scan.
- If CONTEXT.md was not found in Step 1 — use only the plan's requirements/summary section (as before).

#### 4.2. Features (by Wave)

For each Wave from the dependency graph:
- Check: does a feature with this `wave:N` label already exist among Epic's children (from Step 0)?
- If yes — remember its ID, do NOT create duplicate.
- If no — create:
```bash
W1=$(bd create "Wave 1: {brief task list}" --type feature --parent "$EPIC" \
  -d "{wave description from dependency graph}" --labels "wave:1" --silent) || { echo "FAILED"; }
```

Features use default priority (P2). Wave ordering is handled by dependencies (Step 4.3), not priority.

#### 4.2.1. Dry-run validation

After Epic and first Wave are created (`$EPIC` and `$W1` exist), validate the first task command with `--dry-run` using the **exact same structure** as Step 4.4:
```bash
bd create "{first task title}" --type task --parent "$W1" \
  -d "$(cat <<'__EOF_DESC__'
{description}
__EOF_DESC__
)" \
  --design "$(cat <<'__EOF_DESIGN__'
{implementation}
__EOF_DESIGN__
)" \
  --acceptance "$(cat <<'__EOF_AC__'
{criteria}
__EOF_AC__
)" \
  --labels "wave:1,tid:T01,risk:low,backend" --dry-run
```
If it fails — fix the command format before proceeding with the real batch.

#### 4.3. Wave dependencies

Waves are implicitly sequential: Wave 2 depends on Wave 1, etc.

```bash
bd dep add "$W2" "$W1"    # Wave 2 depends on Wave 1
```

**`bd dep add` semantics**: `bd dep add ISSUE DEPENDS_ON` — first arg is the issue, second is what it depends on.

Skip dependencies if both ends already existed.

#### 4.4. Tasks

For each task from the plan:
```bash
T01=$(bd create "{task title}" --type task --parent "$W1" \
  -d "$(cat <<'__EOF_DESC__'
{brief summary — first 2-3 sentences of implementation section}

Files: {file paths from **Files:**}
Input: {from **Input:**, if present}
Output: {from **Output:**, if present}
Rollback: {from **Rollback:**, if present}
__EOF_DESC__
)" \
  --design "$(cat <<'__EOF_DESIGN__'
{full content of implementation section (e.g., "What to do")}

{full content of TDD section, if present}
__EOF_DESIGN__
)" \
  --acceptance "$(cat <<'__EOF_AC__'
{all - [ ] items from acceptance criteria section}
Verify: {exact command from verify section}
__EOF_AC__
)" \
  --labels "wave:1,tid:T01,risk:low,backend" \
  --estimate 60 \
  --silent) || { echo "FAILED to create task"; }
```

**Complexity → Estimate mapping** (if no explicit estimate):
- `**Complexity:** S` → `--estimate 60` (1 hour)
- `**Complexity:** M` → `--estimate 180` (3 hours)
- `**Complexity:** L` → `--estimate 480` (8 hours)

**IMPORTANT**: save the mapping `task_plan_id → bd_id` (e.g., `T01 → bd-a1b2`) for wiring dependencies.
After each successful create, append to the progress log immediately (Step 7).

#### 4.5. Task dependencies

From `**Depends on:**` of each task. Parse formats:
- `none` → skip
- `T01` → single dependency
- `T01, T02` → multiple
- `T01-T07` → range, expand to T01, T02, ..., T07
- `Task 1` / `Task 1, Task 3` → alternative format, match by number

Use the `task_plan_id → bd_id` mapping from 4.4.

```bash
bd dep add "$T02" "$T01"
```

After each successful `bd dep add`, update the `dependencies` array in the progress log with `"done": true`. This enables accurate resume if the process is interrupted during dependency wiring.

### Step 5: Field mapping principles

| What to extract | bd field | How |
|---|---|---|
| Plan title (top heading) | Epic title | Strip "APPROVED" prefix |
| Summary/requirements section | Epic `-d` | From plan |
| CONTEXT.md: User Stories | Epic `-d` (appended) | From CONTEXT.md |
| CONTEXT.md: Scope (In/Out/Anti) | Epic `-d` (appended) | From CONTEXT.md |
| CONTEXT.md: Decisions | Epic `-d` (appended) | From CONTEXT.md |
| CONTEXT.md: Assumptions | Epic `-d` (appended) | From CONTEXT.md |
| CONTEXT.md: Constraints (Frozen) | Epic `-d` (appended) | From CONTEXT.md |
| CONTEXT.md: Trade-offs | Epic `-d` (appended) | From CONTEXT.md |
| CONTEXT.md: Risks | Epic `-d` (appended) | From CONTEXT.md |
| CONTEXT.md: Stakeholders & Deps | Epic `-d` (appended) | From CONTEXT.md |
| CONTEXT.md: Success Criteria | Epic `-d` (appended) | From CONTEXT.md |
| CONTEXT.md: Priority Map | Epic `-d` (appended) | From CONTEXT.md |
| Pre-requisites section | Epic `-d` (appended) | From plan |
| Advisory/dry-run notes | Epic `-d` (appended) | From plan |
| Dependency graph waves | Feature structure | Wave N → Feature |
| Task heading | Task title | |
| `**Files:**` | Task `-d` | File list in description |
| `**Depends on:**` | `bd dep add` | Parse all ID formats |
| `**Complexity:**` | `--estimate` | S=60, M=180, L=480 min |
| `**Risk:**` | `--labels` | `risk:{level}` |
| `**Input:**` / `**Output:**` | Task `-d` | |
| `**Rollback:**` | Task `-d` | |
| Implementation section | `--design` | Full content verbatim |
| TDD / tests section | `--design` (appended) | Full content verbatim |
| Verify section | `--acceptance` (appended) | Exact command |
| Acceptance criteria | `--acceptance` | All `- [ ]` items |
| Risk register | Not mapped | Per-task risk already in labels |

### Step 6: Verification

After creating all tasks:
```bash
bd epic status              # completion status of all epics (no positional arg)
bd graph "$EPIC"            # children + dependency graph for this epic
bd dep cycles               # detect circular dependencies
bd ready                    # tasks available to start
```

- `bd epic status` — shows completion percentage for all epics (takes NO positional argument)
- `bd graph "$EPIC"` — for epics, shows all children and their dependencies as a layered graph
- `bd dep cycles` — detects circular dependencies (must return 0 cycles)
- `bd ready` — shows tasks with no open blockers

If `bd dep cycles` finds cycles — show them to the user and ask which dependency to remove.

Show user:
1. Summary: X new tasks created, Y skipped (existing), Z dependencies added
2. Dependency graph from `bd graph`
3. Which tasks are available to start (`bd ready`)

### Step 7: Save progress log

After each successful `bd create`, update the progress file for resume capability.

**Path**: `{directory of $ARGUMENTS}/bd-import.json`
Example: if `$ARGUMENTS` = `.bishx-plan/2026-02-20_18-42/APPROVED_PLAN.md`, then progress file = `.bishx-plan/2026-02-20_18-42/bd-import.json`

Content:
```json
{
  "plan_file": "{$ARGUMENTS}",
  "epic_id": "{EPIC}",
  "waves": {
    "wave:1": {"id": "W1_ID", "title": "Wave 1: T01, T05"},
    "wave:2": {"id": "W2_ID", "title": "Wave 2: T02, T03"}
  },
  "tasks": {
    "T01": {"id": "BD_ID", "title": "Rewrite DTOs..."},
    "T02": {"id": "BD_ID", "title": "Rewrite API Client..."}
  },
  "dependencies": [
    {"issue": "T02_BD_ID", "depends_on": "T01_BD_ID", "done": true}
  ],
  "imported_at": "2026-02-22T..."
}
```

**On resume**: read the file, verify each stored ID still exists via `bd show {id}`. If an ID no longer exists — recreate that item. Continue from the first missing item.

## Important rules

1. **Do NOT invent tasks** — take exactly what's in the plan. Only labels (context) and estimates (from complexity) are agent-derived.
2. **Do NOT skip tasks** — every task heading must become a bd task (unless already imported)
3. **Do NOT merge tasks** — one plan task = one bd task
4. **Do NOT create duplicates** — check existing epic/feature before creating (match by `wave:N` label)
5. **Preserve order** — tasks are created in the same order as in the plan
6. **Use `--silent`** for epic, feature, AND task creation to capture IDs
7. **All bd commands run sequentially** (each depends on previous ID)
8. **If bd create fails** — stop, show error, save progress log, ask user. Never continue silently.
9. **When ambiguous** — ask user, don't decide yourself
10. **Use heredoc** with unique terminators for multi-line values
11. **Map implementation + TDD sections → `--design`** — preserve full content verbatim
12. **Map verify section → append to `--acceptance`** — verification commands are acceptance criteria
13. **Store plan source** in Epic's `--external-ref` for traceability
14. **Verify exit codes** — check `$?` and non-empty ID after every `bd create`
15. **Run `bd dep cycles`** in verification — circular dependencies must be caught
16. **Parse dependency ranges** — `T01-T07` → expand to all individual task IDs
17. **Adapt to plan format** — identify sections by semantic meaning, not exact heading text
18. **ONLY read 2 files** — the plan file from `$ARGUMENTS` + CONTEXT.md from same directory. Do NOT read iteration files, previous versions, or report files. The plan is self-contained.

## Arguments (required)

- `$ARGUMENTS` — path to plan file. **Must be specified.** If missing — ask the user for the path, do not proceed without it.
- Example: `/bishx:plan-to-bd-tasks .bishx-plan/2026-02-20_18-42/APPROVED_PLAN.md`
