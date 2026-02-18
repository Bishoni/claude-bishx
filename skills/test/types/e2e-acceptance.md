# Test Type: E2E Acceptance

**PREREQUISITE:** Services must be running. Health check must pass.

## Discovery Context

Read these sections from `{run_dir}/discovery-report.md`:
- Component Map (pages, routes, user flows)
- Available Test Types

## Prior Results

Read `{run_dir}/bugs-summary.md` for findings from previous waves.
Use it to verify backend bugs are visible in UI and check graceful error handling.
Do NOT read full reports from other phases.

## Context Budget

- browser_snapshot output: scan for relevant elements, do NOT copy entire accessibility tree into notes
- Screenshots: take them but reference by filename, don't describe pixel-by-pixel
- Source reads: only frontend route files + page components referenced in discovery
- Limit yourself to 5-8 most critical user flows, not every possible path

## Instructions

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

6. **Context from prior waves:**
   Read bugs-summary.md. If backend tests found bugs:
   - Verify the bug is visible in UI too
   - Check if UI handles backend errors gracefully

For each issue: screenshot + steps + expected vs actual + severity.

## Output

File: `{run_dir}/e2e-report.md`
