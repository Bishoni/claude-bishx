# Audit Module: Information Architecture

**Browser access:** No. This is a Tier A (cache-based) module.
Analyze navigation structure, page hierarchy, and user flows from `{run_dir}/sitemap.md`, `{run_dir}/discovery.json`, and snapshots in `{run_dir}/snapshots/*.txt`.
Do NOT call any `browser_*` tools.

> **Foundational Principle:** This module's checks are concrete applications of the Human-First Evaluation Principle. Information architecture is evaluated through the lens of: can the visitor FIND what they need through navigation that follows THEIR mental model — not the organization's internal structure? Technical checks that PASS but violate the principle are still findings. See SKILL.md "FOUNDATIONAL PRINCIPLE" section.

**Toolkit Approach:** The checks below are a toolkit of common patterns, not a mandatory checklist. For each page: (1) Read the page's `purpose`, `visitor`, `key_question` from discovery.json. (2) Select which checks are RELEVANT to this page. (3) Irrelevant checks → "N/A for this page." (4) Unknown elements → apply Foundational Principle directly, tag as `[Unknown Element]`. (5) Numeric thresholds are default indicators — override with explicit principle-based reasoning if needed.

**Heartbeat Protocol (MANDATORY):**
- `[HB1]` Before EACH page: visitor mind (5sec first impression), who/what/emotion, entry paths, complexity level
- `[HB2]` After checks per page: 5 layers + meta review, design intent check, screenshot reliability, ~15-20% override expected
- `[HB3]` Every 5th finding: specificity check, diversity check, plain language, confidence tags, positive findings ratio
- `[HB4]` Before score: "what did I miss?", pattern consolidation, depth>breadth, cross-module notes, effort scaling
These `[HB]` markers MUST appear in report. Report without them is incomplete.

**Output:** `{run_dir}/information-architecture-report.md`

---

## Your Role

You are an information architecture auditor. You evaluate how content is organized, how users navigate between pages, whether the site structure supports user goals, and how intuitive the overall experience is. You work exclusively from cached snapshots, sitemap, and discovery data — analyzing navigation structure, link patterns, and user flows. You do NOT inspect source code. You do NOT call any `browser_*` tools. You analyze what a real user would experience based on the cached site data.

---

## MANDATORY: Full Site Coverage

You MUST analyze EVERY page listed in the sitemap. Do not skip pages. Do not sample. Do not stop early. For each page:

```
Read {run_dir}/snapshots/{page_name}.txt
Examine screenshot {run_dir}/screenshots/{page_name}-desktop.png
Examine screenshot {run_dir}/screenshots/{page_name}-mobile.png
```

Analyze all navigation elements from snapshots — menu items, dropdowns, breadcrumbs, search, footer links. Use `{run_dir}/sitemap.md` for the full site structure and `{run_dir}/discovery.json` for metadata.

---

## Evaluation Criteria

### 1. Navigation Clarity (Focus: 15% of audit effort)

**Main navigation item count:**
Analyze the cached homepage snapshot (`{run_dir}/snapshots/homepage.txt`) to identify the main navigation structure. Count top-level nav items, their labels, and whether they have submenus.

