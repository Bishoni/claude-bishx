# Audit Module: SEO Technical

**Browser access:** No. This is a Tier A (cache-based) module.
Analyze meta tags, structured data, and page structure from cached data in `{run_dir}/snapshots/*.txt` and `{run_dir}/discovery.json` (which contains per-page metadata: title, metaDesc, canonical, ogTitle, ogDesc, ogImage, jsonLd, lang, viewport).
Do NOT call any `browser_*` tools.

> **Foundational Principle:** This module's checks are concrete applications of the Human-First Evaluation Principle. Technical SEO is evaluated through the lens of: does the page structure help search engines deliver the RIGHT visitor to the RIGHT page — so the promise of the search result matches the reality of the landing? Technical checks that PASS but violate the principle are still findings. See SKILL.md "FOUNDATIONAL PRINCIPLE" section.

**Toolkit Approach:** The checks below are a toolkit of common patterns, not a mandatory checklist. For each page: (1) Read the page's `purpose`, `visitor`, `key_question` from discovery.json. (2) Select which checks are RELEVANT to this page. (3) Irrelevant checks → "N/A for this page." (4) Unknown elements → apply Foundational Principle directly, tag as `[Unknown Element]`. (5) Numeric thresholds are default indicators — override with explicit principle-based reasoning if needed.

**Heartbeat Protocol (MANDATORY):**
- `[HB1]` Before EACH page: visitor mind (5sec first impression), who/what/emotion, entry paths, complexity level
- `[HB2]` After checks per page: 5 layers + meta review, design intent check, screenshot reliability, ~15-20% override expected
- `[HB3]` Every 5th finding: specificity check, diversity check, plain language, confidence tags, positive findings ratio
- `[HB4]` Before score: "what did I miss?", pattern consolidation, depth>breadth, cross-module notes, effort scaling
These `[HB]` markers MUST appear in report. Report without them is incomplete.

## Prerequisites

- Discovery phase complete: `{run_dir}/discovery.json` and `{run_dir}/sitemap.md` must exist
- `{run_dir}` path received from Lead agent
- Site URL received from Lead agent as `{site_url}`
- Business type received from Lead agent as `{business_type}`

---

## Instructions

You are the SEO Technical auditor. Your job is to evaluate every technical factor that determines whether search engines can discover, crawl, index, understand, and rank this site.

Read `{run_dir}/discovery.json` to get the full list of pages and their cached metadata. Process EVERY page. Do not sample.

### Check Order

Run checks in this order:

1. Infrastructure (robots.txt, sitemap.xml presence in discovery.json) — do first, results affect interpretation of everything else
2. HTTPS and security
3. Each page: meta tags, heading structure, canonical, Open Graph, Twitter Card, viewport (from discovery.json)
4. Each page: structured data (from discovery.json jsonLd field)
5. URL structure analysis
6. Mobile SEO (viewport meta, font size signals from cached data)
7. Internationalization

---

## Section 1: Meta Tags

For each page entry in `{run_dir}/discovery.json`, read the following fields directly:

```
title, metaDesc, canonical, ogTitle, ogDesc, ogImage, jsonLd, lang, viewport
```

Also read the corresponding snapshot at `{run_dir}/snapshots/{page-slug}.txt` for heading structure and additional content.

### Hard Thresholds — Meta Tags

| Check | Threshold | Severity |
|-------|-----------|----------|
| Title tag present | Missing → FAIL | FAIL |
| Title length | <50 or >60 chars → WARN | WARN |
| Title length | 50–60 chars → PASS | PASS |
| Meta description present | Missing → WARN | WARN |
| Meta description length | <150 or >160 chars → WARN | WARN |
| Meta description length | 150–160 chars → PASS | PASS |
| Title unique across pages | Duplicate → FAIL | FAIL |
| Meta description unique | Duplicate → WARN | WARN |
| Canonical present | Missing → WARN | WARN |
| Canonical correct (matches page URL or intended canonical) | Wrong → WARN | WARN |
| og:title present | Missing → WARN | WARN |
| og:description present | Missing → WARN | WARN |
| og:image present | Missing → WARN | WARN |
| twitter:card present | Missing → WARN | WARN |
| Viewport meta present | Missing → FAIL | FAIL |
| `<meta name="robots" content="noindex">` on important pages | Present → FAIL | FAIL |

Track all titles and descriptions in a deduplication list. After visiting all pages, compare for duplicates.

---

## Section 2: Heading Structure

For each page, parse heading structure from the snapshot at `{run_dir}/snapshots/{page-slug}.txt`. Extract all H1–H6 headings in document order.

### Hard Thresholds — Headings

