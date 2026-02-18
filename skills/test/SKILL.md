---
name: test
description: "Deep system testing — auto-detects stack, discovers components, runs unit/integration/E2E/security/performance tests, reports bugs to bd with full reproduction steps."
---

# Bishx-Test: Deep System Testing

Autonomous testing skill. Detects project stack, discovers components, runs existing tests,
performs E2E acceptance testing via Playwright MCP, security audit, data integrity and
performance checks. Writes proposed tests to run directory (never touches project source).
Produces structured bug reports in bd.

## Skill Library

Before any testing task, find a matching skill:
1. Read `~/.claude/skill-library/INDEX.md` — match task to category
2. Read `~/.claude/skill-library/<category>/INDEX.md` — find skill by keywords and "Use when..." triggers
3. Read the matching `SKILL.md` and follow it. Budget: total loaded ≤1500 lines
If no skill matches — proceed without one, don't force it.

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

### Output: `.bishx-test/{YYYY-MM-DD_HH-MM}/profile.json`

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
   - UX/UI Visual: available if `e2e_possible == true` (uses Playwright for visual quality checks across viewports)
   - Web Bug Hunting: available if `e2e_possible == true` (uses Playwright for exploratory bug search)

### Output: `.bishx-test/{YYYY-MM-DD_HH-MM}/discovery-report.md`

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
        // Only include if backend stack detected
        {
          label: "Backend Unit",
          description: "Services, parsers, business logic, edge cases. {N} modules, {M}% covered."
        },
        // Only include if API endpoints exist
        {
          label: "Backend API",
          description: "Endpoints, contracts, status codes, error responses. {N} routes found."
        },
        // Always available
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
        // Always available
        {
          label: "Security",
          description: "OWASP Top 10: injections, XSS, file upload abuse, CORS, auth."
        },
        // Only include if data pipeline exists
        {
          label: "Data Integrity",
          description: "Data pipeline consistency: import to DB to API to UI."
        },
        // Only include if API endpoints exist
        {
          label: "Performance",
          description: "Response times, large datasets, slow queries, memory."
        },
        // Always available — shortcut
        {
          label: "Full",
          description: "Select ALL available test types across all groups."
        }
      ]
    }
  ]
)
```

If user selects "Full" in any group — enable ALL available types across ALL groups (override individual selections).

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

### Pre-flight Check (before wave 3)

If any Wave 3 type is selected (E2E Acceptance, Accessibility, UX/UI Visual, Web Bug Hunting):
1. Check if services are running: `curl {profile.services.health_check}`
2. If NOT running and docker_compose is available:
   - Ask user: "Services are not running. Start with `{profile.services.start_cmd}`?"
3. If NOT running and no docker_compose:
   - Ask user how to start services
4. Do NOT proceed with E2E until health check passes

---

### Test Type: Backend Unit

**Agent:** Opus, full access

```
Task(
  subagent_type="oh-my-claudecode:executor-high",
  model="opus",
  prompt=<profile + discovery + instructions below>
)
```

**Instructions:**

You are testing project "{profile.project}".

Stack: {stack.lang} / {stack.framework}
Test runner: {stack.test_runner}
Run existing tests: `{stack.test_cmd}`
Source: {stack.source_dir}
Tests: {stack.test_dir}
Venv: {stack.venv} (if set, prefix ALL commands)

Workflow:
1. Run ALL existing tests: `{stack.test_cmd}`
   - Any failure: record as P1 (regression)
   - Parse output for pass/fail counts

2. Read discovery priority matrix. For each high-priority untested module:
   a. Read the source code
   b. Identify testable functions/methods
   c. If `audit_mode == "hybrid"`: write proposed test file to `{run_dir}/proposed-tests/test_deep_{module_name}.{ext}`
      If `audit_mode == "readonly"`: document what tests SHOULD exist in the report
   d. Match existing test patterns (imports, fixtures, assertions)
   e. Test cases MUST include:
      - Happy path (normal input, expected output)
      - Empty input (None, "", [], {})
      - Boundary values (0, -1, MAX_INT, very long strings)
      - Invalid types (string where int expected, etc.)
      - Unicode / special characters
      - Concurrent access (if async/threaded)
   f. Run the new test
   g. If test FAILS: likely a BUG, record with full details
   h. If test PASSES: coverage improved, note it

3. Do NOT write tests that are fitted to implementation.
   Tests must verify BEHAVIOR, not implementation details.
   No hardcoded magic values — derive expected values from logic.

Output: `.bishx-test/{YYYY-MM-DD_HH-MM}/backend-unit-report.md`

```markdown
# Backend Unit Test Report

## Existing Tests
- Total: N, Passed: N, Failed: N, Skipped: N
- Failures: [list with details]

## Proposed Tests (hybrid mode)
| File | Tests | Target Module | Bug Reference |

## Bugs Found
[structured bug entries — see Bug Format below]

