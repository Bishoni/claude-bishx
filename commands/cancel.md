---
description: Stop the active bishx-run or bishx-site session gracefully
---

Stop the active bishx session. Check both modes:

## bishx-run

1. Read `.omc/state/bishx-run-state.json`
2. If no active session → skip to bishx-site check
3. If active:
   - Send shutdown_request to all active teammates
   - Wait for confirmations (max 30s)
   - Set `paused: false`, `active: false` in state.json
   - Generate final report (section 10.2 of spec):
     - Tasks completed / skipped / failed
     - Retries count
     - QA bugs found
     - Commits list
     - Files modified
   - Delete team via TeamDelete
   - Report: "bishx-run session stopped. Final report above."
4. Emit `<bishx-complete>` to allow exit.

## bishx-site

1. Read `.bishx-site/active`
2. If no active session → report "No active bishx session."
3. If active:
   - Read `state.json` from the session dir
   - Set `active: false`, `phase: "cancelled"` in state.json
   - Remove `.bishx-site/active`
   - Set `agent_pending: false` in state.json
   - Report what was completed: pages crawled, reports generated, current phase, wave number
   - If agents were running (agent_pending was true): note that subagents may still complete in the background. Their output will be in the session directory but will not be synthesized.
   - Report: "bishx-site session cancelled."
4. Emit `<bishx-site-complete>` to allow exit.
