---
name: test
description: "Deep system testing — auto-detects stack, discovers components, runs unit/integration/E2E/security/performance tests, reports bugs to bd with full reproduction steps."
---

# Bishx-Test: Deep System Testing

Autonomous testing skill. Detects project stack, discovers components, runs existing tests,
performs E2E acceptance testing via Playwright MCP, security audit, data integrity and
performance checks. Writes proposed tests to run directory (never touches project source).
Produces structured bug reports in bd.

## FORBIDDEN

- Skipping Discovery phase
- Hardcoding project-specific paths, commands, or URLs
- Running E2E without Playwright MCP (if web UI exists)
- Fixing bugs — ONLY find and report
- Creating bd tasks without severity and reproduction steps
- Using Sonnet/Haiku agents — ALL agents are Opus
- Writing ANY files into the project source tree — all output goes to `{run_dir}/`
- Modifying existing project code, tests, or configuration

## Flow

```
/bishx:test
     │
     ▼
Phase 0: DETECT — auto-detect stack, build profile.json
     │
     ▼
Phase 1: DISCOVER — map components, coverage, gaps, risk areas
     │
     ▼
Phase 2: ASK — AskUserQuestion with available test types
     │
     ▼
Phase 3: EXECUTE — run selected test types (parallel where possible)
     │
     ▼
Phase 4: REPORT — create/update bd epic, summary to user
```

---

## Phase 0: DETECT

**Actor:** Lead (main thread)
**Goal:** Build a machine-readable project profile.

### Run Directory

All artifacts for this run go into `.bishx-test/{YYYY-MM-DD_HH-MM}/` where the value is date + time (e.g. `2026-02-17_14-30`).
Create the directory at the start. Pass the resolved path to all agents as `{run_dir}`.

Read the project root and detect:

### Stack Detection Rules

| Marker File | Stack |
|------------|-------|
| `pyproject.toml`, `requirements.txt`, `setup.py`, `Pipfile` | Python |
| `package.json` | Node/TypeScript/JavaScript |
| `go.mod` | Go |
| `Cargo.toml` | Rust |
| `*.csproj`, `*.sln` | C# / .NET |
| `pom.xml`, `build.gradle` | Java/Kotlin |
| `composer.json` | PHP |

### Test Runner Detection

| Marker | Runner | Command Pattern |
|--------|--------|----------------|
| `pytest.ini`, `conftest.py`, `pyproject.toml[tool.pytest]` | pytest | `pytest {test_dir} -v --tb=short` |
| `vitest.config.*` | vitest | `npx vitest run` |
| `jest.config.*`, `package.json["jest"]` | jest | `npx jest` |
| `*_test.go` | go test | `go test ./...` |
| `Cargo.toml` + `#[cfg(test)]` | cargo test | `cargo test` |
| `*.test.cs`, `*.Tests.csproj` | dotnet test | `dotnet test` |

### Virtual Environment Detection (Python)

Check in order: `.venv/`, `venv/`, `.env/`, `env/`
If found, prefix all Python commands: `{venv}/bin/python`, `{venv}/bin/pytest`, etc.

### Infrastructure Detection

| Marker | What |
|--------|------|
| `docker-compose.yml` / `compose.yml` | Services, ports, health checks |
| `Dockerfile` | Build context |
| `.env` / `.env.example` | Environment variables |
| Vite/Next/Nuxt config | Frontend dev server URL + port |

### MCP Detection

Check available MCP tools by attempting to list them. Key tools:
- `browser_navigate` — Playwright MCP available, E2E possible
- `send_message` (Telegram) — Telegram MCP available
- Other domain-specific MCPs

### Output: `{run_dir}/profile.json`