## Coverage Gaps
| Module | Current Coverage | Missing |
```

---

### Test Type: Backend API

**Agent:** Opus, full access

```
Task(
  subagent_type="oh-my-claudecode:executor-high",
  model="opus",
  prompt=<profile + discovery + instructions below>
)
```

**Instructions:**

You are testing API endpoints of "{profile.project}".

API URL: {profile.services.api_url}
Stack: {stack.lang} / {stack.framework}
Test runner: {stack.test_runner}

Workflow:
1. Discover all API routes:
   - Read router/controller files from source
   - List: method, path, expected request/response

2. For each endpoint, test:
   a. **Happy path** — valid request, correct response + status code
   b. **Validation** — missing required fields, expect 400/422 with clear error
   c. **Not found** — invalid IDs, expect 404
   d. **Method not allowed** — wrong HTTP method, expect 405
   e. **Empty results** — valid query with no data, expect empty array not error
   f. **Large payloads** — oversized request body, appropriate limit
   g. **Content-Type** — wrong content type, expect 415 or graceful handling
   h. **Response schema** — response matches expected shape (all fields present, correct types)

3. If `audit_mode == "hybrid"`: Write proposed test files to `{run_dir}/proposed-tests/test_api_{endpoint}.{ext}`.
   If `audit_mode == "readonly"`: Document what tests should exist in the report.
   Do NOT write into the project test directory.
   Use test client (httpx/supertest/etc.), NOT live HTTP calls.

4. Contract check: compare API response shapes with frontend consumption.
   Read frontend API client code, verify it expects what API actually returns.

Output: `.bishx-test/{YYYY-MM-DD_HH-MM}/backend-api-report.md`

```markdown
# Backend API Test Report

## Endpoints Tested
| Method | Path | Tests | Pass | Fail |

## Contract Mismatches
[API returns X but frontend expects Y]

## Bugs Found
[structured bug entries]
```

---

### Test Type: Security

**Agent:** Opus, read-only + bash for verification commands

```
Task(
  subagent_type="oh-my-claudecode:security-reviewer",
  model="opus",
  prompt=<profile + discovery + instructions below>
)
```

**Instructions:**

You are performing a security audit of "{profile.project}".

Stack: {stack.lang} / {stack.framework}
Source: {stack.source_dir}

Check OWASP Top 10 + common vulnerabilities:

1. **Injection (SQLi, Command, Template)**
   - Search for raw SQL queries, string concatenation in queries
   - Search for dangerous functions (eval, exec, system, shell execution)
   - Check ORM usage — parameterized or raw?

2. **XSS (Cross-Site Scripting)**
   - Check if user input is rendered without escaping
   - Check API responses — do they include unsanitized user data?
   - Check Content-Type headers on responses

3. **Broken Authentication / Authorization**
   - Are there protected endpoints? How is auth implemented?
   - Can endpoints be accessed without auth?
   - JWT/session handling — expiration, rotation, storage

4. **File Upload Vulnerabilities**
   - File type validation (extension only? or magic bytes?)
   - File size limits
   - Path traversal in filenames
   - Formula injection (Excel/CSV)
   - Zip bomb / decompression bomb
   - Where are uploaded files stored? Accessible publicly?

5. **Security Misconfiguration**
   - CORS policy — permissive origins is a finding
   - Debug mode in production configs
   - Default credentials in configs/docker
   - Sensitive data in error responses (tracebacks, paths, versions)
   - Missing security headers (CSP, X-Frame-Options, HSTS)

6. **Sensitive Data Exposure**
   - Secrets in code (API keys, passwords, tokens) — grep for patterns
   - Secrets in git history
   - Logging sensitive data (passwords, tokens, PII)
   - Dotenv files in public directories

7. **Dependency Vulnerabilities**
   - Check for known CVEs: `pip audit` / `npm audit` / `cargo audit`
   - Outdated packages with known issues

Do NOT fix anything. Report with severity and exact location.

Output: `.bishx-test/{YYYY-MM-DD_HH-MM}/security-report.md`

```markdown
# Security Audit Report

## Summary
- Critical: N, High: N, Medium: N, Low: N, Info: N

