# Audit Module: Brand Consistency

**Browser access:** No. This is a Tier A (cache-based) module.
Analyze visual consistency across pages from cached screenshots in `{run_dir}/screenshots/` and snapshots in `{run_dir}/snapshots/*.txt`.
Do NOT call any `browser_*` tools.

> **Foundational Principle:** This module's checks are concrete applications of the Human-First Evaluation Principle. Brand consistency is evaluated through the lens of: does a consistent experience build trust so the visitor focuses on CONTENT, not on wondering "is this the same site?" Consistency serves trust — it is not an end in itself. Technical checks that PASS but violate the principle are still findings. See SKILL.md "FOUNDATIONAL PRINCIPLE" section.

**Toolkit Approach:** The checks below are a toolkit of common patterns, not a mandatory checklist. For each page: (1) Read the page's `purpose`, `visitor`, `key_question` from discovery.json. (2) Select which checks are RELEVANT to this page. (3) Irrelevant checks → "N/A for this page." (4) Unknown elements → apply Foundational Principle directly, tag as `[Unknown Element]`. (5) Numeric thresholds are default indicators — override with explicit principle-based reasoning if needed.

**Heartbeat Protocol (MANDATORY):**
- `[HB1]` Before EACH page: visitor mind (5sec first impression), who/what/emotion, entry paths, complexity level
- `[HB2]` After checks per page: 5 layers + meta review, design intent check, screenshot reliability, ~15-20% override expected
- `[HB3]` Every 5th finding: specificity check, diversity check, plain language, confidence tags, positive findings ratio
- `[HB4]` Before score: "what did I miss?", pattern consolidation, depth>breadth, cross-module notes, effort scaling
These `[HB]` markers MUST appear in report. Report without them is incomplete.

**Output:** `{run_dir}/brand-consistency-report.md`

---

## Your Role

You are a brand consistency auditor. You evaluate whether the website presents a coherent, unified visual identity and brand experience across every page. You look for inconsistencies in color, typography, components, tone of voice, imagery, spacing, interactions, and overall brand personality. You work exclusively from cached screenshots and snapshots — comparing visual treatments across all pages and documenting deviations. You do NOT inspect source code. You do NOT call any `browser_*` tools. You evaluate the visual and tonal output from cached data.

---

## MANDATORY: Full Site Coverage

You MUST analyze EVERY page listed in the sitemap. Do not skip pages. Do not sample. Do not stop early. For each page:

```
Read {run_dir}/snapshots/{page_name}.txt
Examine screenshot {run_dir}/screenshots/{page_name}-desktop.png
Examine screenshot {run_dir}/screenshots/{page_name}-mobile.png
```

Brand consistency can ONLY be evaluated by comparing ALL pages against each other. A single skipped page could hide the worst inconsistency.

---

## Evaluation Criteria

### 1. Color Consistency (Focus: 15% of audit effort)

**Analyze color palette from each page's screenshot:**
Visually identify the dominant colors (backgrounds, text, accents) from each page's desktop screenshot. Compare across all pages.

**Compare across all pages:**

- Are the top 3-5 background colors the same across all pages?
- Are text colors consistent?
- Is the accent/primary color always used for the same purpose (CTAs, links, highlights)?
- WARN if any page introduces a color not seen on other pages
- WARN if the primary CTA color varies between pages
- FAIL if different pages use clearly different primary brand colors

**Specific checks:**
- Link colors: same on all pages?
- Button primary color: same on all pages?
- Header background: same on all pages?
- Footer background: same on all pages?

### 2. Typography Consistency (Focus: 15% of audit effort)

**Analyze typography from each page's screenshot and snapshot:**
Visually identify heading fonts, body fonts, sizes, and weights from screenshots. Compare across all pages.

**Compare across all pages:**

- Same heading font family across all pages?
- Same body font family across all pages?
- H1 sizes consistent? H2 sizes consistent?
- Font weights consistent for same heading levels?
- WARN if blog uses different fonts than homepage
- WARN if any page uses a font family not seen elsewhere on the site
- FAIL if core pages (homepage, pricing, about) use different type systems

**Type scale consistency:**
- Is there a clear visual hierarchy (H1 > H2 > H3 > body)?
- Are the size ratios consistent across pages?
- WARN if heading sizes vary inconsistently (H2 is 28px on one page, 24px on another)

### 3. Component Consistency (Focus: 15% of audit effort)

Compare the same UI components across different pages:

**Buttons:**
Visually identify all button variants from screenshots and snapshots on every page. Compare:
- Primary buttons: same background, radius, padding, font everywhere?
- Secondary buttons: consistent treatment?
- WARN if "the same kind of button" looks different on different pages
- Ghost buttons, outline buttons — same style everywhere?

**Cards:**
- If the site uses card components (blog cards, feature cards, pricing cards):
  - Same border radius?
  - Same shadow?
  - Same padding?
  - Same hover behavior?
  - WARN if card styling varies between sections

**Form inputs:**
Identify form inputs from snapshots on pages that contain forms.
- Same input styling everywhere?
- WARN if contact form inputs look different from login/signup inputs

**Navigation component:**
- Does the header look identical on every page?
- Does the footer look identical on every page?
- FAIL if header/footer change between pages (different layout, different links)

### 4. Tone of Voice (Focus: 10% of audit effort)

Evaluate writing style consistency across pages. Read the text content on every page from cached snapshots in `{run_dir}/snapshots/`:

**Formality level:**
- Is the tone consistently formal or casual?
- WARN if homepage is casual/fun but pricing page is corporate/stiff
- WARN if blog tone is completely different from main site

**Person/perspective:**
- "We" vs "I" vs company name — is it consistent?
- "You" / direct address used consistently?
- WARN if some pages say "We help you" and others say "{Company} helps clients"

**Terminology:**
- Are the same features/concepts called the same thing everywhere?
- WARN if the product is described differently on different pages
- "Platform" on homepage, "tool" on features, "software" on pricing → WARN

**Call-to-action language:**
- Are CTAs in the same style? ("Get Started" vs "Start Now" vs "Try Free" vs "Sign Up" — pick one)
- WARN if every CTA uses different language for the same action

**Energy/confidence level:**
- Some pages bold and confident, others hedging and uncertain?
- WARN if there's a jarring shift in energy between pages

### 5. Logo Usage (Focus: 5% of audit effort)

**Check logo on every page:**
Visually identify the logo from each page's screenshot. Check snapshots for logo alt text. Compare:
- Same logo on all pages?
- Same dimensions on all pages?
- Color version consistent? (no mix of full-color and monochrome without reason)
- WARN if logo changes between pages
- FAIL if some pages have no logo
- Is logo linked to homepage?

**Footer logo:**
- If there's a footer logo, is it the same version or an appropriate variant (e.g., white version on dark footer)?

### 6. Imagery Style (Focus: 10% of audit effort)

Visually analyze images on each page from screenshots:

**Photo style:**
- Are photos consistent in treatment? (Same filters, saturation, warmth, contrast)
- Are they the same genre? (Real photography vs stock, candid vs staged, close-up vs wide)
- WARN if homepage uses custom photography but inner pages use obvious stock photos
- WARN if photo quality varies dramatically (some high-res, some pixelated)

**Illustration style:**
- If illustrations are used, are they the same style throughout?
- Same line weight, color palette, complexity?
- WARN if different illustration styles appear on different pages (flat + 3D, line art + filled)
- FAIL if illustrations look like they're from different sources/artists

**Icon style:**
- Are icons consistent? (All line icons, all filled, all same weight)
- Same icon set throughout?
- WARN if icon styles mix (some outline, some filled, some colored, some monochrome)

**Mixed media:**
- Does the site use photos AND illustrations? Is the mix intentional and consistent?
- WARN if the mix feels random/unplanned

### 7. Spacing Rhythm (Focus: 5% of audit effort)

Evaluate visual spacing consistency:

**Section spacing:**
Visually assess section spacing from each page's screenshot. Compare spacing rhythm across pages.

**Compare across pages:**
- Are section paddings consistent across pages?
- WARN if some pages feel spacious and others cramped
- Is there a consistent spacing scale? (e.g., multiples of 8px or 4px)
- WARN if spacing values seem random (17px here, 23px there, 42px elsewhere)

**Element spacing:**
- Do cards/components have consistent internal padding?
- Is gap between elements consistent in similar contexts?
- WARN if the same component has different spacing on different pages

### 8. Interactive Patterns (Focus: 10% of audit effort)

Compare interactive behavior across pages:

**Hover effects:**
- If hover-state screenshots exist in `{run_dir}/screenshots/` (e.g., `*-hover.png`), compare hover effects across pages.
- Otherwise, note that hover consistency evaluation is limited in Tier A cache mode.
- WARN if hover effects vary visibly across pages (from available screenshots)

