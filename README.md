# bishx

Full dev lifecycle plugin for [Claude Code](https://claude.com/product/claude-code). Takes you from a raw idea to shipped code through a structured pipeline of AI agents.

```
idea → prompt → plan → tasks → code
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
| `/bishx:run` | Execute tasks with multi-agent orchestration (Lead → Dev → Reviewer → QA) |
| `/bishx:run full` | Full cycle: development + code review + QA testing |
| `/bishx:run dev` | Fast cycle: development + code review only |

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

## Architecture

The plugin uses [Agent Teams](https://docs.anthropic.com/en/docs/claude-code/agent-teams) — independent Claude Code sessions that communicate peer-to-peer via `SendMessage` and coordinate through a shared `TaskList`.

### Planning pipeline (5 actors)

```
Interview → Research → [Planner → Skeptic → TDD Reviewer → Critic] ×N
```

Iterates up to 5 times until the Critic scores ≥20/25 (APPROVED).

### Execution pipeline

```
Lead (orchestrator) → Dev (implementation) → Reviewer (code review) → QA (testing)
```

Lead assigns bd tasks, Dev implements, Reviewer catches issues, QA validates. All agents run as independent sessions with their own context.

## File Structure

```
bishx/
├── .claude-plugin/plugin.json    # Plugin manifest
├── README.md
├── agents/                       # Agent role definitions
│   ├── critic.md                 # Final quality gate (plan)
│   ├── dev.md                    # Developer agent (run)
│   ├── operator.md               # Lead/orchestrator (run)
│   ├── planner.md                # Implementation planner (plan)
│   ├── qa.md                     # QA tester (run)
│   ├── researcher.md             # Deep research (plan)
│   ├── reviewer.md               # Code reviewer (run)
│   ├── skeptic.md                # Mirage detector (plan)
│   └── tdd-reviewer.md           # TDD compliance (plan)
├── commands/                     # Slash command definitions
│   ├── bd.md
│   ├── cancel.md
│   ├── idea.md
│   ├── init.md
│   ├── init-sync.md
│   ├── plan.md
│   ├── polish.md
│   ├── prompt.md
│   ├── run.md
│   └── status.md
├── hooks/                        # Stop hooks for session persistence
│   ├── discover-skills.sh
│   ├── hooks.json
│   └── stop-hook.sh
└── skills/                       # Detailed skill instructions
    ├── init-sync/SKILL.md
    ├── plan/SKILL.md
    ├── prompt/SKILL.md
    └── run/SKILL.md
```

## License

MIT