## Findings
[structured entries with OWASP category, severity, location, description, remediation suggestion]
```

---

### Test Type: Data Integrity

**Agent:** Opus, full access

```
Task(
  subagent_type="oh-my-claudecode:executor-high",
  model="opus",
  prompt=<profile + discovery + instructions below>
)
```

**Instructions:**

You are verifying data integrity of "{profile.project}".

Goal: Ensure data is consistent across all layers — input, storage, API, UI.

Workflow:
1. **Identify data pipelines:**
   Read source code to map: where does data enter? How is it transformed? Where is it stored? How is it served?

2. **Input to Storage consistency:**
   - Import sample data (if test data exists in project)
   - Query DB directly — row count matches input?
   - All fields mapped correctly? No data loss in transformation?
   - Character encoding preserved? (Unicode, special chars)

3. **Storage to API consistency:**
   - Call API endpoints that serve stored data
   - Compare: API response totals = DB totals?
   - Aggregations correct? (sums, counts, groupings)
   - Filters don't lose records? (sum of filtered subsets = total)

4. **Duplicate handling:**
   - Import same data twice — duplicated or deduplicated?
   - Is this the intended behavior? Document it.

5. **Edge cases:**
   - Empty dataset — does the pipeline handle zero records?
   - Single record — boundary condition
   - Maximum expected volume — does anything overflow or truncate?
   - Null/missing fields — how are they handled at each layer?

6. **Referential integrity:**
   - Foreign keys respected?
   - Orphaned records possible?
   - Cascade behavior on deletes (if applicable)

If `audit_mode == "hybrid"`: Write proposed verification tests to `{run_dir}/proposed-tests/test_data_{pipeline}.{ext}`.
If `audit_mode == "readonly"`: Document inconsistencies in the report only.
Do NOT write into the project test directory.

Output: `.bishx-test/{YYYY-MM-DD_HH-MM}/data-integrity-report.md`

---

### Test Type: Performance

**Agent:** Opus, full access

```
Task(
  subagent_type="oh-my-claudecode:executor-high",
  model="opus",
  prompt=<profile + discovery + instructions below>
)
```

**Instructions:**

You are performance-testing "{profile.project}".

API URL: {profile.services.api_url}
Stack: {stack.lang} / {stack.framework}

Workflow:
1. **Baseline response times:**
   For each API endpoint:
   - Measure response time with minimal data
   - Measure response time with typical data volume
   - Measure with large data volume (generate or multiply test data)
   - Threshold: API response > 500ms = P3, > 2s = P2, > 5s = P1

2. **Database query analysis:**
   - Enable query logging if possible
   - Identify N+1 query patterns (multiple queries where one JOIN would suffice)
   - Check for missing indexes on filtered/sorted columns
   - Large table scans on big datasets

3. **Payload size:**
   - Measure API response size in bytes
   - Are unnecessary fields being sent?
   - Pagination implemented for large collections?

4. **Memory / resource usage:**
   - Import large file — does memory spike? Does it stream or load all at once?
   - Concurrent requests — does the server handle 10 simultaneous requests?

5. **Frontend performance** (if web_url available and Playwright MCP present):
   - Page load time (browser_navigate, then measure)
   - Time to interactive
   - Large data rendering (does table/chart freeze with 1000+ rows?)

If `audit_mode == "hybrid"`: Write proposed benchmark tests to `{run_dir}/proposed-tests/test_perf_{endpoint}.{ext}`.
If `audit_mode == "readonly"`: Document performance findings in the report only.
Do NOT write into the project test directory.

Output: `.bishx-test/{YYYY-MM-DD_HH-MM}/performance-report.md`

---

### Test Type: E2E Acceptance

**PREREQUISITE:** Services must be running. Health check must pass.

**Agent:** Opus, full access + MCP

```
Task(
  subagent_type="oh-my-claudecode:executor-high",
  model="opus",
  prompt=<profile + discovery + all prior reports + instructions below>
)
```

**Instructions:**

You are performing E2E acceptance testing of "{profile.project}".

Web URL: {profile.services.web_url}
API URL: {profile.services.api_url}

MANDATORY: Use MCP Playwright for ALL web testing:
- `browser_navigate(url)` — open pages
- `browser_snapshot()` — read page state (accessibility tree)
- `browser_click(element, ref)` — interact with elements
- `browser_type(element, ref, text)` — fill inputs
- `browser_take_screenshot()` — capture visual state
- `browser_select_option(element, ref, values)` — dropdowns
- `browser_press_key(key)` — keyboard actions
- `browser_wait_for_navigation()` — wait for transitions

Web testing is NOT considered done without Playwright MCP.

Workflow:
1. **Smoke test:**
   - Navigate to web_url
   - Page loads without errors
   - Key elements visible (browser_snapshot)
   - Screenshot baseline

2. **Discover pages and flows:**
   - Read frontend source to identify all routes/pages
   - Map user flows: what can a user DO in this app?
   - Navigate to each page — renders without errors?

3. **Test each user flow:**
   For each flow:
   a. Execute the flow step by step via Playwright
   b. Verify each step produces expected result
   c. Screenshot before and after key actions
   d. Check API-to-UI consistency (data shown matches API response)

4. **Input validation:**
   - Submit forms with empty fields
   - Submit with invalid data
   - Upload wrong file types (if upload exists)
   - Special characters in text inputs

5. **Edge cases:**
   - Empty state (no data) — graceful empty message or broken layout?
   - Rapid repeated actions (double-click submit, spam refresh)
   - Browser back/forward navigation
   - Direct URL access to deep pages

6. **Visual checks:**
   - Layout breaks (overlapping elements, scrollbar issues)
   - Responsive behavior (if applicable)
   - Loading states (spinners, skeletons vs blank screen)
   - Error states (network failure, 500 response)

7. **Context from prior test phases:**
   Read reports from other phases. If backend tests found bugs:
   - Verify the bug is visible in UI too
   - Check if UI handles backend errors gracefully

For each issue: screenshot + steps + expected vs actual + severity.

Output: `.bishx-test/{YYYY-MM-DD_HH-MM}/e2e-report.md`

---

### Test Type: Accessibility

**PREREQUISITE:** Services must be running. Health check must pass.

**Agent:** Opus, full access + MCP

```
Task(
  subagent_type="oh-my-claudecode:executor-high",
  model="opus",
  prompt=<profile + discovery + instructions below>
)
```

**Instructions:**

You are performing accessibility (a11y) testing of "{profile.project}".

Web URL: {profile.services.web_url}

MANDATORY: Use MCP Playwright for all checks:
- `browser_navigate(url)` — open pages
- `browser_snapshot()` — returns the accessibility tree (primary tool for a11y)
- `browser_click(element, ref)` — interact with elements
- `browser_press_key(key)` — keyboard navigation (Tab, Enter, Escape, Arrow keys)
- `browser_take_screenshot()` — capture visual state

Workflow:
1. **Accessibility tree audit:**
   For each page/route:
   - `browser_navigate` to the page
   - `browser_snapshot` to get the accessibility tree
   - Check every interactive element has:
     - Accessible name (label, aria-label, aria-labelledby)
     - Correct role (button, link, textbox, combobox, etc.)
     - State info where needed (aria-expanded, aria-selected, aria-checked)
   - Flag: unnamed buttons, images without alt text, inputs without labels, generic divs used as buttons

2. **Keyboard navigation:**
   - Tab through the entire page: can you reach every interactive element?
   - Is focus order logical? (top-to-bottom, left-to-right)
   - Is focus visible? (focus ring or highlight on focused element)
   - Can you activate buttons/links with Enter/Space?
   - Can you close modals/dropdowns with Escape?
   - Are there keyboard traps? (focus stuck in an element, can't Tab out)

3. **Semantic HTML:**
   - Read frontend source for:
     - Heading hierarchy (h1 > h2 > h3, no skipped levels)
     - Landmark regions (header, nav, main, footer, or ARIA equivalents)
     - Lists used for list content (ul/ol, not divs)
     - Tables have proper headers (th, scope, caption)
     - Forms have fieldset/legend where appropriate

4. **Color and contrast:**
   - Read CSS/Tailwind classes for text colors vs backgrounds
   - Flag: light gray text on white, low-contrast combinations
   - WCAG AA minimum: 4.5:1 for normal text, 3:1 for large text
   - Check that information is not conveyed by color alone (e.g., red=error needs icon or text too)

5. **Dynamic content:**
   - After user actions (button click, form submit, data load):
     - Is the result announced? (aria-live regions, role=alert, role=status)
     - Loading states: is there an aria-busy or sr-only loading text?
     - Error messages: are they associated with inputs (aria-describedby)?
     - Toasts/notifications: do they have role=alert?

6. **Common patterns:**
   - Modals: focus trapped inside, Escape closes, focus returns to trigger
   - Dropdowns: arrow key navigation, Escape closes
   - Tabs: arrow keys switch tabs, Tab moves to content
   - Data tables: sortable columns announced, pagination navigable

For each issue:
- WCAG criterion violated (e.g., "1.1.1 Non-text Content", "2.1.1 Keyboard")
- Severity: P2 if blocks access entirely, P3 if inconvenient, P4 if minor
- Element location (page, component, selector)
- Screenshot if visual issue

Output: `.bishx-test/{YYYY-MM-DD_HH-MM}/accessibility-report.md`

---

### Test Type: UX/UI Visual

**PREREQUISITE:** Services must be running. Health check must pass.

**Agent:** Opus, full access + MCP

```
Task(
  subagent_type="oh-my-claudecode:executor-high",
  model="opus",
  prompt=<profile + discovery + instructions below>
)
```

**Instructions:**

You are a **senior UX/UI design reviewer** performing an aesthetic and usability audit of "{profile.project}".

Your primary mission is DESIGN QUALITY EVALUATION — not just finding broken pixels, but judging whether the product looks and feels good to use. Think like a designer from a top product studio reviewing a client's app.

Web URL: {profile.services.web_url}

MANDATORY: Use MCP Playwright for ALL visual checks:
- `browser_navigate(url)` — open pages
- `browser_snapshot()` — read accessibility tree (structure, labels, roles)
- `browser_take_screenshot()` — capture visual state (PRIMARY tool — screenshot EVERY page)
- `browser_click(element, ref)` — interact with elements
- `browser_press_key(key)` — keyboard actions
- `browser_resize(width, height)` — test different viewports

Also read frontend source code (CSS, Tailwind config, component files) to understand design tokens, theme setup, and design system choices.

---

### Part A: Technical Visual Checks

1. **Viewport matrix:**
   For each page/route, test on:
   - Mobile: 375×812 (iPhone)
   - Tablet: 768×1024 (iPad)
   - Desktop: 1440×900
   - Wide: 1920×1080
   Screenshot each combination. Flag: overlapping elements, horizontal scroll, cut-off content, invisible buttons.

2. **State completeness:**
   Check every page for all possible states:
   - **Empty** — no data: meaningful placeholder or broken layout?
   - **Loading** — skeleton/spinner or content flash/layout shift?
   - **Error** — styled page with recovery path or raw error?
   - **Partial** — some data loaded, some failed: graceful degradation?
   Screenshot each state.

3. **Overflow and truncation:**
   - Very long text, numbers, file names, emails — ellipsis or layout break?
   - Dynamic content overflowing containers?
   - Tables with many columns — horizontal scroll or squished?

4. **Dark/light theme** (if applicable):
   - All elements visible in both modes?
   - No hardcoded colors bypassing the theme?
   - Images/icons adapt?

---

### Part B: Deep Aesthetic Evaluation (CORE)

This is the main deliverable of UX/UI Visual testing. Evaluate each page through multiple design lenses. Be brutally honest but constructive — every criticism must come with a specific recommendation.

#### B1. First Impression (3-second test)

For each page, open it fresh and answer within 3 seconds of looking at the screenshot:
- What is this page about? (If unclear → hierarchy problem)
- What should I do here? (If unclear → CTA problem)
- Do I want to stay or leave? (If leave → aesthetic/trust problem)
- Does it feel professional? (If not → polish problem)

Rate the gut feeling: positive / neutral / negative. Negative = mandatory finding.

#### B2. Visual Composition & Balance

- **Layout grid** — is there an underlying grid structure? Or elements placed seemingly at random?
- **Visual weight distribution** — is the page balanced (left-right, top-bottom)? Or top-heavy, lopsided?
- **Alignment** — are elements aligned to a consistent grid? Misaligned elements by 2-3px create subconscious unease
- **Grouping (Gestalt proximity)** — are related items visually grouped? Is there enough separation between unrelated groups?
- **Symmetry vs intentional asymmetry** — if asymmetric, does it feel intentional or accidental?
- **Visual flow** — does the eye naturally follow a logical path (Z-pattern or F-pattern for content pages)?
- **Density zones** — are there areas that are too dense vs too empty on the same page?

#### B3. Color & Palette

Read the CSS/Tailwind theme config and evaluate:
- **Palette size** — how many distinct colors? (Ideal: 1 primary, 1-2 accents, 2-3 neutrals, semantic colors for status)
- **60-30-10 rule** — ~60% dominant (background), ~30% secondary (cards, surfaces), ~10% accent (CTAs, highlights)?
- **Color harmony** — complementary, analogous, triadic? Or random?
- **Semantic consistency** — red always=danger, green always=success, yellow always=warning? Or mixed meanings?
- **Saturation balance** — are colors overly saturated (eye strain) or too muted (feels lifeless)?
- **Background layers** — clear visual depth? (page bg → card bg → element bg) Or flat/confusing?
- **Accent usage** — is the accent color used sparingly for emphasis, or overused (losing impact)?
- **Dark surfaces** — if dark theme: are there enough contrast levels between surfaces, or is it "all one shade of gray"?

#### B4. Typography

Read font imports, Tailwind typography config, CSS:
- **Font choice** — is it appropriate for the product type? (SaaS/dashboard → clean sans-serif; creative → more expressive)
- **Font pairing** — if multiple fonts, do they complement each other? (Same font, different weights is safer than mismatched fonts)
- **Type scale** — is there a consistent scale? (e.g., 12/14/16/20/24/32) Or random sizes everywhere?
- **Hierarchy depth** — at least 3-4 levels clearly distinguishable: page title > section heading > body > caption/secondary
- **Line height** — body text at 1.5-1.7× is comfortable. Headings at 1.1-1.3×. Check actual values.
- **Line length** — 50-75 characters per line is optimal for readability. Wider = hard to track lines. Check content areas.
- **Font weight usage** — too many weights on one page (thin, regular, medium, semibold, bold) = visual noise. Limit to 2-3 per page.
- **Text contrast** — sufficient contrast against background? Secondary text not too faint?
- **Number formatting** — tabular figures for tables/data? Monospace for code? Proper thousand separators?

#### B5. Iconography & Visual Assets

- **Icon style consistency** — all outline, all filled, or all duotone? Mixed styles = amateur look
- **Icon size consistency** — same-purpose icons same size? Navigation icons same weight as content icons?
- **Icon metaphors** — are icons recognizable? Does the "export" icon look like export? Or ambiguous abstract shapes?
- **Icon-to-text alignment** — vertically centered with adjacent text? Or shifted up/down?
- **Illustrations/images** — consistent style? Professional quality? Or mix of stock photos, screenshots, and clipart?
- **Favicons and branding** — present and crisp? Or missing/default/pixelated?
- **Decorative elements** — purposeful and subtle, or distracting?

#### B6. Component Craft

Evaluate the quality of individual UI components:
- **Buttons** — do they look "clickable"? Visual distinction between primary/secondary/tertiary/destructive? Appropriate padding? Consistent border-radius?
- **Inputs & forms** — clear affordance (looks like you can type)? Focus state obvious? Error state informative? Labels properly positioned?
- **Cards** — consistent padding, shadow depth, border-radius? Content well-structured inside?
- **Tables** — header row distinct? Row separation (zebra/lines/spacing)? Sorting indicators? Responsive behavior?
- **Modals/dialogs** — appropriate size? Overlay dimming? Close affordance? Not covering critical info?
- **Navigation** — active state clear? Current location obvious? Breadcrumbs where needed?
- **Tooltips/popovers** — styled consistently? Positioned well? Arrow pointing correctly?
- **Badges/tags/chips** — readable at small size? Color-coded meaningfully? Not overused?
- **Notifications/toasts** — positioned well? Visually distinct by type (success/error/info)? Auto-dismiss or manual?

Rate component library maturity: custom/polished → using UI kit well → using UI kit poorly → unstyled/default HTML.

#### B7. Motion & Micro-interactions

Navigate through the app, interact with elements, and evaluate:
- **Page transitions** — smooth or jarring instant switch?
- **Hover effects** — subtle and helpful, or absent/excessive?
- **Loading transitions** — content fades in gracefully, or pops in with layout shift?
- **Button feedback** — click produces visual response (ripple, scale, color change)?
- **Form interactions** — focus transition smooth? Validation appears gracefully?
- **Scroll behavior** — smooth scrolling? Sticky headers? Scroll-triggered animations (if any) — tasteful or distracting?
- **Open/close animations** — modals, dropdowns, sidebars: animated or instant?
- **Overall motion feel** — cohesive timing (all ~200-300ms)? Or inconsistent (some instant, some slow)?
- If no animations at all: note as "feels static/dead" — even subtle transitions (150ms fade) add perceived quality.

#### B8. Information Architecture & Visual Load

- **Page purpose clarity** — can you state what each page does in one sentence?
- **Information density** — count visible elements (buttons, links, data points, labels) per screen. >50 = likely overloaded.
- **Progressive disclosure** — is complexity hidden behind expand/collapse, tabs, "show more"? Or everything dumped on screen at once?
- **Whitespace** — measure the breathing room. Is there consistent padding between sections? Or elements crammed together?
- **Visual noise audit** — count decorative-only elements (borders, separators, background patterns, shadows) that don't serve a functional purpose. Each adds cognitive load.
- **Competing actions** — how many buttons/links are visible at once? If >5 actions visible, user may feel paralyzed.
- **Data presentation** — large datasets: paginated, virtualized, or ALL rendered? Charts: clear or cluttered? Numbers: formatted or raw?
- **Content hierarchy** — primary content occupies >60% of screen? Or sidebar/header/footer consume too much?

#### B9. Emotional Tone & Brand Fit

- **What emotion does the design evoke?** (trustworthy, playful, serious, cold, warm, corporate, startup-casual)
- **Is it appropriate for the domain?** (security tool should feel reliable; creative tool should feel inspiring; admin panel should feel efficient)
- **Consistency of tone** — does every page feel like the same product? Or some pages feel like different apps glued together?
- **Copywriting quality** (if visible) — button labels clear? Error messages helpful or cryptic? Headings descriptive?
- **"Crafted" vs "thrown together"** — does it feel like someone cared about every detail? Or are there signs of "just make it work"?

#### B10. Competitive Context

Based on the detected stack and project type:
- **What category is this product?** (admin panel, dashboard, SaaS, e-commerce, internal tool, etc.)
- **What do best-in-class products in this category look like?** (reference general patterns, not specific competitors)
- **How does this compare?** — significantly below average / below average / average / above average / excellent
- **Biggest gap** — what ONE change would most improve the perceived quality?

---

### Part B Summary: Page Scorecard

Rate each page on each dimension (1-5 scale):

| Dimension | 1 (Poor) | 3 (Acceptable) | 5 (Excellent) |
|-----------|----------|-----------------|----------------|
| First Impression | Confusing, want to leave | Functional, unremarkable | Clear, inviting, professional |
| Composition | No grid, random placement | Basic structure, some issues | Balanced, intentional layout |
| Color | Clashing or monotone | Functional, some inconsistency | Harmonious, purposeful |
| Typography | Hard to read, random sizes | Readable, basic hierarchy | Beautiful type, clear scale |
| Iconography | Mixed styles, unclear meaning | Consistent but generic | Cohesive, clear, polished |
| Components | Default/unstyled HTML feel | UI kit basics, some rough edges | Crafted, polished, delightful |
| Motion | Static/dead or janky | Some transitions, inconsistent | Smooth, cohesive, purposeful |
| Visual Load | Overwhelming or barren | Manageable, some clutter | Clean, focused, breathable |
| Emotional Tone | Off-putting or inappropriate | Neutral, generic | On-brand, confident, trustworthy |

**Overall aesthetic score** = average of all dimensions, rounded.

Scoring rules:
- **1-2 overall** → P2 bug: "Design quality critically below standard — detailed redesign recommendations attached"
- **3 on any dimension** → P3 bug per dimension with specific improvement steps
- **4-5 overall** → no bugs, note positives and minor polish suggestions as P4

**CRITICAL: Be specific and actionable.** Every score below 4 MUST include:
- What exactly is wrong (with screenshot reference)
- Why it matters (impact on user perception/usability)
- How to fix it (concrete CSS/component/layout change — not vague "make it better")

Example of GOOD feedback:
> "The events table (score 2: Visual Load) shows 12 columns with no horizontal priority. The user's eye has nowhere to land. Recommendation: hide columns 7-12 behind a 'More' expand, increase row height from 32px to 44px, add subtle zebra striping with bg-muted/50, and make the first column (timestamp) sticky on horizontal scroll."

Example of BAD feedback:
> "The table looks cluttered. Consider improving the layout."

---

### Part C: Technical Polish Checks

9. **Interactive states:**
   For buttons, links, inputs — check:
   - Hover state (cursor changes, visual feedback)
   - Active/pressed state
   - Focus state (visible ring for keyboard users)
   - Disabled state (visually distinct, not clickable)

10. **Design token consistency:**
    Read CSS/Tailwind config. Check:
    - Color palette defined in config vs hardcoded hex values in components?
    - Spacing scale consistent (4px/8px grid)?
    - Border-radius values from a limited set or random?
    - Shadow values consistent or ad-hoc?
    - If using a UI library (shadcn, Radix, MUI): are customizations consistent or scattered overrides?

For each issue:
- Screenshot (mandatory for every visual finding)
- Viewport where it occurs
- Severity: P2 if design critically below standard, P3 if noticeably subpar, P4 if minor polish
- Element location (page, component)
- Specific recommendation (not vague)

Output: `.bishx-test/{YYYY-MM-DD_HH-MM}/ux-ui-visual-report.md`

```markdown
# UX/UI Visual Report

