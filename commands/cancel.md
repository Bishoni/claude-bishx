---
description: Stop the active bishx-run session gracefully
---

Stop the active bishx-run session:

1. Read `.omc/state/bishx-run-state.json`
2. If no active session → report "No active bishx-run session."
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
