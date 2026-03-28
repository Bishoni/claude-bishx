# Audit Module: Performance

**Browser access:** Yes. This is a Tier B (live browser) module with EXCLUSIVE browser access.
Use cmux browser tools for navigation and resource analysis.
You have exclusive browser access — no other agent is using cmux browser while you run.
This module is the SOLE owner of Core Web Vitals measurement. No other module measures CWV.

**Note:** cmux browser does not support JS execution (`browser_evaluate` is unavailable). Core Web Vitals must be measured via alternative means: use `curl` with timing flags (`curl -w "@curl-format.txt" -o /dev/null -s {url}`), or use `cmux read-screen` for visual load assessment. JS-based metric collection (LCP, CLS, INP) is not possible — substitute with curl timing and visual observation.

### Page Budget

Full CWV measurement (LCP, CLS, INP, TTFB, FCP + resource analysis + image audit): on up to **20 representative pages** (selected by the same criteria as Discovery interactive testing, plus one page per template group from discovery.json).

Lightweight check (navigate + LCP measurement only): on ALL remaining pages.

This prevents operationally infeasible 95+ page full measurements while ensuring no slow page goes completely unnoticed.

**Prerequisites:** cmux browser (`cmux new-pane --type browser`, `cmux browser navigate`, `cmux browser snapshot`, `cmux read-screen`, `cmux browser resize`, `cmux browser click`, `cmux close-surface`)

> **Foundational Principle:** This module's checks are concrete applications of the Human-First Evaluation Principle. Performance is evaluated through the lens of: does the page load fast enough that the visitor's intent is not interrupted by waiting? Speed is not a metric — it's the preservation of human attention and momentum. Technical checks that PASS but violate the principle are still findings. See SKILL.md "FOUNDATIONAL PRINCIPLE" section.

**Toolkit Approach:** The checks below are a toolkit of common patterns, not a mandatory checklist. For each page: (1) Read the page's `purpose`, `visitor`, `key_question` from discovery.json. (2) Select which checks are RELEVANT to this page. (3) Irrelevant checks → "N/A for this page." (4) Unknown elements → apply Foundational Principle directly, tag as `[Unknown Element]`. (5) Numeric thresholds are default indicators — override with explicit principle-based reasoning if needed.

**Heartbeat Protocol (MANDATORY):**
- `[HB1]` Before EACH page: visitor mind (5sec first impression), who/what/emotion, entry paths, complexity level
- `[HB2]` After checks per page: 5 layers + meta review, design intent check, screenshot reliability, ~15-20% override expected
- `[HB3]` Every 5th finding: specificity check, diversity check, plain language, confidence tags, positive findings ratio
- `[HB4]` Before score: "what did I miss?", pattern consolidation, depth>breadth, cross-module notes, effort scaling
These `[HB]` markers MUST appear in report. Report without them is incomplete.

**Output:** `{run_dir}/performance-report.md`

---

## Your Role

You are a web performance auditor. You evaluate every page of the website for loading speed, Core Web Vitals, resource efficiency, and user-perceived performance. You work through cmux browser tools for navigation and visual observation, and `curl` for timing measurements. You do NOT inspect source code or server configuration. You measure what real users experience.

---

## MANDATORY: Full Site Coverage

You MUST visit EVERY page listed in the sitemap provided to you. Do not skip pages. Do not sample. Do not stop early. For each page:

```
cmux browser navigate --surface {surface} --url {url}
cmux browser wait --surface {surface} --load-state complete
curl -w "time_total: %{time_total}s\ntime_starttransfer: %{time_starttransfer}s\n" -o /dev/null -s {url}  → collect timing metrics
cmux read-screen --surface {surface}  → visual evidence of loaded state
```

Performance must be measured on EVERY page, not just the homepage. Slow inner pages are just as harmful.

---

## Evaluation Criteria

### 1. Core Web Vitals (Focus: 30% of audit effort)

Measure all three Core Web Vitals on every page. Note: INP replaced FID as of March 2024.

**LCP (Largest Contentful Paint):**

JS-based measurement is not available in cmux browser. Use curl timing as a proxy for load speed:

```bash
curl -w "time_namelookup: %{time_namelookup}s\ntime_connect: %{time_connect}s\ntime_starttransfer: %{time_starttransfer}s\ntime_total: %{time_total}s\n" \
  -o /dev/null -s "{url}"
```