## Executive Summary
- Overall aesthetic score: {N}/5
- Strongest areas: {list}
- Weakest areas: {list}
- Single biggest improvement opportunity: {description}

## Page Scorecards
### {Page Name}
| Dimension | Score | Key Finding |
|-----------|-------|-------------|
| First Impression | N | ... |
| Composition | N | ... |
| Color | N | ... |
| Typography | N | ... |
| Iconography | N | ... |
| Components | N | ... |
| Motion | N | ... |
| Visual Load | N | ... |
| Emotional Tone | N | ... |
| **Overall** | **N** | ... |

**Screenshots:** [list]
**Top issues:** [numbered list with specific recommendations]

[Repeat for each page]

## Cross-Page Analysis

### Design System Health
| Token | Defined | Consistent | Issues |
(colors, typography, spacing, radii, shadows)

### Viewport Matrix
| Page | Mobile | Tablet | Desktop | Wide | Issues |

### State Completeness
| Page | Empty | Loading | Error | Partial |

### Component Quality
| Component | Craft Level | Issues | Recommendation |

### Motion Audit
| Interaction | Has Animation | Duration | Easing | Quality |

## Prioritized Recommendations
1. [P2] {Critical design issue — with before/after description}
2. [P3] {Notable issue — with specific fix}
3. [P3] {Notable issue — with specific fix}
...

