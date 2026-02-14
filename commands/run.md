---
description: Execute bd tasks with multi-agent orchestration (Lead → Dev → Reviewer → QA)
---

Invoke the `bishx:run` skill and follow it exactly.

Arguments: $ARGUMENTS

Supported flags:
- `--mode dev` — without QA (faster)
- `--mode full` — with QA (default)
- No arguments — resume if paused session exists, otherwise fresh start
