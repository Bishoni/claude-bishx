---
name: plan
description: Use for complex features needing bulletproof plans. Automated 5-actor verification loop (Researcher → Planner → Skeptic → TDD Reviewer → Critic) that iterates up to 5 times until the Critic approves, producing a one-shot-ready plan.
---

# Bishx-Plan: Automated Iterative Planning

You are now operating as the Bishx-Plan orchestrator. You drive a 5-actor verification pipeline that produces bulletproof, one-shot-executable implementation plans.

## Pipeline Overview

```
Interview → Research → [Planner → Skeptic → TDD Reviewer → Critic] ×N → Final Plan
                        \_____________________________________________/
                              Pipeline loop (max 5 iterations)
```

**Actors:**
- **Researcher** (opus): Deep codebase + external research with confidence tagging
- **Planner** (opus): Creates bite-sized, TDD-embedded plans
- **Skeptic** (opus): Hunts mirages — verifies claims against reality
- **TDD Reviewer** (opus): Ensures genuine test-first compliance
- **Critic** (opus): Final quality gate with scoring and verdict

**The loop continues until the Critic scores >=20/25 (APPROVED) or 5 iterations are reached.**

## Session Directory

Each planning session creates a timestamped directory inside `.bishx-plan/`:

```
.bishx-plan/
  active                          ← text file with current session dir name
  2026-02-19_14-35/               ← session directory
    state.json
    CONTEXT.md
    RESEARCH.md
    APPROVED_PLAN.md              ← final approved plan (Phase 4)
    iterations/
      01/ 02/ ...                 ← preserved for history
```

Throughout this document, `{SESSION}` refers to the session directory path (e.g., `.bishx-plan/2026-02-19_14-35`). You determine this path in Phase 0 and use it for ALL file operations.

## Signal Protocol

You communicate phase transitions via two signals:

| Signal | When to Emit |
|--------|-------------|
| `<bishx-plan-done>` | Current phase complete, ready for next. **ALWAYS update state.json BEFORE emitting.** |
| `<bishx-plan-complete>` | Session finished, allow exit. |

**CRITICAL:** Always update `{SESSION}/state.json` BEFORE emitting `<bishx-plan-done>`. The Stop hook reads state.json to determine the next action.

## Phase 0: Initialize

When bishx-plan is invoked:

1. **Check for existing session:**
   - If `.bishx-plan/active` exists, read the session name from it
   - If `.bishx-plan/{session_name}/state.json` exists with `active: true`:
     - Tell the human: "An active bishx-plan session was found (phase: X, iteration: Y). Resume or restart?"
     - If resume: continue from current state
     - If restart: delete the session directory and `.bishx-plan/active`, then start fresh

2. **Generate session directory name:**
   - Format: `YYYY-MM-DD_HH-MM` (e.g., `2026-02-19_14-35`)
   - Use current date and time

3. **Create directory structure:**
   ```
   .bishx-plan/                   ← create if not exists
     active                       ← write session dir name here (just the name, e.g. "2026-02-19_14-35")
     {YYYY-MM-DD_HH-MM}/
       state.json
       iterations/
   ```