## Positive Highlights
[What the design does WELL — important for balanced feedback]

## Bugs Found
[structured bug entries — only for scores ≤3]
```

---

### Test Type: Web Bug Hunting

**PREREQUISITE:** Services must be running. Health check must pass.

**Agent:** Opus, full access + MCP

```
Task(
  subagent_type="oh-my-claudecode:executor-high",
  model="opus",
  prompt=<profile + discovery + all prior reports + instructions below>
)
```

**Instructions:**

You are performing exploratory bug hunting on "{profile.project}" web interface.

Web URL: {profile.services.web_url}
API URL: {profile.services.api_url}

MANDATORY: Use MCP Playwright for ALL web testing.

This is NOT scripted flow testing (that's E2E Acceptance). This is **exploratory testing** — you are a tester trying to BREAK the application through creative, unexpected interactions.

Workflow:
1. **Console errors audit:**
   Navigate to every page/route. After each navigation:
   - Check browser console for JS errors, warnings, unhandled promise rejections
   - Record: page URL, error message, stack trace if available
   - Any console error = at least P3

2. **Broken links and navigation:**
   For every link and button on every page:
   - Click it — does it go where expected?
   - Any 404, blank page, or wrong destination = bug
   - Check: dead links to removed pages/features?

3. **State management bugs:**
   - Navigate Page A → Page B → back to Page A. Is state preserved correctly?
   - Open a resource, navigate away, come back — stale data?
   - Perform action (create/edit/delete), navigate elsewhere, return — reflected?
   - Open same page in "two tabs" (navigate, go back) — any conflict?

4. **URL manipulation:**
   - Change URL parameters manually (IDs, filters, page numbers)
   - Use invalid IDs in URLs — graceful 404 or crash?
   - Use SQL injection / XSS payloads in URL parameters — reflected in page?
   - Remove required query params — how does page handle it?
   - Navigate directly to deep pages without prior navigation

5. **Rapid interactions:**
   - Double-click submit buttons — duplicate submissions?
   - Click a link during page load — correct behavior?
   - Rapidly switch between tabs/sections
   - Submit form while previous request still pending

6. **Form stress testing:**
   - Paste extremely long text (10,000 chars) into fields
   - Paste rich text / HTML into plain text fields
   - Use emoji, Unicode, RTL text, zero-width chars
   - Browser autofill — does it work correctly?
   - Tab through form fields — correct order?
   - Submit with browser dev tools (bypass frontend validation)

7. **Network edge cases:**
   If API endpoints are known:
   - What does UI show when API returns 500?
   - What does UI show when API returns empty data vs error?
   - Does UI handle slow responses (show loading)?
   - Does UI retry or show timeout message?

8. **Context from prior test phases:**
   Read reports from other phases. If backend tests found bugs:
   - Try to trigger those bugs from the UI
   - Check if UI masks or surfaces the backend error
   If security tests found XSS vectors:
   - Try them in UI input fields
   If data integrity tests found inconsistencies:
   - Verify in the UI display

For each bug:
- Steps to reproduce (exact clicks, text entered, URLs)
- Screenshot
- Console errors if any
- Expected vs actual behavior
- Severity: P1 if data loss/corruption, P2 if feature broken, P3 if edge case, P4 if cosmetic

Output: `.bishx-test/{YYYY-MM-DD_HH-MM}/web-bug-hunting-report.md`

```markdown
# Web Bug Hunting Report

