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

MANDATORY: Use cmux browser for ALL web testing. Full reference: `~/.claude/skill-library/references/cmux-browser.md`.

```bash
RAW=$(cmux browser open {web_url})
SURFACE=$(echo "$RAW" | grep -o 'surface:[0-9]*' | head -1)   # open browser, save surface ID
cmux browser --surface $SURFACE wait --load-state complete     # wait for page load
cmux browser --surface $SURFACE snapshot -i                    # read page state + element refs
cmux browser --surface $SURFACE click {ref}                    # click (prefer refs from snapshot -i)
cmux browser --surface $SURFACE type {ref} '{text}'            # type into element (keystroke sim)
cmux browser --surface $SURFACE fill {ref} '{text}'            # fill input field (direct set)
cmux browser --surface $SURFACE press Enter                    # submit / confirm
cmux browser --surface $SURFACE screenshot --out /tmp/e2e.png  # capture state
cmux browser --surface $SURFACE eval '{js}'                    # execute JavaScript
cmux browser --surface $SURFACE console list                   # check console errors
cmux close-surface --surface $SURFACE                          # MANDATORY when done
```

Workflow:
1. **Smoke test:**
   - Navigate to web_url
   - Page loads without errors
   - Key elements visible (`cmux browser --surface $SURFACE snapshot -i`)
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
