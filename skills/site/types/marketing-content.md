# Audit Module: Marketing Content

**Browser access:** No. This is a Tier A (cache-based) module.
Analyze marketing copy quality from cached data only:
- `{run_dir}/snapshots/*.txt` — accessibility tree text for each page
- `{run_dir}/screenshots/*.png` — visual evidence
- `{run_dir}/discovery.json` — page inventory
- `{run_dir}/sitemap.md` — full site structure

Do NOT call any cmux browser tools. Do NOT reference cmux browser.

> **Foundational Principle:** This module's checks are concrete applications of the Human-First Evaluation Principle. Copy and content are evaluated through the lens of: does the text speak to the visitor's need in their language, at their depth, matching their emotional state — or does it speak about the creator's product in the creator's terms? Technical checks that PASS but violate the principle are still findings. See SKILL.md "FOUNDATIONAL PRINCIPLE" section.

**Toolkit Approach:** The checks below are a toolkit of common patterns, not a mandatory checklist. For each page: (1) Read the page's `purpose`, `visitor`, `key_question` from discovery.json. (2) Select which checks are RELEVANT to this page. (3) Irrelevant checks → "N/A for this page." (4) Unknown elements → apply Foundational Principle directly, tag as `[Unknown Element]`. (5) Numeric thresholds are default indicators — override with explicit principle-based reasoning if needed.

**Heartbeat Protocol (MANDATORY):**
- `[HB1]` Before EACH page: visitor mind (5sec first impression), who/what/emotion, entry paths, complexity level
- `[HB2]` After checks per page: 5 layers + meta review, design intent check, screenshot reliability, ~15-20% override expected
- `[HB3]` Every 5th finding: specificity check, diversity check, plain language, confidence tags, positive findings ratio
- `[HB4]` Before score: "what did I miss?", pattern consolidation, depth>breadth, cross-module notes, effort scaling
These `[HB]` markers MUST appear in report. Report without them is incomplete.

## Prerequisites

- Discovery phase complete: `{run_dir}/discovery.json` and `{run_dir}/sitemap.md` exist
- Snapshots collected: `{run_dir}/snapshots/` contains `.txt` files (accessibility trees) for every crawled page
- Screenshots collected: `{run_dir}/screenshots/` contains `.png` files for visual reference
- Run directory: `{run_dir}` (passed by Lead)
- Site URL: `{site_url}` (passed by Lead)
- Business type: `{business_type}` (passed by Lead)

---

## Instructions

You are the Marketing Content auditor for `{site_url}`. Your job is to evaluate whether the site's copy persuades, builds trust, and drives action — purely from cached snapshots and screenshots.

Analyze EVERY page listed in the sitemap. Do not skip pages. Do not economize on thoroughness.

Work through each evaluation dimension below. For each check, record your finding using the finding template defined in the main SKILL.md.

### Data Sources

For every evaluation below, use these sources:

- **Text analysis:** Read `{run_dir}/snapshots/{page}.txt` — the accessibility tree captures all visible text, headings, buttons, links, form labels, and ARIA content.
- **Visual evidence:** Reference `{run_dir}/screenshots/{page}.png` for layout context (above/below fold, proximity of elements).
- **Page inventory:** Read `{run_dir}/discovery.json` and `{run_dir}/sitemap.md` to identify which pages exist and their roles.

### Ownership Boundaries

This module evaluates **copy quality** — the words, not the structure or placement.

Deferred to other modules:
- **Readability metrics** (Flesch-Kincaid, reading grade level) → SEO Content module
- **CTA placement, above-fold presence, CTA count per viewport** → Conversion module
- **Heading hierarchy** (H1 count, H1-H6 nesting order) → SEO Technical module

See the respective module reports for those evaluations.

---

### Business Type Examples (calibration, not rules)

