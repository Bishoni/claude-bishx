---
description: Show current bishx-run session status
---

Read `.omc/state/bishx-run-state.json` and `.omc/state/bishx-run-context.md` and present a concise status:

- **Session:** active / paused / inactive
- **Mode:** dev / full
- **Current task:** id + title (from bd)
- **Progress:** X/Y tasks done
- **Agents:** Dev (working/idle), Reviewer (working/idle), QA (working/idle), Operator (listening)
- **Retries:** count
- **Last event:** timestamp + description

If no state file exists, report "No active bishx-run session."

Also run `bd epic status` if epic_id is in state to show bd-level progress.
