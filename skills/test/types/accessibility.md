# Test Type: Accessibility

**PREREQUISITE:** Services must be running. Health check must pass.

## Discovery Context

Read these sections from `{run_dir}/discovery-report.md`:
- Component Map (pages, routes)

## Context Budget

- cmux browser snapshot: scan for a11y issues, do NOT copy entire tree into report
- Source reads: only component files with interactive elements (forms, buttons, navigation)
- Limit to main pages/routes (max 8), not every sub-component
- Grep/search: max 30 matches per query

## Instructions

You are performing accessibility (a11y) testing of "{profile.project}".

Web URL: {profile.services.web_url}

MANDATORY: Use cmux browser for all checks:
- `cmux new-pane --type browser --url {url}` → returns surface ID (store as $SURFACE)
- `cmux browser wait --surface $SURFACE --load-state complete` — wait for page load
- `cmux browser navigate --surface $SURFACE --url {url}` — navigate to pages
- `cmux browser snapshot --surface $SURFACE --interactive` — returns the accessibility tree (primary tool for a11y)
- `cmux browser click --surface $SURFACE '{ref}'` — interact with elements
- `cmux read-screen --surface $SURFACE` — capture visual state
- `cmux close-surface --surface $SURFACE` — MANDATORY when done

Note: `browser_press_key` is not directly available in cmux browser. Use `cmux browser type --surface $SURFACE '{ref}' ''` for text input, or click to trigger navigation. Keyboard navigation testing is limited.

Workflow:
1. **Accessibility tree audit:**
   For each page/route:
   - `cmux browser navigate --surface $SURFACE --url {url}` to the page
   - `cmux browser snapshot --surface $SURFACE --interactive` to get the accessibility tree
   - Check every interactive element has:
     - Accessible name (label, aria-label, aria-labelledby)
     - Correct role (button, link, textbox, combobox, etc.)
     - State info where needed (aria-expanded, aria-selected, aria-checked)
   - Flag: unnamed buttons, images without alt text, inputs without labels, generic divs used as buttons

2. **Keyboard navigation:**
   - Note: `browser_press_key` is not available in cmux browser. Test keyboard navigation by clicking elements in sequence and observing focus via snapshot.
   - Check snapshot for focus indicators and logical element order
   - Test activation: `cmux browser click --surface $SURFACE '{ref}'` and verify result
   - Can you close modals/dropdowns? Check for close button refs in snapshot
   - Are there keyboard traps? Look for modal/overlay patterns in snapshot with no close mechanism

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
   - Check that information is not conveyed by color alone

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

## Output

File: `{run_dir}/accessibility-report.md`
