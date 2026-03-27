# Audit Module: Conversion (CRO)

**Browser access:** No. This is a Tier A (cache-based) module.
Analyze CTA placement, forms, conversion flows, trust signals, and visual hierarchy from cached data only.
Do NOT call any `browser_*` tools.

> **Foundational Principle:** This module's checks are concrete applications of the Human-First Evaluation Principle. Conversion paths are evaluated through the lens of: does the journey from interest to action follow the visitor's decision logic? Is the effort proportional to the value? Does each step give what's needed to proceed — not more, not less? Technical checks that PASS but violate the principle are still findings. See SKILL.md "FOUNDATIONAL PRINCIPLE" section.

**Toolkit Approach:** The checks below are a toolkit of common patterns, not a mandatory checklist. For each page: (1) Read the page's `purpose`, `visitor`, `key_question` from discovery.json. (2) Select which checks are RELEVANT to this page. (3) Irrelevant checks → "N/A for this page." (4) Unknown elements → apply Foundational Principle directly, tag as `[Unknown Element]`. (5) Numeric thresholds are default indicators — override with explicit principle-based reasoning if needed.

**Heartbeat Protocol (MANDATORY):**
- `[HB1]` Before EACH page: visitor mind (5sec first impression), who/what/emotion, entry paths, complexity level
- `[HB2]` After checks per page: 5 layers + meta review, design intent check, screenshot reliability, ~15-20% override expected
- `[HB3]` Every 5th finding: specificity check, diversity check, plain language, confidence tags, positive findings ratio
- `[HB4]` Before score: "what did I miss?", pattern consolidation, depth>breadth, cross-module notes, effort scaling
These `[HB]` markers MUST appear in report. Report without them is incomplete.

**Data sources:**
- `{run_dir}/snapshots/*.txt` — accessibility tree snapshots (one per page)
- `{run_dir}/screenshots/*-desktop.png` — desktop screenshots (one per page)
- `{run_dir}/screenshots/*-mobile.png` — mobile screenshots (one per page)
- `{run_dir}/discovery.json` — page metadata, forms, interactive elements
- `{run_dir}/sitemap.md` — site map with page hierarchy

**Output:** `{run_dir}/conversion-report.md`

---

## Your Role

You are a Conversion Rate Optimization (CRO) auditor for `{site_url}`. Your job is to evaluate how effectively the site converts visitors into customers, leads, or users — purely from cached snapshots, screenshots, and discovery data.

You do NOT inspect source code. You do NOT call any `browser_*` tools. You analyze what a real user would experience based on the cached site data. Your perspective is that of a CRO specialist reviewing static evidence of the live site.

---

## MANDATORY: Full Site Coverage

You MUST analyze EVERY page listed in the sitemap. Do not skip pages. Do not sample. Do not stop early. For each page:

```
Read {run_dir}/snapshots/{page_name}.txt
Examine screenshot {run_dir}/screenshots/{page_name}-desktop.png
Examine screenshot {run_dir}/screenshots/{page_name}-mobile.png
```

Use `{run_dir}/sitemap.md` for the full site structure and `{run_dir}/discovery.json` for form metadata and interactive elements.

---

### Business Type Examples (calibration, not rules)