**Transitions/animations:**
- Are transitions consistent? (Same duration, same easing)
- Do some pages have scroll animations while others are static?
- WARN if animation treatment is inconsistent across pages

**Feedback patterns:**
- Clicking buttons: same feedback everywhere? (Color change, loading state)
- Form submission: same success/error pattern?
- WARN if different forms show errors differently

**Scroll behavior:**
- Sticky header on all pages or only some? WARN if inconsistent
- Smooth scrolling vs instant jump — is it consistent?

### 9. Error/Empty State Consistency (Focus: 5% of audit effort)

**404 page:**
- Does it match the site's design?
- Same header/footer as other pages?
- WARN if 404 page looks completely different from the rest of the site

**Form errors:**
- Trigger validation errors on every form found
- Are error messages styled the same way across all forms?
- Same color for errors? Same icon? Same position?
- WARN if different forms show errors differently

**Empty states (if applicable):**
- Search with no results: styled consistently with the site?
- Empty categories or listing pages: handled with consistent design?

### 10. Brand Signals / Distinctiveness (Focus: 10% of audit effort)

Evaluate whether the site has a unique, recognizable brand identity:

**Template test:**
- Could you tell what brand this is WITHOUT the logo?
- Does the design have unique personality (custom illustrations, distinctive color scheme, unique layout patterns)?
- Or is it a completely generic template with nothing distinctive?
- WARN if the site looks like an out-of-the-box template with no customization
- Note what IS distinctive about the brand (if anything)

**Brand personality consistency:**
- Does the visual design match the tone of voice?
- Is the brand personality consistent? (E.g., playful brand has playful design throughout, not serious design on some pages)
- WARN if visual personality shifts between pages

**Differentiation:**
- What visual elements make this brand unique?
- Are these elements used consistently across the site?
- If the brand has a signature visual (custom shapes, unique gradient, specific illustration style), is it present on every page?

---

## Scoring

Scoring follows the Unified Scoring System defined in SKILL.md: FAIL = -15, WARN = -5, starting from 100.

**FAIL** items (each unresolved FAIL = -15 points from base 100):
- Core pages use different type systems (different font families on homepage vs pricing vs about)
- Different pages use clearly different primary brand colors
- Header/footer layout changes between pages
- Illustrations look like they're from different sources/artists
- Some pages have no logo

**WARN** items (each unresolved WARN = -5 points from base 100):
- Any page introduces a color not seen on other pages
- Primary CTA color varies between pages
- Blog uses different fonts than homepage
- Any page uses a font family not seen elsewhere
- Heading sizes vary inconsistently across pages
- Same-type button looks different on different pages
- Card styling varies between sections
- Contact form inputs look different from other form inputs
- Logo changes between pages (different variant without clear reason)
- Homepage uses custom photography but inner pages use stock
- Photo quality varies dramatically across pages
- Different illustration styles on different pages (flat + 3D, line + filled)
- Icon styles mix (outline + filled + colored + monochrome)
- Casual homepage tone but corporate pricing page (or similar tone shifts)
- Product described differently on different pages
- Every CTA uses different language for same action
- Hover effects vary across pages
- Animation treatment inconsistent
- Sticky header on some pages only
- Different forms show errors differently
- 404 page looks completely different from rest of site
- Site looks like unmodified template with no customization
- Visual personality shifts between pages

Minimum score: **0**. No negative scores.

---

## Report Format

Write the report to `{run_dir}/brand-consistency-report.md`:

