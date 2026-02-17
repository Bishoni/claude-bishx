#!/bin/bash
set -euo pipefail

HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"
PLAN_STATE=".bishx-plan/state.json"
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
if [[ -f "$PLAN_STATE" ]]; then
  PLAN_ACTIVE=$(jq -r '.active // false' "$PLAN_STATE")
  if [[ "$PLAN_ACTIVE" == "true" ]]; then

    PHASE=$(jq -r '.phase // ""' "$PLAN_STATE")
    ACTOR=$(jq -r '.pipeline_actor // ""' "$PLAN_STATE")
    ITERATION=$(jq -r '.iteration // 1' "$PLAN_STATE")
    MAX_ITER=$(jq -r '.max_iterations // 5' "$PLAN_STATE")
    VERDICT=$(jq -r '.critic_verdict // ""' "$PLAN_STATE")
    FLAGS=$(jq -r '.flags // [] | join(",")' "$PLAN_STATE")

    # Safety: max iterations reached
    if [[ "$ITERATION" -gt "$MAX_ITER" ]]; then
      jq '.phase = "max_iterations"' "$PLAN_STATE" > "$PLAN_STATE.tmp" && mv "$PLAN_STATE.tmp" "$PLAN_STATE"
      PROMPT="BISHX-PLAN: Maximum iterations ($MAX_ITER) reached.

Present the BEST plan from all iterations to the human for review.

1. Read .bishx-plan/iterations/ and find the highest-scoring iteration
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