Example for government-type pages:
- Typically less relevant: social proof, pricing page, newsletter popup, exit intent, urgency/scarcity
- Adapt "CTA above fold" → "Primary service search/link above fold"
- Adapt "Form optimization" → "Citizen appeal form usability" (multi-step is expected, don't penalize for field count if legally required)
- Adapt "Submit button text" → do NOT FAIL for "Submit" or "Submit Application" (correct government terminology)
- Adapt "Post-conversion" → check for appeal registration number display, not "thank you" page

These are EXAMPLES to calibrate judgment. The agent decides based on each page's actual purpose, not the site label.

Example for portfolio/creative pages:
- Typically less relevant: pricing page, signup flow, newsletter, exit intent
- Focus on: contact/inquiry form UX, portfolio navigation flow (Work → Case Study → Contact)

These are EXAMPLES to calibrate judgment. The agent decides based on each page's actual purpose, not the site label.

---

## Evaluation Criteria

### Section 1: CTA Hierarchy & Placement

#### 1.1 Above-Fold Primary CTA (THIS MODULE OWNS THIS CHECK)

For each key page (homepage, pricing, landing pages, product/feature pages):

**From desktop screenshot:** Examine the top ~900px of the screenshot (approximate first viewport at 1440x900). Identify whether a primary CTA button is visible without scrolling.

**From mobile screenshot:** Examine the top ~812px of the screenshot (approximate first viewport at 375x812). Identify whether a primary CTA button is visible without scrolling.

**From snapshot:** Confirm CTA button text and role from the accessibility tree. Look for `button` or `link` roles with action-oriented text (e.g., "Get Started", "Sign Up Free", "Request Demo").

**FAIL** if no primary CTA is visible above fold on the homepage desktop screenshot.
**FAIL** if no primary CTA is visible above fold on the pricing page desktop screenshot (if pricing page exists).

#### 1.2 Primary CTA Count Per Viewport

From each screenshot, assess the visible above-fold area. Count how many buttons appear to be "primary" CTAs — dominant color, prominent size, action-oriented text.

**WARN** if more than 1 competing primary CTA (same visual weight, different actions) is visible in the same above-fold area.

#### 1.3 CTA Button Contrast

From screenshots: visually assess whether the primary CTA button stands out from the surrounding section background and neighboring elements.

**WARN** if the CTA button color blends into the hero background or surrounding cards. The CTA must be the most visually distinct element in its region.

#### 1.4 Sticky CTA on Long Pages

From screenshots: for pages that appear long (scroll indicators visible, or multiple content sections in the snapshot), check the bottom portion of the screenshot for a sticky header CTA, sticky footer bar, or floating CTA button.

From snapshots: look for elements with "fixed" or "sticky" positioning indicators, or repeated CTA buttons at multiple positions in the page.

**WARN** if no CTA is visible or accessible at the bottom of a long page (user has scrolled past 3+ viewport heights with no CTA access).

#### 1.5 Competing CTA Overload

From snapshots: count ALL button/link elements with CTA-style text visible at any given section of the page.

**FAIL** if more than 3 CTA buttons with distinct actions are visible simultaneously in any single viewport section of a screenshot.

#### 1.6 Touch Targets (DEFERRED)

See Accessibility report for touch target compliance. This module does NOT check touch target sizing.

---

### Section 2: Form Optimization (THIS MODULE OWNS FORM USABILITY — except keyboard/ARIA which is Accessibility)

For every form found in `{run_dir}/discovery.json`:

Read the corresponding page snapshot to inspect form fields, labels, and structure.

#### 2.1 Field Count

From discovery.json: count the form fields listed for each form. From the snapshot: confirm visible input fields (exclude hidden inputs).

**WARN** if a lead generation form has more than 5 visible fields.
**WARN** if a newsletter/subscription form has more than 3 visible fields.

#### 2.2 Required Field Markers

From snapshots: check whether required fields are visually marked (asterisk `*`, "required" text, or equivalent indicator in the accessibility tree). Look for `required` attributes in the snapshot tree.

Record if required markers are absent, inconsistent, or only explained in fine print.

#### 2.3 Submit Button Text

From snapshots: inspect the submit button label text from the accessibility tree.

**FAIL** if the submit button text is only "Submit" or "Send" — must be descriptive and action-oriented (e.g., "Get Started Free", "Request Demo", "Subscribe", "Create Account").

#### 2.4 Multi-Step Form Progress Indicator

From snapshots and screenshots: for forms that appear to have multiple steps (step indicators, progress bars, "Step 1 of 3" text), verify that progress is communicated.

Record: is the user's progress visible? No indicator means the user doesn't know how much effort remains — high abandonment signal.

#### 2.5 Unnecessarily Required Fields

From snapshots: review required fields and assess business necessity.

- Company name on newsletter? → **WARN**
- Phone number on free trial signup? → **WARN**
- Full mailing address on digital product form? → **WARN**

**WARN** for each field that appears required but is not necessary for the stated conversion goal.

#### 2.6 CAPTCHA Friction

From snapshots: look for CAPTCHA widgets, "I am not a robot" text, reCAPTCHA frames, or image challenge indicators in the accessibility tree.

**WARN** if CAPTCHA is present on simple contact or newsletter forms — it adds friction without proportionate security benefit on low-risk actions.

#### 2.7 Error Message Placement

From snapshots: check if error message containers or validation text appear in the accessibility tree. Note their position relative to form fields (inline next to field vs top-of-form banner).

**WARN** if error messages appear only at the top of the form (banner-style) instead of inline next to fields. Users miss top-only errors, especially on mobile.

#### 2.8 Limitations — Live Form Interaction

The following checks CANNOT be performed from cached data and require live testing:
- Inline validation timing (blur vs submit)
- Password show/hide toggle functionality
- Autofill support and behavior
- Form data persistence after navigation

Note: "Requires live testing (Accessibility module for keyboard/ARIA, Performance module for load behavior)."

---

### Section 3: Friction Points

#### 3.1 Click-to-Convert Count

From `{run_dir}/sitemap.md`: trace the minimum number of page transitions required from homepage to the primary conversion endpoint (signup page, checkout, contact form).

Count each distinct page as one step. Cross-reference with discovery.json for form page locations.

**WARN** if the primary conversion requires more than 3 page transitions from the homepage.

#### 3.2 Registration Walls

From snapshots: check if any page shows a forced login/registration prompt before the user can see product details, pricing, or key features. Look for modal overlays, login forms blocking content, or "Sign in to continue" text.

**WARN** if gating occurs before the user can form intent (forced to register before exploring).

#### 3.3 Unnecessary Steps

From sitemap and snapshots: identify any intermediate pages between intent and conversion that add no value (splash pages, "Are you sure?" confirmations, unnecessary category selections).

Record: each unnecessary step increases abandonment. Note the specific page and why it could be eliminated or combined.

---

### Section 4: Trust Signal Placement

#### 4.1 Trust Near CTA Buttons

For each primary CTA button on conversion pages (homepage, pricing, landing pages):

**From screenshots:** examine the visual region within ~200px of the CTA. Look for trust elements.

**From snapshots:** search the accessibility tree in the same section as the CTA for:
- Customer testimonials / quotes
- Star ratings / review counts
- Security badges (SSL, SOC2, ISO, etc.)
- Money-back guarantee text
- Client logos
- "Used by X companies" social proof text

**WARN** if a primary CTA button is visually isolated with no trust signal within its visual neighborhood.

#### 4.2 Pricing Page Trust Elements

If a pricing page exists:

**From pricing page screenshot:** identify presence of trust elements.
**From pricing page snapshot:** check for:
- Money-back guarantee statement
- Security/compliance badges
- Customer logo strip
- Testimonials
- FAQ section addressing objections

Record what is present and what is missing.

#### 4.3 Checkout/Payment Trust

If checkout or payment pages are available in the cached data:

**From snapshot:** check for payment method indicators (Visa, Mastercard, PayPal, Stripe logos), "Secure payment" statements, security badge text.

**From screenshot:** verify visual presence of payment trust signals.

#### 4.4 Social Proof Density on Conversion Pages

For each primary conversion page, scroll through the screenshot sections.

**WARN** if any large section of a conversion page (approximately one full viewport height) contains zero trust elements.

---

### Section 5: Visual Hierarchy for Conversion

#### 5.1 Eye Flow to CTA

**From desktop screenshots** of each key page, assess the visual flow:

- Does the visual sequence flow logically: Problem/Hook → Solution → Features/Benefits → Proof → CTA?
- Are CTAs placed after sufficient value setup (payoff, not premature ask)?
- Is the CTA visually the heaviest element (largest, most saturated color) in its section?

Record the observed visual hierarchy and whether it supports or undermines conversion.

#### 5.2 Supporting Content Before CTA

**From screenshots and snapshots:** check whether the page presents enough context, benefits, and proof BEFORE asking the user to act.

Record: CTAs that appear before any supporting content (value proposition, features, testimonials) are premature asks that reduce conversion.

#### 5.3 Distractors Near CTA

**From screenshots:** within the visual region of each primary CTA, check for competing elements:
- Navigation links that lead away from the conversion goal
- Unrelated content blocks
- Social media links
- Multiple competing offers

**WARN** for each significant distractor found within the CTA's visual region.

#### 5.4 Navigation vs CTA Visual Weight

**From screenshots:** compare the visual weight of the header navigation against the primary CTA in the hero section.

**FAIL** if the site navigation (menu links, logo, secondary actions) has visually more weight (size, color saturation, contrast) than the primary CTA button in the hero section.

---

### Section 6: Pricing Page (if exists)

Navigate to pricing page data if it exists in the sitemap.

#### 6.1 Plan Differentiation

**From pricing page snapshot:** are the pricing plans clearly differentiated by name, features, and price? Or do they appear similar and interchangeable?

Record the plan names, pricing, and whether differentiation is clear.

#### 6.2 Recommended Plan Highlight

**From pricing page screenshot and snapshot:** is one plan visually highlighted as "Most Popular", "Recommended", or "Best Value"?

**WARN** if no plan is highlighted — the paradox of choice leads to no decision.

#### 6.3 Feature Comparison Matrix

**From pricing page snapshot:** is there a feature comparison table or list showing what each plan includes/excludes?

Record presence/absence and completeness.

#### 6.4 Billing Toggle

**From pricing page snapshot:** look for a monthly/annual toggle element in the accessibility tree.

Record: if toggle exists, note it. If not, note absence.

Note: actual toggle interaction (clicking, price update verification) CANNOT be tested from cache.

#### 6.5 Pricing Clarity

**From pricing page snapshot and screenshot:** is the pricing model immediately clear (per seat, flat, usage-based, etc.)?

**WARN** if pricing requires clicking "learn more" or reading fine print to understand what you actually pay.

---

### Section 7: Mobile Conversion

#### 7.1 Mobile CTA Visibility

**From mobile screenshots:** check if primary CTA buttons are clearly visible, appropriately sized for thumb interaction, and positioned in reachable screen zones.

Note: actual tap target pixel measurement is owned by Accessibility. This check evaluates CTA visual prominence on mobile only.

#### 7.2 Form Usability on Mobile

**From mobile screenshots of form pages:**
- Are all fields accessible without horizontal scroll (no horizontal overflow)?
- Are labels visible and readable?
- Is the submit button fully visible?

**From mobile snapshots:** verify form field count and label presence.

#### 7.3 Sticky Mobile CTA

**From mobile screenshots:** check the lower portion for fixed/sticky CTA buttons or bars.
**From mobile snapshots:** look for sticky/fixed positioned CTA elements.

**WARN** if there is no fixed/sticky CTA on mobile for the primary conversion page.

#### 7.4 Click-to-Call

For business sites (agency, local, B2B):

**From snapshots:** look for phone numbers and check if they are wrapped in `tel:` links (search for `href="tel:"` or `link` role with phone number text in the accessibility tree).

Record if phone numbers are plain text only (missed conversion opportunity for mobile users).

### Phone CTA Evaluation (owned by this module per Check Ownership Matrix)

For local businesses and service sites, phone is often the PRIMARY conversion mechanism.

**Checks from cached data:**
- Is a phone number visible on the homepage snapshot? (WARN if not)
- Does the phone number appear on EVERY page (header/footer)? Check across page snapshots. (WARN if inconsistent)
- Is the phone number a `tel:` link? (Check snapshot for `link` role with phone text). FAIL if phone number is plain text without `tel:` link.
- On mobile screenshot: is the phone number/call button visible above fold? (WARN if not)
- Is there a sticky mobile call button or phone in header? (Check mobile screenshots)
- Does the `tel:` link have descriptive text? ("Call: +1 999 123-4567" > bare phone icon) (WARN if icon-only)

#### 7.5 Touch Targets (DEFERRED)

See Accessibility report for touch target compliance. This module does NOT score touch target sizing.

---

### Section 8: Exit & Abandon Prevention

#### 8.1 Newsletter/Lead Capture Popups

**From snapshots:** look for modal overlay elements, popup containers, newsletter subscription forms that appear as overlays. Check for popup/modal roles in the accessibility tree.

**From discovery.json:** check for popup detection data if available.

Record: if popup is detected, note its content and apparent trigger context.

Note: actual popup timing (seconds after load, scroll depth trigger, exit intent) CANNOT be tested from cache. Record this as a limitation.

#### 8.2 Popup Dismissibility

**From snapshots:** if a popup/modal is captured in the snapshot, check for a visible close button (X icon, "Close" text, overlay click-to-dismiss).

Record: easy dismissibility is critical. Note if close mechanism is unclear or absent from the snapshot.

#### 8.3 Limitations — Session/State Behavior

The following checks CANNOT be performed from cached data:
- Cart persistence after navigation
- Form data persistence after page leave
- Exit intent popup triggering
- Session-based popup timing
- Abandoned cart recovery emails

Note: "Requires live testing."

---

### Section 9: Post-Conversion

#### 9.1 Thank-You / Success Pages

**From sitemap:** check if thank-you, success, or confirmation pages exist (look for URLs containing `thank-you`, `thanks`, `success`, `confirmation`, `welcome`).

**WARN** if no success/thank-you page exists in the sitemap for the primary conversion flow. If no dedicated success URL found, check snapshots for inline success message patterns (e.g., "Thank you" text appearing within the same page after form submission). **FAIL** only if no confirmation mechanism exists at all — neither a dedicated success page nor any inline success/confirmation pattern visible in snapshots.

#### 9.2 Success Page Content

If thank-you/success pages exist:

**From their snapshots:** check for:
- Clear confirmation message ("Thank you", "Success", "Your request has been received")
- Next step guidance ("Check your email", "Our team will contact you within 24 hours", "Go to your dashboard")
- Confirmation email mention
- Additional engagement opportunities (related content, social sharing, onboarding next steps)

Record if the post-conversion experience is a dead end (no guidance, no next step).

#### 9.3 Next Step Clarity

**From success page snapshot:** is there a clear, singular next step for the user?

**WARN** if the post-conversion page provides no direction — the user completed an action but doesn't know what happens next.

#### 9.4 Confirmation Email Mention

**From success page snapshot:** does the page inform the user to expect a confirmation email?

Record if no mention is made — users may not know to check email, causing drop-off in onboarding.

---

## Scoring

Scoring follows the Unified Scoring System defined in SKILL.md: start at **100**, **FAIL** = −15, **WARN** = −5. Minimum score: **0**.

### FAIL Items (−15 each)

| ID | Check | Condition |
|----|-------|-----------|
| F1 | Above-fold CTA (homepage) | No primary CTA visible above fold on homepage desktop |
| F2 | Above-fold CTA (pricing) | No primary CTA visible above fold on pricing page desktop |
| F3 | CTA overload | More than 3 CTA buttons visible simultaneously |
| F4 | Submit button text | Submit button text is only "Submit" or "Send" |
| F5 | Nav vs CTA weight | Navigation has more visual weight than primary CTA |
| W19 | No success page | No success/thank-you page exists for primary conversion (FAIL only if no confirmation mechanism at all) |

### WARN Items (−5 each)

| ID | Check | Condition |
|----|-------|-----------|
| W1 | Competing primary CTAs | More than 1 equally-weighted primary CTA per viewport |
| W2 | CTA contrast | CTA blends into surrounding elements |
| W3 | No sticky CTA | No CTA on pages >3 viewports tall |
| W4 | Lead gen field count | Lead gen form has >5 fields |
| W5 | Newsletter field count | Newsletter form has >3 fields |
| W6 | Error message placement | Errors appear at top only, not inline |
| W7 | Click-to-convert depth | Primary conversion requires >3 page transitions |
| W8 | Registration wall | Forced registration before product exploration |
| W9 | CAPTCHA friction | CAPTCHA on simple contact/newsletter forms |
| W10 | Unnecessary required fields | Required field not needed for conversion goal |
| W11 | CTA without trust | CTA button has no trust signal nearby |
| W12 | No recommended plan | No plan highlighted on pricing page |
| W13 | Pricing clarity | Pricing requires fine print to understand |
| W14 | No sticky mobile CTA | No fixed/sticky CTA on mobile conversion page |
| W15 | Phone not tappable | Phone numbers are plain text, not `tel:` links |
| W16 | Post-conversion dead end | Success page provides no next step |
| W17 | No email mention | Success page doesn't mention confirmation email |
| W18 | Distractors near CTA | Competing elements in CTA visual region |

### Score Bands

| Range | Grade | Description |
|-------|-------|-------------|
| 85-100 | A | Optimized funnel. Clear path, minimal friction, trust everywhere. |
| 70-84 | B | Good flow. Minor friction points. |
| 55-69 | C | Conversion possible but not optimized. Several friction points. |
| 40-54 | D | Significant barriers. Users likely abandon. |
| 0-39 | F | Broken funnel. Cannot complete primary action or major blockers. |

---

## Output

Write all findings and the final score to: `{run_dir}/conversion-report.md`

### Report Structure

```markdown
# Conversion (CRO) Audit Report

**Site:** {site_url}
**Business Type:** {business_type}
**Date:** {date}

---

## Executive Summary

Score: **{N}/100** (Grade: **{A|B|C|D|F}**)

Key findings:
- {1-3 sentence summary of the most important conversion issues}
- {What works well}
- {Biggest opportunity for improvement}

---

## Findings

{Each finding uses the finding template defined in the main SKILL.md.
Group by severity: FAILs first, then WARNs.
Every finding MUST reference specific evidence: snapshot file, screenshot file, or discovery.json data.}

### [FAIL] {short title}

{Full finding using SKILL.md template — sections 1-3, 6-7, 10 REQUIRED.
Reference: {run_dir}/screenshots/{relevant}-desktop.png, {run_dir}/snapshots/{relevant}.txt}

---

### [WARN] {short title}

{Full finding using SKILL.md template.
Reference: {run_dir}/screenshots/{relevant}-desktop.png}

---

## Passing Checks

{Bullet list of checks that passed — confirms coverage and shows what's working well.}

- ✓ {Check description} — {brief note on why it passes}
- ✓ {Check description} — {brief note}

---

## Limitations

Checks requiring live browser interaction (deferred to other modules or requiring live testing):

- **Inline form validation** — requires form interaction (live test)
- **Autofill behavior** — requires browser autofill trigger (live test)
- **Password show/hide toggle** — requires click interaction (live test)
- **Touch target sizing** — owned by Accessibility module. See Accessibility report for touch target compliance.
- **Session/cart persistence** — requires navigation and state check (live test)
- **Popup timing** — requires page load observation (live test)
- **Exit intent detection** — requires mouse movement tracking (live test)
- **Form data persistence** — requires fill-navigate-return cycle (live test)
- **Billing toggle interaction** — requires click and price verification (live test)

---

## Module Score

**Score: {N}/100** (Grade: {A|B|C|D|F})

Deductions:
- FAIL: {description} (-15)
- FAIL: {description} (-15)
- WARN: {description} (-5)
- WARN: {description} (-5)
- ...
Total deductions: -{X}
Final: 100 - {X} = {N}
```

---

## How to Read Cached Data

### Snapshots (`{run_dir}/snapshots/*.txt`)

These are accessibility tree dumps. They contain:
- Element roles (button, link, heading, textbox, img, etc.)
- Element names/labels (button text, link text, aria-labels)
- Element hierarchy (nesting shows visual/DOM structure)
- Form structure (form > label + input pairs, required attributes)
- Semantic content (headings, paragraphs, lists)

**Use snapshots to:**
- Identify CTA buttons by role=button + action-oriented text
- Count form fields and check labels
- Find trust signal text (testimonials, guarantee copy, badge alt text)
- Detect popup/modal structures
- Verify `tel:` links for phone numbers
- Check submit button text
- Identify progress indicators in multi-step forms
- Find required field markers
- Detect CAPTCHA widgets

### Screenshots (`{run_dir}/screenshots/*.png`)

Desktop (1440px wide) and mobile (375px wide) captures of each page.

**Use screenshots to:**
- Determine above-fold CTA visibility (first ~900px desktop, ~812px mobile)
- Assess CTA visual weight, color, contrast against background
- Evaluate visual hierarchy — eye flow, element sizing, color dominance
- Check trust signal visual proximity to CTAs
- Verify pricing page visual layout and plan highlighting
- Assess mobile CTA visibility and form layout
- Identify sticky elements at bottom of page
- Evaluate overall conversion page design quality

### Discovery JSON (`{run_dir}/discovery.json`)

Structured metadata about the site including:
- Page list with URLs and metadata
- Form definitions (fields, types, required status)
- Interactive elements inventory
- Popup/modal detection (if captured during discovery)

**Use discovery.json to:**
- Get definitive form field counts and types
- Identify all pages with forms
- Map page relationships for click-to-convert analysis
- Check for popup presence indicators

### Sitemap (`{run_dir}/sitemap.md`)

Hierarchical site structure.

**Use sitemap to:**
- Calculate click depth from homepage to conversion pages
- Identify thank-you/success pages
- Map the complete conversion funnel path
- Identify pricing pages, product pages, landing pages

---

## Ownership Boundaries

**This module OWNS:**
- CTA above fold — primary ownership, no other module checks this
- Form usability — field count, labels, submit text, required fields, error placement, CAPTCHA
- Conversion funnel friction — click depth, registration walls, unnecessary steps
- Trust signal placement near CTAs
- Visual hierarchy for conversion
- Pricing page optimization
- Mobile conversion (CTA visibility, form layout, sticky elements)
- Post-conversion experience (success pages, next steps)

**This module does NOT check (owned by other modules):**
- Touch target sizing (44x44px) → Accessibility
- Color contrast WCAG ratios → Accessibility
- Keyboard/ARIA form aspects → Accessibility
- Form field keyboard navigation → Accessibility
- Core Web Vitals → Performance
- Heading hierarchy → SEO Technical
- Meta tags → SEO Technical

If you encounter an issue in another module's domain, note it briefly as "See {module} report" but do NOT include it in scoring deductions.

---

## Rules

1. **ZERO `browser_*` calls.** All analysis from cached data. No exceptions.
2. **Full coverage.** Analyze every page in the sitemap.
3. **Finding template.** Every finding uses the SKILL.md template. Sections 1-3, 6-7, 10 REQUIRED. Sections 4-5, 8-9 may be "N/A" if inapplicable.
4. **Evidence-based.** Every finding references a specific file: snapshot, screenshot, or discovery.json.
5. **Specific, not generic.** "Move the 'Get Started' CTA button above the testimonials block on the homepage" — not "improve CTA placement".
6. **Honest limitations.** If something cannot be tested from cache, say so explicitly. Do not guess at dynamic behavior.
7. **Language.** All report content in English. Technical terms (CTA, CRO, UX, CAPTCHA) in English.
8. **Unified scoring.** FAIL = −15, WARN = −5, starting from 100. No custom formulas.
9. **Check ownership.** Do not score issues owned by other modules. Reference them with "See {module} report."
10. **Screenshots are evidence.** Every finding references at least one screenshot from `{run_dir}/screenshots/`.