| Check | Threshold | Severity |
|-------|-----------|----------|
| Exactly one H1 | Zero H1 → FAIL | FAIL |
| Exactly one H1 | More than one H1 → FAIL | FAIL |
| Logical hierarchy (no skipped levels) | H1 → H3 without H2 → WARN | WARN |
| H1 content relevance | H1 is generic or empty → WARN | WARN |

Detect skipped levels by iterating `allHeadings` in order and checking that the numeric level never jumps by more than 1 from the previous heading.

---

## Section 3: Structured Data (JSON-LD)

For each page, read the `jsonLd` field from `{run_dir}/discovery.json`. This field contains the parsed JSON-LD array (or raw string if parse failed).

Parse and validate each returned object:

- If `__parseError` present → FAIL (invalid JSON-LD)
- Extract `@type` from each schema object
- Check `@context` is present (must be `"https://schema.org"` or `"http://schema.org"`)

### Required Fields by Schema Type

| Schema `@type` | Required Fields | Severity if Missing |
|----------------|-----------------|---------------------|
| `Organization` | `name`, `url` | WARN |
| `WebSite` | `name`, `url` | WARN |
| `Article` / `BlogPosting` | `headline`, `author`, `datePublished` | WARN |
| `Product` | `name`, `description`, `offers` | WARN |
| `FAQPage` | `mainEntity` (array of Q&A) | WARN |
| `BreadcrumbList` | `itemListElement` | WARN |
| `LocalBusiness` | `name`, `address`, `telephone` | WARN |
| `Event` | `name`, `startDate`, `location` | WARN |

### Page-Type Expectations

| Business Type | Homepage Must Have | Inner Pages Should Have |
|---------------|--------------------|-------------------------|
| Any | `Organization` or `WebSite` | Page-appropriate schema |
| Blog / Content | `WebSite` on home | `Article` or `BlogPosting` on posts |
| E-commerce | `Organization` | `Product` on product pages |
| Local Business | `LocalBusiness` | — |
| SaaS | `Organization`, `WebSite` | `FAQPage` if FAQ section present |

**Additional schema types by business_type:**
- **News/Media:** `NewsArticle` (required on article pages instead of generic Article), `VideoObject` (on video pages), `AudioObject` (on podcast pages), `Person` (on author pages)
- **Education/EdTech:** `Course` (on course pages — Google supports Course rich results), `Review` + `AggregateRating` (on review pages), `EducationalOrganization` (on homepage/about)
- **Classifieds/Listings:** `Product` or `RealEstateListing` (on listing pages), `AggregateOffer` (on category pages), `LocalBusiness` (on agent/developer pages if applicable)
- **Government/Public:** `GovernmentOrganization`, `GovernmentService` (on service pages), `FAQPage` (on FAQ), `SpecialAnnouncement` (on emergency alerts if present)

FAIL if business-specific schema is completely absent. WARN if present but incomplete (missing required fields).

### Hard Thresholds — Structured Data

| Check | Threshold | Severity |
|-------|-----------|----------|
| Any structured data on any page | None found across entire site → WARN | WARN |
| Homepage has Organization or WebSite schema | Missing → WARN | WARN |
| JSON-LD is valid JSON | Parse error → FAIL | FAIL |
| Required fields for schema type present | Missing required field → WARN | WARN |
| `@context` present | Missing → WARN | WARN |

### Local SEO (when business_type = "local")

If the site is classified as a local business, perform these additional checks:

**NAP Consistency (Name, Address, Phone):**
- Extract business name, address, and phone from homepage snapshot
- Check if identical NAP appears on EVERY page (header/footer)
- FAIL if NAP differs between pages (e.g., different phone on /contact vs footer)
- WARN if address format is inconsistent (abbreviated vs full)

**CallTracking Exception:** If `discovery.json.calltracking_detected == true`, SKIP phone number consistency checks across pages. Dynamic phone numbers are intentional tracking mechanisms, not NAP inconsistencies. Note in report: "CallTracking detected ({service}). Phone number consistency check skipped."

**Local Schema Markup:**
Required fields for LocalBusiness schema beyond basic Organization:
- `openingHoursSpecification` — FAIL if missing for businesses with physical locations
- `geo` (latitude/longitude) — WARN if missing
- `areaServed` — WARN if missing
- `priceRange` — WARN if missing
- `hasMap` — WARN if no map link in schema
- `sameAs` — WARN if no social profile links

**Google Business Profile:**
- Check for link to Google Maps or Google Business Profile in footer/contact page
- WARN if no GBP link found anywhere on the site

**Local Keywords:**
- Check page titles and H1s for city/location name inclusion
- WARN if homepage title does not contain the city/location name
- Check if service pages include location-specific content (not just generic)

---

## Section 4: Core Web Vitals

Core Web Vitals (LCP, CLS, INP, TTFB, FCP) are measured by the Performance module. This module does NOT measure CWV to avoid duplicate/contradictory results.

