# Test Type: Accessibility

**PREREQUISITE:** Services must be running. Health check must pass.

## Discovery Context

Read these sections from `{run_dir}/discovery-report.md`:
- Component Map (pages, routes)

## Context Budget

- browser_snapshot: scan for a11y issues, do NOT copy entire tree into report
- Source reads: only component files with interactive elements (forms, buttons, navigation)
- Limit to main pages/routes (max 8), not every sub-component
- Grep/search: max 30 matches per query

## Instructions

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
