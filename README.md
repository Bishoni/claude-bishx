# bishx

Full dev lifecycle plugin for [Claude Code](https://claude.com/product/claude-code). Takes you from a raw idea to shipped code through a structured pipeline of AI agents.

```
idea → prompt → plan → tasks → code → test
```

## Installation

### Quick install

```bash
# Clone into Claude Code plugins directory
git clone https://github.com/Bishoni/claude-bishx.git ~/.claude/plugins/bishx

# Register in local marketplace
mkdir -p ~/.claude/plugins/marketplaces/local/plugins
ln -s ~/.claude/plugins/bishx ~/.claude/plugins/marketplaces/local/plugins/bishx

# Register in cache
mkdir -p ~/.claude/plugins/cache/local/bishx
ln -s ~/.claude/plugins/bishx ~/.claude/plugins/cache/local/bishx/1.0.0
```

Restart Claude Code. Type `/bishx:` to verify commands appear in autocomplete.

### Prerequisites

- [Claude Code](https://claude.com/product/claude-code) CLI
- [bd (beads)](https://github.com/steveyegge/beads) — local task tracker used for task decomposition and execution

## Commands

### Setup

| Command | Description |
|---------|-------------|
| `/bishx:init` | Scaffold `CLAUDE.md` and `AGENTS.md` templates in project root |
| `/bishx:init-sync` | Scan existing codebase and populate both files with real data |

Run `init` when starting a project from scratch. Run `init-sync` once there's code to analyze.

### Development Cycle

```
/bishx:prompt → /bishx:plan → /bishx:bd → /bishx:run
```

| Command | Description |
|---------|-------------|
| `/bishx:prompt <idea>` | Turn a raw idea into a structured planning prompt |
| `/bishx:plan <prompt>` | Run 5-actor verification pipeline (Researcher → Planner → Skeptic → TDD Reviewer → Critic) to produce a bulletproof implementation plan |
| `/bishx:bd` | Decompose the approved plan into bd tasks (Epic → Feature → Task hierarchy) |
| `/bishx:run` | Execute tasks with multi-agent orchestration (Lead → Dev → 3 Reviewers → QA) |
| `/bishx:run full` | Full cycle: development + code review + QA testing |
| `/bishx:run dev` | Fast cycle: development + code review only |
| `/bishx:test` | Deep system testing: auto-detects stack, discovers components, runs unit/integration/E2E/security/performance tests, reports bugs to bd |

### Analysis

| Command | Description |
|---------|-------------|
| `/bishx:idea` | Analyze the project and suggest new features sorted by ROI |
| `/bishx:idea <focus>` | Narrow suggestions to a specific area (e.g., `marketing`, `monetization`, `ux`) |
| `/bishx:polish` | Find technical improvements: performance, security, code quality, architecture |
| `/bishx:polish <focus>` | Narrow analysis to a specific area (e.g., `security`, `performance`, `dx`) |

### Management

| Command | Description |
|---------|-------------|
| `/bishx:status` | Check current development session status |
| `/bishx:cancel` | Stop the active development session |

### Testing

| Command | Description |
|---------|-------------|
| `/bishx:test` | Deep system testing — auto-detects stack, discovers components, runs all test types, reports bugs to bd with reproduction steps |
| `/bishx:test <types>` | Run specific test types (e.g., `unit`, `integration`, `e2e`, `security`, `performance`) |

### Hooks

The plugin registers a **Stop hook** that keeps planning and execution sessions alive. It prevents Claude Code from exiting mid-pipeline by intercepting stop signals and re-injecting continuation prompts. The hook also cleans up tmux windows left behind by exited teammate agents.

## Architecture

The plugin uses [Agent Teams](https://docs.anthropic.com/en/docs/claude-code/agent-teams) — independent Claude Code sessions that communicate peer-to-peer via `SendMessage` and coordinate through a shared `TaskList`.

### Planning pipeline (5 actors)

```
Interview → Research → [Planner → Skeptic → TDD Reviewer → Critic] ×N
```

Iterates up to 5 times until the Critic scores ≥20/25 (APPROVED).

### Execution pipeline

```
Lead → Dev (opus) → 3 Reviewers (sonnet, parallel) → Validate (haiku) → QA (opus)
```

Lead assigns bd tasks from the board and orchestrates the full cycle:

1. **Dev** (opus) implements the task
2. **Three parallel reviewers** (sonnet) analyze the diff independently:
   - **Bug Reviewer** — correctness, logic errors, syntax, tests
   - **Security Reviewer** — OWASP vulnerabilities, injection, XSS, SSRF, secrets
   - **Compliance Reviewer** — CLAUDE.md/AGENTS.md project rules
3. **Per-issue validation** (haiku) — each CRITICAL/MAJOR finding is independently confirmed or rejected by a haiku subagent to suppress false positives
4. **QA** (opus) runs acceptance testing

Each reviewer has formal severity definitions (CRITICAL/MAJOR/MINOR/INFO), HIGH SIGNAL filters ("what NOT to flag"), scope discipline (diff-only), and self-validation. Pass/fail is deterministic: zero CRITICAL + zero MAJOR + automated checks pass.

Review approach inspired by the [Anthropic code-review plugin](https://github.com/anthropics/claude-code/tree/main/plugins/code-review).

Lead performs centralized skill lookup from the skill library before each task, passing relevant skill paths to each agent (≤1500 lines budget per agent).

Run modes:
- `full` — Dev → Review → QA (default)
- `dev` — Dev → Review only (faster)

## File Structure

```
bishx/
├── .claude-plugin/plugin.json    # Plugin manifest
├── README.md
├── agents/                       # Agent role definitions (planning pipeline)
│   ├── critic.md                 # Final quality gate
│   ├── planner.md                # Implementation planner
│   ├── researcher.md             # Deep codebase/API research
│   ├── skeptic.md                # Mirage detector — verifies claims against reality
│   └── tdd-reviewer.md           # TDD compliance checker
├── commands/                     # Slash command definitions
│   ├── cancel.md
│   ├── idea.md
│   ├── init.md
│   ├── init-sync.md
│   ├── plan.md
│   ├── plan-to-bd-tasks.md       # /bishx:bd implementation
│   ├── polish.md
│   ├── prompt.md
│   ├── run.md
│   ├── status.md
│   └── test.md
├── hooks/                        # Stop hooks for session persistence
│   ├── discover-skills.sh        # Auto-detect relevant skills for planning
│   ├── hooks.json
│   └── stop-hook.sh              # Keeps plan/run sessions alive
└── skills/                       # Detailed skill instructions
    ├── init-sync/SKILL.md
    ├── plan/SKILL.md
    ├── prompt/SKILL.md
    ├── run/SKILL.md
    └── test/SKILL.md
```

## Credits

The planning stage (`/bishx:plan`, `/bishx:prompt`) is based on [beast-plan](https://github.com/malakhov-dmitrii/beast-plan) by Dmitrii Malakhov.

## License

MIT
