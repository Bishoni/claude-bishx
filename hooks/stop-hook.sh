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
    MAX_ITER=$(jq -r '.max_iterations // 5' "$PLAN_STATE")
    VERDICT=$(jq -r '.critic_verdict // ""' "$PLAN_STATE")
    FLAGS=$(jq -r '.flags // [] | join(",")' "$PLAN_STATE")
    COMPLEXITY=$(jq -r '.complexity_tier // "medium"' "$PLAN_STATE")
    if [[ -z "$COMPLEXITY" ]]; then COMPLEXITY="medium"; fi

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
              skill_name=$(echo "$DISCOVERED_SKILLS" | jq -r ".[] | select(.path == \"$skill_path\") | .name")
              if [[ -f "$skill_path" ]] && [[ -n "$skill_name" ]]; then
                skill_preview=$(head -100 "$skill_path" 2>/dev/null || true)
                SKILL_CONTENT="${SKILL_CONTENT}\n### Skill: $skill_name\n\n\`\`\`\n${skill_preview}\n\`\`\`\n\n"
              fi
            done < <(echo "$DISCOVERED_SKILLS" | jq -r '.[].path')

            DETECTED_NAMES=$(echo "$DISCOVERED_SKILLS" | jq -c '[.[].name]')
            jq ".detected_skills = $DETECTED_NAMES" "$PLAN_STATE" > "$PLAN_STATE.tmp" && mv "$PLAN_STATE.tmp" "$PLAN_STATE"
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
BISHX-PLAN: Research complete. Now run the PLANNING phase (iteration starts).

