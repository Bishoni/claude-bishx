# bishx

Full dev lifecycle plugin for [Claude Code](https://claude.com/product/claude-code). Takes you from a raw idea to shipped code through a structured pipeline of AI agents.

```
idea → prompt → plan → tasks → code → test → site audit
```

## Installation

```bash
git clone https://github.com/Bishoni/claude-bishx.git ~/.claude/plugins/bishx
```

Then launch Claude Code with the plugin:

```bash
claude --plugin-dir ~/.claude/plugins/bishx
```

Type `/bishx:` to verify commands appear in autocomplete.

### Prerequisites

- [Claude Code](https://claude.com/product/claude-code) CLI
- [bd (beads)](https://github.com/steveyegge/beads) — local task tracker used for task decomposition and execution

## Commands

| Command | Description |
|---------|-------------|
| `/bishx:prompt <idea>` | Generate a structured planning prompt from a raw idea |
| `/bishx:plan <prompt>` | Run 10-actor verification pipeline (up to 10 iterations) to produce a bulletproof implementation plan |
| `/bishx:plan-to-bd-tasks` | Decompose the approved plan into bd tasks (Epic → Feature → Task hierarchy) |
| `/bishx:run` | Execute tasks with multi-agent orchestration (Lead → Dev → 3 Reviewers → QA) |
| `/bishx:run <epic>` | Select a specific epic by name (partial match, e.g. `/bishx:run auth`) |
| `/bishx:test` | Deep system testing: auto-detects stack, discovers components, runs all test types, reports bugs to bd |
| `/bishx:site <url>` | Full website audit — crawls up to 100 pages via cmux browser, analyzes UX/UI, SEO, accessibility, performance, conversion |
| `/bishx:init` | Create CLAUDE.md and AGENTS.md templates in the project root |
| `/bishx:init-sync` | Scan codebase and fill/update CLAUDE.md and AGENTS.md with real project data |

> `/bishx:status`, `/bishx:cancel`, `/bishx:polish`, `/bishx:idea` are defined but **not yet functional**.

## Architecture

The plugin uses [Agent Teams](https://docs.anthropic.com/en/docs/claude-code/agent-teams) — independent Claude Code sessions that communicate peer-to-peer via `SendMessage` and coordinate through a shared `TaskList`.

### Planning pipeline (10 actors)

```
                                  ┌─ Skeptic (opus)
                                  ├─ TDD Reviewer (sonnet)
Interview → Research → Planner →  ├─ Completeness (sonnet)  → Critic → Dry-Run? ×N
                                  ├─ Integration (sonnet)
                                  ├─ Security* (sonnet)
                                  └─ Performance* (sonnet)
                                    * = conditional
```

Iterates up to 10 times until the Critic scores ≥75% with zero blocking issues (APPROVED) and the Dry-Run Simulator passes. Complexity gate adapts the pipeline: TRIVIAL skips review, SMALL runs lite review, MEDIUM+ runs full parallel review. Each session is stored in a timestamped directory (`.bishx-plan/YYYY-MM-DD_HH-MM/`) with all iterations preserved for history. The approved plan is saved as `APPROVED_PLAN.md` inside the session directory.

#### Skill-library integration

After research completes, the orchestrator performs a skill-library lookup from `~/.claude/skill-library/`:

1. Reads `INDEX.md` hierarchy to identify relevant categories by tech stack
2. Selects skills per-role: implementation patterns for Planner, verification rules for Skeptic
3. Writes `PLANNER-SKILLS.md` and `SKEPTIC-SKILLS.md` with full skill paths
4. Agents read FULL SKILL.md files themselves (no truncation, ≤2500 lines budget per agent)

### Execution pipeline

```
Lead → Dev (opus) → 3 Reviewers (sonnet, parallel) → Validate (sonnet) → QA (opus)
```

Lead assigns bd tasks from the board and orchestrates the full cycle:

1. **Dev** (opus) implements the task
2. **Three parallel reviewers** (sonnet) analyze the diff independently:
   - **Bug Reviewer** — correctness, logic errors, syntax, tests
   - **Security Reviewer** — OWASP vulnerabilities, injection, XSS, SSRF, secrets
   - **Compliance Reviewer** — CLAUDE.md/AGENTS.md project rules
3. **Per-issue validation** (sonnet) — each CRITICAL/MAJOR finding is independently confirmed or rejected by a sonnet subagent to suppress false positives
4. **QA** (opus) runs acceptance testing

Each reviewer has formal severity definitions (CRITICAL/MAJOR/MINOR/INFO), HIGH SIGNAL filters ("what NOT to flag"), scope discipline (diff-only), and self-validation. Pass/fail is deterministic: zero CRITICAL + zero MAJOR + automated checks pass.

Review approach inspired by the [Anthropic code-review plugin](https://github.com/anthropics/claude-code/tree/main/plugins/code-review).

Lead performs centralized skill lookup from the skill library before each task, passing relevant skill paths to each agent (≤2500 lines budget per agent).

All teammates (Dev, Reviewers, QA) reason and communicate in English for better analytical quality. Lead communicates with the user in the user's language.

### Site audit

```
/bishx:site https://example.com
```

Autonomous website audit powered by cmux browser. Crawls up to 100 pages and produces a design critique document (not code) with actionable recommendations.

**cmux** is a native macOS terminal application with a built-in WebKit browser. All browser commands are executed via **Bash** (not MCP tools). Full reference: `~/.claude/skill-library/references/cmux-browser.md`.
```bash
RAW=$(cmux browser open {url})   # uses $CMUX_WORKSPACE_ID automatically
SURFACE=$(echo "$RAW" | grep -o 'surface:[0-9]*' | head -1)
```
All subsequent commands follow the pattern `cmux browser --surface $SURFACE <subcommand> [args]`. Close surfaces when done with `cmux close-surface --surface $SURFACE`.

Evaluates through a Human-First lens across five layers:

1. **FOR WHOM** — is the right person being served?
2. **WHAT** — is the right content shown?
3. **HOW** — is the presentation right?
4. **FEELING** — how does the page feel to use?
5. **BEHAVIOR** — how does the site respond?

Audit covers 9 modules: UX design, accessibility, SEO (technical + content), performance, marketing content, brand consistency, information architecture, and conversion optimization.

Use when you need a comprehensive quality review of a live website before launch, after a redesign, or as a periodic health check.

Run modes:
- `full` — Dev → Review → QA (default)
- `dev` — Dev → Review only (faster)

## File Structure

```
bishx/
├── .claude-plugin/plugin.json    # Plugin manifest (v2.12.0)
├── README.md
├── agents/                       # Agent role definitions (planning pipeline)
│   ├── completeness-validator.md # Requirements traceability checker
│   ├── critic.md                 # Final quality gate with weighted scoring
│   ├── dry-run-simulator.md      # Simulates plan execution with zero context
│   ├── integration-validator.md  # Inter-task compatibility checker
│   ├── performance-auditor.md    # Performance analysis (conditional)
│   ├── planner.md                # Implementation planner with complexity budget
│   ├── researcher.md             # Deep codebase/API research with RQ protocol
│   ├── security-reviewer.md      # Security analysis (conditional)
│   ├── skeptic.md                # Mirage detector — presence + absence mirages
│   └── tdd-reviewer.md           # TDD compliance with quantitative metrics
├── commands/                     # Slash command definitions
│   ├── cancel.md
│   ├── idea.md
│   ├── init.md
│   ├── init-sync.md
│   ├── plan.md
│   ├── plan-to-bd-tasks.md
│   ├── polish.md
│   ├── prompt.md
│   ├── run.md
│   ├── site.md
│   ├── status.md
│   └── test.md
├── hooks/                        # Stop hooks for session persistence
│   ├── discover-skills.sh        # Auto-detect relevant skills for research
│   ├── hooks.json
│   └── stop-hook.sh              # Keeps plan/run sessions alive
└── skills/                       # Detailed skill instructions
    ├── init-sync/SKILL.md
    ├── plan/SKILL.md
    ├── prompt/SKILL.md
    ├── run/SKILL.md
    ├── site/
    │   ├── SKILL.md              # Full audit framework
    │   └── types/                # 9 audit modules
    │       ├── accessibility.md
    │       ├── brand-consistency.md
    │       ├── conversion.md
    │       ├── information-architecture.md
    │       ├── marketing-content.md
    │       ├── performance.md
    │       ├── seo-content.md
    │       ├── seo-technical.md
    │       └── ux-design.md
    └── test/
        ├── SKILL.md
        └── types/                # Modular test type definitions
            ├── accessibility.md
            ├── backend-api.md
            ├── backend-unit.md
            ├── data-integrity.md
            ├── e2e-acceptance.md
            ├── error-handling.md
            ├── performance.md
            ├── security.md
            ├── ux-ui-visual.md
            └── web-bug-hunting.md
```

## Credits

The planning stage (`/bishx:plan`, `/bishx:prompt`) is based on [beast-plan](https://github.com/malakhov-dmitrii/beast-plan) by Dmitrii Malakhov.

## License

MIT
