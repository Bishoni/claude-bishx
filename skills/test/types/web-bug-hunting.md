# Test Type: Web Bug Hunting

**PREREQUISITE:** Services must be running. Health check must pass.

## Discovery Context

Read these sections from `{run_dir}/discovery-report.md`:
- Component Map (pages, routes, forms)

## Prior Results

Read `{run_dir}/bugs-summary.md` for findings from previous waves.
Try to trigger known backend/security bugs from the UI.
Do NOT read full reports from other phases.

## Context Budget

- browser_snapshot: scan for issues, do NOT copy entire accessibility tree
- Console messages: first 20 per page, then "... and N more"
- Source reads: only files relevant to bugs you're investigating
- Focus on 5-8 highest-risk pages, not exhaustive coverage of every route

## Instructions

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

7. **Network edge cases:**
   If API endpoints are known:
   - What does UI show when API returns 500?
   - What does UI show when API returns empty data vs error?
   - Does UI handle slow responses (show loading)?

8. **Context from prior waves:**
   Read bugs-summary.md:
   - Try to trigger backend bugs from the UI
   - Check if UI masks or surfaces backend errors
   - If security tests found XSS vectors — try them in UI input fields
   - If data integrity tests found inconsistencies — verify in UI display

For each bug:
- Steps to reproduce (exact clicks, text entered, URLs)
- Screenshot
- Console errors if any
- Expected vs actual behavior
- Severity: P1 if data loss/corruption, P2 if feature broken, P3 if edge case, P4 if cosmetic

## Output

File: `{run_dir}/web-bug-hunting-report.md`

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
