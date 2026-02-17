---
name: test
description: "Deep system testing — auto-detects stack, discovers components, runs unit/integration/E2E/security/performance tests, reports bugs to bd with full reproduction steps."
---

# Bishx-Test: Deep System Testing

Autonomous testing skill. Detects project stack, discovers components, runs existing tests,
writes missing ones, performs E2E acceptance testing via Playwright MCP, security audit,
data integrity and performance checks. Produces structured bug reports in bd.

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

Read discovery report. Present available test types via AskUserQuestion:

```
AskUserQuestion(
  questions=[{
    question: "Which testing types to run?",
    header: "Test types",
    multiSelect: true,
    options: [
      // Only include options where discovery confirmed availability
      {
        label: "Backend Unit",
        description: "Services, parsers, business logic, edge cases. {N} modules, {M}% covered."
      },
      {
        label: "Backend API",
        description: "Endpoints, contracts, status codes, error responses. {N} routes found."
      },
      {
        label: "E2E Acceptance",
        description: "UI flows via Playwright MCP. Requires running services."
      },
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
        label: "Accessibility",
        description: "WCAG compliance: ARIA, contrast, keyboard navigation, screen reader support."
      },
      {
        label: "Error Handling",
        description: "Resilience: DB down, invalid config, corrupted input, network failures."
      },
      {
        label: "Full",
        description: "All available test types."
      }
    ]
  }]
)
```

Populate descriptions with real numbers from discovery (coverage %, module count, route count).
If a type is unavailable, do NOT include it in options.

---

## Phase 3: EXECUTE

### Execution Order

```
Wave 1 (parallel):   Backend Unit + Backend API + Security + Error Handling
Wave 2 (parallel):   Data Integrity + Performance
Wave 3 (parallel):   E2E Acceptance + Accessibility
```

Only run waves that contain selected test types.
If only E2E selected, skip waves 1-2, go straight to wave 3.

### Pre-flight Check (before wave 3)

If E2E is selected:
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
   c. Write test file: `{stack.test_dir}/test_deep_{module_name}.{ext}`
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

## New Tests Written
| File | Tests | Target Module | Result |

## Bugs Found
[structured bug entries — see Bug Format below]

## Coverage Delta
| Module | Before | After |
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

3. Write API test files using project's test framework.
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

Write tests using project's test framework where possible.

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

Write benchmark tests using project's test framework.
Include timing assertions where appropriate.

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

Write tests using project's test framework. Use mocking/patching for dependency failures.

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
|   +-- Task: [{severity}] {bug title}
|   |   +-- description: full bug report
|   +-- Task: [{severity}] {bug title}
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

### Where to Fix
- **File:** {file_path}:{line_number}
- **What:** {Specific guidance — what to change, add, or remove}
- **Related:** {Other files/tests affected by this fix}

### Context
{How this was discovered. Coverage gap? Edge case? Random exploration?
Any additional context that helps a developer understand the full picture.}
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

### New Test Files
- {path/to/test_deep_module.ext} — {N} tests
- ...
```

---

## Rules

1. **Discovery first** — never test blindly. Always build profile + discovery report.
2. **Profile-driven** — all commands, paths, URLs come from profile.json. No hardcoding.
3. **Playwright MCP is MANDATORY** for web E2E. No curl/fetch substitutes for UI testing.
4. **Do NOT fix bugs** — only find and report. The output is a bd task, not a code change.
5. **New tests must NOT be test-fitted** — no hardcoded magic values, test behavior not implementation.
6. **Screenshot every visual anomaly** — via browser_take_screenshot.
7. **Keep test files** — they are useful for developers when fixing bugs.
8. **Exhaustive bug descriptions** — developer must be able to fix without asking questions.
9. **Deduplicate** — same root cause found by multiple phases = one bd task, mention all evidence.
10. **All agents are Opus** — no cost-cutting on test quality.
11. **Adapt, don't fail** — if a test type is unavailable, skip it gracefully and inform the user.
12. **Reuse bd epics** — same test type across runs shares one epic, each run is a feature.