```markdown
# Brand Consistency Audit Report

**Site:** {site_url}
**Date:** {date}
**Pages Analyzed:** {N} / {total_pages}
**Module Score:** {score}/100

---

## Score Breakdown

> The Focus percentages guide audit effort allocation, not scoring. The Module Score uses only the Unified Scoring System (FAIL/WARN deductions).

| Criterion | Focus | Findings | Notes |
|-----------|-------|----------|-------|
| Color Consistency | 15% | {N FAILs, M WARNs} | {summary} |
| Typography Consistency | 15% | {N FAILs, M WARNs} | {summary} |
| Component Consistency | 15% | {N FAILs, M WARNs} | {summary} |
| Tone of Voice | 10% | {N FAILs, M WARNs} | {summary} |
| Logo Usage | 5% | {N FAILs, M WARNs} | {summary} |
| Imagery Style | 10% | {N FAILs, M WARNs} | {summary} |
| Spacing Rhythm | 5% | {N FAILs, M WARNs} | {summary} |
| Interactive Patterns | 10% | {N FAILs, M WARNs} | {summary} |
| Error/Empty States | 5% | {N FAILs, M WARNs} | {summary} |
| Brand Signals | 10% | {N FAILs, M WARNs} | {summary} |

---

## Brand Identity Summary

**Primary Colors:** {list with hex/rgb values}
**Font Families:** {heading font, body font}
**Brand Personality:** {description — playful/serious/minimal/bold/etc.}
**Distinctive Elements:** {what makes this brand unique visually}

---

## Cross-Page Comparison Matrix

| Aspect | Homepage | Pricing | Blog | About | Contact | Status |
|--------|----------|---------|------|-------|---------|--------|
| Primary color | {color} | {color} | {color} | {color} | {color} | OK/WARN |
| Heading font | {font} | {font} | {font} | {font} | {font} | OK/WARN |
| Body font | {font} | {font} | {font} | {font} | {font} | OK/WARN |
| Button style | {desc} | {desc} | {desc} | {desc} | {desc} | OK/WARN |
| Header | {same?} | {same?} | {same?} | {same?} | {same?} | OK/WARN |
| Footer | {same?} | {same?} | {same?} | {same?} | {same?} | OK/WARN |
| Tone | {desc} | {desc} | {desc} | {desc} | {desc} | OK/WARN |
| Imagery | {desc} | {desc} | {desc} | {desc} | {desc} | OK/WARN |

---

## Detailed Color Analysis

### Color Palette (aggregated across all pages)
| Color | Usage | Pages Present | Consistent? |
|-------|-------|---------------|-------------|
| {hex} | Primary background | All | Yes |
| {hex} | CTA buttons | Homepage, Pricing | WARN: Missing on Blog |
| ... | ... | ... | ... |

### Inconsistencies Found
{detailed description of each color inconsistency}

---

## Detailed Typography Analysis

### Type System (aggregated)
| Level | Font | Size | Weight | Consistent? |
|-------|------|------|--------|-------------|
| H1 | {font} | {size} | {weight} | {Yes/WARN + details} |
| H2 | {font} | {size} | {weight} | {Yes/WARN + details} |
| H3 | {font} | {size} | {weight} | {Yes/WARN + details} |
| Body | {font} | {size} | {weight} | {Yes/WARN + details} |

### Inconsistencies Found
{detailed description of each typography inconsistency}

---

## Component Consistency Audit

### Buttons
| Variant | Pages | Style Match? | Notes |
|---------|-------|--------------|-------|
| Primary CTA | All | {Yes/WARN} | {details} |
| Secondary | Homepage, About | {Yes/WARN} | {details} |
| Ghost/Outline | Pricing | N/A | {details} |

### Cards
{same analysis}

### Inputs
{same analysis}

---

## Page-by-Page Results

### {Page URL}
- **Color match:** {matches brand palette: Yes/deviations noted}
- **Typography match:** {matches type system: Yes/deviations noted}
- **Component match:** {standard components used correctly: Yes/issues}
- **Tone match:** {matches overall voice: Yes/shift noted}
- **Imagery:** {matches style: Yes/different treatment}
- **Issues:** {list}

{repeat for EVERY page}

---

## Findings

{Each finding uses the FULL finding template from SKILL.md}

### Finding #1: {title}
{...complete template with all sections...}

---

## Recommendations Summary

### Critical (brand fragmentation visible to users)
1. ...

### High Priority (noticeable inconsistencies)
1. ...

### Medium Priority (subtle differences)
1. ...

### Brand Enhancement Opportunities
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

- All report content in Russian. Technical terms (CTA, UI, UX, brand identity) in English.
- Every finding must use the FULL finding template provided in SKILL.md — all sections filled.
- Reference screenshots from `{run_dir}/screenshots/` as evidence. Screenshots are ESPECIALLY important for this module — every visual inconsistency needs photographic evidence.
- Do not inspect source code. Evaluate only cached screenshots and snapshots.
- Do not call any `browser_*` tools. All data comes from `{run_dir}/snapshots/`, `{run_dir}/screenshots/`, and `{run_dir}/discovery.json`.
- Do not visit external websites or compare to competitors. Only analyze the target site's internal consistency.
- Compare EVERY page against EVERY other page. The whole point of this module is cross-page comparison.
- Pay special attention to pages that look like they were built at different times or by different people — these are where inconsistencies hide.
- Analyze both desktop and mobile screenshots to catch responsive inconsistencies.
- Note limitations of cache-based analysis (hover effects, transitions) in the report where applicable.
