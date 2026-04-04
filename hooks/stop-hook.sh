#!/bin/bash
set -euo pipefail

HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"
PLAN_ACTIVE_FILE=".bishx-plan/active"
RUN_STATE=".omc/state/bishx-run-state.json"

# Read hook input from stdin (must happen early, before any exit paths)
HOOK_INPUT=$(cat)
TRANSCRIPT_PATH=$(echo "$HOOK_INPUT" | jq -r '.transcript_path // empty' 2>/dev/null || echo "")

LAST_OUTPUT=""
if [[ -n "$TRANSCRIPT_PATH" && -f "$TRANSCRIPT_PATH" ]]; then
  LAST_LINE=$(grep '"role":"assistant"' "$TRANSCRIPT_PATH" | tail -1 || echo "")
  if [[ -n "$LAST_LINE" ]]; then
    LAST_OUTPUT=$(echo "$LAST_LINE" | jq -r '
      .message.content |
      map(select(.type == "text")) |
      map(.text) |
      join("\n")
    ' 2>/dev/null || echo "")
  fi
fi

# ============================================================
# MODE 1: bishx-plan (planning pipeline)
# ============================================================

# Resolve session directory from active file
SESSION_DIR=""
PLAN_STATE=""
if [[ -f "$PLAN_ACTIVE_FILE" ]]; then
  SESSION_NAME=$(cat "$PLAN_ACTIVE_FILE" 2>/dev/null | tr -d '[:space:]')
  if [[ -n "$SESSION_NAME" ]]; then
    SESSION_DIR=".bishx-plan/$SESSION_NAME"
    PLAN_STATE="$SESSION_DIR/state.json"
  fi
fi

if [[ -n "$PLAN_STATE" && -f "$PLAN_STATE" ]]; then
  PLAN_ACTIVE=$(jq -r '.active // false' "$PLAN_STATE")
  if [[ "$PLAN_ACTIVE" == "true" ]]; then

    PHASE=$(jq -r '.phase // ""' "$PLAN_STATE")
    ACTOR=$(jq -r '.pipeline_actor // ""' "$PLAN_STATE")
    ITERATION=$(jq -r '.iteration // 1' "$PLAN_STATE")
    MAX_ITER=$(jq -r '.max_iterations // 10' "$PLAN_STATE")
    VERDICT=$(jq -r '.critic_verdict // ""' "$PLAN_STATE")
    FLAGS=$(jq -r '.flags // [] | join(",")' "$PLAN_STATE")
    COMPLEXITY=$(jq -r '.complexity_tier // "medium"' "$PLAN_STATE")
    if [[ -z "$COMPLEXITY" ]]; then COMPLEXITY="medium"; fi

    # Phase already complete — don't interfere (active=false may not be written yet)
    if [[ "$PHASE" == "complete" || "$PHASE" == "max_iterations" ]]; then
      exit 0
    fi

    # Safety: max iterations reached
    if [[ "$ITERATION" -gt "$MAX_ITER" ]]; then
      jq '.phase = "max_iterations"' "$PLAN_STATE" > "$PLAN_STATE.tmp" && mv "$PLAN_STATE.tmp" "$PLAN_STATE"
      PROMPT="BISHX-PLAN: Maximum iterations ($MAX_ITER) reached.

Present the BEST plan from all iterations to the human for review.

1. Read $SESSION_DIR/iterations/ and find the highest-scoring iteration
2. Present a summary: iteration count, final scores, what improved vs what couldn't be resolved
3. Ask the human whether to:
   a) Accept the plan as-is
   b) Provide additional guidance for one more iteration
   c) Cancel the session

Do NOT emit any signals. Wait for human input."
      jq -n --arg reason "$PROMPT" '{"decision": "block", "reason": $reason}'
      exit 0
    fi

    # Signal: complete — allow exit
    if echo "$LAST_OUTPUT" | grep -q "<bishx-plan-complete>"; then
      jq '.active = false | .phase = "complete"' "$PLAN_STATE" > "$PLAN_STATE.tmp" && mv "$PLAN_STATE.tmp" "$PLAN_STATE"
      exit 0
    fi

    # Signal: phase-done — route based on state
    if echo "$LAST_OUTPUT" | grep -q "<bishx-plan-done>"; then
      # Re-read state (Claude updated it before emitting signal)
      PHASE=$(jq -r '.phase // ""' "$PLAN_STATE")
      ACTOR=$(jq -r '.pipeline_actor // ""' "$PLAN_STATE")
      VERDICT=$(jq -r '.critic_verdict // ""' "$PLAN_STATE")
      ITERATION=$(jq -r '.iteration // 1' "$PLAN_STATE")
      FLAGS=$(jq -r '.flags // [] | join(",")' "$PLAN_STATE")

      case "$PHASE:$ACTOR" in
        "interview:")
          # Domain detection: discover relevant skills for this task
          TASK_DESC=$(jq -r '.task_description // ""' "$PLAN_STATE")
          DISCOVERED_SKILLS=$(bash "$HOOK_DIR/discover-skills.sh" "$TASK_DESC" 2>/dev/null || echo "[]")

          # Build skill content injection
          SKILL_CONTENT=""
          if [[ "$DISCOVERED_SKILLS" != "[]" ]] && echo "$DISCOVERED_SKILLS" | jq -e '. | length > 0' >/dev/null 2>&1; then
            SKILL_CONTENT="\n\n## Detected Domain Skills\n\nThe following skills were automatically discovered for this task:\n\n"

            while IFS= read -r skill_path; do
              skill_name=$(echo "$DISCOVERED_SKILLS" | jq -r --arg p "$skill_path" '.[] | select(.path == $p) | .name')
              if [[ -f "$skill_path" ]] && [[ -n "$skill_name" ]]; then
                skill_preview=$(head -100 "$skill_path" 2>/dev/null || true)
                SKILL_CONTENT="${SKILL_CONTENT}\n### Skill: $skill_name\n\n\`\`\`\n${skill_preview}\n\`\`\`\n\n"
              fi
            done < <(echo "$DISCOVERED_SKILLS" | jq -r '.[].path')

            DETECTED_NAMES=$(echo "$DISCOVERED_SKILLS" | jq -c '[.[].name]')
            DETECTED_PATHS_JSON=$(echo "$DISCOVERED_SKILLS" | jq -c '[.[].path]')
            jq --argjson names "$DETECTED_NAMES" --argjson paths "$DETECTED_PATHS_JSON" \
              '.detected_skills = $names | .detected_skill_paths = $paths' "$PLAN_STATE" > "$PLAN_STATE.tmp" && mv "$PLAN_STATE.tmp" "$PLAN_STATE"

            # Skill-library lookup for planner & skeptic is done by the orchestrator
            # during research→planner transition (not here). See SKILL.md "Skill-Library Lookup".
          fi

          read -r -d '' PROMPT << HEREDOC || true
BISHX-PLAN: Interview complete. Now run the RESEARCH phase.