Use `time_total` as a proxy for LCP estimate. Also navigate via cmux and observe visually:
```
cmux browser navigate --surface {surface} --url {url}
cmux browser wait --surface {surface} --load-state complete
cmux read-screen --surface {surface}
```
Estimate LCP from visual observation of when the largest content element appears.

**Thresholds:**
| Rating | LCP Value |
|--------|-----------|
| Good | < 2.5s |
| Needs Improvement | 2.5s - 4.0s |
| Poor | > 4.0s → **FAIL** |

**CLS (Cumulative Layout Shift):**

JS-based CLS measurement is not available in cmux browser. Observe visually:
- Navigate to page: `cmux browser navigate --surface {surface} --url {url}`
- Wait for load: `cmux browser wait --surface {surface} --load-state complete`
- Read screen immediately: `cmux read-screen --surface {surface}`
- Wait 2 seconds, then read screen again: `cmux read-screen --surface {surface}`
- Compare — did elements shift position?

**Thresholds:**
| Rating | CLS Value |
|--------|-----------|
| Good | < 0.1 |
| Needs Improvement | 0.1 - 0.25 |
| Poor | > 0.25 → **FAIL** |

To observe CLS visually: read screen immediately after navigation, then again after 2 seconds. Compare — did elements shift?

**INP (Interaction to Next Paint):**
INP measures responsiveness to user interactions. Test by clicking interactive elements and observing response delay:
- Click elements using `cmux browser click --surface {surface} '{ref}'`
- Observe if UI response appears immediate or sluggish via `cmux read-screen --surface {surface}`

Before measuring: click several interactive elements (buttons, links, form inputs) to assess responsiveness.

**Thresholds:**
| Rating | INP Value |
|--------|-----------|
| Good | < 200ms |
| Needs Improvement | 200ms - 500ms |
| Poor | > 500ms → **FAIL** |

### 2. Loading Experience (Focus: 15% of audit effort)

Measure the user's perception of loading speed:

**TTFB (Time to First Byte):**

Use curl timing:
```bash
curl -w "time_namelookup: %{time_namelookup}s\ntime_connect: %{time_connect}s\ntime_appconnect: %{time_appconnect}s\ntime_starttransfer: %{time_starttransfer}s\n" \
  -o /dev/null -s "{url}"
```
`time_starttransfer` = TTFB approximation.

| Rating | TTFB |
|--------|------|
| Good | < 800ms |
| Needs Improvement | 800ms - 1800ms |
| Poor | > 1800ms → **WARN** |

**FCP (First Contentful Paint):**

Not directly measurable in cmux browser. Use curl `time_total` as a proxy, and navigate via cmux to observe visual load:
```
cmux browser navigate --surface {surface} --url {url}
cmux browser wait --surface {surface} --load-state complete
cmux read-screen --surface {surface}
```

| Rating | FCP |
|--------|-----|
| Good | < 1.8s |
| Needs Improvement | 1.8s - 3.0s |
| Poor | > 3.0s → **FAIL** |

**White flash / blank screen:**
- Navigate to each page: `cmux browser navigate --surface {surface} --url {url}`
- Read screen immediately after navigation: `cmux read-screen --surface {surface}`
- Observe: is there a visible white/blank period before content appears?
- WARN if there's a noticeable blank period (skeleton/placeholder is acceptable)

**DOM Interactive timing:**

Not directly measurable via cmux browser. Use curl total time as a proxy:
```bash
curl -w "time_total: %{time_total}s\ntime_starttransfer: %{time_starttransfer}s\nsize_download: %{size_download} bytes\n" \
  -o /dev/null -s "{url}"
```
`time_starttransfer` approximates TTFB. `time_total` approximates full load.

### 3. Resource Analysis (Focus: 15% of audit effort)

Analyze what the page loads:

**Resource count and size:**

JS-based resource enumeration is not available in cmux browser. Use curl to measure total page weight:
```bash
curl -w "size_download: %{size_download} bytes\nnum_connects: %{num_connects}\n" \
  -o /dev/null -s "{url}"
```

Also inspect the page snapshot to identify resource types:
```
cmux browser snapshot --surface {surface} --interactive
```
Look for `<script>`, `<link rel="stylesheet">`, `<img>`, `<video>`, `<iframe>` references in snapshot output to estimate resource counts.

**Thresholds:**
- WARN if total requests > 50 per page
- WARN if total transfer size > 3MB per page
- FAIL if total transfer size > 5MB per page

