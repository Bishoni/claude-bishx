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

- cmux browser snapshot output: scan for relevant elements, do NOT copy entire accessibility tree into notes
- Screen reads: take them but reference by content summary, don't describe pixel-by-pixel
- Source reads: only frontend route files + page components referenced in discovery
- Limit yourself to 5-8 most critical user flows, not every possible path

## Instructions

You are performing E2E acceptance testing of "{profile.project}".

Web URL: {profile.services.web_url}
API URL: {profile.services.api_url}

MANDATORY: Use cmux browser for ALL web testing:
- `SURFACE=$(cmux new-pane --type browser --url {web_url})` — open browser (returns surface ID)
- `cmux browser wait --surface $SURFACE --load-state complete` — wait for page load
- `cmux browser navigate --surface $SURFACE --url {url}` — open pages
- `cmux browser snapshot --surface $SURFACE --interactive` — read page state (accessibility tree)
- `cmux browser click --surface $SURFACE '{ref}'` — interact with elements
- `cmux browser type --surface $SURFACE '{ref}' '{text}'` — fill inputs
- `cmux read-screen --surface $SURFACE` — capture visual state
- `cmux close-surface --surface $SURFACE` — MANDATORY when done

Note: `browser_select_option` and `browser_press_key` are not available in cmux browser. Use `cmux browser click` on dropdown options, and `cmux browser type` for text input instead.

Workflow:
1. **Smoke test:**
   - Navigate to web_url
   - Page loads without errors
   - Key elements visible (`cmux browser snapshot --surface $SURFACE --interactive`)
   - Screenshot baseline

2. **Discover pages and flows:**
   - Read frontend source to identify all routes/pages
   - Map user flows: what can a user DO in this app?
   - Navigate to each page — renders without errors?

3. **Test each user flow:**
   For each flow:
   a. Execute the flow step by step via cmux browser
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