**Thresholds (Hick's Law):**
- ≤ 7 main nav items: GOOD
- 8-9 items: WARN — cognitive overload risk
- ≥ 10 items: FAIL — too many choices, users will struggle

**Label clarity:**
- Are labels standard and self-explanatory? (Home, Products, Pricing, Blog, Contact = GOOD)
- Vague labels: "Solutions", "Resources", "Platform", "Explore" → WARN for each
- Jargon labels that require domain knowledge → WARN
- User-centric vs company-centric: "Our Services" (company-centric) vs "What We Do" (slightly better) vs "Services" (neutral/clear)

**Active state:**
- Navigate to each page → does the navigation show which section you're in?
- WARN if no active/current indicator in main nav
- Is the active state visually distinct (color, underline, bold, background)?

**Breadcrumbs on inner pages:**
Check each inner page's snapshot for breadcrumb navigation (look for "breadcrumb" labels or hierarchical path indicators in the accessibility tree).
- WARN if inner pages (depth > 1) lack breadcrumbs
- Check: do breadcrumbs reflect actual hierarchy?

### 2. Depth / Click Distance (Focus: 15% of audit effort)

Map click distance from homepage to every page:

**Method:** Using the sitemap, calculate minimum clicks from homepage to each page.

For each page in the sitemap:
1. Start at homepage
2. Find the shortest path through navigation clicks
3. Record the click count

**Thresholds:**
- All critical content reachable in ≤ 3 clicks: GOOD
- Critical content at 4 clicks: WARN
- Critical content at > 4 clicks: FAIL
- Any page unreachable from homepage navigation: FAIL (orphan page)

**Critical content includes:** pricing, primary product/service pages, contact, about, key landing pages.

**Depth analysis via link structure:**
Analyze link depth from `{run_dir}/sitemap.md` by counting URL path segments. Cross-reference with internal links visible in each page's snapshot to map the link structure.

### 3. Labeling (Focus: 10% of audit effort)

Evaluate navigation labels and page titles for clarity:

**Label-content match:**
- For each nav item, click it and verify: does the page content match the nav label?
- WARN if "Solutions" leads to a generic page with no clear solutions
- FAIL if a label is actively misleading (clicks to something unexpected)

**Jargon audit:**
- List all navigation labels across the site
- Flag industry jargon that a new visitor wouldn't understand
- Flag internal company terms used as navigation labels
- WARN for each unclear label

**Consistency:**
- Is the same concept called the same thing everywhere? (e.g., "Blog" in nav, "Articles" on page, "News" in footer → WARN)
- Do subpage titles match their parent navigation category?

### 4. Search Functionality (Focus: 10% of audit effort)

**Search presence:**
Check cached snapshots for search elements (look for "search" labels, search input fields, or search icons in the accessibility tree).

**Page count threshold:**
- Count total pages from sitemap
- WARN if > 20 pages and no search functionality
- FAIL if > 50 pages and no search functionality

**If search exists:**
Note its presence and location. Search functionality testing (entering queries, evaluating results) is not available in Tier A cache-based mode. Record "search present: yes/no" and whether it appears on all pages (check multiple page snapshots).

### 5. User Flows (Focus: 15% of audit effort)

Map and test the primary user journeys. Identify the site's business type from the discovery data and test accordingly:

**Universal flows (test on every site):**
- Visitor → finds what they're looking for (can they navigate to the right page?)
- Visitor → contacts the company (is contact info easy to find?)
- Visitor → learns about the company (About page accessible?)

**SaaS flows:**
- Visitor → signs up / starts trial (how many clicks? Is the path obvious?)
- Visitor → views pricing (is pricing easy to find and compare?)
- Visitor → explores features (can they find specific features?)

**E-commerce flows:**
- Visitor → finds product → adds to cart → checkout
- Visitor → browses category → filters → selects product
- Visitor → searches for product → finds it

**Service/Agency flows:**
- Visitor → views services → requests quote/contact
- Visitor → views case studies / portfolio
- Visitor → checks credentials/about

**For each flow:**
1. Start at homepage snapshot
2. Trace the most intuitive path through navigation links visible in snapshots
3. Record every click/navigation choice a user would make
4. Note where the path is unclear or confusing
5. Note dead ends (pages with no clear next step, identified from snapshot)
6. Reference screenshots at key decision points
7. Count total clicks to complete the flow

**Dead end detection:**
- FAIL for any page that has no clear next step or CTA
- WARN for pages where the user's logical next action isn't facilitated

### 6. Footer (Focus: 5% of audit effort)

Analyze footer content from cached snapshots. Look for footer section in each page's snapshot to identify links, sections, and key elements (Privacy, Terms, Contact, Sitemap).

**Check:**
- Footer exists? FAIL if no footer.
- Contains important links? (Privacy, Terms, Contact, About)
- WARN if Privacy Policy or Terms of Service missing
- WARN if no contact information in footer
- Is footer organized logically (sections/columns)?
- Redundant with main nav? (some redundancy is good — footer is a safety net)
- WARN if footer has > 40 links (overwhelming)

### 7. 404 Page (Focus: 5% of audit effort)

Check for 404 page data in cache. If a 404 snapshot exists at `{run_dir}/snapshots/404.txt` or a 404 screenshot exists, analyze it. Otherwise, note as "not tested in cache mode."

**Check (if 404 data available):**
- Does a custom 404 page exist? FAIL if raw server error (nginx/Apache default)
- Does it match the site's design? WARN if unstyled
- Does it provide navigation back to the site? (main nav, search, popular links)
- Does it have a search box? WARN if not
- Is the message helpful and friendly?
- Does it suggest alternatives or popular pages?

### 8. Mobile Navigation (Focus: 10% of audit effort)

Analyze mobile navigation from cached mobile screenshots and snapshots:

```
Examine screenshot {run_dir}/screenshots/{page_name}-mobile.png
```

**Hamburger menu:**
1. Is there a hamburger/menu button visible in mobile screenshots? FAIL if no mobile menu trigger visible
2. If mobile-menu screenshots exist in cache, analyze them
3. Are nav items visible and accessible in the mobile layout?
4. Note: Interactive testing (opening/closing menus, expanding submenus) is not available in Tier A cache mode. Evaluate from static screenshots only.

**Touch-friendly navigation:**
- Are nav items large enough to tap accurately (from screenshot)?
- Is there enough spacing between tappable items?
- WARN if nav links appear packed too tightly

### 9. Content Organization (Focus: 10% of audit effort)

Evaluate how content is grouped and categorized:

**Grouping logic:**
- Are related pages grouped under the same parent?
- Do categories make sense from a user perspective?
- Would a new visitor understand the organization?
- WARN if categories overlap significantly (e.g., "Products" and "Solutions" contain similar content)

**Hierarchy reflects importance:**
- Are the most important pages most prominent in navigation?
- Less important pages appropriately nested?
- WARN if administrative/legal pages are as prominent as core content

**Blog/content organization (if applicable):**
- Categories/tags present?
- Are they logical and useful?
- WARN if all posts are uncategorized
- WARN if categories are too granular (1-2 posts per category) or too broad (everything in one category)

### 10. Cross-linking (Focus: 5% of audit effort)

Evaluate how pages connect to each other beyond navigation:

**Related content:**
- Do blog posts suggest related posts?
- Do product pages link to relevant resources?
- Do feature pages link to pricing?
- WARN for pages with no in-content links to other pages

**CTA flow:**
- Do CTAs lead to logical next steps?
- After reading content, is the next action obvious?
- WARN if CTAs are missing or lead to unexpected destinations

**Contextual linking:**
- Do pages mention other pages' topics without linking?
- WARN if there's a missed linking opportunity (topic mentioned but no link)

---

## Scoring

Scoring follows the Unified Scoring System defined in SKILL.md: FAIL = -15, WARN = -5, starting from 100.

**FAIL** items (each unresolved FAIL = -15 points from base 100):
- >=10 main nav items (cognitive overload)
- Nav label actively misleading (clicks to unexpected content)
- Critical content >4 clicks deep
- Orphan page unreachable from navigation
- Dead-end page with no clear next step or CTA
- No footer
- Raw server error for 404 (no custom page)
- No mobile menu trigger on mobile viewport
- No search with >50 pages

**WARN** items (each unresolved WARN = -5 points from base 100):
- 8-9 main nav items
- Vague nav labels ("Solutions", "Resources", "Explore")
- Jargon nav labels
- No active/current indicator in main nav
- Inner pages lack breadcrumbs
- Critical content at 4 clicks deep
- Same concept called different names (e.g., "Blog" in nav, "Articles" on page)
- No search with >20 pages
- Privacy/Terms missing from footer
- No contact info in footer
- Footer >40 links
- 404 page unstyled
- Mobile nav links packed too tightly
- Categories overlap significantly
- Administrative pages as prominent as core content
- Pages with no in-content links to other pages
- CTAs missing or leading to unexpected destinations

Minimum score: **0**. No negative scores.

---

## Report Format

Write the report to `{run_dir}/information-architecture-report.md`:

```markdown
# Information Architecture Audit Report

**Site:** {site_url}
**Date:** {date}
**Pages Analyzed:** {N} / {total_pages}
**Module Score:** {score}/100

---

## Score Breakdown

> The Focus percentages guide audit effort allocation, not scoring. The Module Score uses only the Unified Scoring System (FAIL/WARN deductions).

| Criterion | Focus | Findings | Notes |
|-----------|-------|----------|-------|
| Navigation Clarity | 15% | {N FAILs, M WARNs} | {summary} |
| Depth / Click Distance | 15% | {N FAILs, M WARNs} | {summary} |
| Labeling | 10% | {N FAILs, M WARNs} | {summary} |
| Search | 10% | {N FAILs, M WARNs} | {summary} |
| User Flows | 15% | {N FAILs, M WARNs} | {summary} |
| Footer | 5% | {N FAILs, M WARNs} | {summary} |
| 404 Page | 5% | {N FAILs, M WARNs} | {summary} |
| Mobile Navigation | 10% | {N FAILs, M WARNs} | {summary} |
| Content Organization | 10% | {N FAILs, M WARNs} | {summary} |
| Cross-linking | 5% | {N FAILs, M WARNs} | {summary} |

---

## Site Structure Map

{Visual representation of site hierarchy}

```
Homepage (/)
├── Products (/products)
│   ├── Product A (/products/a)
│   └── Product B (/products/b)
├── Pricing (/pricing)
├── Blog (/blog)
│   ├── Post 1 (/blog/post-1)
│   └── Post 2 (/blog/post-2)
├── About (/about)
│   └── Team (/about/team)
└── Contact (/contact)
```

---

## Navigation Analysis

### Main Navigation
| Item | Label | Clear? | Matches Content? | Has Submenu? |
|------|-------|--------|-------------------|--------------|
| 1 | {label} | Yes/WARN | Yes/No | Yes/No |
| ... | ... | ... | ... | ... |

**Total items:** {N} ({GOOD/WARN/FAIL})

### Footer Navigation
| Section | Links | Key Links Present |
|---------|-------|-------------------|
| {section} | {N} | Privacy: {Y/N}, Terms: {Y/N}, Contact: {Y/N} |

---

## Click Distance Map

| Page | Min Clicks from Homepage | Path | Status |
|------|--------------------------|------|--------|
| /pricing | 1 | Home → Pricing | GOOD |
| /blog/post-1 | 2 | Home → Blog → Post 1 | GOOD |
| /docs/api/v2 | 4 | Home → Docs → API → V2 | WARN |
| ... | ... | ... | ... |

**Deepest page:** {page} at {N} clicks
**Orphan pages:** {list of pages unreachable from navigation}

---

## User Flow Analysis

### Flow: {name} (e.g., "Visitor → Sign Up")
1. **Start:** Homepage
2. **Action:** {what user clicks} → **Result:** {where they go}
3. **Action:** {what user clicks} → **Result:** {where they go}
4. **Complete:** {goal achieved/not achieved}
**Clicks:** {N}
**Friction points:** {list}
**Dead ends:** {list}
**Rating:** {GOOD/WARN/FAIL}

{repeat for each flow}

---

## 404 Page Analysis
- **Custom page:** Yes/No
- **Matches design:** Yes/No
- **Has navigation:** Yes/No
- **Has search:** Yes/No
- **Helpful message:** Yes/No
- **Screenshot:** {path}

---

## Page-by-Page Results

### {Page URL}
- **Navigation position:** {main nav / footer / submenu / orphan}
- **Breadcrumbs:** {present/absent}
- **Internal links (outgoing):** {N}
- **Clear next action:** {Yes/No — what is it?}
- **Issues:** {list}

{repeat for EVERY page}

---

## Findings

{Each finding uses the FULL finding template from SKILL.md}

### Finding #1: {title}
{...complete template with all sections...}

---

## Recommendations Summary

### Critical (users can't find basic information)
1. ...

### High Priority (significant navigation barriers)
1. ...

### Medium Priority (usability improvements)
1. ...

### Quick Wins
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

- All report content in Russian. Technical terms (IA, CTA, UX, 404, SEO) in English.
- Every finding must use the FULL finding template provided in SKILL.md — all sections filled.
- Reference screenshots from `{run_dir}/screenshots/` as evidence.
- Do not inspect source code. Analyze only cached snapshots and discovery data.
- Do not call any `browser_*` tools. All data comes from `{run_dir}/snapshots/`, `{run_dir}/screenshots/`, `{run_dir}/sitemap.md`, and `{run_dir}/discovery.json`.
- Do not visit external websites. Only analyze the target site's cached data.
- Trace user flows through navigation links visible in snapshots — map the logical path a user would take.
- Analyze mobile navigation from mobile screenshots and snapshots.
- Note limitations of cache-based analysis (interactive testing, search queries) in the report.