```json
{
  "project": "<project name from nearest package.json/pyproject.toml/directory name>",
  "detected_at": "<ISO timestamp>",
  "stacks": [
    {
      "name": "<component name: backend/frontend/api/worker/etc>",
      "lang": "<python|typescript|go|rust|java|csharp|php>",
      "framework": "<fastapi|django|express|nextjs|gin|actix|etc>",
      "test_runner": "<pytest|vitest|jest|go_test|cargo_test|dotnet_test>",
      "test_cmd": "<full command to run existing tests>",
      "coverage_cmd": "<full command to run with coverage, null if unavailable>",
      "test_dir": "<path to test directory>",
      "source_dir": "<path to source directory>",
      "entry_point": "<main file if identifiable>",
      "venv": "<path to venv or null>",
      "has_tests": true
    }
  ],
  "services": {
    "docker_compose": true,
    "compose_file": "<path>",
    "start_cmd": "<command to start all services>",
    "health_check": "<URL or command to verify services are up>",
    "web_url": "<frontend URL if web app, null otherwise>",
    "api_url": "<API base URL if detectable>"
  },
  "mcp": {
    "playwright": true,
    "telegram": false
  },
  "e2e_possible": true,
  "db": {
    "type": "<postgresql|mysql|sqlite|mongodb|etc>",
    "test_db": "<in-memory strategy or test DB config>"
  }
}
```

If detection fails for any field, set to `null`, do NOT guess.

---

## Phase 1: DISCOVER

**Actor:** Analyst agent (Opus, read-only)

```
Task(
  subagent_type="oh-my-claudecode:architect",
  model="opus",
  prompt=<profile.json + discovery instructions below>
)
```

### Discovery Instructions

Given the project profile, the analyst MUST:

1. **Map all components:**
   - List every service, module, package, router, controller, model
   - For each: purpose, public API, dependencies

2. **Audit existing test coverage:**
   - Run coverage command from profile: `{stack.coverage_cmd}`
   - If no coverage tool, estimate by comparing test files to source files
   - Per-module breakdown: covered / partially covered / no tests

3. **Identify risk areas** (high priority for testing):
   - Data parsing/transformation (parsers, importers, serializers)
   - External integrations (API calls, file I/O, DB queries)
   - User input handling (forms, uploads, query params)
   - Authentication/authorization logic
   - Financial/statistical calculations
   - State mutations (DB writes, cache updates)

4. **Build priority matrix:**
   ```
   Priority = Risk Level x (1 - Coverage)

   Risk Level:
     Critical — data corruption, security, money
     High     — core business logic, main user flows
     Medium   — secondary features, admin functions
     Low      — cosmetic, logging, dev tooling
   ```

5. **Determine available test types** based on profile:
   - Backend Unit: available if any backend stack detected
   - Backend API: available if API endpoints exist (routers/controllers)
   - E2E Acceptance: available if `e2e_possible == true`
   - Security: always available
   - Data Integrity: available if data pipeline exists (import/export/transform)
   - Performance: available if API endpoints exist
   - Accessibility: available if `e2e_possible == true` (uses Playwright accessibility tree)
   - Error Handling: always available (tests resilience to failures)
   - UX/UI Visual: available if `e2e_possible == true` (uses Playwright for visual quality checks)
   - Web Bug Hunting: available if `e2e_possible == true` (uses Playwright for exploratory bug search)

**CONTEXT BUDGET for analyst:** Keep the report under 200 lines. Be structured and concise — tables over prose.

### Output: `{run_dir}/discovery-report.md`

Structure:
```markdown
# Discovery Report

## Component Map
[table: component, type, source path, purpose]

## Test Coverage
[table: module, coverage %, test count, status]

## Risk Areas
[ordered list with risk level and reasoning]

## Priority Matrix
[table: module, risk, coverage, priority score]

## Available Test Types
[list with availability status and reasoning]

## Recommended Test Plan
[ordered list: what to test first and why]
```

---

## Phase 2: ASK

**Actor:** Lead (main thread)

Read discovery report. Present available test types via AskUserQuestion.
Split into groups so each question has 2-4 options (AskUserQuestion limit).
Populate descriptions with real numbers from discovery (coverage %, module count, route count).
If a type is unavailable, do NOT include it in that group's options.
If all options in a group are unavailable, omit the entire question.