## Console Errors
| Page | Error | Severity | Reproducible |

## Broken Links
| Page | Link Text | Expected Destination | Actual Result |

## State Bugs
| Scenario | Expected | Actual | Severity |

## URL Manipulation
| URL Pattern | Input | Expected | Actual |

## Rapid Interaction Bugs
| Action | Expected | Actual | Severity |

## Form Edge Cases
| Form | Input Type | Expected | Actual |

## Network Resilience
| Scenario | Expected UI | Actual UI | Severity |

## Bugs Found
[structured bug entries]
```

---

### Test Type: Error Handling

**Agent:** Opus, full access

```
Task(
  subagent_type="oh-my-claudecode:executor-high",
  model="opus",
  prompt=<profile + discovery + instructions below>
)
```

**Instructions:**

You are testing error handling and resilience of "{profile.project}".

Stack: {stack.lang} / {stack.framework}
Source: {stack.source_dir}
Test runner: {stack.test_runner}

Goal: What happens when things go wrong? Find silent failures, crashes, data loss, and unhelpful error messages.

Workflow:
1. **Invalid input resilience:**
   For each endpoint/service that accepts input:
   - Send completely wrong types (string where number expected, object where array expected)
   - Send malformed data (broken JSON, truncated XML, corrupt binary)
   - Send extremely large input (10MB string, 100k array elements)
   - Send empty/null/undefined for every field
   - Expected: graceful error response with clear message, not crash or silent failure

2. **Dependency failures:**
   Write tests that simulate:
   - Database unavailable (mock connection to raise error)
   - External API timeout or 500 (if external calls exist)
   - File system errors (read-only, disk full, missing directory)
   - Expected: app returns meaningful error, not traceback or hang

3. **Configuration errors:**
   - Read all env vars / config values used by the app
   - Test: what happens if each required env var is missing?
   - Test: what happens if DB connection string is wrong?
   - Test: what happens if a port is already in use?
   - Expected: clear startup error with guidance, not cryptic traceback

4. **Partial failure scenarios:**
   - Import file with some valid and some invalid rows — does it import valid ones and report errors?
   - Batch operation where one item fails — does it roll back all or continue?
   - Concurrent modifications to same resource — graceful conflict or data corruption?

5. **Error response quality:**
   For each error the app can produce:
   - Is the HTTP status code correct? (400 for client error, 500 for server, not 200 with error body)
   - Is the error message helpful to the user? (not "Internal Server Error" or raw exception)
   - Does the response leak internals? (stack traces, file paths, SQL queries, versions)
   - Is the error machine-readable? (consistent format: {error: ..., detail: ...})

6. **Recovery:**
   - After an error, does the app continue working normally?
   - Does a failed request leave corrupted state in DB?
   - Does a failed import leave partial data?
   - After a crash and restart, does the app recover cleanly?

7. **Silent failure detection:**
   - Search source code for:
     - Bare except/catch blocks with no logging or re-raise
     - Functions that return null/None on error instead of throwing
     - Empty error handlers (catch(e) {})
     - TODO/FIXME/HACK comments near error handling
   - For each found: write a test that triggers that code path and verify behavior

If `audit_mode == "hybrid"`: Write proposed resilience tests to `{run_dir}/proposed-tests/test_error_{service}.{ext}`.
If `audit_mode == "readonly"`: Document error handling gaps in the report only.
Do NOT write into the project test directory. Use mocking/patching for dependency failures in proposed tests.

Output: `.bishx-test/{YYYY-MM-DD_HH-MM}/error-handling-report.md`

```markdown
# Error Handling Report

