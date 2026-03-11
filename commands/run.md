---
description: Execute bd tasks with multi-agent orchestration (Lead → Dev → Reviewer → QA)
---

Invoke the `bishx:run` skill and follow it exactly.

Arguments: $ARGUMENTS

Supported flags:
- `--mode dev` — without QA (faster)
- `--mode full` — with QA (default)
- `<epic name>` — select a specific epic by name (partial match supported)
- No arguments — resume if paused session exists, otherwise fresh start

Examples:
- `/bishx:run auth` — select epic containing "auth" in title
- `/bishx:run --mode dev auth` — dev mode + select "auth" epic
- `/bishx:run` — interactive epic selection