1. Read \`.bishx-plan/CONTEXT.md\` to understand the requirements and decisions.
2. Spawn the researcher agent:
   \`\`\`
   Task(subagent_type="bishx:researcher", model="opus", prompt=<CONTEXT.md content + research instructions>)
   \`\`\`
   Pass the full CONTEXT.md content in the prompt. Tell the researcher to investigate everything needed for a bulletproof implementation plan.${SKILL_CONTENT}
3. Write the researcher's output to \`.bishx-plan/RESEARCH.md\`
4. Update \`.bishx-plan/state.json\`: set \`phase\` to \`"research"\`, \`pipeline_actor\` to \`""\`
5. Emit \`<bishx-plan-done>\`
HEREDOC
          ;;

        "research:")
          read -r -d '' PROMPT << 'HEREDOC' || true
BISHX-PLAN: Research complete. Now run the PLANNING phase (iteration starts).

1. Read `.bishx-plan/CONTEXT.md` and `.bishx-plan/RESEARCH.md`
2. Spawn the planner agent:
   ```
   Task(subagent_type="bishx:planner", model="opus", prompt=<CONTEXT.md + RESEARCH.md content>)
   ```
   Pass both files' content in the prompt. The planner creates a detailed, TDD-embedded, one-shot-executable implementation plan.
3. Create directory `.bishx-plan/iterations/01/` (use current iteration number, zero-padded)
4. Write the planner's output to `.bishx-plan/iterations/01/PLAN.md`
5. Update `.bishx-plan/state.json`: set `phase` to `"pipeline"`, `pipeline_actor` to `"planner"`
6. Emit `<bishx-plan-done>`
HEREDOC
          ;;

        "pipeline:planner")
          ITER_DIR=$(printf "%02d" "$ITERATION")
          read -r -d '' PROMPT << HEREDOC || true
BISHX-PLAN: Plan created. Now run the SKEPTIC review.

1. Read \`.bishx-plan/iterations/${ITER_DIR}/PLAN.md\`
2. Spawn the skeptic agent:
   \`\`\`
   Task(subagent_type="bishx:skeptic", model="opus", prompt=<PLAN.md content + CONTEXT.md summary>)
   \`\`\`
   Pass the full plan and a brief summary of requirements. The skeptic verifies all claims against codebase reality and external facts.
3. Write the skeptic's output to \`.bishx-plan/iterations/${ITER_DIR}/SKEPTIC-REPORT.md\`
4. Update \`.bishx-plan/state.json\`: set \`pipeline_actor\` to \`"skeptic"\`
5. Emit \`<bishx-plan-done>\`
HEREDOC
          ;;

        "pipeline:skeptic")
          ITER_DIR=$(printf "%02d" "$ITERATION")
          read -r -d '' PROMPT << HEREDOC || true
BISHX-PLAN: Skeptic review complete. Now run the TDD REVIEW.

1. Read \`.bishx-plan/iterations/${ITER_DIR}/PLAN.md\` and \`.bishx-plan/iterations/${ITER_DIR}/SKEPTIC-REPORT.md\`
2. Spawn the TDD reviewer agent:
   \`\`\`
   Task(subagent_type="bishx:tdd-reviewer", model="opus", prompt=<PLAN.md content + SKEPTIC-REPORT.md content>)
   \`\`\`
   Pass the plan and skeptic report. The TDD reviewer checks test-first compliance and test quality.
3. Write the TDD reviewer's output to \`.bishx-plan/iterations/${ITER_DIR}/TDD-REPORT.md\`
4. Update \`.bishx-plan/state.json\`: set \`pipeline_actor\` to \`"tdd-reviewer"\`
5. Emit \`<bishx-plan-done>\`
HEREDOC
          ;;

        "pipeline:tdd-reviewer")
          ITER_DIR=$(printf "%02d" "$ITERATION")
          read -r -d '' PROMPT << HEREDOC || true
BISHX-PLAN: TDD review complete. Now run the CRITIC evaluation.

1. Read these files:
   - \`.bishx-plan/iterations/${ITER_DIR}/PLAN.md\`
   - \`.bishx-plan/iterations/${ITER_DIR}/SKEPTIC-REPORT.md\`
   - \`.bishx-plan/iterations/${ITER_DIR}/TDD-REPORT.md\`
   - \`.bishx-plan/CONTEXT.md\` (requirements summary)
2. Spawn the critic agent:
   \`\`\`
   Task(subagent_type="bishx:critic", model="opus", prompt=<all file contents assembled>)
   \`\`\`
   Pass ALL files' content. The critic scores the plan, aggregates feedback, and issues a verdict.
3. Write the critic's output to \`.bishx-plan/iterations/${ITER_DIR}/CRITIC-REPORT.md\`
4. Parse the critic's verdict (APPROVED, REVISE, or REJECT) and scores from the output.
5. Update \`.bishx-plan/state.json\`:
   - Set \`pipeline_actor\` to \`"critic"\`
   - Set \`critic_verdict\` to the verdict string
   - Append scores to \`scores_history\` array
   - Set \`flags\` to any special flags from the critic (NEEDS_RE_RESEARCH, NEEDS_HUMAN_INPUT)
6. Emit \`<bishx-plan-done>\`
HEREDOC
          ;;

        "pipeline:critic")
          case "$VERDICT" in
            "APPROVED")
              ITER_DIR=$(printf "%02d" "$ITERATION")
              read -r -d '' PROMPT << HEREDOC || true
BISHX-PLAN: Plan APPROVED by the Critic! Now FINALIZE.

1. Read the approved plan from \`.bishx-plan/iterations/${ITER_DIR}/PLAN.md\`
2. Generate filename with datetime: \`plan-\$(date +%Y-%m-%d-%H%M%S).md\`
3. Copy it to \`.bishx-plan/{filename}\`
4. Also write to \`~/.claude/plans/{filename}\`
4. Present the final plan to the human with:
   - Total iterations: ${ITERATION}
   - Final score and breakdown from \`.bishx-plan/iterations/${ITER_DIR}/CRITIC-REPORT.md\`
   - Summary of what was improved across iterations (if iteration > 1)
5. Update \`.bishx-plan/state.json\`: set \`phase\` to \`"finalize"\`, \`pipeline_actor\` to \`""\`
6. Emit \`<bishx-plan-done>\`
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

1. Read the Critic report at \`.bishx-plan/iterations/${OLD_ITER_DIR}/CRITIC-REPORT.md\` to identify what needs re-research.
2. Spawn the researcher agent with targeted scope:
   \`\`\`
   Task(subagent_type="bishx:researcher", model="opus", prompt=<targeted research questions from critic report>)
   \`\`\`
3. Append the new findings to \`.bishx-plan/RESEARCH.md\` under a "## Supplemental Research (Iteration ${NEW_ITER})" heading.
4. Then read ALL feedback:
   - \`.bishx-plan/iterations/${OLD_ITER_DIR}/SKEPTIC-REPORT.md\`
   - \`.bishx-plan/iterations/${OLD_ITER_DIR}/TDD-REPORT.md\`
   - \`.bishx-plan/iterations/${OLD_ITER_DIR}/CRITIC-REPORT.md\`
   - Updated \`.bishx-plan/RESEARCH.md\`
   - \`.bishx-plan/CONTEXT.md\`
5. Spawn the planner agent:
   \`\`\`
   Task(subagent_type="bishx:planner", model="opus", prompt=<all feedback + research + context>)
   \`\`\`
   Tell the planner: "Address EVERY issue from prior reports. Include a Revision Notes section."
6. Create directory \`.bishx-plan/iterations/${NEW_ITER_DIR}/\`
7. Write the planner's output to \`.bishx-plan/iterations/${NEW_ITER_DIR}/PLAN.md\`
8. Update \`.bishx-plan/state.json\`: set \`phase\` to \`"pipeline"\`, \`pipeline_actor\` to \`"planner"\`, clear \`flags\`
9. Emit \`<bishx-plan-done>\`
HEREDOC
              else
                read -r -d '' PROMPT << HEREDOC || true
BISHX-PLAN: Plan needs REVISION (iteration ${NEW_ITER} of ${MAX_ITER}).

1. Read ALL feedback from the previous iteration:
   - \`.bishx-plan/iterations/${OLD_ITER_DIR}/PLAN.md\` (previous plan for reference)
   - \`.bishx-plan/iterations/${OLD_ITER_DIR}/SKEPTIC-REPORT.md\`
   - \`.bishx-plan/iterations/${OLD_ITER_DIR}/TDD-REPORT.md\`
   - \`.bishx-plan/iterations/${OLD_ITER_DIR}/CRITIC-REPORT.md\`
   - \`.bishx-plan/CONTEXT.md\`
   - \`.bishx-plan/RESEARCH.md\`
2. Spawn the planner agent:
   \`\`\`
   Task(subagent_type="bishx:planner", model="opus", prompt=<all feedback + context + research>)
   \`\`\`
   Tell the planner: "This is iteration ${NEW_ITER}. Address EVERY issue from the Skeptic, TDD, and Critic reports. Include a Revision Notes section at the top listing each issue and how it was addressed. Do not silently ignore feedback."
3. Create directory \`.bishx-plan/iterations/${NEW_ITER_DIR}/\`
4. Write the planner's output to \`.bishx-plan/iterations/${NEW_ITER_DIR}/PLAN.md\`
5. Update \`.bishx-plan/state.json\`: set \`phase\` to \`"pipeline"\`, \`pipeline_actor\` to \`"planner"\`, clear \`flags\`
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

1. Read the Critic report at \`.bishx-plan/iterations/${OLD_ITER_DIR}/CRITIC-REPORT.md\`
2. Present the specific questions/decisions that need human input
3. Wait for human response — do NOT proceed automatically
4. After receiving human input, update \`.bishx-plan/CONTEXT.md\` with the new decisions
5. Then spawn the researcher if NEEDS_RE_RESEARCH is also flagged, otherwise go straight to planner
6. Continue the pipeline as normal after human input is incorporated

Do NOT emit any signals until human responds.
HEREDOC
              else
                read -r -d '' PROMPT << HEREDOC || true
BISHX-PLAN: Plan REJECTED (iteration ${NEW_ITER} of ${MAX_ITER}).

Fundamental issues require re-research.

1. Read the Critic report at \`.bishx-plan/iterations/${OLD_ITER_DIR}/CRITIC-REPORT.md\`
2. Spawn the researcher agent with targeted scope based on the rejection reasons:
   \`\`\`
   Task(subagent_type="bishx:researcher", model="opus", prompt=<rejection reasons + targeted research questions>)
   \`\`\`
3. Append findings to \`.bishx-plan/RESEARCH.md\` under "## Re-Research (Iteration ${NEW_ITER})"
4. Read ALL prior feedback and updated research
5. Spawn the planner agent with all context
6. Create \`.bishx-plan/iterations/${NEW_ITER_DIR}/\`
7. Write output to \`.bishx-plan/iterations/${NEW_ITER_DIR}/PLAN.md\`
8. Update \`.bishx-plan/state.json\`: set \`phase\` to \`"pipeline"\`, \`pipeline_actor\` to \`"planner"\`, clear \`flags\`
9. Emit \`<bishx-plan-done>\`
HEREDOC
              fi
              ;;

            *)
              read -r -d '' PROMPT << 'HEREDOC' || true
BISHX-PLAN: Could not parse Critic verdict. Re-read the latest CRITIC-REPORT.md, extract the verdict (must be APPROVED, REVISE, or REJECT), update state.json with the correct critic_verdict, and emit <bishx-plan-done>.
HEREDOC
              ;;
          esac
          ;;

        "finalize:")
          read -r -d '' PROMPT << 'HEREDOC' || true
BISHX-PLAN: Finalization complete. The plan has been delivered to the human.

Emit <bishx-plan-complete> to end the session.
HEREDOC
          ;;

        *)
          read -r -d '' PROMPT << 'HEREDOC' || true
BISHX-PLAN: Unknown state encountered. Read .bishx-plan/state.json to understand current phase and continue the pipeline. If state is corrupted, present the situation to the human and ask for guidance.
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
            PROMPT="BISHX-PLAN: You are in the RESEARCH phase. Spawn the researcher agent and write results to RESEARCH.md. When done, update state.json and emit <bishx-plan-done>."
            ;;
          "pipeline:planner")
            PROMPT="BISHX-PLAN: You are in the PLANNING phase. Spawn the planner agent and write PLAN.md. When done, update state.json and emit <bishx-plan-done>."
            ;;
          "pipeline:skeptic")
            PROMPT="BISHX-PLAN: You are in the SKEPTIC phase. Spawn the skeptic agent and write SKEPTIC-REPORT.md. When done, update state.json and emit <bishx-plan-done>."
            ;;
          "pipeline:tdd-reviewer")
            PROMPT="BISHX-PLAN: You are in the TDD REVIEW phase. Spawn the TDD reviewer agent and write TDD-REPORT.md. When done, update state.json and emit <bishx-plan-done>."
            ;;
          "pipeline:critic")
            PROMPT="BISHX-PLAN: You are in the CRITIC phase. Spawn the critic agent and write CRITIC-REPORT.md. When done, update state.json with the verdict and emit <bishx-plan-done>."
            ;;
          "finalize:")
            PROMPT="BISHX-PLAN: Finalization in progress. Complete the finalization steps and emit <bishx-plan-done>."
            ;;
          *)
            PROMPT="BISHX-PLAN: Session is active but state is unclear. Read .bishx-plan/state.json and continue the current phase. Emit <bishx-plan-done> when the current phase is complete."
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

# Cleanup tmux windows left behind by exited teammates (bare shell = agent exited)
_cleanup_tmux() {
  local sock
  sock=$(ls /tmp/tmux-$(id -u)/ 2>/dev/null | grep claude-swarm | head -1 || true)
  if [[ -n "$sock" ]]; then
    tmux -L "$sock" list-windows -a -F '#{session_name}:#{window_index} #{pane_current_command}' 2>/dev/null | while read -r line; do
      local win cmd
      win=$(echo "$line" | awk '{print $1}')
      cmd=$(echo "$line" | awk '{print $NF}')
      if [[ "$cmd" == "zsh" || "$cmd" == "bash" || "$cmd" == "sh" ]]; then
        tmux -L "$sock" kill-window -t "$win" 2>/dev/null || true
      fi
    done || true
  fi
}

if [[ -f "$RUN_STATE" ]]; then
  RUN_ACTIVE=$(jq -r '.active // false' "$RUN_STATE")
  if [[ "$RUN_ACTIVE" == "true" ]]; then

    PAUSED=$(jq -r '.paused // false' "$RUN_STATE")
    CURRENT_TASK=$(jq -r '.current_task // ""' "$RUN_STATE")
    MODE=$(jq -r '.mode // "full"' "$RUN_STATE")

    # Signal: complete — allow exit + tmux cleanup
    if echo "$LAST_OUTPUT" | grep -q "<bishx-complete>"; then
      _cleanup_tmux
      jq '.active = false' "$RUN_STATE" > "$RUN_STATE.tmp" && mv "$RUN_STATE.tmp" "$RUN_STATE"
      exit 0
    fi

    # Session is paused — cleanup + allow exit
    if [[ "$PAUSED" == "true" ]]; then
      _cleanup_tmux
      exit 0
    fi

    # Cleanup: kill tmux windows where the agent exited (shell left behind)
    _cleanup_tmux

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