## Input Resilience
| Endpoint/Service | Input Type | Expected | Actual | Status |

## Dependency Failures
| Dependency | Failure Mode | Expected | Actual | Status |

## Configuration Errors
| Config Key | Missing/Invalid | Expected | Actual | Status |

## Silent Failures Found
| Location | Pattern | Risk | Description |

## Error Response Quality
| Endpoint | Status Code OK | Message Helpful | No Leaks | Format Consistent |

## Bugs Found
[structured bug entries]
```

---

## Phase 4: REPORT

**Actor:** Lead (main thread)

### 4.1 Aggregate Findings

Read all `*-report.md` files from `.bishx-test/{YYYY-MM-DD_HH-MM}/`.
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

### Context
{How this was discovered. Coverage gap? Edge case? Random exploration?
Any additional context that helps a developer understand the full picture.}
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
{Brief description of what the test file covers — which functions, endpoints, or scenarios.}

### Test cases
1. {test_name} — {what it verifies}
2. {test_name} — {what it verifies}
3. ...

### How to use
1. Copy: `cp {run_dir}/proposed-tests/{test_filename} {project_test_dir}/`
2. Review imports and fixtures — adapt to project context if needed
3. Run: `{test_cmd} {project_test_dir}/{test_filename}`

### Dependencies
- Requires: {fixtures, test data, running services, etc.}
- Framework: {pytest/vitest/jest/etc.}
```