Example for government-type pages:
- Typically less relevant: value proposition (it's government — the "value" is public service), power words, urgency, social proof, objection handling
- Adapt: evaluate INFORMATION COMPLETENESS instead of persuasion:
  - Are service descriptions complete (steps, documents, timelines, costs)?
  - Is contact information for each service/department provided?
  - Are legal references (laws, regulations) cited where relevant?
  - Is the content written in plain language (not bureaucratic jargon)?
- Do NOT flag formal government language as "passive" or "not customer-focused"

These are EXAMPLES to calibrate judgment. The agent decides based on each page's actual purpose, not the site label.

Example for portfolio/creative pages:
- Adapt: evaluate case study STORYTELLING instead of conversion copy:
  - Does each case study explain the challenge, process, and result?
  - Is the writing engaging and appropriate for the creative industry?
  - Do project descriptions highlight client impact?

These are EXAMPLES to calibrate judgment. The agent decides based on each page's actual purpose, not the site label.

Example for marketplace/classifieds/platform pages:
- Value proposition is PLATFORM VALUE, not product value: "largest selection," "trusted sellers,"
  "fast delivery," "buyer protection" — not a traditional hero heading with benefit statement
- Do NOT FAIL for "generic value proposition" if the platform's VP is implicit (market leader position)
- Social proof = seller count, listing count, transaction volume, ratings system — not testimonials
- CTA = "Search," "Browse," "Find" — not "Get Started" or "Sign Up"
- Body copy evaluation applies to EDITORIAL pages (blog, guides), not to listing/search/category pages
*These are examples. Decide based on each page's actual content type.*

---

## Evaluation Dimensions

### 1. Value Proposition

**Source:** Homepage snapshot (`{run_dir}/snapshots/homepage.txt` or equivalent).

**What to check:**

Identify the hero section — typically the first heading + subheading block in the snapshot.

- **FAIL** if a first-time visitor cannot understand what the product does from the hero heading + subheading alone (the "5-second test" — is it clear what the product is and who it's for?)
- **FAIL** if the value proposition is generic. Automatic FAIL examples: "We help businesses grow", "Solutions for your needs", "The platform for teams", "Better, faster, smarter", "Innovative solutions for modern challenges"
- **WARN** if the value proposition states a feature rather than a benefit or pain point. Example: "Cloud-based project management" is a feature; "Never miss a deadline again" is a benefit
- PASS if the value proposition is specific and outcome-oriented. Examples: "Cut deployment time by 80%", "Automate your invoicing in 10 minutes", "Ship code 3x faster with zero config"

**Threshold:** Value prop must be specific AND benefit-oriented to pass.

---

### 2. Headline Copy Quality

**Source:** All page snapshots — extract heading elements (H1, H2) from accessibility tree text.

**What to check:**

Evaluate headline **copy effectiveness**, not structural correctness (H1 count, nesting — that is SEO Technical's domain).

- **FAIL** if the homepage H1 is generic or describes a feature rather than a benefit. Feature headline: "Automated Invoicing" → benefit equivalent: "Stop Chasing Payments"
- **WARN** if any headline exceeds 15 words. Ideal headline range: 6-12 words.
- **WARN** if zero power words found across all H1/H2 on the homepage.

**Power words (language-aware):**
- English: free, new, proven, guaranteed, instant, effortless, exclusive, limited, now, today, finally, discover, unlock, transform, stop, never, always
- Russian: free, new, proven, guaranteed, instantly, effortlessly, exclusively, limited, now, today, finally, discover, get, learn, risk-free, tested

Use the appropriate list based on site language (from discovery.json lang field).
- **WARN** if H2s on landing pages are purely section labels ("Features", "Pricing", "How It Works") rather than mini-value propositions ("Everything you need to ship faster", "Pricing that scales with you"). Section labels are missed persuasion opportunities.

Note: H1 presence/absence and heading hierarchy are evaluated by the SEO Technical module.

---

### 3. CTA Copy Quality

**Source:** All page snapshots — identify button labels, link CTAs from accessibility tree.

**What to check:**

Evaluate CTA **text quality**, not placement or count (that is Conversion's domain).

- **FAIL** if any primary CTA uses "Submit", "Click here", or "Continue" with no context. Exception: For form submit buttons specifically, see Conversion report. This module evaluates CTA copy on non-form buttons (hero CTAs, nav CTAs, banner CTAs).
- **FAIL** if primary CTA is passive — missing an action verb and/or missing what the user receives. Strong CTA: "Get started free", "Download the guide", "Start my trial", "Book a demo"
- **WARN** if primary CTA is action-only with no value indication. "Sign up" is weaker than "Sign up free"; "Get started" is weaker than "Get started — no credit card"
- **WARN** if "Learn more" is used as a primary CTA (acceptable on secondary CTAs)
- **WARN** if urgency or social proof copy is completely absent near primary CTAs on pricing or signup pages. Examples of good supporting copy: "Join 12,000+ teams", "Free for 14 days", "No credit card required"
- **WARN** if CTA copy is inconsistent across the site — same action uses different labels without contextual reason (e.g., "Start free trial" in hero, "Sign up" in header, "Register" in footer)

---

### 4. Body Copy

**Source:** Homepage and key page snapshots — read body text paragraphs.

**What to check:**

See SEO Content report for readability metrics (Flesch-Kincaid, grade level).

**Customer focus — "you/your" vs "we/our" ratio:**
- Count approximate occurrences of "you/your/yours" vs "we/our/us" in homepage body copy
- Target: "you/your" should appear at minimum 2x more frequently than "we/our"
- **WARN** if the ratio is inverted (more "we" than "you") — indicates company-centric rather than customer-centric copy

**Language-aware pronoun check:**
- English: count "you/your/you're" vs "we/our/we're"
- Russian: count "you/your/to you/of you" vs "we/our/to us/of us" (formal) OR "you/your/to you/of you" vs "we/our" (informal)
Target ratio: >2:1 customer-focused in both languages.

**Voice:**
- Scan for passive voice patterns ("is/are/was/were + past participle")
- **WARN** if passive voice dominates body copy (more passive than active sentences)

**Paragraph length:**
- **WARN** if any paragraph exceeds 5 sentences or appears as a wall of text with no visual break

**Sentence complexity:**
- **WARN** if sentences are consistently long (estimate average >20 words per sentence from visible paragraphs)

---

### 5. Social Proof

**Source:** All page snapshots — search for testimonials, logos, ratings, stats, case study references.

**What to check:**

- **WARN** if the homepage has zero social proof elements of any kind (no testimonials, no logos, no stats, no reviews)
- **WARN** if all testimonials are generic with no specifics. Generic: "Great product! Highly recommend." — Specific: "Increased our revenue by 40% in 3 months" with named individual, title, company
- **WARN** if testimonials are anonymous ("— A happy customer") with no names, titles, companies, or photos
- **WARN** if social proof exists but is isolated far from any CTA or conversion element (check proximity in snapshots)

**Record:** Total count of social proof elements found (logos, testimonials, stats, reviews, case studies).

---

### 6. Trust Signals

**Source:** Snapshots of pages containing forms, payment elements, pricing. Also check footer across all pages.

**What to check:**

- **WARN** if any payment-related page has no visible trust signals (security badges, payment provider logos, money-back guarantee, SSL indicators)
- **WARN** if privacy policy link is absent from footer or from forms that collect personal data
- **WARN** if contact information requires more than 2 clicks to find from any page — check sitemap for contact/support pages and snapshot text for visible contact details
- **WARN** if About page is missing or contains only a mission statement with no real people, team info, or company narrative

---

### 7. Objection Handling

**Source:** All page snapshots + sitemap for FAQ and comparison page detection.

**What to check:**

- **WARN** if no FAQ section exists on the entire site (especially critical for SaaS, e-commerce, service businesses)
- **WARN** if FAQ exists but does not address common objections: pricing/cost, ease of setup, support quality, migration, cancellation policy. Record which are covered and which are missing.
- **WARN** if pricing CTA has no objection-handling copy nearby. Examples of good objection handling: "No credit card required", "Cancel anytime", "Free migration included", "30-day money-back guarantee"
- Note presence/absence of comparison pages (URL patterns: `/vs/`, `/compare/`, `/alternatives/` in sitemap) — relevant gap for SaaS if absent.

---

### 8. Microcopy

**Source:** Snapshots of pages containing forms, interactive elements.

**What to check:**

- **FAIL** if form inputs have no visible labels (only placeholder text, no persistent label)
- **WARN** if error messages are visible in the snapshot but non-actionable. Actionable: "Please enter a valid email like name@example.com". Non-actionable: "Invalid input", "Error".
- **WARN** if empty states are visible in the snapshot but show no helpful guidance. Good: "No results found. Try different keywords." Bad: "No results."
- **WARN** if placeholder text uses instructions ("Enter your email here") instead of examples ("e.g. john@example.com")

---

### 9. Content Completeness

**Source:** `{run_dir}/sitemap.md` + `{run_dir}/discovery.json` + relevant page snapshots.

**What to check:**

- **WARN** if About page does not exist in sitemap or exists but contains only a mission statement with no real people or narrative (check snapshot)
- **WARN** if Pricing page does not exist or exists but is incomplete — missing plan names, missing prices without explanation, missing what's included, or missing CTA (check snapshot)
- **WARN** if no clear contact method is accessible — no contact page, no support email, no chat widget findable in sitemap or footer snapshots
- **WARN** if page titles are generic placeholders ("Home", "Page", "Untitled") — check title elements in snapshots

---

### 10. Audience-Content Fit (Focus: 15% of audit effort)

**Purpose:** Evaluate whether each page's content matches what its PRIMARY audience needs, and whether content for secondary audiences is properly separated.

**This check applies to ALL business types.** Every page has a primary audience. Content should serve that audience FIRST.

#### Step 1: Identify Page Audience

For each page, determine the primary audience from context:

| Page Type | Primary Audience | They Want to Know |
|-----------|-----------------|-------------------|
| Homepage / Landing | Potential customer (broad) | "What is this? What's in it for me?" |
| Product / Feature | Decision maker | "How does this solve my problem? What results?" |
| Pricing | Budget holder | "How much? What do I get? Comparison?" |
| Case study / Portfolio | Potential client | "What problem did you solve? What was the result?" |
| Blog article | Searcher / Lead | "Answer to my question. Expertise proof." |
| Documentation / API | Developer | "How do I implement this? Code examples." |
| About / Team | Trust-seeker | "Who are these people? Can I trust them?" |
| /for-business (B2B) | Manager / HR / Procurement | "ROI, scale, integration, support, compliance" |
| Service page | Potential buyer | "What will you do for me? Timeline? Cost?" |
| Course / Program | Learner / Career changer | "What will I learn? What job will I get? Outcomes." |
| Government service | Citizen | "What do I need? Steps? Documents? Where to go?" |

Use `product-marketing-context.md` (from `{run_dir}/product-marketing-context.md`) if available for ICP/persona context.

#### Step 2: First Screen Audit (Above Fold)

For each key page (homepage + depth-1 nav pages + conversion pages), examine the first viewport from cached screenshot and snapshot:

**Check A — Heading Language:**
- Does the H1/main heading speak to the primary audience's concern?
- FAIL if a client-facing page leads with technical implementation ("Microservice Architecture in Go" on a case study page where clients want "Increased conversion by 40%")
- WARN if heading is neutral/generic (neither audience-specific nor wrong — just bland)

**Check B — First Paragraph Orientation:**
- Read the first 200 words from the snapshot
- Count: business/outcome words (result, increased, reduced, client, profit, efficiency, solution) vs technical/implementation words (API, framework, architecture, stack, integration, code, deploy, server)
- If technical words dominate on a business-audience page: WARN
- If business words dominate on a developer-audience page (docs/API): also WARN (wrong direction)

**Check C — Jargon Density in First Screen:**
- Estimate percentage of domain-specific jargon in the first 200 words
- On pages for broad audience (homepage, landing, case study): WARN if >15% jargon without explanation
- On pages for specialist audience (docs, API, developer blog): jargon is expected, no penalty

#### Step 3: Content Separation Assessment

For pages that contain content for MULTIPLE audiences (common: case studies with both business results and technical details):

**Check D — Separation Pattern:**
Examine the page structure from snapshot and scroll screenshots:

Good separation patterns (no penalty):
- Tabs: "Overview" / "Technical Details" / "Results"
- Accordion/expandable: business visible, technical collapsed
- Progressive disclosure: summary above fold, details below with clear heading
- Separate sections with distinct headings: "Business Result" then "Technical Implementation"
- "Read more" / "Learn more" toggle

Bad patterns:
- WARN: Monolithic text mixing business and technical content in the same paragraphs
- WARN: Technical details ABOVE business results in scroll order (wrong priority)
- WARN: Single long block with no visual separation between audience-specific content
- FAIL: Key conversion page (case study, service) has zero business-outcome content in the first 2 screens — entirely technical/process description

**Check E — Default State for Multi-Audience Content:**
If tabs/accordion exist:
- WARN if the default open tab shows secondary audience content (e.g., "Technical" tab is default instead of "Overview")
- The default visible state should serve the primary audience

#### Step 4: Specific Recommendations

Every finding MUST include a concrete restructuring suggestion:

Examples of specific recommendations (adapt to actual content found):
- "Move the 'Results' block (currently 3rd screen, after technical description) → first visible block after the H1 heading"
- "Tech stack (React, PostgreSQL, Docker — currently 2nd paragraph of body text) → extract into a collapsible 'Technical Details' block after the business description"
- "Add tabs: 'What We Did' (business result, active by default) / 'How We Did It' (technical process)"
- "Rewrite the first paragraph from 'We used React and Node.js to build...' to 'The client got a system that handles 10,000 orders/day — 3x more than before'"
- "Product specifications (weight, dimensions, materials — currently the first block) → move after the benefits and testimonials block"

**FAIL conditions:**
- Key conversion page (homepage hero, case study, service page, product page) leads entirely with content for the wrong audience in the first viewport — primary audience must scroll past irrelevant content to find value
- Portfolio/case study page has zero mention of business outcome/result — only technical process

**WARN conditions:**
- Content serves the right audience but mixes audiences without structural separation
- Tabs/accordion exist but default state shows secondary audience content
- Jargon density >15% in first 200 words on broad-audience pages
- Business results are present but buried below 2+ screens of technical/process content

**Not a finding:**
- Documentation/API pages that are entirely technical — that IS the audience
- Blog posts that are technical by intent (dev blog, engineering blog)
- Pages where business and technical content are properly separated with clear headings

---

## Scoring

Follows the Unified Scoring System from SKILL.md.

Start at **100**. Deduct per finding:
- **FAIL** = -15 points
- **WARN** = -5 points

Minimum score: **0**. No negative scores.

Only two severity levels: **FAIL** and **WARN**. No "NOTE" severity.

### Score Anchoring

| Score | Grade | Criteria |
|-------|-------|----------|
| 85-100 | A | Compelling copy. Persuasive, specific, drives action. Value prop clear. CTAs strong. Social proof abundant and specific. Objections handled proactively. Content serves the right audience on every page. |
| 70-84 | B | Clear and professional. Minor gaps: one or two weak CTAs, some generic testimonials, or incomplete FAQ. Value prop present but could be sharper. Audience targeting mostly correct with minor separation issues. |
| 55-69 | C | Functional but generic. Copy gets the point across but misses conversion opportunities. Value prop vague. CTAs standard. Social proof minimal. Some pages mix audience content without clear separation. |
| 40-54 | D | Weak copy. Value prop unclear or buried. Multiple generic CTAs. No meaningful social proof. Company-centric body copy. Key pages lead with wrong-audience content. |
| 0-39 | F | Critically deficient. Cannot understand what the product does. No clear CTAs. No social proof. No trust signals. Placeholder-quality language. Conversion pages entirely misaligned with primary audience. |

A score of 90+ requires specific evidence of strength in every dimension. Do not award it generously.

---

## Report Structure

Write `{run_dir}/marketing-content-report.md` with this structure:

```markdown
# Marketing Content Audit Report

**Site:** {site_url}
**Business Type:** {business_type}
**Date:** {date}

---

## Executive Summary

Score: {N}/100 (Grade: {A|B|C|D|F})

{2-3 sentence overview of copy quality: strongest area, weakest area, overall impression.}

---

## Score Breakdown

> Per-dimension status reflects the highest-severity finding in that dimension.

| Dimension | Status | Summary |
|-----------|--------|---------|
| Value Proposition | PASS / FAIL / WARN | {one-line} |
| Headline Copy Quality | PASS / FAIL / WARN | {one-line} |
| CTA Copy Quality | PASS / FAIL / WARN | {one-line} |
| Body Copy | PASS / FAIL / WARN | {one-line} |
| Social Proof | PASS / FAIL / WARN | {one-line} |
| Trust Signals | PASS / FAIL / WARN | {one-line} |
| Objection Handling | PASS / FAIL / WARN | {one-line} |
| Microcopy | PASS / FAIL / WARN | {one-line} |
| Content Completeness | PASS / FAIL / WARN | {one-line} |
| Audience-Content Fit | PASS / FAIL / WARN | {one-line} |

---

## Findings

### FAIL Findings

{All FAIL-level findings using the finding template from SKILL.md}

### WARN Findings

{All WARN-level findings using the finding template from SKILL.md}

---

## Limitations

Deferred to other modules:
- Readability metrics (Flesch-Kincaid, grade level) → See SEO Content report for readability metrics.
- CTA placement, above-fold presence, CTA hierarchy → See Conversion report.
- Heading structure (H1 count, nesting) → See SEO Technical report.

---

## Positive Highlights

{What the site does well from a marketing content perspective. Minimum 2-3 specific items with evidence.}

---

## Priority Recommendations

1. {Most impactful fix — one sentence}
2. {Second most impactful}
3. {Third}
{Continue for all FAIL findings and high-impact WARNs}

---

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

## Rules

1. **No browser tools.** All analysis from cached snapshots, screenshots, discovery.json, and sitemap.md. Zero `browser_*` calls.
2. **Quote actual copy.** When flagging a problem, always include the exact current text as evidence from the snapshot.
3. **Provide exact replacement copy.** Every copy-related finding must include the specific rewrite, not a description of what the rewrite should achieve.
4. **Analyze every page.** Do not limit to homepage. Check About, Pricing, Features, Contact, and all pages in the sitemap.
5. **Only FAIL and WARN.** No "NOTE" severity. Positive observations go in "Positive Highlights" section.
6. **Be conservative with FAILs.** A FAIL is reserved for clear threshold violations as defined above. Preference or taste differences are WARNs.
7. **Finding template from SKILL.md.** Every finding MUST use the finding template defined in the main SKILL.md. Do NOT use any other template format.
8. **Score must reflect reality.** Score anchoring is mandatory — verify your score against the anchoring table before finalizing.