1. Read \`${SESSION_DIR}/CONTEXT.md\` and \`${SESSION_DIR}/RESEARCH.md\`
2. Spawn the planner agent:
   \`\`\`
   Task(subagent_type="bishx:planner", model="opus", prompt=<CONTEXT.md + RESEARCH.md content>)
   \`\`\`
   Pass both files' content in the prompt. The planner creates a detailed, TDD-embedded, one-shot-executable implementation plan.
3. Create directory \`${SESSION_DIR}/iterations/01/\` (use current iteration number, zero-padded)
4. Write the planner's output to \`${SESSION_DIR}/iterations/01/PLAN.md\`
5. Update \`${SESSION_DIR}/state.json\`: set \`phase\` to \`"pipeline"\`, \`pipeline_actor\` to \`"planner"\`
6. Emit \`<bishx-plan-done>\`
HEREDOC
          ;;

        "pipeline:planner")
          ITER_DIR=$(printf "%02d" "$ITERATION")
          ACTIVE_CONDITIONAL=$(jq -r '.active_conditional // [] | join(",")' "$PLAN_STATE")

          if [[ "$COMPLEXITY" == "trivial" ]]; then
            # TRIVIAL: skip parallel review, go directly to critic
            read -r -d '' PROMPT << HEREDOC || true
BISHX-PLAN: Plan created. Complexity tier is TRIVIAL — skipping parallel review, going directly to Critic.

Read the plan from \`${SESSION_DIR}/iterations/${ITER_DIR}/PLAN.md\` and \`${SESSION_DIR}/CONTEXT.md\`.

Spawn the Critic with simplified scoring (Correctness + Executability only):
\`\`\`
Task(subagent_type="bishx:critic", model="opus", prompt=<PLAN.md + CONTEXT.md + "TRIVIAL mode: score only Correctness and Executability dimensions">)
\`\`\`

Write output to \`${SESSION_DIR}/iterations/${ITER_DIR}/CRITIC-REPORT.md\`
Parse verdict and score. Update \`${SESSION_DIR}/state.json\`: set \`pipeline_actor\` to \`"critic"\`, update \`critic_verdict\`, \`critic_score_pct\`, \`scores_history\`
Emit \`<bishx-plan-done>\`
HEREDOC

          elif [[ "$COMPLEXITY" == "small" ]]; then
            # SMALL: lite pipeline — only Skeptic + Completeness
            read -r -d '' PROMPT << HEREDOC || true
BISHX-PLAN: Plan created. Complexity tier is SMALL — running lite parallel review (Skeptic + Completeness only).

Read the plan from \`${SESSION_DIR}/iterations/${ITER_DIR}/PLAN.md\` and \`${SESSION_DIR}/CONTEXT.md\`.

Launch ONLY these 2 review actors IN PARALLEL:
- Task(subagent_type="bishx:skeptic", model="opus", prompt=<PLAN.md content + CONTEXT.md summary>)
- Task(subagent_type="bishx:completeness-validator", model="sonnet", prompt=<PLAN.md content + CONTEXT.md content>)

Write outputs to \`${SESSION_DIR}/iterations/${ITER_DIR}/\`:
- SKEPTIC-REPORT.md
- COMPLETENESS-REPORT.md

Update \`${SESSION_DIR}/state.json\`: set \`pipeline_actor\` to \`"parallel-review"\`
Emit \`<bishx-plan-done>\`
HEREDOC

          else
            # MEDIUM / LARGE / EPIC: full parallel review
            read -r -d '' PROMPT << HEREDOC || true
BISHX-PLAN: Plan created. Now run PARALLEL REVIEW phase.

Read the plan from \`${SESSION_DIR}/iterations/${ITER_DIR}/PLAN.md\` and \`${SESSION_DIR}/CONTEXT.md\`.

Launch ALL applicable review actors IN PARALLEL (single response, multiple Task calls):

Always-on actors:
- Task(subagent_type="bishx:skeptic", model="opus", prompt=<PLAN.md content + CONTEXT.md summary>)
- Task(subagent_type="bishx:tdd-reviewer", model="sonnet", prompt=<PLAN.md content>)
- Task(subagent_type="bishx:completeness-validator", model="sonnet", prompt=<PLAN.md content + CONTEXT.md content>)
- Task(subagent_type="bishx:integration-validator", model="sonnet", prompt=<PLAN.md content>)

Conditional actors (check state.json active_conditional field — current value: "${ACTIVE_CONDITIONAL}"):
- If "security-reviewer" is in active_conditional: Task(subagent_type="bishx:security-reviewer", model="sonnet", prompt=<PLAN.md content + CONTEXT.md content>)
- If "performance-auditor" is in active_conditional: Task(subagent_type="bishx:performance-auditor", model="sonnet", prompt=<PLAN.md content>)

Write ALL outputs to \`${SESSION_DIR}/iterations/${ITER_DIR}/\`:
- SKEPTIC-REPORT.md
- TDD-REPORT.md
- COMPLETENESS-REPORT.md
- INTEGRATION-REPORT.md
- SECURITY-REPORT.md (if security-reviewer was run)
- PERFORMANCE-REPORT.md (if performance-auditor was run)

Update \`${SESSION_DIR}/state.json\`: set \`pipeline_actor\` to \`"parallel-review"\`
Emit \`<bishx-plan-done>\`
HEREDOC
          fi
          ;;

        "pipeline:parallel-review")
          ITER_DIR=$(printf "%02d" "$ITERATION")
          read -r -d '' PROMPT << HEREDOC || true
BISHX-PLAN: Parallel review complete. Now run the CRITIC evaluation.

Read ALL report files from \`${SESSION_DIR}/iterations/${ITER_DIR}/\`:
- PLAN.md
- SKEPTIC-REPORT.md
- TDD-REPORT.md
- COMPLETENESS-REPORT.md
- INTEGRATION-REPORT.md
- SECURITY-REPORT.md (if exists)
- PERFORMANCE-REPORT.md (if exists)
- \`${SESSION_DIR}/CONTEXT.md\`
- \`${SESSION_DIR}/RESEARCH.md\`

Spawn critic:
\`\`\`
Task(subagent_type="bishx:critic", model="opus", prompt=<all reports + context + research assembled>)
\`\`\`

Write to \`${SESSION_DIR}/iterations/${ITER_DIR}/CRITIC-REPORT.md\`
Parse verdict (APPROVED/REVISE/REJECT), score percentage, blocking issue count.
Update \`${SESSION_DIR}/state.json\`:
- Set \`pipeline_actor\` to \`"critic"\`
- Set \`critic_verdict\` to the verdict string
- Append scores to \`scores_history\` array
- Set \`flags\` to any special flags from the critic (NEEDS_RE_RESEARCH, NEEDS_HUMAN_INPUT)
Emit \`<bishx-plan-done>\`
HEREDOC
          ;;

        "pipeline:critic")
          case "$VERDICT" in
            "APPROVED")
              ITER_DIR=$(printf "%02d" "$ITERATION")
              read -r -d '' PROMPT << HEREDOC || true
BISHX-PLAN: Plan APPROVED! Running DRY-RUN SIMULATION as final gate.

Update \`${SESSION_DIR}/state.json\`: set \`phase\` to \`"dry-run"\`, \`pipeline_actor\` to \`""\`

Read ONLY \`${SESSION_DIR}/iterations/${ITER_DIR}/PLAN.md\`

Spawn:
\`\`\`
Task(subagent_type="bishx:dry-run-simulator", model="opus", prompt=<PLAN.md content only>)
\`\`\`
IMPORTANT: Do NOT pass CONTEXT.md or RESEARCH.md — the simulator must verify executability with the plan alone.

Write the simulator's output to \`${SESSION_DIR}/iterations/${ITER_DIR}/DRYRUN-REPORT.md\`
Parse verdict from the output: PASS, FAIL, or WARN

If PASS or WARN:
- Update \`${SESSION_DIR}/state.json\`: set \`phase\` to \`"finalize"\`
- Emit \`<bishx-plan-done>\`

If FAIL:
- Update \`${SESSION_DIR}/state.json\`: set \`critic_verdict\` to \`"REVISE"\`, append DRYRUN issues to feedback
- Emit \`<bishx-plan-done>\` (the hook will route to REVISE)
HEREDOC
              ;;

            "REVISE")
              NEW_ITER=$((ITERATION + 1))
              jq ".iteration = $NEW_ITER | .critic_verdict = \"\" | .pipeline_actor = \"planner\"" "$PLAN_STATE" > "$PLAN_STATE.tmp" && mv "$PLAN_STATE.tmp" "$PLAN_STATE"
              OLD_ITER_DIR=$(printf "%02d" "$ITERATION")
              NEW_ITER_DIR=$(printf "%02d" "$NEW_ITER")

              if echo "$FLAGS" | grep -q "NEEDS_RE_RESEARCH"; then
                read -r -d '' PROMPT << HEREDOC || true
BISHX-PLAN: Plan needs REVISION with RE-RESEARCH (iteration ${NEW_ITER} of ${MAX_ITER}).

The Critic flagged NEEDS_RE_RESEARCH. Run targeted research first.

1. Read the Critic report at \`${SESSION_DIR}/iterations/${OLD_ITER_DIR}/CRITIC-REPORT.md\` to identify what needs re-research.
2. Spawn the researcher agent with targeted scope:
   \`\`\`
   Task(subagent_type="bishx:researcher", model="opus", prompt=<targeted research questions from critic report>)
   \`\`\`
3. Append the new findings to \`${SESSION_DIR}/RESEARCH.md\` under a "## Supplemental Research (Iteration ${NEW_ITER})" heading.
4. Then read ALL available feedback (skip files that don't exist — not all actors run in every complexity tier):
   - \`${SESSION_DIR}/iterations/${OLD_ITER_DIR}/SKEPTIC-REPORT.md\` (if exists)
   - \`${SESSION_DIR}/iterations/${OLD_ITER_DIR}/TDD-REPORT.md\` (if exists)
   - \`${SESSION_DIR}/iterations/${OLD_ITER_DIR}/COMPLETENESS-REPORT.md\` (if exists)
   - \`${SESSION_DIR}/iterations/${OLD_ITER_DIR}/INTEGRATION-REPORT.md\` (if exists)
   - \`${SESSION_DIR}/iterations/${OLD_ITER_DIR}/SECURITY-REPORT.md\` (if exists)
   - \`${SESSION_DIR}/iterations/${OLD_ITER_DIR}/PERFORMANCE-REPORT.md\` (if exists)
   - \`${SESSION_DIR}/iterations/${OLD_ITER_DIR}/CRITIC-REPORT.md\`
   - \`${SESSION_DIR}/iterations/${OLD_ITER_DIR}/DRYRUN-REPORT.md\` (if exists)
   - Updated \`${SESSION_DIR}/RESEARCH.md\`
   - \`${SESSION_DIR}/CONTEXT.md\`
5. Spawn the planner agent:
   \`\`\`
   Task(subagent_type="bishx:planner", model="opus", prompt=<all feedback + research + context>)
   \`\`\`
   Tell the planner: "Address EVERY issue from prior reports. Include a Revision Notes section."
6. Create directory \`${SESSION_DIR}/iterations/${NEW_ITER_DIR}/\`
7. Write the planner's output to \`${SESSION_DIR}/iterations/${NEW_ITER_DIR}/PLAN.md\`
8. Update \`${SESSION_DIR}/state.json\`: set \`phase\` to \`"pipeline"\`, \`pipeline_actor\` to \`"planner"\`, clear \`flags\`
9. Emit \`<bishx-plan-done>\`
HEREDOC
              else
                read -r -d '' PROMPT << HEREDOC || true
BISHX-PLAN: Plan needs REVISION (iteration ${NEW_ITER} of ${MAX_ITER}).

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
   - \`${SESSION_DIR}/CONTEXT.md\`
   - \`${SESSION_DIR}/RESEARCH.md\`
2. Spawn the planner agent:
   \`\`\`
   Task(subagent_type="bishx:planner", model="opus", prompt=<all available feedback + context + research>)
   \`\`\`
   Tell the planner: "This is iteration ${NEW_ITER}. Address EVERY issue from the available review reports and the Critic report. Include a Revision Notes section at the top listing each issue and how it was addressed. Do not silently ignore feedback."
3. Create directory \`${SESSION_DIR}/iterations/${NEW_ITER_DIR}/\`
4. Write the planner's output to \`${SESSION_DIR}/iterations/${NEW_ITER_DIR}/PLAN.md\`
5. Update \`${SESSION_DIR}/state.json\`: set \`phase\` to \`"pipeline"\`, \`pipeline_actor\` to \`"planner"\`, clear \`flags\`
6. Emit \`<bishx-plan-done>\`
HEREDOC
              fi
              ;;

            "REJECT")
              NEW_ITER=$((ITERATION + 1))
              jq ".iteration = $NEW_ITER | .critic_verdict = \"\" | .pipeline_actor = \"planner\"" "$PLAN_STATE" > "$PLAN_STATE.tmp" && mv "$PLAN_STATE.tmp" "$PLAN_STATE"
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
6. Continue the pipeline as normal after human input is incorporated

Do NOT emit any signals until human responds.
HEREDOC
              else
                read -r -d '' PROMPT << HEREDOC || true
BISHX-PLAN: Plan REJECTED (iteration ${NEW_ITER} of ${MAX_ITER}).

Fundamental issues require re-research.

1. Read the Critic report at \`${SESSION_DIR}/iterations/${OLD_ITER_DIR}/CRITIC-REPORT.md\`
2. Spawn the researcher agent with targeted scope based on the rejection reasons:
   \`\`\`
   Task(subagent_type="bishx:researcher", model="opus", prompt=<rejection reasons + targeted research questions>)
   \`\`\`
3. Append findings to \`${SESSION_DIR}/RESEARCH.md\` under "## Re-Research (Iteration ${NEW_ITER})"
4. Read ALL available prior feedback and updated research (skip files that don't exist — not all actors run in every complexity tier):
   - \`${SESSION_DIR}/iterations/${OLD_ITER_DIR}/SKEPTIC-REPORT.md\` (if exists)
   - \`${SESSION_DIR}/iterations/${OLD_ITER_DIR}/TDD-REPORT.md\` (if exists)
   - \`${SESSION_DIR}/iterations/${OLD_ITER_DIR}/COMPLETENESS-REPORT.md\` (if exists)
   - \`${SESSION_DIR}/iterations/${OLD_ITER_DIR}/INTEGRATION-REPORT.md\` (if exists)
   - \`${SESSION_DIR}/iterations/${OLD_ITER_DIR}/SECURITY-REPORT.md\` (if exists)
   - \`${SESSION_DIR}/iterations/${OLD_ITER_DIR}/PERFORMANCE-REPORT.md\` (if exists)
   - \`${SESSION_DIR}/iterations/${OLD_ITER_DIR}/CRITIC-REPORT.md\`
   - \`${SESSION_DIR}/iterations/${OLD_ITER_DIR}/DRYRUN-REPORT.md\` (if exists)
5. Spawn the planner agent with all available context
6. Create \`${SESSION_DIR}/iterations/${NEW_ITER_DIR}/\`
7. Write output to \`${SESSION_DIR}/iterations/${NEW_ITER_DIR}/PLAN.md\`
8. Update \`${SESSION_DIR}/state.json\`: set \`phase\` to \`"pipeline"\`, \`pipeline_actor\` to \`"planner"\`, clear \`flags\`
9. Emit \`<bishx-plan-done>\`
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
            jq ".iteration = $NEW_ITER | .critic_verdict = \"\" | .pipeline_actor = \"planner\" | .phase = \"pipeline\"" "$PLAN_STATE" > "$PLAN_STATE.tmp" && mv "$PLAN_STATE.tmp" "$PLAN_STATE"
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
   Also read \`${SESSION_DIR}/CONTEXT.md\` and \`${SESSION_DIR}/RESEARCH.md\`
2. Focus on the DRYRUN-REPORT issues — these are executability problems the simulator found.
3. Spawn the planner agent with all available feedback.
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
            PROMPT="BISHX-PLAN: You are in the PLANNING phase. Spawn the planner agent and write PLAN.md. When done, update state.json and emit <bishx-plan-done>."
            ;;
          "pipeline:parallel-review")
            PROMPT="BISHX-PLAN: You are in PARALLEL REVIEW. Launch all parallel actors (skeptic, tdd-reviewer, completeness-validator, integration-validator, plus any conditional actors) and write all reports. When done, update state.json and emit <bishx-plan-done>."
            ;;
          "pipeline:critic")
            PROMPT="BISHX-PLAN: You are in the CRITIC phase. Spawn the critic agent and write CRITIC-REPORT.md. When done, update state.json with the verdict and emit <bishx-plan-done>."
            ;;
          "dry-run:")
            PROMPT="BISHX-PLAN: You are in DRY-RUN phase. Spawn the dry-run simulator with PLAN.md only. Write DRYRUN-REPORT.md, parse the verdict, update state.json, and emit <bishx-plan-done>."
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

    PAUSED=$(jq -r '.paused // false' "$RUN_STATE")
    CURRENT_TASK=$(jq -r '.current_task // ""' "$RUN_STATE")
    MODE=$(jq -r '.mode // "full"' "$RUN_STATE")

    # Signal: complete — allow exit
    if echo "$LAST_OUTPUT" | grep -q "<bishx-complete>"; then
      jq '.active = false' "$RUN_STATE" > "$RUN_STATE.tmp" && mv "$RUN_STATE.tmp" "$RUN_STATE"
      exit 0
    fi

    # Session is paused — allow exit
    if [[ "$PAUSED" == "true" ]]; then
      exit 0
    fi

    # Active session, not paused, no complete signal → keep the loop alive
    COMPLETED=$(jq -r '.completed_tasks | length' "$RUN_STATE" 2>/dev/null || echo "0")
    WAITING_FOR=$(jq -r '.waiting_for // ""' "$RUN_STATE" 2>/dev/null || echo "")

    if [[ -n "$WAITING_FOR" && "$WAITING_FOR" != "null" ]]; then
      # Lead is WAITING for a teammate → allow stop, teammate's SendMessage
      # will be delivered automatically as a new turn
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
# Neither mode active → allow exit
# ============================================================
exit 0