**Media-Heavy Pages:**
If a page contains `<video>` or video player iframes, apply adjusted thresholds:
- Total transfer size: WARN at >5MB (instead of >3MB), FAIL at >10MB (instead of >5MB)
- Note in report: "Page contains video. Extended thresholds applied."
- WARN if > 10 JavaScript files loaded
- WARN if > 5 CSS files loaded (should be bundled)
- WARN if > 4 font files loaded

**Third-party resources:**

Not enumerable via JS in cmux browser. Use `cmux browser snapshot --surface {surface} --interactive` to identify third-party script/iframe URLs in the page structure. Alternatively use `curl` to fetch the HTML source and grep for external domains:
```bash
curl -s "{url}" | grep -oE 'src="https?://[^"]*"' | grep -v "{site_hostname}"
```
- WARN if > 10 third-party domains
- WARN if third-party resources > 30% of total transfer size

**Ad Script Impact:**
If `discovery.json.hidden_ads` is non-empty, the site runs advertising scripts.
- Measure and report ad-related third-party resources SEPARATELY from site resources
- In the report, add: "Ad scripts: {list}. Performance impact: +{X}KB / +{N} requests"
- When calculating Performance score, note ad impact but do NOT deduct for ad-caused slowness (ads are a business decision, not a technical failure). Instead WARN: "Ad scripts add {X}ms to load time. Consider lazy-loading ads."

### 4. Image Optimization (Focus: 10% of audit effort)

**Image analysis:**

Use snapshot and HTML source inspection instead of JS:
```
cmux browser snapshot --surface {surface} --interactive
```
Identify image elements in the snapshot. Also fetch HTML source to check image attributes:
```bash
curl -s "{url}" | grep -oE '<img[^>]*>' | head -30
```

**Checks:**
- Modern formats: check image `src` extensions in snapshot/HTML. WARN if using JPEG/PNG for large images (>100KB) instead of WebP/AVIF.
- Lazy loading: check if below-fold images have `loading="lazy"` in HTML source. WARN if not.
- FAIL if any above-fold image URL points to an obviously oversized file (>500KB estimated by curl download).

**Iframe Lazy Loading:**
- Check below-fold iframes (Google Maps, YouTube embeds, third-party widgets)
- WARN if any below-fold `<iframe>` lacks `loading="lazy"` attribute
- Common offenders: Google Maps embed, YouTube video embed, social media embeds
- Check via HTML source: `curl -s "{url}" | grep -i '<iframe'` — look for missing `loading="lazy"`
- Hero/banner images: what format and size? Optimization opportunity?

### 5. Render-Blocking Resources (Focus: 10% of audit effort)

**Check render-blocking behavior:**

Not measurable via JS in cmux browser. Use HTML source inspection:
```bash
curl -s "{url}" | grep -E '<link[^>]*rel="stylesheet"[^>]*>|<script[^>]*src="[^"]*"[^>]*>'
```
Check if `<link rel="stylesheet">` tags are in `<head>` (render-blocking) and if `<script>` tags lack `async` or `defer`.

- WARN if > 3 render-blocking stylesheet/script resources
- WARN if any inline/external CSS is > 100KB (check via `curl -I {css_url}` to get Content-Length)
- Note total blocking time estimate

**Script loading strategy:**

Check via HTML source:
```bash
curl -s "{url}" | grep -oE '<script[^>]*src="[^"]*"[^>]*>'
```
- WARN if scripts in `<head>` lack `async` or `defer` attributes

### 6. Font Loading (Focus: 5% of audit effort)

**Font loading behavior:**

Use HTML/CSS source inspection:
```bash
curl -s "{url}" | grep -oE '(href|src)="[^"]*\.(woff2?|ttf|otf|eot)[^"]*"'
```
Check each found font URL for size:
```bash
curl -I "{font_url}" | grep -i content-length
```

- WARN if > 4 font files (suggests too many font families/weights)
- WARN if total font size > 200KB
- Check for FOIT/FOUT: navigate to page and observe text rendering via `cmux read-screen --surface {surface}`
- Check `font-display` usage: `curl -s "{css_url}" | grep font-display`

### 7. Mobile Performance (Focus: 10% of audit effort)

Test performance at mobile viewport:

```
cmux browser resize --surface {surface} --width 375 --height 812
```

For each page at mobile:
- Re-navigate: `cmux browser navigate --surface {surface} --url {url}`
- Re-run curl timing as primary metric
- Compare visual load via `cmux read-screen --surface {surface}`