### Severity Guide

| Level | Label | Criteria |
|-------|-------|----------|
| P1 | Blocker | Crash, data loss, security vulnerability, regression in existing tests |
| P2 | Major | Core feature broken, wrong data shown, missing validation |
| P3 | Minor | Edge case failure, non-critical UX issue, missing error message |
| P4 | Cosmetic | Layout glitch, typo, inconsistent formatting |

### 4.4 Summary to User

After bd tasks are created, present a summary:

```markdown
## Test Run Complete

**Project:** {name}
**Date:** {date}
**Types:** {selected test types}
**Duration:** {total time}

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
2. [P1] {title} — {one-line description}
3. [P2] {title} — {one-line description}
...

### Coverage Impact
| Module | Before | After | Delta |

### Proposed Tests (hybrid mode only)
| File | Tests | Target Module | Related Bugs | bd Task |
- Location: `.bishx-test/{run}/proposed-tests/`
- To use: `cp .bishx-test/{run}/proposed-tests/* {project_test_dir}/`
- Each file has a bd task with full description — search `[Proposed]` in bd
```

---

## Rules

1. **Discovery first** — never test blindly. Always build profile + discovery report.
2. **Profile-driven** — all commands, paths, URLs come from profile.json. No hardcoding.
3. **Playwright MCP is MANDATORY** for web E2E. No curl/fetch substitutes for UI testing.
4. **Do NOT fix bugs** — only find and report. The output is a bd task, not a code change.
5. **Proposed tests go to `{run_dir}/proposed-tests/` ONLY** — never write into the project tree. No test-fitting, no hardcoded magic values.
6. **Screenshot every visual anomaly** — via browser_take_screenshot.
7. **Proposed test files are suggestions** — user decides whether to copy them into the project.
8. **Exhaustive bug descriptions** — developer must be able to fix without asking questions.
9. **Deduplicate** — same root cause found by multiple phases = one bd task, mention all evidence.
10. **All agents are Opus** — no cost-cutting on test quality.
11. **Adapt, don't fail** — if a test type is unavailable, skip it gracefully and inform the user.
12. **Reuse bd epics** — same test type across runs shares one epic, each run is a feature.
13. **Respect audit mode** — "readonly" means NO test files at all, only reports. "hybrid" means proposed tests in run dir.