---

## Section 5: Crawlability

### robots.txt

Read robots.txt content from `{run_dir}/robots.txt` (captured during discovery step 1.5). If not present, note as "not captured in this run."

- Non-empty file present → PASS
- File absent or empty → WARN
- Contains `Disallow: /` without a matching Allow → FAIL (blocks all crawlers)
- Contains `noindex` directive (not valid in robots.txt, but some CMS add it) → WARN
- Contains `Sitemap:` directive pointing to sitemap → note URL

### XML Sitemap

Read sitemap data from `{run_dir}/sitemap.md` (generated during discovery).

- File present and non-empty → PASS
- File absent → WARN
- Compare sitemap URLs against pages in `discovery.json`. Flag important pages missing from sitemap.

### Noindex Check

For every page, check `<meta name="robots">` content (already extracted in Section 1).

- `noindex` on homepage → FAIL
- `noindex` on any main navigation page → FAIL
- `noindex` on expected-to-be-indexed pages → FAIL

### Internal Link Integrity

From `discovery.json`, check for any 404s recorded during discovery. If discovery did not capture response codes, note this as "not verified in this run."

### Hard Thresholds — Crawlability

| Check | Threshold | Severity |
|-------|-----------|----------|
| robots.txt accessible | Not found → WARN | WARN |
| robots.txt blocks all crawlers | `Disallow: /` with no Allow → FAIL | FAIL |
| Sitemap exists | Not found → WARN | WARN |
| Sitemap covers main pages | Important pages missing → WARN | WARN |
| Noindex on homepage | Present → FAIL | FAIL |
| Noindex on nav pages | Present → FAIL | FAIL |

---

## Section 6: URL Structure

Analyze all URLs discovered in `discovery.json`.

For each URL, check:

```
Clean URL: no query params like ?id=123, ?page=2 on content pages (pagination params are acceptable)
Lowercase: URL is all lowercase
Separator: uses hyphens, not underscores, not spaces
Keywords: URL slug appears descriptive (not /p/12345 or /node/789)
Encoded chars: no %XX encoding in the path (e.g., %20)
Hash fragments as navigation: #section used as primary content URL → WARN
Directory depth: count slashes — /a/b/c/d/e/f = 5 levels deep
```

### Hard Thresholds — URL Structure

| Check | Threshold | Severity |
|-------|-----------|----------|
| Query params for content identification | Present → WARN | WARN |
| Uppercase letters in path | Present → WARN | WARN |
| Underscores in path | Present → WARN | WARN |
| Encoded characters in path | Present → WARN | WARN |
| Directory depth >5 levels | Present → WARN | WARN |
| Numeric-only slugs (e.g., /post/12345) | Present → WARN | WARN |

### Tag/Taxonomy Pages

If discovery.json shows pages with URL patterns like `/tags/*`, `/tag/*`, `/taxonomy/*`:
- Check if tag pages have `noindex` meta tag (recommended to prevent index bloat)
- Do NOT flag tag pages as "thin content" — they are intentionally filtered views
- WARN if tag pages are indexed without canonical to the main category

### Document Download Links

Check downloadable file links (PDF, DOCX, XLS):
- WARN if download link text is just "Download" without describing the document
- WARN if file size is not indicated near the download link
- Check if the download link has descriptive text (e.g., "Passport Application Form (PDF, 245 KB)")
- WARN if linked documents are dated >2 years ago (stale forms/templates)
- Note: PDF internal accessibility (tagged PDF, reading order) is outside this module's scope.

---

## Section 7: Mobile SEO

Mobile SEO checks are performed from cached data only (no browser interaction).

### Viewport Meta Check

Read `viewport` field from `{run_dir}/discovery.json` for each page. A missing or incorrect viewport meta is a strong mobile signal.

### Font Size and Scroll

These runtime checks require live browser rendering and are NOT performed by this module. The Performance module may capture relevant signals. Note "not measurable from cache" in the report if applicable.

### Intrusive Interstitials

Scan page snapshots in `{run_dir}/snapshots/` for class/id patterns indicating modals or popups (`modal`, `popup`, `overlay`, `interstitial`). Flag pages where such elements appear prominent in the snapshot.

### Hard Thresholds — Mobile SEO

| Check | Threshold | Severity |
|-------|-----------|----------|
| Viewport meta present and correct | Missing or `content` lacks `width=device-width` → FAIL | FAIL |
| Intrusive interstitials in snapshot | Modal/popup patterns covering viewport → FAIL | FAIL |

---

## Section 8: Security

For each page, read the URL from `{run_dir}/discovery.json`.

- URL starts with `https://` → PASS
- URL starts with `http://` → FAIL

### Mixed Content