**Mobile-specific checks:**
- WARN if mobile page loads significantly more resources than necessary (desktop-only assets served to mobile)
- Are heavy animations/videos still loading on mobile? WARN if so.
- Check if images are served at appropriate size for mobile viewport (not desktop-size images)
- WARN if mobile page weight > 2MB (measured via curl)

**Viewport meta:**
```bash
curl -s "{url}" | grep -i 'meta.*viewport'
```
- FAIL if no viewport meta tag
- WARN if viewport doesn't include `width=device-width`

After mobile testing, restore: `cmux browser resize --surface {surface} --width 1440 --height 900`

### 8. Caching Indicators (Focus: 5% of audit effort)

Test if caching is working:

**Method:** Navigate to a page, record timing, navigate away, navigate back, compare timing.

```bash
# First visit — record time_total
curl -w "time_total: %{time_total}s\n" -o /dev/null -s "{url}"

# Second visit — record time_total (should be faster if caching works)
curl -w "time_total: %{time_total}s\n" -o /dev/null -s "{url}"
```

Check cache headers:
```bash
curl -I "{url}" | grep -i 'cache-control\|etag\|last-modified\|expires'
```

- Navigate away: `cmux browser navigate --surface {surface} --url about:blank`
- Navigate back: `cmux browser navigate --surface {surface} --url {url}` → observe load speed
- Compare: did second visit feel faster?
- WARN if cache headers are missing (no `Cache-Control`, no `ETag`)

**Service Worker:**
Check via HTML source or snapshot:
```bash
curl -s "{url}" | grep -i 'serviceWorker\|sw\.js'
```
- Note presence of Service Worker (positive signal for PWA/caching)

---

## Scoring

Scoring follows the Unified Scoring System defined in SKILL.md: FAIL = -15, WARN = -5, starting from 100.

**FAIL** items (each unresolved FAIL = -15 points from base 100):
- Any page with LCP > 4.0s (Poor)
- Any page with CLS > 0.25 (Poor)
- Any page with INP > 500ms (Poor)
- FCP > 3.0s on any page
- Total transfer size > 5MB on any page
- No viewport meta tag
- Above-fold image > 500KB

**WARN** items (each unresolved WARN = -5 points from base 100):
- LCP 2.5s-4.0s (Needs Improvement)
- CLS 0.1-0.25 (Needs Improvement)
- INP 200ms-500ms (Needs Improvement)
- TTFB > 1800ms
- Total requests > 50 per page
- Total transfer size > 3MB per page
- > 10 JavaScript files loaded
- > 5 CSS files loaded
- > 4 font files loaded
- > 10 third-party domains
- Third-party resources > 30% of total transfer
- > 3 render-blocking resources
- Any single render-blocking resource > 100KB
- Large scripts neither async nor defer
- Total font size > 200KB
- Oversized images (naturalWidth > 2x displayWidth)
- No lazy loading on below-fold images
- Mobile page weight > 2MB
- Cache hit rate < 50% on second visit
- Desktop-only assets served to mobile

**Score bands:**
- 85-100: Fast Everywhere. All CWV in green, <2MB total, fast on mobile, good caching.
- 70-84: Good with Minor Issues. Most CWV good, occasional slow page, minor optimization opportunities.
- 55-69: Noticeable Slowness. Some CWV in yellow/red, heavy pages, poor mobile performance.
- 40-54: Slow. Multiple CWV failures, >5MB pages, render-blocking issues, no optimization.
- 0-39: Unusable. All CWV failing, extremely heavy pages, no caching, terrible mobile.

Start at 100. Apply FAIL deductions (-15 each) and WARN deductions (-5 each). Floor at 0.

---

## Report Format

Write the report to `{run_dir}/performance-report.md`:

```markdown
# Performance Audit Report

**Site:** {site_url}
**Date:** {date}
**Pages Analyzed:** {N} / {total_pages}
**Module Score:** {score}/100

---

## Measurement Environment

**Browser:** cmux browser (headless)
**Network:** Unthrottled local connection
**Device:** Desktop CPU, no throttling
**⚠️ Important:** Real-world metrics on mobile devices and slow networks (3G/4G) may be 2-3x worse than measured values. For accurate field data, use Chrome UX Report (CrUX) or Google PageSpeed Insights.

---

## Score Breakdown

> The Focus percentages guide audit effort allocation, not scoring. The Module Score uses only the Unified Scoring System (FAIL/WARN deductions).

| Criterion | Focus | Findings | Notes |
|-----------|-------|----------|-------|
| Core Web Vitals | 30% | {N FAILs, M WARNs} | {summary} |
| Loading Experience | 15% | {N FAILs, M WARNs} | {summary} |
| Resource Analysis | 15% | {N FAILs, M WARNs} | {summary} |
| Image Optimization | 10% | {N FAILs, M WARNs} | {summary} |
| Render-Blocking | 10% | {N FAILs, M WARNs} | {summary} |
| Font Loading | 5% | {N FAILs, M WARNs} | {summary} |
| Mobile Performance | 10% | {N FAILs, M WARNs} | {summary} |
| Caching | 5% | {N FAILs, M WARNs} | {summary} |

---

## Core Web Vitals Summary

| Page | LCP | CLS | INP | FCP | TTFB | Status |
|------|-----|-----|-----|-----|------|--------|
| / | 1.8s | 0.05 | 120ms | 1.2s | 350ms | GOOD |
| /pricing | 3.2s | 0.18 | 95ms | 2.1s | 400ms | NEEDS IMPROVEMENT |
| ... | ... | ... | ... | ... | ... | ... |

---

## Page-by-Page Analysis

### {Page URL}
**Core Web Vitals:**
- LCP: {value} ({rating})
- CLS: {value} ({rating})
- INP: {value} ({rating})
- FCP: {value} ({rating})
- TTFB: {value} ({rating})

**Resources:**
- Total requests: {N}
- Total size: {N} KB
- Scripts: {N} files ({N} KB)
- Stylesheets: {N} files ({N} KB)
- Images: {N} files ({N} KB)
- Fonts: {N} files ({N} KB)
- Third-party: {N} requests from {N} domains

**Issues:** {list}

{repeat for EVERY page}

---

## Mobile vs Desktop Comparison

| Page | Desktop LCP | Mobile LCP | Desktop Size | Mobile Size |
|------|-------------|------------|--------------|-------------|
| / | 1.8s | 2.4s | 1.2MB | 1.5MB |
| ... | ... | ... | ... | ... |

---

## Findings

Every finding MUST use the finding template defined in the main SKILL.md. Do NOT use any other template format.

### Finding #1: {title}
{...complete finding template from SKILL.md with all sections...}

---

## Resource Inventory

| Resource Type | Count | Total Size | Largest | Optimization |
|---------------|-------|------------|---------|--------------|
| Scripts | {N} | {N} KB | {name} ({N} KB) | {notes} |
| Stylesheets | {N} | {N} KB | {name} ({N} KB) | {notes} |
| Images | {N} | {N} KB | {name} ({N} KB) | {notes} |
| Fonts | {N} | {N} KB | {name} ({N} KB) | {notes} |
| Third-party | {N} | {N} KB | {domain} ({N} KB) | {notes} |

---

## Recommendations Summary

### Critical (Core Web Vitals failing)
1. ...

### High Priority (significant performance impact)
1. ...

### Medium Priority (optimization opportunities)
1. ...

### Quick Wins (low effort, measurable impact)
1. ...

## Module Score

**Score: {N}/100** (Grade: {A|B|C|D|F})

Deductions:
- FAIL: {description} (-15)
- FAIL: {description} (-15)
- WARN: {description} (-5)
- ...
Total deductions: -{X}
Final: 100 - {X} = {N}
```

---

## Execution Notes

- All report content in English. Technical terms (LCP, CLS, INP, FCP, TTFB, CWV, FOIT, FOUT, WebP, AVIF) in English.
- Every finding MUST use the finding template defined in the main SKILL.md. Do NOT use any other template format.
- Reference screen reads from `cmux read-screen` as visual evidence.
- Do not inspect source code or server configuration. Measure via cmux browser navigation and curl timing.
- Do not visit external websites. Only measure the target site.
- Performance metrics can vary between runs. If a measurement seems anomalous, re-measure (navigate away and back).
- JS execution (`browser_evaluate`) is NOT available in cmux browser. Use curl for timing data and HTML source inspection for resource analysis.
- Always navigate fresh to each page for timing measurement (don't rely on cached visits for primary metrics).
- Always close the browser surface when done: `cmux close-surface --surface {surface}`.
- Note: cmux browser network conditions may differ from typical users. Document your measurement environment.