```
AskUserQuestion(
  questions=[
    {
      question: "Backend testing — which types to run?",
      header: "Backend",
      multiSelect: true,
      options: [
        {
          label: "Backend Unit",
          description: "Services, parsers, business logic, edge cases. {N} modules, {M}% covered."
        },
        {
          label: "Backend API",
          description: "Endpoints, contracts, status codes, error responses. {N} routes found."
        },
        {
          label: "Error Handling",
          description: "Resilience: DB down, invalid config, corrupted input, network failures."
        }
      ]
    },
    {
      // Only include this question if e2e_possible == true
      question: "Web testing (Playwright) — which types to run?",
      header: "Web",
      multiSelect: true,
      options: [
        {
          label: "E2E Acceptance",
          description: "User flows step-by-step: forms, navigation, CRUD operations."
        },
        {
          label: "UX/UI Visual",
          description: "Visual quality: responsive viewports, empty/loading/error states, design consistency."
        },
        {
          label: "Web Bug Hunting",
          description: "Exploratory testing: console errors, broken links, state bugs, URL manipulation."
        },
        {
          label: "Accessibility",
          description: "WCAG compliance: ARIA, contrast, keyboard navigation, screen reader support."
        }
      ]
    },
    {
      question: "Specialized testing — which types to run?",
      header: "Specialized",
      multiSelect: true,
      options: [
        {
          label: "Security",
          description: "OWASP Top 10: injections, XSS, file upload abuse, CORS, auth."
        },
        {
          label: "Data Integrity",
          description: "Data pipeline consistency: import to DB to API to UI."
        },
        {
          label: "Performance",
          description: "Response times, large datasets, slow queries, memory."
        },
        {
          label: "Full",
          description: "Select ALL available test types across all groups."
        }
      ]
    }
  ]
)
```

If user selects "Full" in any group — enable ALL available types across ALL groups.

After user selects test types, ask about audit mode:

```
AskUserQuestion(
  questions=[{
    question: "Audit mode — should agents propose test files?",
    header: "Audit mode",
    multiSelect: false,
    options: [
      {
        label: "Hybrid (Recommended)",
        description: "Agents find bugs AND write proposed test files to .bishx-test/{run}/proposed-tests/. Project is untouched."
      },
      {
        label: "Read-only",
        description: "Agents only find bugs and write reports. No test files created."
      }
    ]
  }]
)
```

Store the choice. Pass `audit_mode: "hybrid"` or `audit_mode: "readonly"` to all agent prompts.

---

### Proposed Tests Directory (Hybrid mode only)

When `audit_mode == "hybrid"`, agents write proposed test files to:

```
{run_dir}/proposed-tests/
├── test_deep_{module_name}.{ext}
├── test_api_{endpoint_name}.{ext}
├── test_error_{service_name}.{ext}
└── ...
```

Rules for proposed tests:
- Files go ONLY into `{run_dir}/proposed-tests/` — NEVER into the project tree
- Use the project's test framework, imports, and fixtures
- Each test file has a header comment:
  ```
  # Proposed by bishx:test — Run #{N}, {date}
  # Target: {source_file}:{line}
  # Bug: {bug_title}
  # To use: copy this file to {project_test_dir}/ and run with {test_cmd}
  ```
- Tests must be self-contained and runnable when copied to the project test directory
- Do NOT run proposed tests (they may require project test directory context/fixtures)

---

## Phase 3: EXECUTE

### Execution Order

```
Wave 1 (parallel):   Backend Unit + Backend API + Security + Error Handling
Wave 2 (parallel):   Data Integrity + Performance
Wave 3 (parallel):   E2E Acceptance + Accessibility + UX/UI Visual + Web Bug Hunting
```

Only run waves that contain selected test types.
If only E2E selected, skip waves 1-2, go straight to wave 3.

### Pre-flight Check (before Wave 3)

If any Wave 3 type is selected (E2E Acceptance, Accessibility, UX/UI Visual, Web Bug Hunting):
1. Check if services are running: `curl {profile.services.health_check}`
2. If NOT running and docker_compose is available:
   - Ask user: "Services are not running. Start with `{profile.services.start_cmd}`?"
3. If NOT running and no docker_compose:
   - Ask user how to start services
4. Do NOT proceed with E2E until health check passes

### Bugs Summary (before Wave 3)

Before launching Wave 3, Lead reads all Wave 1-2 report files and creates a condensed summary:

**File:** `{run_dir}/bugs-summary.md`

Format:
```markdown
# Bugs Summary (Waves 1-2)

## P1 (Blockers)
- [Backend Unit] {title} — {file}:{line} — {1-line description}

## P2 (Major)
- [Security] {title} — {file}:{line} — {1-line description}

## P3 (Minor)
- [API] {title} — {file}:{line} — {1-line description}

## Key Findings
- {1-line insight relevant to UI testing}
- {1-line insight relevant to UI testing}
```

Keep under 50 lines. Wave 3 agents read THIS instead of full reports.

### Agent Spawn Pattern

For each selected test type, spawn an agent with a slim prompt:

```
Task(
  subagent_type="{agent_type}",
  model="opus",
  prompt="You are testing '{profile.project}'.

Stack: {relevant stack info from profile}
Run dir: {run_dir}
Audit mode: {audit_mode}
Venv: {stack.venv or 'none'}

Instructions: Read ~/.claude/plugins/bishx/skills/test/types/{type_file} and follow them.

Output: {run_dir}/{report_file}"
)
```

### Type → File Mapping

| Type | File | Agent Type | Report File |
|------|------|------------|-------------|
| Backend Unit | `backend-unit.md` | executor-high | `backend-unit-report.md` |
| Backend API | `backend-api.md` | executor-high | `backend-api-report.md` |
| Security | `security.md` | security-reviewer | `security-report.md` |
| Error Handling | `error-handling.md` | executor-high | `error-handling-report.md` |
| Data Integrity | `data-integrity.md` | executor-high | `data-integrity-report.md` |
| Performance | `performance.md` | executor-high | `performance-report.md` |
| E2E Acceptance | `e2e-acceptance.md` | executor-high | `e2e-report.md` |
| Accessibility | `accessibility.md` | executor-high | `accessibility-report.md` |
| UX/UI Visual | `ux-ui-visual.md` | executor-high | `ux-ui-visual-report.md` |
| Web Bug Hunting | `web-bug-hunting.md` | executor-high | `web-bug-hunting-report.md` |

All type files are at: `~/.claude/plugins/bishx/skills/test/types/`

### Python Projects

If .venv/ or venv/ exists, include in the spawn prompt:
```
IMPORTANT: Use {venv}/bin/python, {venv}/bin/pytest, {venv}/bin/ruff — NEVER bare python/pytest.
```

---

## Phase 4: REPORT

**Actor:** Lead (main thread)

### 4.1 Aggregate Findings

Read all `*-report.md` files from `{run_dir}/`.
Merge all bugs into a single list. Deduplicate (same root cause found by different phases).

### 4.2 bd Integration

#### Epic naming convention:

```
QA: {TestType}
```

Examples:
- `QA: Backend Unit`
- `QA: E2E Acceptance`
- `QA: Security`
- `QA: Full` (when multiple types selected)

#### Structure:

```
Epic: "QA: {TestType}"                          <- created once, reused across runs
|
+-- Feature: "Run #{N} — {YYYY-MM-DD}"          <- each /bishx:test invocation
|   +-- Task: [P2] bug title                    <- bug
|   +-- Task: [P3] bug title                    <- bug
|   +-- Task: [Proposed] test_deep_parser.py    <- proposed test (hybrid mode)
|   +-- Task: [Proposed] test_api_upload.py     <- proposed test (hybrid mode)
|   +-- ...
```

#### Finding existing epic:

```bash
bd search "QA: {TestType}" --json
# or
bd list --type epic --json
```

Parse JSON output to find matching epic ID. If exists, reuse. If not, create:

```bash
bd create "QA: {TestType}" --type epic --description "Deep testing results for {TestType}"
```

#### Creating feature (run):

Count existing children of the epic to determine run number:

```bash
bd children {epic_id} --json
```

Create feature as child of epic:

```bash
bd create "Run #{N} — {date_time}" --type feature --parent {epic_id} --description "Test run on {date_time}. Selected: {test_types}. Profile: {stack summary}."
```

#### Creating tasks (bugs):

For each bug found, create as child of feature:

```bash
bd create "[P{n}] {short title}" --type bug --parent {feature_id} --priority {0-4} --description "{full bug description}"
```

Priority mapping: P1=1, P2=2, P3=3, P4=4 (bd uses 0-4 where 0=highest).

#### Creating tasks (proposed tests) — hybrid mode only:

For each proposed test file, create a task under the same feature:

```bash
bd create "[Proposed] {test_filename} — {N} tests for {module}" --type task --parent {feature_id} --priority 3 --description "{proposed test description}"
```

Proposed test tasks are always priority 3 (low) — they are suggestions, not bugs.

### 4.3 Bug Description Format

Every bd task MUST contain:

```markdown
## [{severity}] {Short descriptive title}

**Severity:** {P1|P2|P3|P4} — {Blocker|Major|Minor|Cosmetic}
**Component:** {file_path}:{line_number} (or {module/area} if not pinpointable)
**Test type:** {which phase found this}
**Found by:** bishx:test Run #{N}

### Description
{Clear explanation of what is wrong and why it matters.}

### Steps to Reproduce
1. {Step 1}
2. {Step 2}
3. {Step 3}

### Expected Behavior
{What should happen.}

### Actual Behavior
{What actually happens. Include error messages, tracebacks, wrong values.}

### Evidence
- Screenshot: {if E2E — describe what screenshot shows}
- Test file: {path to test that caught this}
- Logs: {relevant log output if any}

### Proposed Test (hybrid mode)
- **File:** `{run_dir}/proposed-tests/{test_filename}`
- **Reproduces this bug:** yes/partially/no (coverage only)
- **How to use:** `cp {run_dir}/proposed-tests/{test_filename} {project_test_dir}/ && {test_cmd}`
(Omit this section in readonly mode or if no proposed test covers this bug)

### Where to Fix
- **File:** {file_path}:{line_number}
- **What:** {Specific guidance — what to change, add, or remove}
- **Related:** {Other files/tests affected by this fix}
```

### 4.4 Proposed Test Description Format (hybrid mode only)

Every proposed test bd task MUST contain:

```markdown
## [Proposed] {test_filename}

**File:** `{run_dir}/proposed-tests/{test_filename}`
**Target module:** {source_file}:{line_range}
**Test type:** {which phase produced this}
**Tests count:** {N}
**Found by:** bishx:test Run #{N}

### What it tests
{Brief description — which functions, endpoints, or scenarios.}

### Test cases
1. {test_name} — {what it verifies}
2. {test_name} — {what it verifies}

### How to use
1. Copy: `cp {run_dir}/proposed-tests/{test_filename} {project_test_dir}/`
2. Review imports and fixtures — adapt to project context if needed
3. Run: `{test_cmd} {project_test_dir}/{test_filename}`
```

### Severity Guide

| Level | Label | Criteria |
|-------|-------|----------|
| P1 | Blocker | Crash, data loss, security vulnerability, regression in existing tests |
| P2 | Major | Core feature broken, wrong data shown, missing validation |
| P3 | Minor | Edge case failure, non-critical UX issue, missing error message |
| P4 | Cosmetic | Layout glitch, typo, inconsistent formatting |

### 4.5 Summary to User

After bd tasks are created, present a summary:

```markdown
## Test Run Complete

**Project:** {name}
**Date:** {date}
**Types:** {selected test types}

### Results
| Type | Tests Run | Passed | Failed | Bugs Found |

### Bugs by Severity
| P1 | P2 | P3 | P4 | Total |

### bd
- Epic: "{epic name}" (#{epic_id})
- Feature: "Run #{N}" (#{feature_id})
- Tasks created: {count}

### Top Issues
1. [P1] {title} — {one-line description}
2. [P2] {title} — {one-line description}

### Proposed Tests (hybrid mode only)
| File | Tests | Target Module | Related Bugs | bd Task |
- Location: `.bishx-test/{run}/proposed-tests/`
- To use: `cp .bishx-test/{run}/proposed-tests/* {project_test_dir}/`
```

---

## Rules

1. **Discovery first** — never test blindly. Always build profile + discovery report.
2. **Profile-driven** — all commands, paths, URLs come from profile.json. No hardcoding.
3. **Playwright MCP is MANDATORY** for web E2E. No curl/fetch substitutes for UI testing.
4. **Do NOT fix bugs** — only find and report. The output is a bd task, not a code change.
5. **Proposed tests go to `{run_dir}/proposed-tests/` ONLY** — never write into the project tree.
6. **Screenshot every visual anomaly** — via browser_take_screenshot.
7. **Proposed test files are suggestions** — user decides whether to copy them into the project.
8. **Exhaustive bug descriptions** — developer must be able to fix without asking questions.
9. **Deduplicate** — same root cause found by multiple phases = one bd task, mention all evidence.
10. **All agents are Opus** — no cost-cutting on test quality.
11. **Adapt, don't fail** — if a test type is unavailable, skip it gracefully and inform the user.
12. **Reuse bd epics** — same test type across runs shares one epic, each run is a feature.
13. **Respect audit mode** — "readonly" = no test files, only reports. "hybrid" = proposed tests in run dir.
14. **Context budget** — agents MUST respect their type file's Context Budget section. Truncate verbose output.