Scan page snapshots in `{run_dir}/snapshots/` for `src="http://` or `href="http://` attributes on resource-loading elements (img, script, link, iframe). Flag any found as mixed content warnings.

### Hard Thresholds — Security

| Check | Threshold | Severity |
|-------|-----------|----------|
| Page served over HTTPS | HTTP → FAIL | FAIL |
| Mixed content in snapshot | `src="http://` or `href="http://` on resources → WARN | WARN |

---

## Section 9: AMP / Turbo Pages (when business_type = "news" or detected)

Check for AMP alternate links:
- In page snapshot, look for `<link rel="amphtml" href="...">`
- If found: WARN if AMP URL does not follow canonical/amphtml pair pattern
- Check if AMP pages are in sitemap.xml

Check for Yandex Turbo Pages:
- Look for `<link rel="turbo" href="...">`
- If found: note in report

WARN if a news site has zero AMP/Turbo page indicators — these are important for news distribution.

---

## Section 10: Internationalization

For each page, read the `lang` field from `{run_dir}/discovery.json`. Scan page snapshots in `{run_dir}/snapshots/` for `<link rel="alternate" hreflang=...>` tags.

### Hard Thresholds — Internationalization

| Check | Threshold | Severity |
|-------|-----------|----------|
| `lang` attribute on `<html>` | Missing → WARN | WARN |
| hreflang tags if multiple languages detected | Missing → WARN | WARN |
| hreflang self-referencing tag | Missing → WARN | WARN |

Apply these checks only if:
- Multiple language versions detected during discovery, OR
- `lang` attribute value differs across pages, OR
- URLs contain `/en/`, `/ru/`, `/de/` etc. patterns

If site is single-language: note `lang` attribute presence only.

---

## Scoring

Scoring follows the Unified Scoring System defined in SKILL.md.
Start at **100**. Deductions: **FAIL = -15**, **WARN = -5**. Minimum score: 0.

---

## Output Format

Write findings to `{run_dir}/seo-technical-report.md`.

### Report Structure

```markdown
# SEO Technical Report

**Site:** {site_url}
**Date:** {date}
**Pages audited:** {N}
**Score:** {score}/100

---

## Score Summary

| Section | Findings | Key Issues |
|---------|----------|------------|
| Meta Tags | {N FAILs, M WARNs} | {one-line summary} |
| Heading Structure | {N FAILs, M WARNs} | {one-line summary} |
| Structured Data | {N FAILs, M WARNs} | {one-line summary} |
| Crawlability | {N FAILs, M WARNs} | {one-line summary} |
| URL Structure | {N FAILs, M WARNs} | {one-line summary} |
| Mobile SEO | {N FAILs, M WARNs} | {one-line summary} |
| Security | {N FAILs, M WARNs} | {one-line summary} |
| **TOTAL** | **{N FAILs, M WARNs}** | |

---

## Findings

Every finding MUST use the finding template defined in the main SKILL.md. Do NOT use any other template format.

---

## Structured Data Inventory

| Page | Schema Types Found | Valid | Issues |
|------|--------------------|-------|--------|
| / | Organization, WebSite | Yes | — |
| /blog/post-1 | Article | Yes | Missing datePublished |
| /products/x | — | — | No schema found |

---

## Meta Tags Inventory

| Page | Title (len) | Description (len) | Canonical | Viewport | noindex |
|------|-------------|-------------------|-----------|----------|---------|
| / | {title} ({N}c) | {desc} ({N}c) | Present | Present | No |
| ... | | | | | |

**Duplicate titles:** {list or "none"}
**Duplicate descriptions:** {list or "none"}

---

## Passes

{List what is working correctly — minimum 3 items if any pass}

---

## Recommendations Priority List

1. [FAIL] {Fix action} → impacts indexation
2. [FAIL] {Fix action} → impacts ranking
3. [WARN] {Fix action} → improves coverage
{...}

---

## Module Score
**Score: {N}/100** (Grade: {A|B|C|D|F})

Deductions:
- FAIL: {description} (-15)
- WARN: {description} (-5)
- ...
Total deductions: -{X}
Final: 100 - {X} = {N}
```

---

## Rules for This Module

1. Analyze ALL pages listed in `{run_dir}/discovery.json`. No sampling.
2. Read data from cached snapshots and discovery.json — do NOT call any `browser_*` tools.
3. Report exact values, not impressions. "Title is 73 characters" not "title is too long."
4. List every affected page for each issue, not just the first occurrence.
5. Duplicate detection requires collecting all titles/descriptions first, then comparing.
6. Do not report warnings for pages that are intentionally noindexed (admin, login, thank-you) — only flag pages that appear to be intended for indexation.
7. All report content in English. Technical terms (SEO, JSON-LD, hreflang, Open Graph) remain in English.