1. Read \`${SESSION_DIR}/CONTEXT.md\` to understand the requirements and decisions.
2. Spawn the researcher agent:
   \`\`\`
   Task(subagent_type="bishx:researcher", model="opus", prompt=<CONTEXT.md content + research instructions>)
   \`\`\`
   Pass the full CONTEXT.md content in the prompt. Tell the researcher to investigate everything needed for a bulletproof implementation plan.${SKILL_CONTENT}
3. Write the researcher's output to \`${SESSION_DIR}/RESEARCH.md\`
4. Update \`${SESSION_DIR}/state.json\`: set \`phase\` to \`"research"\`, \`pipeline_actor\` to \`""\`
5. Emit \`<bishx-plan-done>\`
HEREDOC
          ;;

        "research:")
          read -r -d '' PROMPT << HEREDOC || true
BISHX-PLAN: Research complete. Now perform skill-library lookup and run the PLANNING phase.

1. Update \`${SESSION_DIR}/state.json\`: set \`phase\` to \`"pipeline"\`, \`pipeline_actor\` to \`"planner"\`, \`agent_pending\` to \`true\`
2. Read \`${SESSION_DIR}/CONTEXT.md\` and \`${SESSION_DIR}/RESEARCH.md\`
3. **Skill-library lookup for Planner and Skeptic:**
   a. Read \`~/.claude/skill-library/INDEX.md\` — identify ALL relevant categories based on tech stack from CONTEXT.md and RESEARCH.md
   b. For each relevant category, read \`~/.claude/skill-library/<category>/INDEX.md\` — review skill descriptions and "Use when..." triggers
   c. **For Planner** — select skills matching the task's technologies where "Use when..." aligns with implementation needs:
      - Implementation patterns, API usage, framework conventions, best practices
      - EXCLUDE: review-only checklists, testing methodology skills
   d. **For Skeptic** — select skills useful for verifying plan correctness:
      - Anti-pattern catalogs, correctness rules, known pitfalls, security patterns
      - EXCLUDE: step-by-step setup guides, deployment procedures
   e. For each selected skill, note the SKILL.md path and line count (use \`wc -l\` via Bash)
   f. **Budget: ≤2500 total lines per agent.** If over budget, drop least relevant skills first.
   g. Write \`${SESSION_DIR}/PLANNER-SKILLS.md\`:
      \`\`\`
      # Planner Skills
      Read these FULL SKILL.md files before creating the plan. Budget: ≤2500 lines.
      1. \`path/to/SKILL.md\` (N lines) — brief description
      \`\`\`
   h. Write \`${SESSION_DIR}/SKEPTIC-SKILLS.md\` (same format, different selection)
   i. Skills may overlap between planner and skeptic — that's fine
4. Spawn the planner agent:
   \`\`\`
   Task(subagent_type="bishx:planner", model="opus", prompt=<CONTEXT.md + RESEARCH.md content>)
   \`\`\`
   Pass both files' content in the prompt. Also tell the planner: "Read the skill files listed in \`${SESSION_DIR}/PLANNER-SKILLS.md\` before creating the plan."
5. When planner completes: set \`agent_pending\` to \`false\` in \`${SESSION_DIR}/state.json\`
6. Create directory \`${SESSION_DIR}/iterations/01/\` (use current iteration number, zero-padded)
7. Write the planner's output to \`${SESSION_DIR}/iterations/01/PLAN.md\`
8. Emit \`<bishx-plan-done>\`
HEREDOC
          ;;

        "pipeline:planner")
          ITER_DIR=$(printf "%02d" "$ITERATION")
          ACTIVE_CONDITIONAL=$(jq -r '.active_conditional // [] | join(",")' "$PLAN_STATE")

          if [[ "$COMPLEXITY" == "trivial" ]]; then
            # TRIVIAL: skip parallel review, go directly to critic
            read -r -d '' PROMPT << HEREDOC || true
BISHX-PLAN: Plan created. Complexity tier is TRIVIAL — skipping parallel review, going directly to Critic.

1. Update \`${SESSION_DIR}/state.json\`: set \`pipeline_actor\` to \`"critic"\`, \`agent_pending\` to \`true\`
2. Read the plan from \`${SESSION_DIR}/iterations/${ITER_DIR}/PLAN.md\` and \`${SESSION_DIR}/CONTEXT.md\`.
3. Spawn the Critic with simplified scoring (Correctness + Executability only):
   \`\`\`
   Task(subagent_type="bishx:critic", model="opus", prompt=<PLAN.md + CONTEXT.md + "TRIVIAL mode: score only Correctness and Executability dimensions">)
   \`\`\`
4. When Critic completes: set \`agent_pending\` to \`false\` in \`${SESSION_DIR}/state.json\`
5. Write TWO files to \`${SESSION_DIR}/iterations/${ITER_DIR}/\`:
   - \`CRITIC-REPORT.md\` — the evaluation report
   - \`VERIFIED_ITEMS.md\` — regression baseline for the next iteration (see critic agent instructions)
6. Parse verdict and score. Update \`${SESSION_DIR}/state.json\`: set \`critic_verdict\`, \`critic_score_pct\`, \`scores_history\`
7. Emit \`<bishx-plan-done>\`
HEREDOC

          elif [[ "$COMPLEXITY" == "small" ]]; then
            # SMALL: lite pipeline — only Skeptic + Completeness
            read -r -d '' PROMPT << HEREDOC || true
BISHX-PLAN: Plan created. Complexity tier is SMALL — running lite parallel review (Skeptic + Completeness only).

1. Update \`${SESSION_DIR}/state.json\`: set \`pipeline_actor\` to \`"parallel-review"\`, \`agent_pending\` to \`true\`
2. Read the plan from \`${SESSION_DIR}/iterations/${ITER_DIR}/PLAN.md\` and \`${SESSION_DIR}/CONTEXT.md\`.
3. Launch ONLY these 2 review actors IN PARALLEL (prepend OUTPUT_PATH to each prompt — agents write reports to disk themselves):
   - Task(subagent_type="bishx:skeptic", model="opus", prompt="OUTPUT_PATH: ${SESSION_DIR}/iterations/${ITER_DIR}/SKEPTIC-REPORT.md\n\n" + <PLAN.md content + CONTEXT.md summary> + "Read the skill files listed in ${SESSION_DIR}/SKEPTIC-SKILLS.md before reviewing (if file exists)")
   - Task(subagent_type="bishx:completeness-validator", model="sonnet", prompt="OUTPUT_PATH: ${SESSION_DIR}/iterations/${ITER_DIR}/COMPLETENESS-REPORT.md\n\n" + <PLAN.md content + CONTEXT.md content>)
4. When ALL actors complete: verify report files exist via Glob("${SESSION_DIR}/iterations/${ITER_DIR}/*-REPORT.md"). If any missing — warn user.
5. Set \`agent_pending\` to \`false\` in \`${SESSION_DIR}/state.json\`
6. Emit \`<bishx-plan-done>\`
HEREDOC

          else
            # MEDIUM / LARGE / EPIC: full parallel review
            read -r -d '' PROMPT << HEREDOC || true
BISHX-PLAN: Plan created. Now run PARALLEL REVIEW phase.

1. Update \`${SESSION_DIR}/state.json\`: set \`pipeline_actor\` to \`"parallel-review"\`, \`agent_pending\` to \`true\`
2. Read the plan from \`${SESSION_DIR}/iterations/${ITER_DIR}/PLAN.md\` and \`${SESSION_DIR}/CONTEXT.md\`.
3. Launch ALL applicable review actors IN PARALLEL (single response, multiple Task calls).
   Prepend OUTPUT_PATH to each prompt — agents write reports to disk themselves via Write tool.

   Always-on actors:
   - Task(subagent_type="bishx:skeptic", model="opus", prompt="OUTPUT_PATH: ${SESSION_DIR}/iterations/${ITER_DIR}/SKEPTIC-REPORT.md\n\n" + <PLAN.md content + CONTEXT.md summary> + "Read the skill files listed in ${SESSION_DIR}/SKEPTIC-SKILLS.md before reviewing (if file exists)")
   - Task(subagent_type="bishx:tdd-reviewer", model="sonnet", prompt="OUTPUT_PATH: ${SESSION_DIR}/iterations/${ITER_DIR}/TDD-REPORT.md\n\n" + <PLAN.md content>)
   - Task(subagent_type="bishx:completeness-validator", model="sonnet", prompt="OUTPUT_PATH: ${SESSION_DIR}/iterations/${ITER_DIR}/COMPLETENESS-REPORT.md\n\n" + <PLAN.md content + CONTEXT.md content>)
   - Task(subagent_type="bishx:integration-validator", model="sonnet", prompt="OUTPUT_PATH: ${SESSION_DIR}/iterations/${ITER_DIR}/INTEGRATION-REPORT.md\n\n" + <PLAN.md content>)

   Conditional actors (check state.json active_conditional field — current value: "${ACTIVE_CONDITIONAL}"):
   - If "security-reviewer" is in active_conditional: Task(subagent_type="bishx:security-reviewer", model="sonnet", prompt="OUTPUT_PATH: ${SESSION_DIR}/iterations/${ITER_DIR}/SECURITY-REPORT.md\n\n" + <PLAN.md content + CONTEXT.md content>)
   - If "performance-auditor" is in active_conditional: Task(subagent_type="bishx:performance-auditor", model="sonnet", prompt="OUTPUT_PATH: ${SESSION_DIR}/iterations/${ITER_DIR}/PERFORMANCE-REPORT.md\n\n" + <PLAN.md content>)

4. When ALL actors complete: verify ALL expected report files exist via Glob("${SESSION_DIR}/iterations/${ITER_DIR}/*-REPORT.md"). If any missing — warn user, do NOT proceed.
5. Set \`agent_pending\` to \`false\` in \`${SESSION_DIR}/state.json\`
6. Emit \`<bishx-plan-done>\`
HEREDOC
          fi
          ;;

        "pipeline:parallel-review")
          ITER_DIR=$(printf "%02d" "$ITERATION")
          read -r -d '' PROMPT << HEREDOC || true
BISHX-PLAN: Parallel review complete. Now run the CRITIC evaluation.

1. Update \`${SESSION_DIR}/state.json\`: set \`pipeline_actor\` to \`"critic"\`, \`agent_pending\` to \`true\`
2. Read ALL report files from \`${SESSION_DIR}/iterations/${ITER_DIR}/\`:
   - PLAN.md
   - SKEPTIC-REPORT.md (if exists)
   - TDD-REPORT.md (if exists)
   - COMPLETENESS-REPORT.md (if exists)
   - INTEGRATION-REPORT.md (if exists)
   - SECURITY-REPORT.md (if exists)
   - PERFORMANCE-REPORT.md (if exists)
   - \`${SESSION_DIR}/CONTEXT.md\`
   - \`${SESSION_DIR}/RESEARCH.md\`

   If iteration > 1: also read the PREVIOUS iteration's \`VERIFIED_ITEMS.md\` for regression baseline.
   Example: if current iteration is 02, read \`${SESSION_DIR}/iterations/01/VERIFIED_ITEMS.md\` (if exists).

3. Spawn critic:
   \`\`\`
   Task(subagent_type="bishx:critic", model="opus", prompt=<all reports + context + research + previous VERIFIED_ITEMS.md if applicable>)
   \`\`\`
4. When Critic completes: set \`agent_pending\` to \`false\` in \`${SESSION_DIR}/state.json\`
5. Write TWO files to \`${SESSION_DIR}/iterations/${ITER_DIR}/\`:
   - \`CRITIC-REPORT.md\` — the full evaluation report
   - \`VERIFIED_ITEMS.md\` — regression baseline for the next iteration (see critic agent instructions)
6. Parse verdict (APPROVED/REVISE/REJECT), score percentage, blocking issue count.
7. Update \`${SESSION_DIR}/state.json\`:
   - Set \`critic_verdict\` to the verdict string
   - Append scores to \`scores_history\` array
   - Set \`flags\` to any special flags from the critic (NEEDS_RE_RESEARCH, NEEDS_HUMAN_INPUT, NEEDS_SPLIT)
8. Emit \`<bishx-plan-done>\`
HEREDOC
          ;;

        "pipeline:critic")
          DRY_RUN_ENABLED=$(jq -r '.dry_run_enabled // false' "$PLAN_STATE")
          case "$VERDICT" in
            "APPROVED")
              ITER_DIR=$(printf "%02d" "$ITERATION")
              if [[ "$DRY_RUN_ENABLED" == "true" ]]; then
                read -r -d '' PROMPT << HEREDOC || true
BISHX-PLAN: Plan APPROVED! Running DRY-RUN SIMULATION (opt-in via +dry-run flag).

1. Update \`${SESSION_DIR}/state.json\`: set \`phase\` to \`"dry-run"\`, \`pipeline_actor\` to \`""\`, \`agent_pending\` to \`true\`
2. Read ONLY \`${SESSION_DIR}/iterations/${ITER_DIR}/PLAN.md\`
3. Spawn:
   \`\`\`
   Task(subagent_type="bishx:dry-run-simulator", model="opus", prompt=<PLAN.md content only>)
   \`\`\`
   IMPORTANT: Do NOT pass CONTEXT.md or RESEARCH.md — the simulator must verify executability with the plan alone.
4. When simulator completes: set \`agent_pending\` to \`false\` in \`${SESSION_DIR}/state.json\`
5. Write the simulator's output to \`${SESSION_DIR}/iterations/${ITER_DIR}/DRYRUN-REPORT.md\`
6. Parse verdict from the output: PASS, FAIL, or WARN

If PASS or WARN:
- Update \`${SESSION_DIR}/state.json\`: set \`phase\` to \`"finalize"\`
- Emit \`<bishx-plan-done>\`

If FAIL:
- Update \`${SESSION_DIR}/state.json\`: set \`critic_verdict\` to \`"REVISE"\`, append DRYRUN issues to feedback
- Emit \`<bishx-plan-done>\` (the hook will route to REVISE)
HEREDOC
              else
                read -r -d '' PROMPT << HEREDOC || true
BISHX-PLAN: Plan APPROVED! Dry-run is disabled (default). Proceeding directly to FINALIZE.

1. Update \`${SESSION_DIR}/state.json\`: set \`phase\` to \`"finalize"\`, \`pipeline_actor\` to \`""\`
2. Proceed to Phase 4 (Finalize):
   - Read the approved plan from \`${SESSION_DIR}/iterations/${ITER_DIR}/PLAN.md\`
   - Read the Critic report from \`${SESSION_DIR}/iterations/${ITER_DIR}/CRITIC-REPORT.md\`
   - Write \`${SESSION_DIR}/APPROVED_PLAN.md\` (copy of approved plan with Execution Readiness Summary appended)
   - Generate datetime filename and write to \`~/.claude/plans/\`
   - Present final summary to human
3. Update state.json: \`phase\` → \`"finalize"\`
4. Emit \`<bishx-plan-done>\`
HEREDOC
              fi
              ;;

            "REVISE")
              NEW_ITER=$((ITERATION + 1))
              jq ".iteration = $NEW_ITER | .critic_verdict = \"\" | .pipeline_actor = \"planner\" | .flags = []" "$PLAN_STATE" > "$PLAN_STATE.tmp" && mv "$PLAN_STATE.tmp" "$PLAN_STATE"
              OLD_ITER_DIR=$(printf "%02d" "$ITERATION")
              NEW_ITER_DIR=$(printf "%02d" "$NEW_ITER")

              if echo "$FLAGS" | grep -q "NEEDS_SPLIT"; then
                read -r -d '' PROMPT << HEREDOC || true
BISHX-PLAN: Plan flagged NEEDS_SPLIT (iteration ${NEW_ITER} of ${MAX_ITER}).

The Critic determined the plan is too large or spans multiple bounded contexts and needs decomposition.

1. Read the Critic report at \`${SESSION_DIR}/iterations/${OLD_ITER_DIR}/CRITIC-REPORT.md\`
2. Also read \`${SESSION_DIR}/iterations/${OLD_ITER_DIR}/VERIFIED_ITEMS.md\` (if exists)
3. Present the NEEDS_SPLIT recommendation to the human with suggested split boundaries
4. Wait for human response — do NOT proceed automatically
5. After receiving human guidance on how to split, either:
   a. Decompose into sub-plans (create separate sessions for each), or
   b. If human overrides, continue with the current plan as-is
6. Update \`${SESSION_DIR}/CONTEXT.md\` with the split decision
7. Update \`${SESSION_DIR}/state.json\`: set \`phase\` to \`"pipeline"\`, \`pipeline_actor\` to \`"planner"\`
8. Set \`agent_pending\` to \`true\` in \`${SESSION_DIR}/state.json\`. Spawn the planner with updated scope. Tell the planner: "Read the skill files listed in \`${SESSION_DIR}/PLANNER-SKILLS.md\` (if exists). Do NOT break items listed in VERIFIED_ITEMS.md." When planner completes, set \`agent_pending\` to \`false\`. Emit \`<bishx-plan-done>\`

Do NOT emit any signals until human responds.
HEREDOC
              elif echo "$FLAGS" | grep -q "NEEDS_HUMAN_INPUT"; then
                read -r -d '' PROMPT << HEREDOC || true
BISHX-PLAN: Plan needs REVISION with NEEDS_HUMAN_INPUT flag (iteration ${NEW_ITER} of ${MAX_ITER}).

The Critic needs human guidance before continuing.

1. Read the Critic report at \`${SESSION_DIR}/iterations/${OLD_ITER_DIR}/CRITIC-REPORT.md\`
2. Present the specific questions/decisions that need human input
3. Wait for human response — do NOT proceed automatically
4. After receiving human input, update \`${SESSION_DIR}/CONTEXT.md\` with the new decisions
5. Then spawn the researcher if NEEDS_RE_RESEARCH is also flagged, otherwise go straight to planner
6. Update \`${SESSION_DIR}/state.json\`: set \`phase\` to \`"pipeline"\`, \`pipeline_actor\` to \`"planner"\`
7. Set \`agent_pending\` to \`true\` before spawning any agent. If spawning planner, tell it to read skill files listed in \`${SESSION_DIR}/PLANNER-SKILLS.md\` (if exists). Continue the pipeline as normal after human input is incorporated. When agent completes, set \`agent_pending\` to \`false\`. Emit \`<bishx-plan-done>\`

Do NOT emit any signals until human responds.
HEREDOC
              elif echo "$FLAGS" | grep -q "NEEDS_RE_RESEARCH"; then
                read -r -d '' PROMPT << HEREDOC || true
BISHX-PLAN: Plan needs REVISION with RE-RESEARCH (iteration ${NEW_ITER} of ${MAX_ITER}).

The Critic flagged NEEDS_RE_RESEARCH. Run targeted research first.

**IMPORTANT:** Before spawning any agent, set \`agent_pending\` to \`true\` in state.json. After the agent completes, set it to \`false\`.

1. Update \`${SESSION_DIR}/state.json\`: set \`phase\` to \`"pipeline"\`, \`pipeline_actor\` to \`"planner"\`, clear \`flags\`
2. Read the Critic report at \`${SESSION_DIR}/iterations/${OLD_ITER_DIR}/CRITIC-REPORT.md\` to identify what needs re-research.
3. Set \`agent_pending\` to \`true\` in state.json. Spawn the researcher agent with targeted scope:
   \`\`\`
   Task(subagent_type="bishx:researcher", model="opus", prompt=<targeted research questions from critic report>)
   \`\`\`
4. When researcher completes: set \`agent_pending\` to \`false\`. Append the new findings to \`${SESSION_DIR}/RESEARCH.md\` under a "## Supplemental Research (Iteration ${NEW_ITER})" heading.
5. Read ALL available feedback (skip files that don't exist — not all actors run in every complexity tier):
   - \`${SESSION_DIR}/iterations/${OLD_ITER_DIR}/SKEPTIC-REPORT.md\` (if exists)
   - \`${SESSION_DIR}/iterations/${OLD_ITER_DIR}/TDD-REPORT.md\` (if exists)
   - \`${SESSION_DIR}/iterations/${OLD_ITER_DIR}/COMPLETENESS-REPORT.md\` (if exists)
   - \`${SESSION_DIR}/iterations/${OLD_ITER_DIR}/INTEGRATION-REPORT.md\` (if exists)
   - \`${SESSION_DIR}/iterations/${OLD_ITER_DIR}/SECURITY-REPORT.md\` (if exists)
   - \`${SESSION_DIR}/iterations/${OLD_ITER_DIR}/PERFORMANCE-REPORT.md\` (if exists)
   - \`${SESSION_DIR}/iterations/${OLD_ITER_DIR}/CRITIC-REPORT.md\`
   - \`${SESSION_DIR}/iterations/${OLD_ITER_DIR}/DRYRUN-REPORT.md\` (if exists)
   - \`${SESSION_DIR}/iterations/${OLD_ITER_DIR}/VERIFIED_ITEMS.md\` (if exists)
   - Updated \`${SESSION_DIR}/RESEARCH.md\`
   - \`${SESSION_DIR}/CONTEXT.md\`
6. Set \`agent_pending\` to \`true\` in state.json. Spawn the planner agent:
   \`\`\`
   Task(subagent_type="bishx:planner", model="opus", prompt=<all feedback + research + context>)
   \`\`\`
   Tell the planner to read skill files listed in \`${SESSION_DIR}/PLANNER-SKILLS.md\` (if exists).
   Tell the planner: "Address EVERY issue from prior reports. Do NOT break items listed in VERIFIED_ITEMS.md. Include a Revision Notes section."
7. When planner completes: set \`agent_pending\` to \`false\`
8. Create directory \`${SESSION_DIR}/iterations/${NEW_ITER_DIR}/\`
9. Write the planner's output to \`${SESSION_DIR}/iterations/${NEW_ITER_DIR}/PLAN.md\`
10. Emit \`<bishx-plan-done>\`
HEREDOC
              else
                read -r -d '' PROMPT << HEREDOC || true
BISHX-PLAN: Plan needs REVISION (iteration ${NEW_ITER} of ${MAX_ITER}).

**IMPORTANT:** Before spawning any agent, set \`agent_pending\` to \`true\` in state.json. After the agent completes, set it to \`false\`.

1. Read ALL available feedback from the previous iteration (skip files that don't exist — not all actors run in every complexity tier):
   - \`${SESSION_DIR}/iterations/${OLD_ITER_DIR}/PLAN.md\` (previous plan for reference)
   - \`${SESSION_DIR}/iterations/${OLD_ITER_DIR}/SKEPTIC-REPORT.md\` (if exists)
   - \`${SESSION_DIR}/iterations/${OLD_ITER_DIR}/TDD-REPORT.md\` (if exists)
   - \`${SESSION_DIR}/iterations/${OLD_ITER_DIR}/COMPLETENESS-REPORT.md\` (if exists)
   - \`${SESSION_DIR}/iterations/${OLD_ITER_DIR}/INTEGRATION-REPORT.md\` (if exists)
   - \`${SESSION_DIR}/iterations/${OLD_ITER_DIR}/SECURITY-REPORT.md\` (if exists)
   - \`${SESSION_DIR}/iterations/${OLD_ITER_DIR}/PERFORMANCE-REPORT.md\` (if exists)
   - \`${SESSION_DIR}/iterations/${OLD_ITER_DIR}/CRITIC-REPORT.md\`
   - \`${SESSION_DIR}/iterations/${OLD_ITER_DIR}/DRYRUN-REPORT.md\` (if exists)
   - \`${SESSION_DIR}/iterations/${OLD_ITER_DIR}/VERIFIED_ITEMS.md\` (if exists)
   - \`${SESSION_DIR}/CONTEXT.md\`
   - \`${SESSION_DIR}/RESEARCH.md\`
2. Set \`agent_pending\` to \`true\` in state.json. Spawn the planner agent:
   \`\`\`
   Task(subagent_type="bishx:planner", model="opus", prompt=<all available feedback + context + research>)
   \`\`\`
   Tell the planner to read skill files listed in \`${SESSION_DIR}/PLANNER-SKILLS.md\` (if exists).
   Tell the planner: "This is iteration ${NEW_ITER}. Address EVERY issue from the available review reports and the Critic report. Do NOT break items listed in VERIFIED_ITEMS.md. Include a Revision Notes section at the top listing each issue and how it was addressed. Do not silently ignore feedback."
3. When planner completes: set \`agent_pending\` to \`false\` in state.json.
4. Create directory \`${SESSION_DIR}/iterations/${NEW_ITER_DIR}/\`
5. Write the planner's output to \`${SESSION_DIR}/iterations/${NEW_ITER_DIR}/PLAN.md\`
6. Update \`${SESSION_DIR}/state.json\`: set \`phase\` to \`"pipeline"\`, \`pipeline_actor\` to \`"planner"\`, clear \`flags\`
7. Emit \`<bishx-plan-done>\`
HEREDOC
              fi
              ;;

            "REJECT")
              NEW_ITER=$((ITERATION + 1))
              jq ".iteration = $NEW_ITER | .critic_verdict = \"\" | .pipeline_actor = \"planner\" | .flags = []" "$PLAN_STATE" > "$PLAN_STATE.tmp" && mv "$PLAN_STATE.tmp" "$PLAN_STATE"
              OLD_ITER_DIR=$(printf "%02d" "$ITERATION")
              NEW_ITER_DIR=$(printf "%02d" "$NEW_ITER")

              if echo "$FLAGS" | grep -q "NEEDS_HUMAN_INPUT"; then
                read -r -d '' PROMPT << HEREDOC || true
BISHX-PLAN: Plan REJECTED with NEEDS_HUMAN_INPUT flag (iteration ${NEW_ITER} of ${MAX_ITER}).

The Critic needs human guidance before continuing.

1. Read the Critic report at \`${SESSION_DIR}/iterations/${OLD_ITER_DIR}/CRITIC-REPORT.md\`
2. Present the specific questions/decisions that need human input
3. Wait for human response — do NOT proceed automatically
4. After receiving human input, update \`${SESSION_DIR}/CONTEXT.md\` with the new decisions
5. Then spawn the researcher if NEEDS_RE_RESEARCH is also flagged, otherwise go straight to planner
6. Update \`${SESSION_DIR}/state.json\`: set \`phase\` to \`"pipeline"\`, \`pipeline_actor\` to \`"planner"\`
7. Set \`agent_pending\` to \`true\` before spawning any agent. If spawning planner, tell it to read skill files listed in \`${SESSION_DIR}/PLANNER-SKILLS.md\` (if exists). Continue the pipeline as normal after human input is incorporated. When agent completes, set \`agent_pending\` to \`false\`. Emit \`<bishx-plan-done>\`

Do NOT emit any signals until human responds.
HEREDOC
              else
                read -r -d '' PROMPT << HEREDOC || true
BISHX-PLAN: Plan REJECTED (iteration ${NEW_ITER} of ${MAX_ITER}).

Fundamental issues require re-research.

**IMPORTANT:** Before spawning any agent, set \`agent_pending\` to \`true\` in state.json. After the agent completes, set it to \`false\`.

1. Read the Critic report at \`${SESSION_DIR}/iterations/${OLD_ITER_DIR}/CRITIC-REPORT.md\`
2. Set \`agent_pending\` to \`true\` in state.json. Spawn the researcher agent with targeted scope based on the rejection reasons:
   \`\`\`
   Task(subagent_type="bishx:researcher", model="opus", prompt=<rejection reasons + targeted research questions>)
   \`\`\`
3. When researcher completes: set \`agent_pending\` to \`false\`. Append findings to \`${SESSION_DIR}/RESEARCH.md\` under "## Re-Research (Iteration ${NEW_ITER})"
4. Read ALL available prior feedback and updated research (skip files that don't exist — not all actors run in every complexity tier):
   - \`${SESSION_DIR}/iterations/${OLD_ITER_DIR}/SKEPTIC-REPORT.md\` (if exists)
   - \`${SESSION_DIR}/iterations/${OLD_ITER_DIR}/TDD-REPORT.md\` (if exists)
   - \`${SESSION_DIR}/iterations/${OLD_ITER_DIR}/COMPLETENESS-REPORT.md\` (if exists)
   - \`${SESSION_DIR}/iterations/${OLD_ITER_DIR}/INTEGRATION-REPORT.md\` (if exists)
   - \`${SESSION_DIR}/iterations/${OLD_ITER_DIR}/SECURITY-REPORT.md\` (if exists)
   - \`${SESSION_DIR}/iterations/${OLD_ITER_DIR}/PERFORMANCE-REPORT.md\` (if exists)
   - \`${SESSION_DIR}/iterations/${OLD_ITER_DIR}/CRITIC-REPORT.md\`
   - \`${SESSION_DIR}/iterations/${OLD_ITER_DIR}/DRYRUN-REPORT.md\` (if exists)
   - \`${SESSION_DIR}/iterations/${OLD_ITER_DIR}/VERIFIED_ITEMS.md\` (if exists)
5. Set \`agent_pending\` to \`true\` in state.json. Spawn the planner agent with all available context. Tell the planner: "Read the skill files listed in \`${SESSION_DIR}/PLANNER-SKILLS.md\` (if exists). Do NOT break items listed in VERIFIED_ITEMS.md."
6. When planner completes: set \`agent_pending\` to \`false\`
7. Create \`${SESSION_DIR}/iterations/${NEW_ITER_DIR}/\`
8. Write output to \`${SESSION_DIR}/iterations/${NEW_ITER_DIR}/PLAN.md\`
9. Update \`${SESSION_DIR}/state.json\`: set \`phase\` to \`"pipeline"\`, \`pipeline_actor\` to \`"planner"\`, clear \`flags\`
10. Emit \`<bishx-plan-done>\`
HEREDOC
              fi
              ;;

            *)
              read -r -d '' PROMPT << HEREDOC || true
BISHX-PLAN: Could not parse Critic verdict. Re-read the latest CRITIC-REPORT.md from ${SESSION_DIR}/iterations/, extract the verdict (must be APPROVED, REVISE, or REJECT), update state.json with the correct critic_verdict, and emit <bishx-plan-done>.
HEREDOC
              ;;
          esac
          ;;

        "dry-run:")
          ITER_DIR=$(printf "%02d" "$ITERATION")
          if [[ "$VERDICT" == "REVISE" ]]; then
            # Dry-run FAIL path: route to planner for revision (not re-run dry-run)
            NEW_ITER=$((ITERATION + 1))
            jq ".iteration = $NEW_ITER | .critic_verdict = \"\" | .pipeline_actor = \"planner\" | .phase = \"pipeline\" | .flags = []" "$PLAN_STATE" > "$PLAN_STATE.tmp" && mv "$PLAN_STATE.tmp" "$PLAN_STATE"
            OLD_ITER_DIR=$(printf "%02d" "$ITERATION")
            NEW_ITER_DIR=$(printf "%02d" "$NEW_ITER")
            read -r -d '' PROMPT << HEREDOC || true
BISHX-PLAN: Dry-run FAILED. Plan needs REVISION (iteration ${NEW_ITER} of ${MAX_ITER}).

1. Read available feedback from \`${SESSION_DIR}/iterations/${OLD_ITER_DIR}/\`:
   - \`PLAN.md\` (previous plan)
   - \`CRITIC-REPORT.md\`
   - \`DRYRUN-REPORT.md\`
   - \`SKEPTIC-REPORT.md\` (if exists)
   - \`TDD-REPORT.md\` (if exists)
   - \`COMPLETENESS-REPORT.md\` (if exists)
   - \`INTEGRATION-REPORT.md\` (if exists)
   - \`SECURITY-REPORT.md\` (if exists)
   - \`PERFORMANCE-REPORT.md\` (if exists)
   - \`VERIFIED_ITEMS.md\` (if exists)
   Also read \`${SESSION_DIR}/CONTEXT.md\` and \`${SESSION_DIR}/RESEARCH.md\`
2. Focus on the DRYRUN-REPORT issues — these are executability problems the simulator found. Do NOT break items listed in VERIFIED_ITEMS.md.
3. Spawn the planner agent with all available feedback. Tell the planner to read skill files listed in \`${SESSION_DIR}/PLANNER-SKILLS.md\` (if exists).
4. Create \`${SESSION_DIR}/iterations/${NEW_ITER_DIR}/\`
5. Write output to \`${SESSION_DIR}/iterations/${NEW_ITER_DIR}/PLAN.md\`
6. Update \`${SESSION_DIR}/state.json\`: set \`phase\` to \`"pipeline"\`, \`pipeline_actor\` to \`"planner"\`, clear \`flags\`
7. Emit \`<bishx-plan-done>\`
HEREDOC
          else
            # Normal dry-run: spawn simulator
            read -r -d '' PROMPT << HEREDOC || true
BISHX-PLAN: You are in DRY-RUN phase. Spawn the dry-run simulator.

Read ONLY \`${SESSION_DIR}/iterations/${ITER_DIR}/PLAN.md\`

Spawn:
\`\`\`
Task(subagent_type="bishx:dry-run-simulator", model="opus", prompt=<PLAN.md content only>)
\`\`\`
IMPORTANT: Do NOT pass CONTEXT.md or RESEARCH.md — the simulator must verify executability with the plan alone.

Write the simulator's output to \`${SESSION_DIR}/iterations/${ITER_DIR}/DRYRUN-REPORT.md\`
Parse verdict: PASS, FAIL, or WARN

If PASS or WARN: Update \`${SESSION_DIR}/state.json\` phase to \`"finalize"\`, emit \`<bishx-plan-done>\`
If FAIL: Set \`critic_verdict\` to \`"REVISE"\`, add DRYRUN issues to feedback, emit \`<bishx-plan-done>\`
HEREDOC
          fi
          ;;

        "finalize:")
          read -r -d '' PROMPT << 'HEREDOC' || true
BISHX-PLAN: Finalization complete. The plan has been delivered to the human.

Emit <bishx-plan-complete> to end the session.
HEREDOC
          ;;

        *)
          read -r -d '' PROMPT << HEREDOC || true
BISHX-PLAN: Unknown state encountered. Read ${SESSION_DIR}/state.json to understand current phase and continue the pipeline. If state is corrupted, present the situation to the human and ask for guidance.
HEREDOC
          ;;
      esac

      jq -n --arg reason "$PROMPT" '{"decision": "block", "reason": $reason}'
      exit 0
    fi

    # No signal detected — handle based on phase (bishx-plan)
    # Check if an agent is currently running in the background
    AGENT_PENDING=$(jq -r '.agent_pending // false' "$PLAN_STATE")
    if [[ "$AGENT_PENDING" == "true" ]]; then
      # Agent is executing in background — don't interfere
      exit 0
    fi

    case "$PHASE:$ACTOR" in
      "interview:")
        # Don't block during interview — let Claude wait for user input
        exit 0
        ;;
      *)
        case "$PHASE:$ACTOR" in
          "research:")
            PROMPT="BISHX-PLAN: You are in the RESEARCH phase. Spawn the researcher agent and write results to ${SESSION_DIR}/RESEARCH.md. When done, update state.json and emit <bishx-plan-done>."
            ;;
          "pipeline:planner")
            PROMPT="BISHX-PLAN: You are in the PLANNING phase. Spawn the planner agent and write PLAN.md. Tell the planner to read skill files listed in ${SESSION_DIR}/PLANNER-SKILLS.md (if exists). When done, update state.json and emit <bishx-plan-done>."
            ;;
          "pipeline:parallel-review")
            # Check if reports already exist on disk (agents write directly)
            PR_ITER_DIR=$(printf "%02d" "$ITERATION")
            PR_REPORTS_DIR="$SESSION_DIR/iterations/$PR_ITER_DIR"
            PR_FOUND=0
            PR_EXPECTED=("SKEPTIC-REPORT.md" "TDD-REPORT.md" "COMPLETENESS-REPORT.md" "INTEGRATION-REPORT.md")
            PR_ACTIVE_COND=$(jq -r '.active_conditional // [] | .[]' "$PLAN_STATE" 2>/dev/null || true)
            echo "$PR_ACTIVE_COND" | grep -q "security-reviewer" 2>/dev/null && PR_EXPECTED+=("SECURITY-REPORT.md")
            echo "$PR_ACTIVE_COND" | grep -q "performance-auditor" 2>/dev/null && PR_EXPECTED+=("PERFORMANCE-REPORT.md")
            # For SMALL tier, only expect 2 reports
            if [[ "$COMPLEXITY" == "small" ]]; then
              PR_EXPECTED=("SKEPTIC-REPORT.md" "COMPLETENESS-REPORT.md")
            fi
            PR_TOTAL=${#PR_EXPECTED[@]}
            for prf in "${PR_EXPECTED[@]}"; do
              [[ -f "$PR_REPORTS_DIR/$prf" ]] && ((PR_FOUND++)) || true
            done

            if [[ $PR_FOUND -eq $PR_TOTAL ]]; then
              PROMPT="BISHX-PLAN: All $PR_TOTAL review reports found on disk in $PR_REPORTS_DIR. Transition to CRITIC phase. Set pipeline_actor to 'critic', agent_pending to true, read all reports, and proceed to Critic. When done, update state.json and emit <bishx-plan-done>."
            elif [[ $PR_FOUND -gt 0 ]]; then
              PROMPT="BISHX-PLAN: $PR_FOUND/$PR_TOTAL review reports written to $PR_REPORTS_DIR. Some agents may still be running. Check remaining reports and wait for completion. When ALL reports exist, set agent_pending to false and emit <bishx-plan-done>."
            else
              PROMPT="BISHX-PLAN: You are in PARALLEL REVIEW. Launch all parallel actors (with OUTPUT_PATH for each) and let them write reports to disk. Tell Skeptic to read skill files listed in ${SESSION_DIR}/SKEPTIC-SKILLS.md (if exists). When done, verify all files exist, update state.json and emit <bishx-plan-done>."
            fi
            ;;
          "pipeline:critic")
            PROMPT="BISHX-PLAN: You are in the CRITIC phase. Spawn the critic agent and write CRITIC-REPORT.md. When done, update state.json with the verdict and emit <bishx-plan-done>."
            ;;
          "dry-run:")
            DRY_RUN_CHECK=$(jq -r '.dry_run_enabled // false' "$PLAN_STATE")
            if [[ "$DRY_RUN_CHECK" == "true" ]]; then
              PROMPT="BISHX-PLAN: You are in DRY-RUN phase. Spawn the dry-run simulator with PLAN.md only. Write DRYRUN-REPORT.md, parse the verdict, update state.json, and emit <bishx-plan-done>."
            else
              PROMPT="BISHX-PLAN: Dry-run is disabled but phase is dry-run. This is unexpected. Set phase to 'finalize' and emit <bishx-plan-done>."
            fi
            ;;
          "finalize:")
            PROMPT="BISHX-PLAN: Finalization in progress. Complete the finalization steps and emit <bishx-plan-done>."
            ;;
          *)
            PROMPT="BISHX-PLAN: Session is active but state is unclear. Read ${SESSION_DIR}/state.json and continue the current phase. Emit <bishx-plan-done> when the current phase is complete."
            ;;
        esac
        jq -n --arg reason "$PROMPT" '{"decision": "block", "reason": $reason}'
        exit 0
        ;;
    esac
  fi
fi

# ============================================================
# MODE 2: bishx-run (task execution loop)
# ============================================================

if [[ -f "$RUN_STATE" ]]; then
  RUN_ACTIVE=$(jq -r '.active // false' "$RUN_STATE")
  if [[ "$RUN_ACTIVE" == "true" ]]; then

    # Teammates (dev, qa, reviewers) should NOT be blocked by this hook.
    # Only Lead should be kept alive. Detect by comparing session_id:
    # First Stop call records Lead's session_id. Subsequent calls from
    # teammate panes (different session_id) are allowed through.
    HOOK_SESSION_ID=$(echo "$HOOK_INPUT" | jq -r '.session_id // empty' 2>/dev/null || echo "")
    LEAD_SESSION_ID=$(jq -r '.lead_session_id // ""' "$RUN_STATE" 2>/dev/null || echo "")
    if [[ -n "$HOOK_SESSION_ID" ]]; then
      if [[ -z "$LEAD_SESSION_ID" || "$LEAD_SESSION_ID" == "null" ]]; then
        # First Stop call — record Lead's session_id
        jq --arg sid "$HOOK_SESSION_ID" '.lead_session_id = $sid' "$RUN_STATE" > "$RUN_STATE.tmp" && mv "$RUN_STATE.tmp" "$RUN_STATE"
      elif [[ "$HOOK_SESSION_ID" != "$LEAD_SESSION_ID" ]]; then
        # Different session_id → this is a teammate pane, not Lead — allow stop
        exit 0
      fi
    fi

    CURRENT_TASK=$(jq -r '.current_task // ""' "$RUN_STATE")

    # Signal: complete — allow exit
    if echo "$LAST_OUTPUT" | grep -q "<bishx-complete>"; then
      jq '.active = false' "$RUN_STATE" > "$RUN_STATE.tmp" && mv "$RUN_STATE.tmp" "$RUN_STATE"
      exit 0
    fi

    # Active session, no complete signal → keep the loop alive
    WAITING_FOR=$(jq -r '.waiting_for // ""' "$RUN_STATE" 2>/dev/null || echo "")

    if [[ -n "$WAITING_FOR" && "$WAITING_FOR" != "null" ]]; then
      # Lead is WAITING for a teammate → allow stop, teammate's SendMessage
      # will be delivered automatically as a new turn
      exit 0
    elif [[ ${#LAST_OUTPUT} -lt 15 ]] && echo "$LAST_OUTPUT" | grep -qiE "^[[:space:]]*(Жду|Ожидаю|Waiting for|На месте)[[:space:].!]*$"; then
      # Lead's ENTIRE output is just a short waiting phrase (not part of longer work message)
      # Forgot to set waiting_for in state → allow exit to prevent infinite loop
      exit 0
    elif [[ -z "$CURRENT_TASK" || "$CURRENT_TASK" == "null" ]]; then
      # No current task → IDLE mode, allow exit
      exit 0
    else
      # Lead is NOT waiting → short nudge to continue
      PROMPT="BISHX-RUN: Do not stop. Continue from where you left off. Current task: ${CURRENT_TASK:-none}."
    fi

    jq -n --arg reason "$PROMPT" '{"decision": "block", "reason": $reason}'
    exit 0
  fi
fi

# ============================================================
# MODE 3: bishx-site (website audit)
# ============================================================

SITE_ACTIVE_FILE=".bishx-site/active"
SITE_SESSION_DIR=""
SITE_STATE=""
if [[ -f "$SITE_ACTIVE_FILE" ]]; then
  SITE_SESSION_NAME=$(cat "$SITE_ACTIVE_FILE" 2>/dev/null | tr -d '[:space:]')
  if [[ -n "$SITE_SESSION_NAME" ]]; then
    SITE_SESSION_DIR=".bishx-site/$SITE_SESSION_NAME"
    SITE_STATE="$SITE_SESSION_DIR/state.json"
  fi
fi

if [[ -n "$SITE_STATE" && -f "$SITE_STATE" ]]; then
  SITE_ACTIVE=$(jq -r '.active // false' "$SITE_STATE" 2>/dev/null || echo "false")
  if [[ "$SITE_ACTIVE" == "true" ]]; then

    SITE_PHASE=$(jq -r '.phase // ""' "$SITE_STATE" 2>/dev/null || echo "")
    MODULES_TOTAL=$(jq -r '.modules_total // 0' "$SITE_STATE" 2>/dev/null || echo "0")
    SITE_WAVE=$(jq -r '.wave // 0' "$SITE_STATE" 2>/dev/null || echo "0")

    # Terminal state — allow exit immediately
    if [[ "$SITE_PHASE" == "complete" || "$SITE_PHASE" == "cancelled" ]]; then
      rm -f "$SITE_ACTIVE_FILE" 2>/dev/null || true
      exit 0
    fi

    # Signal: complete — allow exit, clean up (checked BEFORE agent_pending
    # so that a complete signal from a finishing agent is never missed)
    if echo "$LAST_OUTPUT" | grep -q "<bishx-site-complete>"; then
      jq '.active = false | .phase = "complete"' "$SITE_STATE" > "$SITE_STATE.tmp" && mv "$SITE_STATE.tmp" "$SITE_STATE"
      rm -f "$SITE_ACTIVE_FILE"
      exit 0
    fi

    # Agent is running — don't interfere
    SITE_AGENT_PENDING=$(jq -r '.agent_pending // false' "$SITE_STATE" 2>/dev/null || echo "false")
    if [[ "$SITE_AGENT_PENDING" == "true" ]]; then
      exit 0
    fi

    # Waiting for user input (ASK phase) — allow exit
    SITE_WAITING=$(jq -r '.waiting_for // ""' "$SITE_STATE" 2>/dev/null || echo "")
    if [[ -n "$SITE_WAITING" && "$SITE_WAITING" != "null" ]]; then
      exit 0
    fi

    # Signal: phase-done — route based on state
    if echo "$LAST_OUTPUT" | grep -q "<bishx-site-done>"; then
      SITE_PHASE=$(jq -r '.phase // ""' "$SITE_STATE" 2>/dev/null || echo "")
      SITE_WAVE=$(jq -r '.wave // 0' "$SITE_STATE" 2>/dev/null || echo "0")

      case "$SITE_PHASE" in

        "discover")
          # Discovery complete → transition to ASK phase
          jq '.phase = "ask" | .waiting_for = "scope_selection"' "$SITE_STATE" > "$SITE_STATE.tmp" && mv "$SITE_STATE.tmp" "$SITE_STATE"
          read -r -d '' PROMPT << HEREDOC || true
BISHX-SITE: Discovery complete. Now run ASK phase — present scope confirmation to user.

1. Phase is now 'ask' (set by stop hook). Present AskUserQuestion with scope options (see SKILL.md Phase 0.5)
2. Read \`${SITE_SESSION_DIR}/discovery.json\` to get page count and business type
3. Present AskUserQuestion with scope options
4. After user responds: update \`selected_modules\` in state.json, set \`modules_total\` to len(selected_modules), set \`waiting_for\` to \`""\`. Then emit \`<bishx-site-done>\`
HEREDOC
          ;;

        "ask")
          # ASK complete, user selected scope → transition to Execute Wave 1
          jq '.phase = "execute" | .wave = 1 | .agent_pending = true | .waiting_for = ""' "$SITE_STATE" > "$SITE_STATE.tmp" && mv "$SITE_STATE.tmp" "$SITE_STATE"
          # Read selected_modules from state to build dynamic module list
          SELECTED_MODULES=$(jq -r '.selected_modules // [] | join(",")' "$SITE_STATE" 2>/dev/null || echo "")

          read -r -d '' PROMPT << HEREDOC || true
BISHX-SITE: Scope selection complete. Now run EXECUTE phase — Wave 1.

Phase is now 'execute' (set by stop hook). Read selected_modules from \`${SITE_SESSION_DIR}/state.json\` and launch Wave 1.
Selected modules: ${SELECTED_MODULES}

**Wave 1 (parallel, Tier A — no browser):**
1. Read \`${SITE_SESSION_DIR}/discovery.json\` and \`${SITE_SESSION_DIR}/sitemap.md\`
2. Load relevant skill-library skills (see SKILL.md)
3. Spawn Tier A modules (all selected_modules EXCEPT accessibility and performance) IN PARALLEL:
   - Each: \`Task(subagent_type="oh-my-claudecode:executor-high", model="opus")\`
   - Each reads its type file from \`~/.claude/plugins/bishx/skills/site/types/{module}.md\`
   - Each receives: sitemap, discovery data, snapshot content, skill-library context, finding template, scoring rules
   - Each writes to \`${SITE_SESSION_DIR}/{module}-report.md\`
4. When all Tier A reports exist → set \`agent_pending\` → \`false\`
5. Emit \`<bishx-site-done>\`
HEREDOC
          ;;

        "execute")
          # Count reports dynamically from selected_modules in state.json
          SELECTED_JSON=$(jq -r '.selected_modules // []' "$SITE_STATE" 2>/dev/null || echo "[]")
          TIER_A_EXPECTED=0
          TIER_A_DONE=0
          TIER_B_MODULES=""
          TIER_B_EXPECTED=0
          TIER_B_DONE=0
          SITE_REPORTS_FOUND=0

          # Iterate selected_modules: Tier B = accessibility, performance; rest = Tier A
          while IFS= read -r mod; do
            if [[ "$mod" == "accessibility" || "$mod" == "performance" ]]; then
              ((TIER_B_EXPECTED++)) || true
              TIER_B_MODULES="${TIER_B_MODULES} ${mod}"
              [[ -f "$SITE_SESSION_DIR/${mod}-report.md" ]] && grep -q "BISHX-SITE-REPORT-COMPLETE" "$SITE_SESSION_DIR/${mod}-report.md" 2>/dev/null && ((TIER_B_DONE++)) || true
            else
              ((TIER_A_EXPECTED++)) || true
              [[ -f "$SITE_SESSION_DIR/${mod}-report.md" ]] && grep -q "BISHX-SITE-REPORT-COMPLETE" "$SITE_SESSION_DIR/${mod}-report.md" 2>/dev/null && ((TIER_A_DONE++)) || true
            fi
          done < <(echo "$SELECTED_JSON" | jq -r '.[]' 2>/dev/null)

          # Enforce SKILL.md ordering: accessibility before performance
          TIER_B_ORDERED=""
          [[ "$TIER_B_MODULES" == *accessibility* ]] && TIER_B_ORDERED="accessibility"
          [[ "$TIER_B_MODULES" == *performance* ]] && TIER_B_ORDERED="${TIER_B_ORDERED:+$TIER_B_ORDERED }performance"
          TIER_B_MODULES="${TIER_B_ORDERED:-$TIER_B_MODULES}"

          SITE_REPORTS_FOUND=$((TIER_A_DONE + TIER_B_DONE))

          if [[ $SITE_REPORTS_FOUND -ge $MODULES_TOTAL ]]; then
            # All done → synthesize
            jq '.phase = "synthesize" | .agent_pending = false' "$SITE_STATE" > "$SITE_STATE.tmp" && mv "$SITE_STATE.tmp" "$SITE_STATE"
            read -r -d '' PROMPT << HEREDOC || true
BISHX-SITE: All ${MODULES_TOTAL} audit reports complete. Now run SYNTHESIZE phase.

1. Phase is now 'synthesize' (set by stop hook).
2. Read ALL report files from \`${SITE_SESSION_DIR}/\`
3. Extract module scores (each report ends with "Module Score" section)
4. Calculate weighted total using weights from \`${SITE_SESSION_DIR}/discovery.json\`
5. Check for previous audit run in \`.bishx-site/\` — if exists, calculate diff
6. Aggregate and deduplicate all findings across modules
7. Cross-reference related findings
8. Write \`${SITE_SESSION_DIR}/scores.json\`
9. Emit \`<bishx-site-done>\`
HEREDOC

          elif [[ "$SITE_WAVE" == "1" && $TIER_A_DONE -ge $TIER_A_EXPECTED ]]; then
            # Wave 1 done — check if Wave 2 is needed
            if [[ $TIER_B_EXPECTED -gt 0 ]]; then
              # Tier B modules selected → start Wave 2 (sequential browser modules)
              jq '.wave = 2 | .agent_pending = true' "$SITE_STATE" > "$SITE_STATE.tmp" && mv "$SITE_STATE.tmp" "$SITE_STATE"
              read -r -d '' PROMPT << HEREDOC || true
BISHX-SITE: Wave 1 complete (${TIER_A_DONE}/${TIER_A_EXPECTED} Tier A reports). Now run Wave 2 — browser modules SEQUENTIALLY.

1. Wave 2 is now active with agent_pending=true (set by stop hook).
2. Run Tier B modules ONE AT A TIME (exclusive cmux browser access):$(
  for bmod in $TIER_B_MODULES; do
    echo "
   - ${bmod}: \`Task(subagent_type=\"oh-my-claudecode:executor-high\", model=\"opus\", prompt=<${bmod} instructions + sitemap + finding template + scoring rules>)\`
     Wait for completion → \`${SITE_SESSION_DIR}/${bmod}-report.md\`"
  done)
3. Set \`agent_pending\` → \`false\`
4. Emit \`<bishx-site-done>\`

IMPORTANT: Run these modules ONE AT A TIME. They need exclusive cmux browser access.
HEREDOC
            else
              # No Tier B modules selected → all done, go to synthesize
              jq '.phase = "synthesize" | .agent_pending = false' "$SITE_STATE" > "$SITE_STATE.tmp" && mv "$SITE_STATE.tmp" "$SITE_STATE"
              read -r -d '' PROMPT << HEREDOC || true
BISHX-SITE: Wave 1 complete (${TIER_A_DONE}/${TIER_A_EXPECTED} Tier A reports). No browser modules selected — all reports done. Proceed to SYNTHESIZE.

1. Phase is now 'synthesize' (set by stop hook).
2. Read ALL report files from \`${SITE_SESSION_DIR}/\`
3. Extract module scores, calculate weighted total, write \`${SITE_SESSION_DIR}/scores.json\`
4. Emit \`<bishx-site-done>\`
HEREDOC
            fi

          elif [[ "$SITE_WAVE" == "1" ]]; then
            read -r -d '' PROMPT << HEREDOC || true
BISHX-SITE: Wave 1 in progress. ${TIER_A_DONE}/${TIER_A_EXPECTED} Tier A reports ready. Wait for remaining agents. When all ${TIER_A_EXPECTED} Tier A reports exist, emit \`<bishx-site-done>\`.
HEREDOC

          else
            # Wave 2 in progress — show status for each Tier B module
            TIER_B_STATUS=""
            for bmod in $TIER_B_MODULES; do
              if [[ -f "$SITE_SESSION_DIR/${bmod}-report.md" ]]; then
                TIER_B_STATUS="${TIER_B_STATUS} ${bmod}:done"
              else
                TIER_B_STATUS="${TIER_B_STATUS} ${bmod}:pending"
              fi
            done
            read -r -d '' PROMPT << HEREDOC || true
BISHX-SITE: Wave 2 in progress.${TIER_B_STATUS}. Run remaining browser module(s) sequentially. When all complete, emit \`<bishx-site-done>\`.
HEREDOC
          fi
          ;;

        "synthesize")
          jq '.phase = "report"' "$SITE_STATE" > "$SITE_STATE.tmp" && mv "$SITE_STATE.tmp" "$SITE_STATE"
          read -r -d '' PROMPT << HEREDOC || true
BISHX-SITE: Synthesis complete. Now generate the final REPORT.

1. Phase is now 'report' (set by stop hook).
2. Read \`${SITE_SESSION_DIR}/scores.json\` and ALL report files
3. Generate \`${SITE_SESSION_DIR}/SITE-REVIEW.md\` following the format in SKILL.md Phase 3
4. Every finding uses the finding template (required sections: 1-3, 6-7, 10; optional: 4-5, 8-9)
5. Sort findings by priority: critical → high → medium → low
6. Include positive highlights and quick wins summary
7. Add skill-library cross-reference table at the end
8. Present summary to user with overall score and grade
9. Emit \`<bishx-site-complete>\`
HEREDOC
          ;;

        "report")
          # Report phase emits <bishx-site-complete>, not <bishx-site-done>
          # If we get here, Claude emitted wrong signal — redirect
          read -r -d '' PROMPT << HEREDOC || true
BISHX-SITE: Report phase should emit \`<bishx-site-complete>\`, not \`<bishx-site-done>\`.
Continue writing SITE-REVIEW.md. When fully complete, emit \`<bishx-site-complete>\` to end the session.
HEREDOC
          ;;

        *)
          read -r -d '' PROMPT << HEREDOC || true
BISHX-SITE: Unknown phase "${SITE_PHASE}". Read \`${SITE_SESSION_DIR}/state.json\` and continue from current phase. If corrupted, ask user for guidance.
HEREDOC
          ;;
      esac

      jq -n --arg reason "$PROMPT" '{"decision": "block", "reason": $reason}'
      exit 0
    fi

    # No signal detected — nudge based on phase
    case "$SITE_PHASE" in
      "discover")
        PROMPT="BISHX-SITE: Continue Discovery. Crawl remaining pages via cmux browser. When complete, emit <bishx-site-done>."
        ;;
      "ask")
        # User input needed — allow exit
        exit 0
        ;;
      "execute")
        SITE_REPORTS_FOUND=0
        SELECTED_JSON=$(jq -r '.selected_modules // []' "$SITE_STATE" 2>/dev/null || echo "[]")
        while IFS= read -r mod; do
          [[ -n "$mod" && -f "$SITE_SESSION_DIR/${mod}-report.md" ]] && grep -q "BISHX-SITE-REPORT-COMPLETE" "$SITE_SESSION_DIR/${mod}-report.md" 2>/dev/null && ((SITE_REPORTS_FOUND++)) || true
        done < <(echo "$SELECTED_JSON" | jq -r '.[]' 2>/dev/null)
        if [[ $SITE_REPORTS_FOUND -ge $MODULES_TOTAL ]]; then
          PROMPT="BISHX-SITE: All ${MODULES_TOTAL} reports exist. Proceed to synthesize. Emit <bishx-site-done>."
        else
          PROMPT="BISHX-SITE: ${SITE_REPORTS_FOUND}/${MODULES_TOTAL} reports ready. Continue execute phase. When all reports complete, emit <bishx-site-done>."
        fi
        ;;
      "synthesize")
        PROMPT="BISHX-SITE: Continue synthesis. Calculate scores, check for previous run diff. When done, emit <bishx-site-done>."
        ;;
      "report")
        PROMPT="BISHX-SITE: Continue generating SITE-REVIEW.md. When complete, emit <bishx-site-complete>."
        ;;
      *)
        PROMPT="BISHX-SITE: Read ${SITE_SESSION_DIR}/state.json and continue."
        ;;
    esac

    jq -n --arg reason "$PROMPT" '{"decision": "block", "reason": $reason}'
    exit 0
  fi
fi

# ============================================================
# No active mode → allow exit
# ============================================================
exit 0