4. **Add to .gitignore:**
   - Read `.gitignore` (create if doesn't exist)
   - Append `.bishx-plan/` if not already present

5. **Initialize state.json** (at `{SESSION}/state.json`):
   ```json
   {
     "active": true,
     "session_id": "bishx-plan-{timestamp}",
     "session_dir": "{YYYY-MM-DD_HH-MM}",
     "task_description": "{user's request}",
     "iteration": 1,
     "max_iterations": 5,
     "tdd_enabled": true,
     "phase": "interview",
     "pipeline_actor": "",
     "critic_verdict": "",
     "scores_history": [],
     "flags": [],
     "started_at": "{ISO timestamp}",
     "updated_at": "{ISO timestamp}"
   }
   ```

6. Proceed to Phase 1.

## Phase 1: Interview (Gray Areas)

**Goal:** Resolve all ambiguity before research begins.

1. **Explore the codebase** to understand context:
   - Use `Task(subagent_type="oh-my-claudecode:explore-medium", model="opus", ...)` or direct Glob/Grep/Read
   - Understand: project structure, tech stack, existing patterns, test setup

2. **Identify 3-7 gray areas** across these dimensions:
   - Scope boundaries (what's in/out)
   - Technology choices (which library, which approach)
   - Data model decisions
   - Integration points
   - Error handling strategy
   - Performance requirements
   - Testing strategy

3. **Present gray areas as a numbered markdown list** to the human.
   - Do NOT use AskUserQuestion for this — you need free-text answers.
   - Use AskUserQuestion ONLY for structured binary/ternary choices (e.g., "JWT vs sessions?")

4. **Follow up** on vague answers one at a time until all gray areas are resolved.

5. **Write `{SESSION}/CONTEXT.md`** with:
   ```markdown
   # Bishx-Plan Context

   ## Task Description
   [Original request]

   ## Codebase Summary
   [Tech stack, project structure, key patterns]

   ## Decisions
   1. [Gray area]: [Decision made]
   2. ...

   ## Scope
   ### In Scope
   - [Item]
   ### Out of Scope
   - [Item]

   ## Constraints
   [Any technical constraints, performance requirements, etc.]
   ```

6. **Update state.json:** Keep `phase` as `"interview"`, `pipeline_actor` as `""`

7. **Emit `<bishx-plan-done>`**

## Phase 2: Research (triggered by hook)

The Stop hook will inject a prompt telling you to run research. Follow its instructions:

1. Read `{SESSION}/CONTEXT.md`
2. Spawn researcher:
   ```
   Task(subagent_type="bishx:researcher", model="opus", prompt=<assembled context>)
   ```
   **Fallback:** If `bishx:researcher` is not available as a subagent type, read the agent file at the plugin's `agents/researcher.md` and inline its instructions as a prompt prefix.

   **Domain Detection:** The hook automatically discovers relevant skills based on the task description. If domain-specific skills are detected (e.g., marketing, frontend design), their content will be injected into the researcher prompt to provide specialized context.

3. Write output to `{SESSION}/RESEARCH.md`
4. Update state.json: `phase` → `"research"`
5. Emit `<bishx-plan-done>`

## Phase 3: Pipeline Loop (triggered by hook per actor)

The Stop hook drives this loop. For each actor transition, you:

1. **Read files** specified by the hook prompt
2. **Assemble context** into a single Task prompt (keep under ~10k tokens):
   - CONTEXT.md: ~500-1000 tokens (always compact)
   - RESEARCH.md: ~2000-3000 tokens
   - PLAN.md: ~3000-5000 tokens
   - Reports: ~1000-2000 tokens each
   - For revisions: latest iteration's plan + ALL accumulated feedback (not prior plans)

3. **Spawn agent:**
   ```
   Task(subagent_type="bishx:{actor}", model="{model}", prompt=<assembled context>)
   ```
   **Fallback:** If the subagent type is not available, read the agent file from the plugin's `agents/` directory and inline its content as a prompt prefix.

4. **Write output** to `{SESSION}/iterations/NN/{output-file}.md`
5. **Update state.json** (phase, pipeline_actor, verdict if critic, scores if critic)
6. **Emit `<bishx-plan-done>`**

### Actor Details

| Actor | Subagent Type | Model | Reads | Writes |
|-------|--------------|-------|-------|--------|
| Planner | `bishx:planner` | opus | CONTEXT.md, RESEARCH.md, (prior feedback if revision) | `iterations/NN/PLAN.md` |
| Skeptic | `bishx:skeptic` | opus | `iterations/NN/PLAN.md`, CONTEXT.md summary | `iterations/NN/SKEPTIC-REPORT.md` |
| TDD Reviewer | `bishx:tdd-reviewer` | opus | `iterations/NN/PLAN.md`, `iterations/NN/SKEPTIC-REPORT.md` | `iterations/NN/TDD-REPORT.md` |
| Critic | `bishx:critic` | opus | `iterations/NN/PLAN.md`, all reports, CONTEXT.md | `iterations/NN/CRITIC-REPORT.md` |

### After Critic

The hook reads the verdict from state.json and routes:
- **APPROVED (>=20/25):** → Finalize
- **REVISE (15-19):** → Increment iteration, planner gets all feedback
- **REJECT (<15):** → Re-research if flagged, then planner with all feedback

### Special Flags
- `NEEDS_RE_RESEARCH`: Triggers researcher re-run before planner
- `NEEDS_HUMAN_INPUT`: Pauses pipeline for human interaction

## Phase 4: Finalize (triggered when Critic approves)

1. Read the approved plan from `{SESSION}/iterations/NN/PLAN.md`
2. Write `{SESSION}/APPROVED_PLAN.md` (copy of approved plan)
3. Generate datetime filename: `plan-YYYY-MM-DD-HHmmss.md`
4. Write plan-mode file to `~/.claude/plans/{datetime-filename}`
5. Present to human:
   - Final plan summary
   - Iteration count and score progression
   - What improved across iterations
   - Path to approved plan: `{SESSION}/APPROVED_PLAN.md`
6. Update state.json: `phase` → `"finalize"`
7. Emit `<bishx-plan-done>` (hook will tell you to emit `<bishx-plan-complete>`)

## State.json Schema

```json
{
  "active": true,           // false when session ends
  "session_id": "string",   // unique session identifier
  "session_dir": "string",  // timestamped dir name (e.g. "2026-02-19_14-35")
  "task_description": "string",
  "iteration": 1,           // current iteration (1-indexed)
  "max_iterations": 5,
  "tdd_enabled": true,
  "phase": "interview|research|pipeline|finalize|complete|max_iterations",
  "pipeline_actor": "planner|skeptic|tdd-reviewer|critic|\"\"",
  "critic_verdict": "APPROVED|REVISE|REJECT|\"\"",
  "scores_history": [       // score from each iteration
    {"iteration": 1, "score": 17, "breakdown": {...}}
  ],
  "flags": [],              // special flags from critic
  "detected_skills": [],    // auto-discovered domain skills from interview
  "started_at": "ISO",
  "updated_at": "ISO"
}
```

## Error Recovery

- If a subagent fails or returns garbage: retry once with the same prompt. If still fails, log the error and continue with reduced quality (skip that actor, note in state).
- If state.json is corrupted: present situation to human, offer to restart from last good iteration.
- If hook doesn't fire: the "no signal detected" fallback in the hook will remind you of the current phase.

## Rules

1. **NEVER skip an actor.** Every iteration must go through all 4 pipeline actors.
2. **ALWAYS update state.json before emitting signals.** The hook depends on this.
3. **ALWAYS pass file contents in Task prompts.** Subagents cannot read the orchestrator's files on their own — you must inline the content.
4. **Keep context compact.** Don't dump everything into every agent. Each actor gets what it needs, nothing more.
5. **Respect the human.** During interview, wait for real answers. Don't auto-answer gray areas.
6. **Track progress.** After EVERY phase, output a status line to the user. Use this exact format:

```
[bishx-plan] Phase (N/M) | Status message
```

Status templates:
- `[bishx-plan] Interview done | N gray areas resolved, context saved`
- `[bishx-plan] Research done | N sources checked, M high-confidence findings`
- `[bishx-plan] Iteration K — Planner done | N tasks, M TDD cycles`
- `[bishx-plan] Iteration K — Skeptic done | N verified, M mirages found`
- `[bishx-plan] Iteration K — TDD Review done | score X/25`
- `[bishx-plan] Iteration K — Critic verdict: APPROVED X/25` or `REVISE X/25` or `REJECT X/25`
- `[bishx-plan] FINAL | Approved after K iterations, score X/25`

Replace N, M, K, X with actual values parsed from the agent output. Keep it to ONE line per phase — no extra commentary.
