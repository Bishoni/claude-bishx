---
name: site
description: "Full website audit — UX/UI design, marketing, SEO, accessibility, performance, conversion. Crawls the site (up to 100 pages) via cmux browser, generates detailed visual critique with actionable recommendations."
---

# Bishx-Site: Full Website Audit

Autonomous website audit skill. Crawls the site (up to 100 pages) via cmux browser, analyzes UX/UI design,
marketing, SEO, accessibility, performance, conversion, brand consistency, and information
architecture. Produces a single detailed visual critique document with actionable recommendations.

**Output is a DESIGN CRITIQUE, not code.** No source code inspection, no technical implementation
details. Pure UX/marketing/visual perspective: what's wrong, what to change it to, where exactly
to move it, and why it works better — at a level of detail where a designer or another agent
can execute without a single clarifying question.

---

## FOUNDATIONAL PRINCIPLE: Human-First Evaluation

**This is the foundation of the entire audit. Every module, every check, every finding
derives from this principle. Module-specific checks (CTA placement, contrast ratios,
heading structure, page speed) are CONCRETE INSTANCES of this abstract principle —
not independent rules.**

### The Principle

> Every element on a page exists to serve a specific human in a specific moment.
> When a page is organized by the creator's logic instead of the visitor's need —
> that is a failure, regardless of how technically correct the page is.

A site can score 100 on Lighthouse, pass every WCAG check, have perfect SEO —
and still fail the human who visits it.

### Five Layers + Meta-Layer

Every page evaluation — in any module — passes through this lens:

**LAYER 1 — FOR WHOM (is the right person being served?)**
- Is the content written for the person actually looking at this page?
- Does the tone match the visitor's emotional state at this point?
  (anxious on payment page → needs reassurance, not excitement;
   frustrated on error page → needs empathy, not branding)
- Does the page assume only what the visitor actually knows?
  (no unexplained jargon, no references to internal concepts)

**Visitor States Beyond "First Visit":**

When identifying WHO is on the page (HB1), consider these states:

| State | What They Need | What Fails Them |
|-------|---------------|-----------------|
| **Multi-tab comparison** (3-5 competitor sites open) | Scannable data points (price, features). Comparable format. Quick extraction. | Buried pricing. Unique terminology. Non-standard metrics. |
| **Frustrated / error-recovery** (broken link, failed payment, bad search) | Acknowledgment of failure. Clear recovery path. Preserved context. | Generic error. Lost form data. No alternative suggestions. |
| **Urgent** (emergency info, time-critical) | ONE fact in <2 seconds. Zero interaction required. | Content hierarchy that buries the answer. Popups. Loading delays. |
| **Reluctant / forced** (must use, no alternative) | Minimum path to completion. No unnecessary friction. | Extra steps. Upsells. Marketing copy on utility pages. |
| **Referred** (friend sent link, high trust, zero context) | Page that stands alone without homepage context. | Assumes prior navigation. Jargon without explanation. |
| **Expert / power-user** (knows domain, seeks specific data) | Jump to data point. Skip preamble. Deep search. | Forced linear reading. No anchor links. No expandable details. |
| **Price-sensitive** (hunting for total cost, hidden fees) | Full cost transparent upfront. Clear comparison. | "from $X" without explanation. Fees added at checkout. |
| **Situationally constrained** (bright sun, one hand, slow connection, tiny screen) | Graceful degradation. High contrast. Large targets. Minimal data usage. | Light gray text. Tiny buttons. Heavy assets without lazy-load. |

These are NOT separate checks. They are PERSPECTIVES for the HB1 heartbeat.
When identifying the visitor, consider: which of these states might they be in?
The page should work for ALL likely visitor states, not just the "ideal" first-time desktop visitor.

**LAYER 2 — WHAT (is the right content shown?)**
- Is the page organized by the VISITOR'S logic or the CREATOR'S logic?
  (creator: features, departments, chronology;
   visitor: problem, solution, proof, action)
- Does the depth match the visitor's readiness?
  (first visit → overview; comparison phase → details; ready to act → specifics)
- Nothing unnecessary, nothing critical missing?

**LAYER 3 — HOW (is the presentation right?)**
- Does the format match the visitor's cognitive mode?
  (scanning → headings, icons, visual signals;
   reading → full text, arguments;
   deciding → comparison tables, calculators;
   doing → step-by-step, not prose)
- Is information in the order the visitor needs it?

**LAYER 4 — FEELING (how does the page FEEL to use?)**
- **Control:** The visitor manages their experience, not the other way around.
  No autoplay without consent. No forced registration before showing content.
  No scroll hijacking. No popups interrupting flow. Back button works.
  The visitor can bookmark, share, and return to any state.
- **Familiar patterns:** The site works like the rest of the web (Jakob's Law).
  Logo top-left links to home. Search in header. Cart top-right.
  "Next" button on the right, "Back" on the left.
  Violating web conventions costs cognitive effort — every deviation must be justified.
- **Overwhelm protection:** The TOTAL cognitive demand of the page is manageable.
  Each element may be justified individually, but 5 CTAs + 3 banners + popup +
  ticker + chat widget + animation TOGETHER = overload.
  Not about individual elements — about the SUM of everything competing for attention.

**LAYER 5 — BEHAVIOR (how does the site RESPOND to the visitor?)**
- **Predictability:** Every element shows what will happen when interacted with.
  Button labeled "Download" downloads, not opens a registration form.
  Link to "Pricing" shows pricing, not "Contact Sales."
  If the outcome can't be predicted from the label — it's a failure.
- **Transparency:** No hidden agenda. No pre-checked opt-ins. No fees revealed
  only at checkout. No "free trial" requiring credit card. No dark patterns.
  The site works IN the visitor's interest, not AGAINST it.
- **Feedback:** Every visitor action gets acknowledgment.
  Click button → button visually responds. Submit form → confirmation appears.
  Add to cart → counter updates. Delete item → "Deleted" message with undo option.
  Silence after action = the visitor doesn't know if it worked.
- **Forgiveness:** The site assumes humans make mistakes — and makes them reversible.
  Accidentally deleted → can recover. Closed tab → form data saved.
  Wrong button → can go back. Wrong input → can edit without restarting.
  Undo is always available for destructive actions.
- **Progress:** The visitor sees forward momentum toward their goal.
  Long form → progress bar. Multi-step process → "Step 2 of 4."
  Long article → estimated reading time. Loading → progress indicator.
  "How much more?" should always have an answer.
- **Respect for time:** Every element justifies its time cost.
  No autoplay video forcing a wait. No interstitial before content.
  No "subscribe" popup 3 seconds after loading. No unnecessary steps.
  Every delay or interruption says "my time matters more than yours."

**META-LAYER — THE JOURNEY (does the page work in context?)**
- **Promise = Reality:** What the entry point promised (button text, link, search result)
  matches what the page delivers
- **Effort ≤ Value:** The page doesn't ask more than it gives
  (10-field form for a 2-page PDF = violation)
- **Trust matches the ask:** The bigger the commitment requested (payment, personal data),
  the more trust the page must earn first
- **Next step is clear:** The visitor knows what to do after this page
- **Memorability:** After the visitor leaves — did something stick?
  Can they describe the site in one sentence? Can they remember how it differs
  from competitors? Will they find it again? Does the shared link preview
  (OG tags) represent the page well?

### How Modules Apply This Principle

Each module is a DOMAIN-SPECIFIC APPLICATION of this principle:

| Module | Layers 1-3 (Content) | Layer 4-5 (Experience) | Meta (Journey) |
|--------|----------------------|------------------------|-----------------|
| UX Design | Composition guides attention to what the VISITOR needs first, not what the creator wants to show | Overwhelm protection: total visual load manageable. Familiar layout patterns respected. | Memorability: distinctive visual identity |
| Marketing Content | Copy serves visitor's need in their language, depth, and tone. Audience-content fit. | Transparency: no manipulative copy, no false urgency. Predictability: CTA labels match outcomes. | Promise of headline = content of page |
| Conversion | Path follows visitor's decision logic. Right info at each decision point. | Control: no forced gates. Feedback: every form action confirmed. Forgiveness: mistakes reversible. Progress visible. | Effort ≤ value. Trust proportional to ask. |
| SEO Technical | Page structure delivers right visitor to right page. | Predictability: search snippet matches page content. | Promise = reality at search level |
| SEO Content | Answers visitor's question at needed depth in their language. | Respect for time: content is not padded. Every paragraph earns its place. | Visitor can describe what they learned |
| Accessibility | Every visitor accesses content regardless of ability. | Control: keyboard works. Feedback: screen reader gets announcements. Forgiveness: errors explained. | The ultimate human-first layer |
| Performance | Page loads fast enough to preserve visitor's intent. | Respect for time: no unnecessary waits. Progress: loading indicators present. | Fast enough that momentum isn't broken |
| Information Architecture | Navigation follows visitor's mental model, not org chart. | Familiar patterns: standard nav placement. Predictability: link labels match destinations. | Visitor always knows where they are and where to go |
| Brand Consistency | Consistent experience = visitor focuses on content, not on "is this the same site?" | Familiar within the site: same patterns everywhere. | Trust through consistency |

### For Agents: How to Use This

When evaluating ANY element on ANY page:
1. First — identify WHO is looking at this page and WHAT they need right now
2. Then — check if the element serves that need (Layer 1-2-3)
3. Then — check if the element works in the journey context (Meta-Layer)
4. Only then — apply your module's specific technical checks

If a technical check PASSES but the principle is VIOLATED — that is a finding.
If a technical check FAILS but the principle is SATISFIED — note it but lower priority.

The principle does not replace technical checks. It PRIORITIZES and CONTEXTUALIZES them.

### Toolkit, Not Checklist

Module-specific checks (FAIL/WARN thresholds) are a TOOLKIT of common patterns —
not a mandatory checklist to execute mechanically on every page.

**How thresholds work:**
- The Foundational Principle is your PRIMARY guide. Always.
- Thresholds (e.g., ">3 CTAs = WARN") are HELPERS that catch things you might miss
- When threshold and principle AGREE — great, report the finding
- When they DISAGREE — the principle wins. Explain the disagreement briefly.
- Override IS expected: in a typical audit, ~15-20% of threshold triggers are false positives
  that should be dismissed or downgraded. If you override ZERO thresholds, you are working
  mechanically — that is the actual failure.
- NOT overriding when the principle says otherwise is worse than overriding incorrectly

**Purpose-level evaluation:**
Each check in a module describes WHAT to evaluate, not HOW to mechanically verify.
- "Check if the page's call to action is clear" — NOT "count buttons and compare to 3"
- "Check if the table is usable" — NOT "verify each cell has minimum contrast"
- "Check if the form is approachable" — NOT "count fields and compare to 5"

The specific numbers/thresholds are EXAMPLES of what commonly indicates a problem.
The agent applies judgment to the actual page, using the principle as the guide.

**Example:**
A pricing page with 4 CTA buttons might PASS if each serves a different plan clearly.
A pricing page with 1 CTA button might FAIL if it's invisible or misleading.
The number of CTAs is an indicator. The principle ("is the next step clear?") is the test.

### Unknown Element Protocol

When an agent encounters an element, widget, or pattern NOT covered by its module toolkit:

**DO NOT skip it.** Apply the Foundational Principle directly:

1. **Identify:** What is this element? (3D tour, mortgage calculator, interactive map,
   custom widget, embedded app, data visualization, etc.)
2. **Purpose:** What is it supposed to do for the visitor?
3. **Evaluate through 5 layers:**
   - Layer 1: Is it for the right audience? Right tone?
   - Layer 2: Does it contain the right content at the right depth?
   - Layer 3: Is the format appropriate for the visitor's mode?
   - Layer 4: Does the visitor feel in control? Is it overwhelming? Familiar enough?
   - Layer 5: Is it predictable? Transparent? Gives feedback? Forgiving?
4. **Meta:** Does it fit the journey? Promise = reality?
5. **If a problem is found** — create a finding using the standard template.
   Tag it as `[Unknown Element]` so SYNTHESIZE can track novel findings.

**Significance gate:** Apply this protocol only to elements that are MEANINGFUL
for the visitor's goal on this page. Skip decorative/cosmetic elements.
A mortgage calculator on a property page = significant. A decorative animation = skip.

### Principle Heartbeat Protocol

Agents WILL forget the principle mid-execution. This protocol prevents that.

**Mandatory checkpoints — agents MUST pause and re-apply the principle at these EXACT moments:**

**Heartbeat 1 — BEFORE starting each page analysis:**
```
[HB1] Page: {url} | Complexity: {simple/standard/complex}
Visitor: {who} | Needs: {what} | State: {emotion}
Visitor Mind (5 sec): {first impression as a first-time visitor — what do I think, feel, want to do?}
Entry paths: {how might someone arrive here — nav / search / direct link / social?}
```
This forces the agent to become the visitor BEFORE running any technical checks.

**Heartbeat 2 — AFTER technical checks for a page, BEFORE writing findings:**
```
[HB2] Principle review for {url}:
- Layer 1-3: content for the right audience? tone? depth? format? sequence?
- Layer 4: control? no overload? familiar patterns?
- Layer 5: predictable? transparent? feedback? forgivable? progress? time respected?
- Meta: promise=reality? effort≤value? trust proportional to ask? memorability?
- Design intent: is anything I marked FAIL potentially an intentional choice?
- Screenshot check: are all findings based on the normal page state?
- PASS on checklist but FAIL on principle? → add finding
- FAIL on checklist but not a real problem? → remove or lower severity
Expected override rate: ~15-20%. If 0 overrides — working mechanically.
```

**Heartbeat 3 — AFTER every 5th finding written:**
```
[HB3] Quality check after {N} findings:
- Are my findings specific ("move X after Y") or generic ("improve Z")?
- Do I still remember who the visitor is? (fresh eyes — not comparing to previous pages)
- Are recommendations varied or am I stuck in one type? (3+ identical → look for something different)
- Are all UX terms explained in plain language?
- Does every finding have a confidence tag ([Certain/Likely/Possible])?
- Assumptions tagged? ([Assumption: ...])
- Are there positive findings? (minimum 1 per every 5 negative)
```

**Heartbeat 4 — BEFORE writing the Module Score section:**
```
[HB4] Final review:
- Top finding: does it actually help the visitor, or is it a formal observation?
- What would the VISITOR notice that I haven't checked? ("What did I miss?")
- Copy-paste: same findings on 3+ pages → merge into a pattern?
- Depth check: if >25 findings → deepen the top 10 instead of generating new ones
- Score normalization: counting UNIQUE problems, not total instances
- Cross-module notes: noticed issues outside my domain? → record [Cross-module: {module}]
- Effort scaling: does every recommendation have a concrete effort level?
```

**These heartbeats are NOT optional. They are MANDATORY steps in the execution flow.**
The `[HB1]`, `[HB2]`, `[HB3]`, `[HB4]` markers MUST appear in the module report.
If a report lacks heartbeat markers, it is considered incomplete.

### Agent Behavior Standards

These standards prevent common AI agent failure modes during real audit execution.

#### Perception Standards

**Fresh Eyes Reset:**
Each page is evaluated INDEPENDENTLY. Do not compare to previously analyzed pages.
Not "this is worse than the homepage" — but "does this work for THIS page's visitor?"
Each HB1 heartbeat is a fresh start. Previous pages do not set the bar.

**Design Intent Check:**
Before flagging any visual/design element as FAIL, ask: "Could this be an intentional choice?"
- If possibly intentional: frame as "If intentional — acceptable. If not — recommendation: {X}"
- If clearly unintentional (broken layout, misaligned elements, clipped text): flag directly
- When in doubt: flag but tag as `[Possible design intent]`

**Screenshot Reliability:**
Before writing a finding based on a screenshot, verify: "Does this screenshot show the normal
page state? Or could this be a loading state, error state, popup overlay, or transition frame?"
If uncertain: tag finding as `[Screenshot state uncertain]` and note the limitation.

**Cultural Context:**
When site lang=ru, apply Russian web conventions:
- Phone-first authentication is NORMAL (not unusual)
- VK, Telegram, OK.ru sharing buttons are STANDARD (not niche)
- Yandex SEO is as relevant as Google SEO
- Formal "Vy" (formal "you") is default (not cold/distant)
- Payment via SBP, MIR card, installments are STANDARD trust signals
Do NOT apply US/EU conventions blindly. When in doubt, default to Russian patterns.

**State Your Assumptions:**
Every finding that relies on an assumption MUST tag it explicitly:
`[Assumption: desktop visitor]`
`[Assumption: first visit]`
`[Assumption: arrived from search]`
`[Assumption: page in final state]`
This makes invisible assumptions visible and challengeable.

#### Quality Standards

**Visitor Mind — 5 Seconds:**
Before ANY technical checks on a page, look at the screenshot as a first-time visitor.
5 seconds. Ask yourself:
- "What do I think this page is about?"
- "What should I do here?"
- "Do I trust this?"
- "Am I confused by anything?"
This gut reaction is MORE VALUABLE than any technical check. It catches what checklists miss.
Write it as the first line of your page analysis.

**Confidence Tagging:**
Every finding gets a confidence level:
- `[Certain]` — objectively verifiable from data (broken link, missing alt text, score < threshold)
- `[Likely]` — strong reasoning from evidence (layout suggests confusion, copy is audience-mismatched)
- `[Possible]` — informed judgment, could go either way (might be intentional design, might be oversight)
Do NOT present [Possible] findings with the same certainty as [Certain] ones.

**Plain Language:**
Every UX/design term MUST be immediately followed by a plain explanation:
- "visual hierarchy (what the eye sees first, second, third)"
- "cognitive load (how much effort it takes to understand the page)"
- "Fitts's Law (the larger and closer a button is, the easier it is to click)"
The site owner may be a dentist, a restaurateur, or a government official — not a designer.

**Technical Fast Path:**
Simple binary technical issues (broken link, missing alt text, 404 error, missing meta tag)
do NOT need full 5-layer principle analysis. Use short format:
- What: {issue}
- Where: {page:element}
- Fix: {action}
- Priority: {level}
The principle applies to SUBJECTIVE evaluations (is this CTA effective? is this copy persuasive?).
Binary pass/fail issues get the fast path.

**Cognitive Load Budget:**
Beyond individual element checks, assess the TOTAL cognitive demand per page:
- Count: distinct decisions required, competing visual elements, different typography styles,
  moving/animated elements, notification badges, separate CTAs
- A page can have every individual element well-designed but TOGETHER overwhelm the visitor
- Reference: if total distinct interactive elements > 15 in one viewport, flag for review
- This is not a hard threshold — it is a lens. Some pages (dashboards) justify high density.

**Error Prevention Assessment:**
Beyond checking error MESSAGES (Conversion/Accessibility), evaluate error PREVENTION:
- Does the date picker prevent invalid dates?
- Does the phone field auto-format?
- Does the address field use autocomplete?
- Are destructive actions (delete, cancel) behind confirmation dialogs?
- Does the form save draft state (prevent loss from accidental navigation)?
Layer 5 (Forgiveness) covers REVERSAL. This covers PREVENTION. Both matter.

**Visual Freshness Assessment:**
Beyond checking content dates (SEO Content), evaluate VISUAL freshness:
- Do product screenshots show the current UI? (outdated screenshots = trust erosion)
- Do team/people photos look recent? (2015 corporate photo style ≠ 2025)
- Does the design itself feel current? (not "trendy" but "maintained")
- Are partner/client logos current branding?
Tag: `[Visual freshness concern]` when the site LOOKS older than it probably IS.

**Internationalization UX (beyond SEO hreflang):**
If the site has a language selector:
- Does it use FLAGS? (wrong — flags = countries, not languages)
- Does it use native language names? ("Deutsch" not "German")
- Does switching preserve the current page?
- Is currency/measurement tied to language?

#### Output Standards

**Depth Over Breadth After Threshold:**
After 25 findings in a module: STOP generating new findings.
Instead: go back to your top 10 findings and DEEPEN them — add more specific recommendations,
more detailed reasoning, more concrete replacement content.
25 findings with 10 deeply detailed > 50 findings all medium depth.
Exception: FAIL-severity findings are always reported regardless of count.

**Mandatory Positive Findings:**
For every 5 negative findings, include at least 1 POSITIVE finding.
Positive findings must be SPECIFIC: "Navigation is intuitive: main sections are reachable
in 1 click, active state is clearly highlighted" — not "The site is generally fine."
If you analyzed 15 pages and found 0 positives — you are biased. Re-examine.

**Positive Pattern Vocabulary:**
When writing positive findings, use these patterns as reference for WHAT excellence looks like:

- **Progressive Trust Architecture:** Trust builds deliberately across the journey —
  free content → case studies → transparent pricing → easy trial → generous refund
- **Contextual Help at Decision Points:** Tooltips and explanations appear exactly where
  the visitor might hesitate — "What's the difference between plans?" on the pricing toggle
- **Ethical Defaults:** Opt-out for marketing, "essential only" cookie default,
  prominent "No thanks" options, no pre-checked boxes
- **Anticipatory Design:** Smart defaults (city from IP, currency from locale),
  recently viewed, "Based on your search" — saving visitor effort
- **Content Density Optimization:** Maximum useful information in minimum space
  WITHOUT feeling cluttered — scannable, dense, efficient
- **Graceful Empty States:** "No results" that educates, encourages, and suggests
  alternatives — not just a blank page
- **Delightful Micro-Moments:** Success animations, witty 404, progress celebrations,
  copy that makes you smile — creates memorability
- **Transparency as Feature:** Public roadmap, uptime page, visible changelog,
  published ranking methodology — proactive honesty
- **Accessibility as Excellence:** Beautiful focus states, curated screen reader
  experience, power-user keyboard shortcuts, brand-preserving high-contrast mode
- **Seamless Multi-Channel:** QR codes for mobile continuation, "Email me this link",
  clean shareable URLs, print-friendly versions

These are NOT mandatory checks. They are a VOCABULARY for recognizing excellence.
When an agent encounters these patterns, they should call them out as positive findings
with the same specificity required for negative findings.

**Anti-Copy-Paste:**
If the same problem appears on >3 pages — do NOT write separate findings for each.
Write ONE pattern finding:
"Pattern: {problem} found on {N} pages.
Example: {one specific page with the full detailed finding}.
Also affects: {list of remaining pages}."
This single pattern finding counts as ONE deduction in scoring, not N deductions.

**Recommendation Diversity:**
If 3 consecutive recommendations are the same type ("add whitespace" × 3):
PAUSE. Look for OTHER types of improvements. Variety of recommendations = more useful audit.

**Effort Scaling in Recommendations:**
Every recommendation specifies effort concretely:
- "Quick fix" (1 hour, anyone can do it — text change, block repositioning)
- "Design change" (requires a designer, 1-2 days — section redesign, new layout)
- "Development" (requires a developer, 3-5 days — new component, interactive feature)
- "Architecture" (requires a tech lead, 1-2 weeks — CMS migration, restructuring)
- "Strategic" (requires stakeholder decision — positioning, audience, business model)

**Multi-Entry Awareness:**
For key pages (homepage, pricing, product, case study), consider:
"How does this page work if visitor arrives from: (a) site navigation, (b) search engine,
(c) direct link shared by someone, (d) social media ad?"
Different entry points = different visitor states. Note when a page works for one path but fails for another.

#### System Integrity Standards

**Score Normalization:**
Scoring is by UNIQUE problems, not total instances.
The same problem on 20 pages = 1 pattern deduction, not 20 deductions.
This prevents score inflation on large sites.

**Contradiction Detection (for SYNTHESIZE phase):**
When aggregating module reports, explicitly check: do any recommendations CONTRADICT each other?
If Module A says "add more content" and Module B says "reduce page length" — this is a
TRADE-OFF finding, not two independent findings. Present as:
"Trade-off: {Module A} recommends {X}, {Module B} recommends {Y}. Compromise: {Z}."

**Motivation Framing (for SITE-REVIEW.md):**
The report is NOT a list of failures. It is a ROADMAP for improvement.
- Start with: "Current level: {score}. With quick wins → ~{score+15}. With strategic changes → ~{score+30}."
- "Quick Wins" section comes BEFORE detailed findings
- Frame as progress path, not failure list
- Include estimated impact per recommendation group

**Complexity-Proportional Effort:**
Not all pages deserve equal analysis depth:
- Complex pages (checkout, pricing, multi-step forms, dashboards): DEEP analysis, full principle application
- Standard pages (about, team, contact, blog post): STANDARD analysis
- Simple pages (legal, terms, privacy, 404): QUICK scan, technical checks only
Discovery tags each page with complexity level. Agents allocate effort proportionally.

**Finding Dependency Graph (for SYNTHESIZE):**
When aggregating findings, identify CAUSAL dependencies:
- "Fixing finding #3 (heavy images) ALSO resolves #7 (slow hero load) and improves #12 (high bounce)"
- Present as: "Root cause: {#3}. Resolves: {#7, #12}. Fix the root, get 3 improvements."
- This helps the report reader prioritize: fix ROOT CAUSES first, not symptoms.

**Finding Actionability Gate:**
Before writing ANY recommendation, verify: "Can a designer/developer execute this
in ONE working session without asking clarifying questions?"
- YES → recommendation is specific enough
- NO → add more detail until the answer is YES
Example of NOT actionable: "Improve the information architecture"
Example of actionable: "Add tabs to the pricing table: 'Key differences' (10 rows,
active by default) and 'Full comparison' (accordion by category)"

**Assumption Challenge at HB4:**
At HB4 (final review), add this check:
"If the visitor were actually {DIFFERENT from my HB1 assumption}, which findings would REVERSE?"
Example: if I assumed "business decision maker" but the visitor is actually "technical implementer"
→ findings about "too much jargon" would reverse, findings about "not enough API details" would appear.
Note any findings that are ASSUMPTION-DEPENDENT in the report.

**Temporal Stability Tagging:**
Tag findings by how STABLE they are over time:
- `[Stable]` — will still be true next month (missing alt text, broken heading hierarchy, structural issues)
- `[Volatile]` — may change soon (seasonal content, A/B test variant, dynamic pricing display, promotional offers)
Advise: "Fix [Stable] issues first — they will still be broken when you get to them."

**Severity by Impact Radius:**
Two identical issues have different impact based on WHERE they occur:
- Homepage (seen by 100% of visitors): full severity
- Depth-1 pages (seen by 50-70%): full severity
- Deep pages (seen by 5-10%): reduced severity consideration
- Utility pages (terms, privacy, sitemap): lowest impact
Note this in findings: "[Impact: high-traffic page]" or "[Impact: deep/utility page]"

**Cross-Audit Learning (for repeat audits):**
When comparing with a previous audit (diff mechanism):
- Same finding appears again → escalate priority: "Repeat audit: this finding has not been fixed.
  Priority raised."
- Finding was fixed → acknowledge: "Fixed since last audit ✓"
- New finding on same page → flag: "New problem on a previously clean page — possible regression"

#### Contextual Intelligence Standards

These standards teach agents to READ THE CONTEXT of what they see — not just check elements mechanically.

**Temporal Awareness:**
All captured data is a snapshot in time. Before any finding about dynamic content:
1. Assess data volatility: `high` (prices, availability, search results change in minutes),
   `medium` (news feed, promotions change daily), `low` (static content pages)
2. For high-volatility content: tag finding with `[Temporal: prices/availability captured at {time}]`
3. Do NOT make definitive claims about dynamic data: "Price is too high" → instead:
   "Price display at time of capture: {X}. Evaluate the PRESENTATION of pricing, not the price itself."
4. If the page shows time-sensitive content (countdowns, "limited offer", flash sales):
   note whether it is verifiable or potentially fake: `[Temporal: countdown detected, genuineness unverifiable from cache]`

**Regulatory Context Detection:**
When the site operates in a regulated industry, agents must identify and account for it:
1. Detect regulatory signals: license numbers in footer, certification badges, legal disclaimers,
   industry-specific terminology (CBR, Roszdravnadzor, FSTEC, Roskomnadzor, SRO)
2. If detected: record as `[Regulatory context: {industry}]` in the report
3. Apply stricter standards: mandatory disclosures become FAIL (not WARN) when missing
4. Effort scaling adjustment: ANY change touching regulated content adds "+compliance review" time
5. Do NOT recommend changes that would violate regulatory requirements
   (e.g., don't suggest removing mandatory legal disclaimers to "clean up the design")
This is NOT about knowing every regulation. It IS about recognizing regulated context
and being conservative with recommendations in those areas.

**YMYL Sensitivity:**
When content can impact health, finances, safety, or legal rights:
1. Detect YMYL signals: medical terms, financial calculations, legal advice, safety instructions,
   "Your Money or Your Life" topics
2. Apply MAXIMUM E-E-A-T scrutiny: author credentials MUST be visible, qualifications MUST be verifiable,
   sources MUST be cited, claims MUST be evidence-based
3. Score impact: YMYL pages with missing credentials = FAIL (not WARN)
4. Note in report: "This site contains YMYL content. Stricter evaluation standards applied."
Every site may have some YMYL content (privacy policy, payment page). Full YMYL sites
(medical, financial, legal) get this treatment on EVERY content page.

**Revenue Model Transparency:**
Identify how the site makes money and check if the visitor can see this:
1. Detect revenue model signals: affiliate links (utm, ref, partner params),
   advertising blocks, subscription gates, commission disclosures, "powered by" labels
2. Layer 5 (Transparency) applies: if the site earns from directing visitor actions
   (affiliate commission, advertising clicks, partner referrals), is this DISCLOSED?
3. "Comparison" or "best price" claims on affiliate sites: WARN if no methodology disclosure
4. Advertising mixed with editorial content: WARN if not clearly labeled
5. Record: `[Revenue model: affiliate/advertising/subscription/sales/freemium]`
This is about HONESTY, not judgment. Affiliate sites are legitimate — but visitors deserve to know.

**Variant Awareness:**
The audit captures ONE state of a potentially multi-variant experience:
1. Detect variant signals: personalization cookies, A/B test framework scripts
   (Optimizely, VWO, Google Optimize, custom), session-based content differences
2. If detected: record `[Variant: personalization/AB-test detected]` in discovery.json
3. Note prominently in SITE-REVIEW.md: "Audit was conducted for the default state
   (anonymous first visit). Personalized/variant content was not evaluated."
4. Do NOT make claims about "the site always shows X" — it may show different X to different visitors
5. For A/B tests: if two versions of a page are encountered during crawl, note BOTH,
   do not flag the variant as "inconsistency"

**Data-Dense Page Pattern:**
For pages primarily about comparison, search results, data tables, or catalog listings:
1. Detect: page has a table >10 rows, or a results list >10 items, or filter controls
2. Replace standard "Visitor Mind 5 seconds" with DATA PAGE variant:
   "In 5 seconds: Can I identify the best option? Can I tell how results are ordered?
   Do I understand the sort/filter controls? Is the key data (price, rating, date) scannable?"
3. Evaluate COMPARISON USABILITY, not just visual layout:
   - Can the visitor sort by the dimension they care about?
   - Can the visitor filter to narrow results to their needs?
   - Is the per-item information hierarchy clear (what's most important WITHIN each result)?
   - Can the visitor compare 2-3 specific options side by side?
4. Do NOT run per-item checks on every row/result — evaluate the PATTERN, not each instance

**Compound Input Gate:**
When a site requires MULTIPLE inputs before showing content (not just a single address/search field):
1. Detect: page has 2+ required input fields AND no content below the form
   AND the site's other pages reference results that require these inputs
2. Examples: flight search (origin + destination + dates), real estate (location + budget + rooms),
   hotel booking (city + dates + guests), job search (position + location)
3. AskUserQuestion with ALL required fields:
   "The site requires filling in multiple fields to display content:
   {field1}: ___
   {field2}: ___
   {field3}: ___
   Enter values for a complete audit, or skip (audit will be limited)."
4. Fill ALL fields, submit, wait for results, then continue crawl from populated state
5. Record: `"input_gate_type": "compound", "fields": ["origin", "destination", "dates"]`

**Diminishing Returns in Score Projections:**
Higher baseline scores → smaller realistic improvement potential:
- Score 0-50: Quick wins may add ~15 points, strategic changes ~25 points
- Score 50-70: Quick wins ~10 points, strategic ~20 points
- Score 70-85: Quick wins ~5 points, strategic ~10 points
- Score 85+: "Further improvement requires A/B testing, user research,
  and iterative optimization. Quick fixes yield minimal gain."
Use these bands in the Improvement Roadmap, not the flat "+15/+30" formula.

**Common Layer 4-5 Violation Patterns:**
These are FREQUENTLY OCCURRING violations that agents should actively look for
(not wait to stumble upon):

Layer 4 (Control) violations:
- Persistent app download banner blocking content on mobile
- Email/newsletter popup appearing within 5 seconds of page load
- Push notification permission request on first visit
- Scroll hijacking (custom scroll behavior that breaks native scrolling)
- "Subscribe to continue reading" gates on content pages
- Undismissable overlays
- Browser back button broken (SPA navigation issues)
- Confirmshaming dismiss copy ("No, I don't want to save money", "I prefer to stay uninformed")
- Roach Motel: signup takes 1 step, cancellation takes 5+ steps or requires phone call
- Misdirection: "Accept" button is large/colored, "Decline" is tiny/gray text
- Infinite scroll without progress indicators, back-to-top, or footer access

Layer 5 (Behavior) violations:
- Fake countdown timers (same timer on every visit = likely fake)
- "Only N left in stock" with no evidence of real inventory data
- Pre-checked opt-in checkboxes (newsletter, marketing, data sharing)
- Hidden fees revealed only at final checkout step
- Price displayed without taxes/fees that will be added later
- "Free trial" requiring credit card before any access
- Automatic subscription renewal buried in fine print
- Dark patterns in unsubscribe/cancellation flow
- Social proof manipulation: stock photos as "real customers", fabricated review counts,
  "As seen in" logos without actual coverage, round numbers suggesting inflation ("10,000+ users")
- Bait-and-switch pricing: listing/ad price ≠ checkout price, "from $X" where X requires
  unrealistic conditions, monthly rate displayed for annual-only plans
- Forced continuity: free trial → paid with no warning email, no easy cancellation
- Privacy Zuckering: "Accept All" prominent, "Manage Preferences" hidden, default = maximum sharing
- Confirmshaming: guilt-inducing decline copy on opt-in modals
- Urgency theater beyond countdowns: "X people viewing now" (unverifiable), "Selling fast!"
  on every item, "Last chance!" on permanent offers
- Attention harvesting: notification badges that never reach zero, autoplay video sequences,
  gamification creating obligation (expiring points, broken streaks)

When an agent encounters ANY of these: it is a finding. Tag with the specific layer violated.
Do NOT dismiss these as "standard business practice" — they are trust/respect violations
regardless of how common they are in the industry.

**Incomplete Information Awareness:**
The audit NEVER has complete information about a site. Always assume:
1. **Pages not crawled** exist and may have different issues
2. **States not captured** (loading, error, empty, authenticated, personalized) may reveal problems
3. **Devices not tested** (tablet breakpoints, specific phones, slow connections) may break layouts
4. **Visitors not simulated** (returning users, users with disabilities, users on corporate networks) may have different experiences
5. **Time not frozen** (content changes, prices fluctuate, promotions expire, A/B tests rotate)

For EVERY finding, ask: "Would this finding change if I had information I don't have?"
- If YES and the missing info is critical → tag: `[Incomplete: {what's missing}]`
- If NO → finding stands as-is

For the OVERALL report, explicitly state what the audit DID and DID NOT cover.
This is not a weakness — it is intellectual honesty that builds trust with the report reader.

Never claim "the site has no accessibility issues" — only "no accessibility issues were found
in the tested pages and states." The difference matters.

**Content Type Awareness:**
Not all pages contain the same TYPE of content. The evaluation criteria must match the content type:

| Content Type | How to Evaluate | Do NOT Apply |
|-------------|-----------------|-------------|
| **Editorial** (blog, articles, guides) | Full copy quality, E-E-A-T, readability, originality | — |
| **User-Generated** (listings, reviews, Q&A, forum) | Evaluate the TEMPLATE and PRESENTATION, not the content itself. UGC quality varies by design. Do NOT flag listings as "thin content" or "duplicate" — they are unique by data, not by prose. | Copy quality, readability scoring, content originality per page |
| **Transactional** (checkout, cart, forms, calculators) | Evaluate flow, trust, clarity, error handling | Value proposition, social proof, SEO content depth |
| **Navigational** (category, search results, index) | Evaluate findability, filtering, sorting, result quality | Body copy, headline effectiveness, E-E-A-T |
| **Institutional** (about, legal, privacy, terms) | Evaluate completeness, accessibility, findability | CTA optimization, conversion, urgency |
| **Platform/Marketplace** (aggregate listings from multiple sellers) | Evaluate comparison UX, transparency, trust signals for PLATFORM (not individual sellers). VP = platform value (coverage, trust, convenience), not product VP. | Traditional value proposition, "generic hero" penalties |
| **Interactive Tool** (calculators, configurators, quizzes, estimators) | Evaluate: input clarity, output comprehensibility, edge case handling (empty/extreme values), shareability of results, mobile usability of controls | Word count, readability scoring, copy quality, SEO content depth |
| **Documentation / Reference** (API docs, knowledge bases, glossaries, wikis, manuals) | Evaluate: search within docs, code sample copy-ability, version selector, sidebar navigation, breadcrumb depth, anchor linking for section sharing | Value proposition, CTA optimization, social proof, urgency |
| **Comparison / Decision-Support** (vs pages, feature matrices, plan selectors) | Evaluate: are the RIGHT criteria compared? Are differences highlighted? Recommendation signals? Price normalization? Ease of adding/removing items? | Body copy readability, keyword density |
| **Status / Live-Data** (dashboards, tickers, status pages, weather, live scores) | Evaluate: data update visibility, last-updated timestamp, graceful stale-data handling, loading states, alert mechanisms. Tag: `[Temporal: high volatility]` | Copy quality, E-E-A-T, conversion optimization |
| **Media Gallery / Detail** (full-screen galleries, video players, virtual tours, 3D viewers) | Evaluate: navigation between items (keyboard, swipe), captions, download/share, zoom, fullscreen, preloading adjacent items | Word count, readability, heading hierarchy |
| **Onboarding / Wizard** (multi-step setup, tutorials, configuration flows) | Evaluate: progress visibility, back/skip ability, cognitive load per step, motivational copy between steps, completion celebration | Traditional page-level copy evaluation |
| **Community / Social** (forums, comments, discussions, Q&A, user profiles) | Evaluate: threading clarity, reply affordances, moderation signals, voting transparency, abuse reporting | Copy quality per post (evaluate TEMPLATE, not individual posts) |
| **Map / Location-Centric** (store locators, delivery zones, venue maps) | Evaluate: map load speed, pin clustering, list-vs-map toggle, filter by attributes, mobile touch, directions integration | Word count, body copy, readability |

Detect content type from: page URL pattern, page purpose (from discovery.json), content structure.
Apply the MATCHING evaluation criteria. Skip criteria from wrong content types.

This prevents: flagging UGC listings as "thin content," penalizing marketplaces for "generic value proposition,"
applying copy quality checks to legal documents, or demanding social proof on checkout pages.

---

## FORBIDDEN

- Skipping Discovery phase
- Limiting page coverage arbitrarily ("max 6 pages", "key pages only") — crawl up to max_pages (default 100), prioritizing by navigation hierarchy
- Using `web_fetch` or MCP tools for browsing — ALL live browser interaction via cmux browser commands (Bash)
- Looking at source code or suggesting code changes
- Using technical language ("change className", "add CSS", "modify component")
- Referencing external websites as examples (no browsing competitors)
- Generic advice ("make it better", "improve the design", "enhance UX")
- Truncating findings to save tokens — every finding gets the FULL template
- Using Sonnet/Haiku agents — ALL agents are Opus
- Skipping states (hover, empty, loading, error) — check them ALL
- Writing anything into the project source tree

## Language Awareness

The system must adapt checks to the site's language (detected via `<html lang="">` or content analysis).

**For Russian-language sites (lang="ru"):**
- **Flesch-Kincaid:** Do NOT use as a scored metric. Russian text naturally scores 4-6 grade levels higher than equivalent English. Use qualitative readability assessment only. SEO Content module should note: "FK is not applicable for Russian text. Readability assessment is qualitative."
- **Power words:** Use Russian equivalents: "free", "new", "proven", "guaranteed", "instantly", "exclusive", "limited", "now", "today", "finally", "discover", "learn", "get", "risk-free" (in Russian: "бесплатно", "новый", "доказанный", "гарантированно", "мгновенно", "эксклюзивно", "ограниченно", "сейчас", "сегодня", "наконец", "откройте", "узнайте", "получите", "без риска")
- **You/We ratio:** Check "vy/vash" vs "my/nash" (formal) or "ty/tvoy" vs "my/nash" (informal). Same >2:1 target.
- **Cookie consent selectors:** Add Russian button texts to the dismissal logic: `button:has-text("Принять")`, `button:has-text("Согласен")`, `button:has-text("Хорошо")`, `button:has-text("Принимаю")`, `button:has-text("OK")`

## Unified Scoring System

ALL modules use the SAME scoring formula. No per-module custom scoring.

### Score Calculation

Each module starts at **100** and deducts:
- **FAIL** = −15 points (critical issue, blocks user or violates hard standard)
- **WARN** = −5 points (notable issue, degrades experience)

Minimum score: **0**. No negative scores.

### Severity Mapping

Modules MUST use only two severity levels in their checks: **FAIL** and **WARN**.
These map to the report priority system:

| Module Severity | Report Priority | Meaning |
|-----------------|-----------------|---------|
| FAIL (first 2) | critical | Blocks primary user goal or violates hard standard |
| FAIL (rest) | high | Significant issue degrading experience |
| WARN | medium | Notable issue worth fixing |
| Positive note | low | Minor polish suggestion |

### Score Anchoring

To ensure comparable scores across modules (same boundaries as Grade Assignment):
- **85-100 (A):** Excellent. Up to 3 WARNs, zero FAILs.
- **70-84 (B):** Good. 1 FAIL + up to 2 WARNs, or 4-6 WARNs with zero FAILs.
- **55-69 (C):** Needs work. 2 FAILs, or 1 FAIL + 4-6 WARNs, or 7-9 WARNs.
- **40-54 (D):** Poor. 3 FAILs, or 2 FAILs + multiple WARNs.
- **0-39 (F):** Critical. 4+ FAILs.

### Score Confidence

When a module cannot fully evaluate a dimension (cache limitations, auth-gated content,
dynamic content not captured, interactive elements not testable), the score must include
a confidence indicator:

**Confidence levels:**
- **High (>80% checks executed):** Score reported as-is: "Score: 75/100"
- **Medium (50-80% checks executed):** Score with range: "Score: 75/100 [Confidence: medium — 25% checks not executable from cache]"
- **Low (<50% checks executed):** Score with caveat: "Score: 75/100 [Confidence: low — >50% of evaluation was not possible. Score reflects only testable aspects.]"

**How to calculate:** Count total FAIL/WARN checks in the module toolkit. Count how many
were marked as "N/A" / "[Screenshot state uncertain]" / "not testable from cache" /
"[Unknown Element] — requires live testing". Ratio = confidence.

**In SITE-REVIEW.md Score Dashboard:** Each module shows confidence:
| Module | Score | Grade | Confidence | Note |
|--------|-------|-------|------------|------|
| UX Design | 80 | B | Medium (70%) | 3D/animation not evaluable from cache |

**SYNTHESIZE uses confidence for weighted total:** Low-confidence module scores are
de-emphasized in the total: multiply module weight by confidence percentage.
Example: UX Design weight 0.20, confidence 70% → effective weight 0.14.
This prevents artificially inflated scores from modules that couldn't fully evaluate.

### Module Score in Report

Each module report MUST end with:
```markdown
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

This makes scoring transparent and auditable.

---

## Skill Library Integration

Before spawning audit agents, Lead reads relevant skills from `~/.claude/skill-library/`:

**Always loaded (every audit):**
- `frontend/accessibility-design/SKILL.md` → accessibility module
- `frontend/ui-ux-pro-max/SKILL.md` → ux-design module
- `frontend/web-design-guidelines/SKILL.md` → ux-design module
- `frontend/frontend-design/SKILL.md` → ux-design module
- `marketing/page-cro/SKILL.md` → conversion module
- `marketing/copywriting/SKILL.md` → marketing-content module
- `marketing/seo-audit/SKILL.md` → seo-technical + seo-content modules
- `marketing/marketing-psychology/SKILL.md` → conversion + marketing-content modules
- `review-qa/performance-audit/SKILL.md` → performance module

**Loaded if applicable (based on business type):**
- `marketing/form-cro/SKILL.md` → if forms detected
- `marketing/signup-flow-cro/SKILL.md` → if signup flow detected (SaaS)
- `marketing/onboarding-cro/SKILL.md` → if onboarding detected (SaaS)
- `marketing/popup-cro/SKILL.md` → if popups/modals with marketing intent detected
- `marketing/paywall-upgrade-cro/SKILL.md` → if paywall detected (SaaS)
- `marketing/pricing-strategy/SKILL.md` → if pricing page detected
- `marketing/schema-markup/SKILL.md` → seo-technical module
- `marketing/content-strategy/SKILL.md` → if blog/content section detected

Each audit agent receives the FULL content of its relevant skills as context in the spawn prompt.
Do NOT summarize skill contents — pass them verbatim.

## Flow

```
/bishx:site [url]
     │
     ▼
DISCOVER — cmux browser crawl (up to max_pages), map site, classify business, cache snapshots
     │
     ▼
ASK — AskUserQuestion: scope confirmation (Full / Visual / SEO / Custom)
     │
     ▼
EXECUTE — Wave 1: Tier A parallel (cache-based) → Wave 2: Tier B sequential (live browser)
     │
     ▼
SYNTHESIZE — weighted scoring, diff with previous run, dedup findings
     │
     ▼
REPORT — single SITE-REVIEW.md with detailed findings
     │
     ▼
COMPLETE — cleanup, present summary
```

---

## Phase 0: DISCOVER

**Actor:** Lead (main thread)
**Goal:** Complete site map, business classification, cache page data for audit agents.

### Initialization

#### Run Directory

All artifacts go into `.bishx-site/{YYYY-MM-DD_HH-MM}/`.
Create the directory and subdirectories at start:
```
{run_dir}/
├── screenshots/
├── snapshots/
├── state.json
```

Pass the resolved path to all agents as `{run_dir}`.

#### .gitignore

Suggest to user: 'It is recommended to add `.bishx-site/` to `.gitignore` — screenshots can take up hundreds of MB.'
Do NOT modify .gitignore directly — this would violate the FORBIDDEN rule against writing to project source tree.

#### Session Resume

Check if `.bishx-site/active` already exists:
- If yes → read the session dir and its `state.json`
  - If `active: true` and `phase` != `"complete"`:
    - AskUserQuestion: "A previous audit session was found ({date}). Resume or start fresh?"
    - Resume: continue from last phase
    - Fresh: archive old session (rename dir to `{dir}-archived`), create new
  - If `active: false`: create new session
- If no → create new session

#### Per-Phase Resume Guidance

If resuming mid-session:
- **discover:** Re-read discovery.json.pages to see how many pages were crawled. Continue crawling from where it stopped.
- **ask:** Check if selected_modules is non-empty in state.json. If yes — skip re-asking, proceed to EXECUTE. If empty — re-present AskUserQuestion and set waiting_for: "scope_selection".
- **execute (wave 1):** Check which report files exist in run_dir. Only spawn agents for modules whose reports are missing.
- **execute (wave 2):** Check which Tier B reports exist. Run remaining ones sequentially.
- **synthesize:** Re-run synthesis from scratch (idempotent).
- **report:** Re-read scores.json and all reports, regenerate SITE-REVIEW.md.

#### Initial State

Write `.bishx-site/active` with session name.
Write `{run_dir}/state.json`:
```json
{
  "skill": "site",
  "active": true,
  "phase": "discover",
  "site_url": "",
  "business_type": "",
  "run_dir": ".bishx-site/{session}/",
  "modules_total": 0, // set by ASK phase
  "modules_completed": [],
  "modules_failed": [],
  "selected_modules": [],
  "wave": 0,
  "agent_pending": false,
  "waiting_for": "",
  "max_pages": 100,
  "pages_crawled": 0,
  "started_at": "ISO timestamp",
  "updated_at": "ISO timestamp"
}
```

### URL Resolution

1. If user passed a URL argument → use it directly
2. If no argument → detect from project:
   - Check `docker-compose.yml` / `compose.yml` for web service ports
   - Check Vite/Next/Nuxt/Astro config for dev server URL + port
   - Check `package.json` scripts for `dev` command port
   - Check `.env` / `.env.example` for `APP_URL`, `NEXT_PUBLIC_URL`, etc.
3. If cannot detect → AskUserQuestion for the URL

Store resolved URL as `{site_url}`.

### cmux Verification

**Read `~/.claude/skill-library/references/cmux-browser.md` for the full cmux browser reference** (commands, type vs fill, viewport, React forms, troubleshooting).

Open a browser surface:
```bash
RAW=$(cmux browser open {site_url})
SURFACE=$(echo "$RAW" | grep -o 'surface:[0-9]*' | head -1)
```
Store the surface ID in `$SURFACE`.

**CRITICAL: Close the browser when done.** When all crawling and testing is finished
(before writing the final SITE-REVIEW.md), close the browser:
```bash
cmux close-surface --surface $SURFACE
```
Never leave the browser open while writing reports or waiting for modules to complete.
If the command fails (cmux not installed) → STOP and tell user to install cmux.

All subsequent browser commands follow the pattern:
```bash
cmux browser --surface $SURFACE <subcommand> [args]
```

### Full Site Crawl

**This is the most critical phase. Thorough but bounded.**

The goal is to discover and document every page, every interactive element, every state —
while staying within practical limits.

#### Crawl Limits

- **Max pages:** 100 (stored in `state.json.max_pages`). If more routes are discovered,
  prioritize: main nav pages first, then footer links, then blog/content, then deep links.
- **Max depth:** 5 levels from homepage
- **Timeout per page:** If a page takes >10s to load, skip with a note
- **Skip:** external links, same-page anchors (e.g., /about#team where path matches current page), mailto:, tel:, javascript:, PDF/image URLs
- **Keep:** hash-based SPA routes (e.g., /#/pricing, /#/about) — these are navigation routes, not page anchors
- **Pagination:** For paginated URLs (`?page=N`, `?p=N`, `/page/N`), crawl only page 1 and the last page (if detectable). Record pagination metadata in discovery.json: `"pagination": {"pattern": "?page=N", "total_pages": 30}`. Paginated URLs do NOT count toward max_pages limit. SEO Technical module checks: rel=next/prev, canonical handling, noindex on paginated pages.

If the site has more than `max_pages` routes, the agent must note which routes were skipped
and why in `sitemap.md`.

#### Step 1: Initial Crawl

```bash
RAW=$(cmux browser open {site_url})
SURFACE=$(echo "$RAW" | grep -o 'surface:[0-9]*' | head -1)
cmux browser --surface $SURFACE wait --load-state complete
```

#### Cookie Consent Dismissal

Before taking any snapshots, dismiss cookie/GDPR banners via snapshot + click:

```bash
cmux browser --surface $SURFACE snapshot -i
```
Look in the snapshot for cookie consent button refs (labels: "Accept", "Agree", "Принять", "Согласен", "OK", "Хорошо", "Принимаю").
If found, click the button:
```bash
cmux browser --surface $SURFACE click {ref_of_accept_button}
```

Wait 1 second after dismissal for animation to complete — simply proceed (cmux browser handles timing).

If no cookie banner found — proceed. This is best-effort, not a hard requirement.
Run this ONCE at the start of Discovery, not on every page.

#### Push Notification Prompt Dismissal

Handle browser-level notification prompts via snapshot + click.
For in-page notification opt-ins:
```bash
cmux browser --surface $SURFACE snapshot -i
```
Look in snapshot for dismiss buttons (labels: "Не сейчас", "Нет", "Позже", "No thanks").
If found: `cmux browser --surface $SURFACE click {ref_of_dismiss_button}`
Best-effort. Run ONCE after cookie consent dismissal.

#### Third-Party Widget Hiding

After cookie consent dismissal, note persistent floating widgets in the snapshot. Widgets can be hidden via JS eval:
- Take snapshot: `cmux browser --surface $SURFACE snapshot -i`
- Identify floating widget refs (Intercom, Drift, Crisp, JivoSite, Telegram widget, LiveChat, etc.) in the snapshot
- Note them in discovery.json: `"floating_widgets": ["intercom", ...]`
- To hide them for screenshots: `cmux browser --surface $SURFACE eval 'document.querySelectorAll(".intercom-launcher, #jivo-iframe-container, [id*="chat"]").forEach(el => el.style.display="none")'`
- When analyzing page layouts, note if widget elements overlap content (document as a finding if so)

Record hidden widgets in discovery.json: `"hidden_widgets": ["intercom", ...]`
Note: Widgets are hidden for SCREENSHOT purposes only. The Accessibility module (Tier B) should test with widgets visible (they are part of the tab order).
Before Tier B modules run, the Lead should note: "Widgets were hidden during Discovery screenshots. Tier B agents work with the live site where widgets are visible."

#### Ad Banner Detection

Ad banners can be hidden via JS eval for cleaner screenshots:
- Take snapshot: `cmux browser --surface $SURFACE snapshot -i`
- Identify ad-related elements in snapshot (classes/IDs containing: yandex_rtb, adfox, advert, ad-banner, adsbygoogle, doubleclick, googlesyndication, native-ad, sponsored)
- Note them in discovery.json: `"hidden_ads": ["yandex_rtb", ...]`
- To hide for screenshots: `cmux browser --surface $SURFACE eval 'document.querySelectorAll("[id*=yandex_rtb], .adsbygoogle, [class*=ad-banner]").forEach(el => el.style.display="none")'`
- Performance module should measure ads as they appear — ads impact real performance.
Add note: "Ad presence documented from snapshot. Performance module tests the live site with ads active."

#### CallTracking Detection

Check for common call tracking scripts via HTML source or eval:
```bash
curl -s "{site_url}" | grep -oiE '(calltouch|comagic|roistat|callibri|mango-office|calltracking|ringostat)'
```
Or via eval: `cmux browser --surface $SURFACE eval 'document.body.innerHTML.match(/(calltouch|comagic|roistat|ringostat)/i)?.[0] || "none"'`

Record in discovery.json: `"calltracking_detected": true/false, "calltracking_service": "calltouch"`
When calltracking is detected, add to discovery.json: `"calltracking_note": "Phone numbers on this site are dynamically replaced by CallTracking service. NAP phone consistency checks should be suppressed — different numbers per page are intentional."`

#### Geo-Detection Check

Check if the site shows geo-dependent content via snapshot:
```bash
cmux browser --surface $SURFACE snapshot -i
```
Look in snapshot for city selection elements (labels/text: "Выберите город", "Ваш город", "Select city") or geo-related button refs.
If found: note detected=true and current city text in discovery.json.

Record in discovery.json: `"geo_detection": {"detected": true, "current_city": "Moscow"}`
Add to ALL module reports: "⚠️ The site uses geo-detection. Audit was conducted for city: {city}. Content and results may differ for other regions."

#### Input-Gate Detection

After initial page load, check if the site requires user input to show content:

Use snapshot to detect input gates:
```bash
cmux browser --surface $SURFACE snapshot -i
```
In the snapshot, check:
- Are there fewer than 10 internal links visible?
- Are there form input elements (text, search, date, select, combobox) prominently displayed?
If yes → site is likely input-gated.

If input-gated:
1. Record in discovery.json: `"input_gated": true, "gate_type": "single|compound", "gate_fields": [{placeholder, type}]`
2. If SINGLE field (1 input): AskUserQuestion with one value request
3. If COMPOUND gate (2+ inputs — travel search, real estate, etc.):
   AskUserQuestion listing ALL required fields:
   "The site requires filling in multiple fields to display content:
   {field1.placeholder}: ___
   {field2.placeholder}: ___
   {field3.placeholder}: ___
   Enter values for a complete audit, or skip."
4. If user provides values: fill ALL inputs via `cmux browser --surface $SURFACE fill {ref} '{text}'`, submit via `cmux browser --surface $SURFACE click {submit_ref}`, wait for load, continue crawl from populated state
5. If user skips: proceed with limited crawl, note in SITE-REVIEW.md: "⚠️ Content behind the input form ({N} fields) was not evaluated."

```bash
cmux browser --surface $SURFACE screenshot --out {run_dir}/screenshots/homepage-desktop.png
cmux browser --surface $SURFACE snapshot -i  # save output to {run_dir}/snapshots/homepage.txt
```

Extract ALL links via snapshot analysis:
From the snapshot, collect all link elements with their href, text, and context (nav/footer position). Build a link queue. Add every unique internal path.

#### SPA Route Discovery

After extracting `<a href>` links from the snapshot, also discover SPA routes:
- From snapshot output, look for elements with `data-href`, `data-to`, `data-path` attributes containing path values
- Check HTML source for Next.js prefetch links: `curl -s "{site_url}" | grep -oE 'href="(/[^"]*)"' | sort -u`

Add any discovered SPA routes to the crawl queue. Note in `sitemap.md` which routes were discovered via SPA detection vs. `<a>` tags.

This is best-effort — some SPA routes are only discoverable by clicking navigation elements (covered by Step 3 interactive testing).

#### Animation Framework Detection

Check via HTML source and snapshot:
```bash
curl -s "{site_url}" | grep -oiE '(gsap|three\.js|lottie|anime\.js)'
```
Also check snapshot for `canvas` elements and `[class*="lottie"]` elements.

Record in discovery.json: `"animation_frameworks": {"gsap": true, "threejs": false, ...}`
If WebGL/Three.js detected, add to ALL Tier A reports: "⚠️ The site uses WebGL/Canvas. Screenshots may not accurately represent 3D content."

#### Step 1.5: Fetch Site Infrastructure

```bash
curl -s "{site_url}/robots.txt" > {run_dir}/robots.txt
curl -s "{site_url}/sitemap.xml" > {run_dir}/sitemap.xml  # may return 404 — check response
```

Add paths to `discovery.json`: `robots_txt_path` and `sitemap_xml_path`.
If sitemap.xml contains additional URLs not found via link crawling, add them to the link queue.

#### Step 2: Recursive Page Discovery

For EACH unique route in the queue (up to `max_pages`):

```bash
cmux browser --surface $SURFACE goto {url}
cmux browser --surface $SURFACE wait --load-state complete
cmux browser --surface $SURFACE snapshot -i  # save to {run_dir}/snapshots/{page_slug}.txt
cmux browser --surface $SURFACE screenshot --out {run_dir}/screenshots/{page_slug}-desktop.png
```

**Note:** Scroll capture is NOT done here. It happens in Step 4 (Post-Interaction Scroll Capture) AFTER interactive testing has revealed hidden content (expanded accordions, loaded "load more" content, etc.).

```bash
cmux resize-pane --pane $(cmux list-panes | grep -o 'pane:[0-9]*' | tail -1) -L --amount 400  # narrow for mobile
cmux browser --surface $SURFACE screenshot --out {run_dir}/screenshots/{page_slug}-mobile.png

# Tablet viewport
cmux resize-pane --pane $(cmux list-panes | grep -o 'pane:[0-9]*' | tail -1) -R --amount 200  # widen for tablet
cmux browser --surface $SURFACE screenshot --out {run_dir}/screenshots/{page_slug}-tablet.png
cmux resize-pane --pane $(cmux list-panes | grep -o 'pane:[0-9]*' | tail -1) -R --amount 200  # restore desktop  # restore desktop
```

Tablet scroll capture is NOT needed (desktop scroll captures cover the content). Tablet screenshot is for responsive layout evaluation only.

Also extract and save page metadata. Wait for SPA hydration using cmux browser wait:

```bash
cmux browser --surface $SURFACE wait --load-state complete
```

Then extract metadata via snapshot and curl:

```bash
cmux browser --surface $SURFACE snapshot -i  # analyze for title, h1, meta description, links, form elements, interactive elements
```

For meta tags not visible in snapshot, use curl:
```bash
curl -s "{url}" | grep -E '<title>|<meta name="description"|<link rel="canonical"|<meta property="og:|<script type="application/ld\+json"|<html lang'
```

Extract from HTML source:
- `title`: from `<title>` tag
- `h1`: from `<h1>` tag text
- `metaDesc`: from `<meta name="description" content="..."`
- `canonical`: from `<link rel="canonical" href="..."`
- `ogTitle`, `ogDesc`, `ogImage`: from `<meta property="og:*"`
- `jsonLd`: from `<script type="application/ld+json">` blocks
- `lang`: from `<html lang="..."`
- `viewport`: from `<meta name="viewport" content="..."`
- `wordCount`: estimate from snapshot text content length

Save metadata per page into `discovery.json.pages[]`.

For EACH page, after extracting metadata, determine and record:
- `purpose`: one sentence — what is this page FOR? (e.g., "Help visitor choose a pricing plan", "Show project case study results", "Collect visitor contact information")
- `visitor`: who most likely looks at this page? (e.g., "Decision maker comparing options", "Developer looking for API docs", "Citizen filing an appeal")
- `key_question`: what question does this visitor have? (e.g., "Which plan fits my needs?", "How do I authenticate API calls?", "What documents do I need?")

Also determine page complexity for effort allocation:
- `complexity`: "complex" (checkout, pricing, multi-step forms, dashboards, configurators) | "standard" (features, about, blog, services, category) | "simple" (legal, terms, privacy, 404, sitemap)

Derive from: number of interactive elements, form count, content depth, page purpose.
Agents allocate analysis depth proportionally: complex = full principle application, standard = standard analysis, simple = quick technical scan.

Derive these from: page URL, H1 text, content structure, position in navigation.
Keep each field to ONE sentence. This is a quick assessment, not deep analysis.

From each page:
- Extract all new internal links → add to queue
- Record: URL, page title, H1, meta description, navigation position

Update `state.json.pages_crawled` after each page.
Continue until queue is empty or `max_pages` reached.

#### Auth-Gated Content Detection

During crawl, detect pages that redirect to login:
- If `cmux browser --surface $SURFACE goto {url}` results in loading a login/register page (check snapshot for login form), record the original URL as auth-gated
- Record in discovery.json: `"auth_gated_pages": ["/dashboard", "/account", "/courses/viewer"]`
- In SITE-REVIEW.md, include a prominent section: "Pages behind authentication (not evaluated): {list}. Credentials are required to audit these pages."
- Do NOT attempt to log in. Do NOT ask user for credentials. Simply document what was found and what was not auditable.

#### Infinite Scroll Detection

After initial page load, check for infinite scroll via snapshot observation:
- Take initial snapshot: `cmux browser --surface $SURFACE snapshot -i`
- Scroll down to check for more content: `cmux browser --surface $SURFACE scroll --dy 2000`
- Note if the snapshot reveals a feed/list structure with `load more` triggers or dynamic loading patterns
- Infinite scroll heuristic: if page contains a list/feed structure with no visible "last page" pagination, assume infinite scroll possible

If infinite scroll detected:
- Do NOT scroll to "bottom" — there is no bottom
- Capture max 5 scroll screenshots (standard cap applies)
- Record in discovery.json per page: `"infinite_scroll": true`
- Note in sitemap.md: "⚠️ Infinite scroll detected on {page}. Content beyond 5 viewports not captured."


#### Step 2.5: Template Grouping

After crawling 10+ pages, detect template patterns from snapshot structure:
- Compare snapshot structural output across pages — look for repeated heading patterns, element hierarchies, and URL patterns (e.g., `/product/123`, `/product/456` → same template)
- Group pages by URL pattern and structural similarity

Group pages with identical structural signatures into template groups.

For each template group with >3 pages:
- Mark 3-5 representative pages for full analysis (diverse content: shortest, longest, most-linked)
- Mark remaining pages as `"template_sampled": true` in discovery.json
- All modules should analyze the template ONCE via representatives, then note: "Applies to {N} pages using this template"

Add to discovery.json schema:
```json
"template_groups": [
  {
    "template_id": "product-page",
    "signature": "...",
    "page_count": 600,
    "representative_pages": ["/product/123", "/product/456", "/product/789"],
    "all_pages": ["/product/123", "/product/456", ...]
  }
],
```

Per-page schema addition: `"template_group": "product-page"` or `null` if unique.

Modules MUST respect template grouping: analyze representative pages in full, note "This finding applies to all {N} pages using the '{template_id}' template" in findings.

#### Population Estimation from Sitemap

If `{run_dir}/sitemap.xml` was fetched and contains URLs:
```javascript
// Parse sitemap and count URLs matching each template group pattern
// Example: template "product-page" has representatives /product/123, /product/456
// Sitemap contains 10000 URLs matching /product/*
// Set template_groups[].estimated_population = 10000
```

For each template group, extract the URL pattern from representative pages and count matches in sitemap.xml.
Update discovery.json: `template_groups[].estimated_population` (from sitemap) vs `template_groups[].page_count` (actually crawled).

All module reports should use `estimated_population` when stating "This finding affects ~{N} pages."

#### Uncrawled Page Type Alert

After crawl completes (max_pages reached), check sitemap.xml for URL patterns NOT represented in crawled pages:

1. Extract all unique URL path patterns from sitemap (e.g., /agents/*, /reviews/*, /api/docs/*)
2. Compare with crawled page URL patterns
3. For each UNCRAWLED pattern with >10 URLs in sitemap:
   - Record in discovery.json: `"uncrawled_types": [{"pattern": "/agents/*", "estimated_count": 5000, "sample_urls": ["...", "..."]}]`
   - Note in sitemap.md: "⚠️ Not included in sample: /agents/* (~5000 pages), /reviews/* (~3000 pages)"

4. In SITE-REVIEW.md, add a section BEFORE findings:
```markdown
## Coverage Limitations

Found {total_sitemap_urls} URLs in sitemap.xml. Evaluated: {crawled_count} ({percentage}%).

Page types not included in the sample:
| Pattern | Count | Reason | Recommendation |
|---------|-------|--------|----------------|
| /agents/* | ~5000 | Exceeded max_pages | Run a separate audit of the agent profile template |
| /reviews/* | ~3000 | Not prioritized | Include 3-5 in the next audit |

Findings below apply ONLY to the evaluated pages.
```

This is NOT a finding — it is a transparency disclosure. The audit honestly reports what it DID and DID NOT cover.

#### Step 3: Interactive Element Discovery

For sites with more than 20 pages, limit interactive element testing to 15 pages selected by these criteria (in priority order):
1. Homepage (always included)
2. Pages with forms (contact, signup, login, checkout)
3. Pages with pricing or plans
4. Depth-1 navigation pages (direct children of main nav)
5. If slots remain: pages with the most incoming internal links (from discovery data)

Document which pages were tested interactively in `discovery.json.interactive_pages` array.
Motion/hover capture (Step 3.5) uses a subset of these — the top 10 by the same criteria.

For EACH page (within the interactive testing scope), interact with EVERY element:

**Buttons and clickables:**
- `cmux browser --surface $SURFACE click {ref}` every button that opens modals, dropdowns, menus, sidebars
- `cmux browser --surface $SURFACE snapshot -i` to capture each opened state
- Click close/X button or take snapshot to verify it closes

**Forms:**
- Find every form on the site via snapshot
- Extract form structure from snapshot: identify all input, textarea, select elements with their labels, placeholders, required state, and submit button text
- Store extracted forms in `discovery.json.pages[].forms`
- Document: fields, labels, placeholders, required markers, submit button text
- Check validation states: click submit without filling → snapshot for error states
- Check field types visible in snapshot

#### Masked Content Detection

Look for buttons that reveal hidden content (common on real estate, marketplaces):

From the snapshot, find button elements with labels matching reveal patterns:
- Russian: "показать телефон", "показать номер", "показать email", "показать контакт", "раскрыть", "развернуть", "показать полностью", "читать далее"
- English: "show phone", "show number", "show contact", "read more"

For each detected masked content button (on interactive testing pages):
1. Click the button: `cmux browser --surface $SURFACE click {ref}`
2. Take snapshot of revealed state: `cmux browser --surface $SURFACE snapshot -i`
3. Record revealed content in discovery.json per page: `"revealed_content": [{"trigger": "Show phone", "content": "+7 999 123-45-67"}]`

#### Interactive Controls Detection (beyond <form>)

Detect interactive filter/calculator widgets that are NOT wrapped in <form> tags:

From the snapshot, identify:
- Range sliders: elements with `role="slider"` or `type="range"`
- Select dropdowns outside forms: `role="listbox"` elements
- Checkbox/radio groups: `role="group"`, `role="radiogroup"`

Record in discovery.json per page: `"interactive_controls": [{type, label, page_section}]`
Note: These controls cannot be tested by Tier A modules. Accessibility (Tier B) should test their keyboard navigability.

#### Cart Population (e-commerce/marketplace/food delivery)

If business_type in [ecommerce, marketplace, food_delivery]:
1. Find one product/item page with "Add to Cart" / "Add to Cart" / "Add" button
2. Click it, wait 2 seconds
3. Navigate to /cart → screenshot + snapshot (populated state)
4. If cart populated, navigate to /checkout → screenshot + snapshot
5. Record populated states in discovery.json: `"cart_populated": true`

This gives modules populated checkout views instead of empty-cart states.

**Navigation:**
- Mobile menu: `cmux resize-pane --pane $(cmux list-panes | grep -o 'pane:[0-9]*' | tail -1) -L --amount 400  # narrow for mobile` → find hamburger menu ref in snapshot → `cmux browser --surface $SURFACE click {hamburger_ref}`
- Dropdown menus: click each nav item with submenus via snapshot refs
- Tab bars, sidebars, breadcrumbs
- `cmux resize-pane --pane $(cmux list-panes | grep -o 'pane:[0-9]*' | tail -1) -R --amount 200  # restore desktop` → restore desktop

**Dynamic content:**
- Scroll to bottom of each page → check for lazy-loaded content
- Click "load more" / pagination buttons
- Check scroll-triggered animations

**States:**
- Empty states (if data-dependent pages, note what they show with no data)
- Loading states (observe during navigation transitions via snapshot)
- Error states (navigate to non-existent routes → 404 page)
- Hover states: use `cmux browser --surface $SURFACE hover {ref}` to trigger hover effects, then take screenshot

#### Step 3.5: Motion & Hover Capture Pass

On up to 10 key pages (homepage + main nav pages + primary conversion pages):

**Hover state capture:**

cmux browser supports hover directly:
```bash
cmux browser --surface $SURFACE hover {element_ref}
cmux browser --surface $SURFACE screenshot --out {run_dir}/screenshots/{page_slug}-hover-{element_desc}.png
```
Use snapshot refs (e1, e2, ...) from `snapshot -i` output rather than CSS selectors with quotes to avoid quoting issues.

**Page transition observation:**
Navigate between 3-5 pages in sequence. After each navigation, note:
- Did the page load instantly or with a visible transition?
- Was there a loading indicator?
- Screenshot the loading/transition state if visible.

Save transition observations to `{run_dir}/motion-notes.md`:
```markdown
# Motion & Transition Notes

## Page Transitions
| From | To | Behavior | Loading Indicator |
|------|----|----------|-------------------|

## Hover States Captured
| Page | Element | Screenshot | Hover Effect |
|------|---------|------------|-------------|

## Scroll Animations
| Page | Element | Trigger | Type |
|------|---------|---------|------|
```

**Scroll animation detection:**

Trigger scroll animations using:
```bash
cmux browser --surface $SURFACE scroll --dy 500
cmux browser --surface $SURFACE screenshot --out {run_dir}/screenshots/{page_slug}-scroll-{N}.png
```
Repeat for progressive scroll positions. JS-based scroll is also available via `eval`:
```bash
cmux browser --surface $SURFACE eval 'window.scrollTo(0, 800)'
```
Note any scroll-triggered animations observed in screenshots in motion-notes.md.

This data feeds UX Design Dimension 6 (Motion & Micro-interactions).
Tier A modules can read `{run_dir}/motion-notes.md` and hover screenshots from cache.

#### Step 3.6: Theme/Dark Mode Detection

Check for theme toggle via snapshot:
```bash
cmux browser --surface $SURFACE snapshot -i
```
Look in snapshot for theme toggle buttons (labels/aria: "dark mode", "dark", "theme", "тёмн", "тем").

If theme toggle found:
1. Click the toggle: `cmux browser --surface $SURFACE click {toggle_ref}`
2. Screenshot for up to 10 key pages (homepage + depth-1 nav pages):
   - `cmux browser --surface $SURFACE screenshot --out {run_dir}/screenshots/{page_slug}-desktop-dark.png`
3. Click toggle again to restore original theme
4. Record in discovery.json: `"dark_mode": {"detected": true, "pages_captured": [...]}`

Tier A modules (UX Design, Brand Consistency, Accessibility) should analyze BOTH theme screenshots when available.
If no toggle found: `"dark_mode": {"detected": false}`. Skip dual capture.

#### Visually Impaired Version Detection (GOST R 52872-2019)

Check for "version for visually impaired" toggle (Russian government/institutional sites) via snapshot:
```bash
cmux browser --surface $SURFACE snapshot -i
```
Look in snapshot for BVI toggle buttons (labels: "Версия для слабовидящих", "Для слабовидящих").

If found:
1. Click the toggle: `cmux browser --surface $SURFACE click {bvi_toggle_ref}`
2. Screenshot for up to 5 key pages and save as `{page_slug}-desktop-bvi.png`
3. Restore normal version
4. Record: `"visually_impaired_version": {"detected": true}`
5. Accessibility module evaluates BOTH versions

#### Step 4: Post-Interaction Scroll Capture

**After** interactive testing (Step 3) has expanded accordions, clicked "load more" buttons, and revealed hidden content, NOW capture full-page scroll screenshots. This ensures expanded states and dynamically loaded content appear in scroll captures.

For EACH page (desktop only):

Capture scroll screenshots using the `scroll` command and `screenshot`:
```bash
cmux browser --surface $SURFACE screenshot --out {run_dir}/screenshots/{page_slug}-desktop-scroll-1.png
cmux browser --surface $SURFACE scroll --dy 800
cmux browser --surface $SURFACE screenshot --out {run_dir}/screenshots/{page_slug}-desktop-scroll-2.png
# repeat as needed (max 5 scroll screenshots per page)
cmux browser --surface $SURFACE snapshot -i  # save as {run_dir}/snapshots/{page_slug}.txt
```

This gives Tier A modules the accessibility tree of the ENTIRE page (snapshot contains all DOM content, not just above-fold).
Do NOT attempt scroll capture on mobile viewport.

**Limits:** Max 5 scroll screenshots per page. Max 150 scroll screenshots total across the site. If a page exceeds 5 viewport heights, capture the first 3 and the last 2 (top + bottom of page). Skip scroll capture entirely on pages shorter than 2 viewports.

#### Step 5: Viewport Testing

**`viewport` and `resize` are NOT supported on WKWebView.** Use `resize-pane` to change browser pane width.
See `~/.claude/skill-library/references/cmux-browser.md` section 16 for details.

For EACH page, test at minimum:
- Desktop: current pane width (typically ~1440px if full-width)
- Mobile: narrow the pane by ~400px

```bash
# Save pane ref for resizing
PANE=$(cmux list-panes | grep -o 'pane:[0-9]*' | tail -1)

# Desktop screenshot (current size)
cmux browser --surface $SURFACE screenshot --out {run_dir}/screenshots/{page_slug}-desktop.png

# Narrow for mobile
cmux resize-pane --pane $PANE -L --amount 400
sleep 0.5
cmux browser --surface $SURFACE screenshot --out {run_dir}/screenshots/{page_slug}-mobile.png

# Restore
cmux resize-pane --pane $PANE -R --amount 400
```

Note any differences in layout, hidden/shown elements, navigation changes.

#### Step 6: Business Classification

**Business type is CONTEXT, not rules.** The classification helps with:
- Module weight calculation (which aspects matter MORE for this type of site)
- Skill library loading (which domain skills to include)
- General orientation for agents

Business type does NOT dictate:
- Which checks to run on each page (agents decide per page purpose)
- Which findings to skip (agents decide per Foundational Principle)
- How to evaluate any specific element (the principle + page purpose decide)

An agent evaluating a government site should not think "I'm in government mode,
skip social proof." It should think "This is a service instruction page,
the visitor needs to understand the process — social proof is irrelevant HERE."
The difference is subtle but critical: the PAGE drives decisions, not the site label.

Based on what was discovered, classify the site:

| Type | Signals |
|------|---------|
| SaaS | Pricing tiers, free trial CTA, dashboard/app section, login/signup, feature pages |
| E-commerce | Product cards, cart, checkout, categories, filters, reviews |
| Agency/Services | Case studies, team page, service descriptions, contact/quote forms |
| Content/Blog | Article listing, categories/tags, author pages, search |
| Local Business | Physical address, hours, map embed, local phone, booking |
| Portfolio | Project gallery, about/bio, minimal pages |
| Landing Page | Single page, strong CTA, no navigation depth |
| Marketplace | Multi-seller, search, categories, user profiles |
| News/Media | News feed, breaking ticker, article dates, multiple authors, categories/tags, high update frequency, ads |
| Education/EdTech | Course catalog, curriculum/program pages, student reviews, certificates, webinar schedule, installment plans |
| Classifieds/Listings | Listing cards with photos, filters sidebar, map view, agent/seller profiles, price ranges, search-centric |
| Government/Public | Service catalog, department pages, citizen forms, news/press, legal text, government coat of arms, accessibility statement, .gov domain |
| Food Delivery | Address input gate, restaurant cards with delivery time, menu with modifiers/prices, cart, order tracking |
| Creative/Portfolio | Case study gallery, uniquely designed pages (zero template matches), GSAP/Three.js/Lottie, custom cursor, video hero, <100 pages |

#### Step 7: Adaptive Weight Calculation

Based on business type, adjust module weights:

**Base weights (default):**

| Module | Base Weight |
|--------|-------------|
| UX Design | 0.20 |
| Marketing Content | 0.15 |
| Conversion | 0.15 |
| SEO Technical | 0.10 |
| SEO Content | 0.10 |
| Accessibility | 0.08 |
| Performance | 0.08 |
| Information Architecture | 0.07 |
| Brand Consistency | 0.07 |

**Multipliers by business type:**

| Type | Adjusted Weights (multipliers on base) |
|------|----------------------------------------|
| SaaS | Conversion ×2, Marketing Content ×1.5, Performance ×1.5 |
| E-commerce | Performance ×2, Conversion ×2, SEO Technical ×1.5 |
| Content/Blog | SEO Content ×2, Marketing Content ×1.5, Information Architecture ×1.5 |
| Local | Accessibility ×1.5, SEO Technical ×2, Brand Consistency ×1.5, Conversion ×1.5, Performance ×1.5 |
| Landing Page | Conversion ×2.5, Marketing Content ×2, UX Design ×1.5 |
| Agency | UX Design ×1.5, Brand Consistency ×1.5, Marketing Content ×1.5 |
| Portfolio | UX Design ×2, Brand Consistency ×2 |
| Marketplace | Information Architecture ×2, Performance ×1.5, Conversion ×1.5 |
| News/Media | Performance ×2, SEO Content ×2, Accessibility ×1.5 |
| Education/EdTech | Conversion ×2, Marketing Content ×1.5, SEO Content ×1.5 |
| Classifieds/Listings | Performance ×2, Conversion ×2, UX Design ×1.5 |
| Government/Public | Accessibility ×3, Information Architecture ×2, SEO Content ×1.5, Performance ×1.5, Marketing Content ×0.2, Conversion ×0.3, Brand Consistency ×0.3 |
| Food Delivery | Conversion ×2, Performance ×2, UX Design ×1.5 |
| Creative/Portfolio | UX Design ×2, Performance adjusted thresholds, Brand Consistency ×0.3 |

After applying multipliers, normalize so weights sum to 1.0.

#### Step 8: Product Context Generation

If `.claude/product-marketing-context.md` does NOT exist in the project:

Generate it from what was discovered:

```markdown
# Product Marketing Context

## Product
- **Name:** {from page title / logo}
- **Type:** {business_type}
- **Value Proposition:** {from hero section / H1}
- **Key Features:** {from feature sections}

## Target Audience
- **Primary:** {inferred from copy tone, imagery, pricing}
- **Language/Tone:** {formal/casual/technical/friendly}

## Pricing
- **Model:** {free/freemium/paid/subscription/one-time}
- **Tiers:** {if detected}

## Competitors
- **Mentioned:** {if comparison pages or "vs" pages found}

## Brand Voice
- **Tone:** {extracted from copy analysis}
- **Key phrases:** {recurring marketing phrases}
```

Write to `{run_dir}/product-marketing-context.md` ONLY (inside run dir, NOT project tree).
Do NOT show this to user during Discovery — it interrupts the pipeline.
Do NOT suggest copying. The recommendation will appear in SITE-REVIEW.md at the end.
Do NOT write to project tree — this is FORBIDDEN.

### Output: `{run_dir}/discovery.json`

```json
{
  "site_url": "...",
  "discovered_at": "ISO timestamp",
  "business_type": "saas|ecommerce|agency|content|local|portfolio|landing|marketplace",
  "robots_txt_path": "robots.txt",
  "sitemap_xml_path": "sitemap.xml",
  "pages": [
    {
      "url": "...",
      "slug": "homepage",
      "title": "...",
      "h1": "...",
      "metaDesc": "...",
      "canonical": "...",
      "ogTitle": "...",
      "ogDesc": "...",
      "ogImage": "...",
      "jsonLd": ["..."],
      "lang": "en",
      "viewport": "width=device-width, initial-scale=1",
      "nav_position": "main|footer|hidden|none",
      "has_forms": true,
      "has_modals": true,
      "has_pricing": false,
      "forms": [
        {
          "action": "/contact",
          "method": "POST",
          "fields": [
            {"name": "email", "type": "email", "required": true, "label": "Email"},
            {"name": "message", "type": "textarea", "required": false, "label": "Message"}
          ],
          "submit_text": "Send"
        }
      ],
      "snapshot": "snapshots/{slug}.txt",
      "wordCount": 0,
      "screenshots": {
        "desktop": "screenshots/{slug}-desktop.png",
        "tablet": "screenshots/{slug}-tablet.png",
        "mobile": "screenshots/{slug}-mobile.png"
      },
      "scroll_screenshots": ["screenshots/{slug}-desktop-scroll-1.png", "screenshots/{slug}-desktop-scroll-2.png"],
      "interactive_tested": true,
      "purpose": "",
      "visitor": "",
      "key_question": "",
      "complexity": "standard"
    }
  ],
  "interactive_pages_count": 0,
  "interactive_elements": {
    "modals": ["login modal", "signup modal", "cookie consent"],
    "forms": ["contact form (3 fields)", "newsletter (1 field)"],
    "dropdowns": ["nav > Products", "nav > Resources"],
    "mobile_menu": true,
    "search": true,
    "chat_widget": false
  },
  "weights": {
    "ux_design": 0.XX,
    "marketing_content": 0.XX,
    "conversion": 0.XX,
    "seo_technical": 0.XX,
    "seo_content": 0.XX,
    "accessibility": 0.XX,
    "performance": 0.XX,
    "information_architecture": 0.XX,
    "brand_consistency": 0.XX
  },
  "motion_notes_path": "motion-notes.md",
  "hover_screenshots": ["screenshots/{slug}-hover-cta.png", "..."],
  "skill_library_skills": ["list of skill paths loaded for this audit"],
  "product_context_generated": true
}
```

### Output: `{run_dir}/sitemap.md`

Human-readable sitemap:

```markdown
# Site Map

## Main Navigation
- / — Homepage
  - /features — Features
  - /pricing — Pricing
  - /about — About Us
- /blog — Blog
  - /blog/article-1 — Article Title
  - ...

## Footer Links
- /privacy — Privacy Policy
- /terms — Terms of Service
- ...

## Discovered via Interaction
- Modal: Login (triggered from header button)
- Modal: Newsletter popup (triggered on scroll 50%)
- ...

## Total
- Pages: {N}
- Modals: {N}
- Forms: {N}
- Interactive elements: {N}
```

Update state.json: `updated_at` → now. Do NOT update phase here — the stop hook handles the transition. Emit `<bishx-site-done>`

---

## Phase 0.5: ASK

**Actor:** Lead (main thread)

After Discovery, present a summary and confirm scope before launching 9 opus agents.

```
AskUserQuestion(
  questions=[{
    question: "Found {N} pages ({business_type}). Run a full audit (9 modules)?",
    header: "Scope",
    multiSelect: false,
    options: [
      {
        label: "Full (Recommended)",
        description: "All 9 modules: UX Design, Marketing, Conversion, SEO Tech, SEO Content, Accessibility, Performance, IA, Brand. ~{N} pages."
      },
      {
        label: "Visual only",
        description: "UX Design + Brand Consistency + Marketing Content (3 modules)"
      },
      {
        label: "SEO + Performance",
        description: "SEO Technical + SEO Content + Performance + Accessibility (4 modules)"
      },
      {
        label: "Custom",
        description: "Select modules manually"
      }
    ]
  }]
)
```

If "Custom" → follow up with multiSelect list of all 9 modules.

Before presenting AskUserQuestion, set `waiting_for: "scope_selection"` in state.json. After user responds, set `waiting_for: ""`.

Store selected modules in `state.json.selected_modules`. Adjust `modules_total` to `len(selected_modules)`. Do NOT update phase — the stop hook handles the transition. Emit `<bishx-site-done>`

---

## Phase 1: EXECUTE

**Actor:** Lead (main thread) spawns agents in waves.

### Browser Sharing Architecture

cmux browser is a single browser surface. Multiple agents CANNOT use it simultaneously.
Solution: two-tier execution model.

**Tier A — Cache-based modules (no live browser needed):**
These modules work from Discovery cache (screen reads, snapshots, discovery.json, sitemap.md).
They analyze existing data and do NOT call any cmux browser tools.
Can run in parallel — they don't touch the browser.

**Tier B — Live browser modules (need cmux browser):**
These modules MUST interact with the live site (keyboard navigation, performance measurement).
Run sequentially — one at a time, exclusive browser access.

### Discovery Cache

Phase 0 DISCOVER stores everything agents need:
- `{run_dir}/screenshots/` — desktop + tablet + mobile screen reads of every page, plus desktop scroll reads (`{page}-desktop-scroll-*.txt`) for full-page visual analysis, and hover state reads (`{page}-hover-*.txt`)
- `{run_dir}/snapshots/` — accessibility tree snapshot of every page (saved as .txt)
- `{run_dir}/discovery.json` — full site structure, interactive elements, page metadata
- `{run_dir}/sitemap.md` — human-readable site map
- `{run_dir}/motion-notes.md` — hover states, page transitions, and scroll animation observations

During Discovery, for EACH page, Lead saves:
```bash
cmux browser --surface $SURFACE goto {url}
cmux browser --surface $SURFACE wait --load-state complete
cmux browser --surface $SURFACE snapshot -i  # save to {run_dir}/snapshots/{page_name}.txt
cmux browser --surface $SURFACE screenshot --out {run_dir}/screenshots/{page_name}-desktop.png
cmux resize-pane --pane $(cmux list-panes | grep -o 'pane:[0-9]*' | tail -1) -L --amount 400  # narrow for mobile
cmux browser --surface $SURFACE screenshot --out {run_dir}/screenshots/{page_name}-mobile.png
cmux resize-pane --pane $(cmux list-panes | grep -o 'pane:[0-9]*' | tail -1) -R --amount 200  # widen for tablet
cmux browser --surface $SURFACE screenshot --out {run_dir}/screenshots/{page_name}-tablet.png
cmux resize-pane --pane $(cmux list-panes | grep -o 'pane:[0-9]*' | tail -1) -R --amount 200  # restore desktop
```

This cached data is sufficient for 7 of 9 modules.

### Skill Library Loading

Use discovery.json fields (`has_forms`, `has_modals`, `has_pricing`) per page to determine which conditional skills to load.

Before spawning agents, Lead reads ALL relevant skill-library files (see Skill Library Integration section above).
For each module, concatenate the relevant skill contents into a `{skill_context}` variable.
Budget: max 1500 lines total of skill content per agent prompt.
If combined skill content exceeds 1500 lines, prioritize: (1) the module's primary skill first, (2) then secondary skills. Truncate the least relevant skill to fit within budget.

### Agent Spawn Pattern

```
Task(
  subagent_type="oh-my-claudecode:executor-high",
  model="opus",
  prompt="You are auditing website '{site_url}' ({business_type}).

Run dir: {run_dir}
Browser access: {yes|no — depends on tier}

Include in EVERY agent prompt:
- Full `sitemap.md` content (human-readable site map)
- Full `discovery.json` (structure, metadata, weights, forms — agents need all of it)
- Full Finding Template (sections 1-10, copied from the Finding Template section)
- Full Scoring Rules (FAIL=-15, WARN=-5, start 100, grade bands)
- Skill-library context for this module (max 1500 lines, prioritized)

Do NOT embed snapshot text or screenshot images in the prompt. Agents read these via `Read` tool using file paths from `discovery.json.pages[].snapshot` and `discovery.json.pages[].screenshots`.

SITE MAP:
{sitemap.md content}

DISCOVERY DATA:
{full discovery.json content}

SCROLL SCREENSHOTS: Available at {run_dir}/screenshots/{page}-desktop-scroll-*.png for full-page visual analysis.
MOTION NOTES: Available at {run_dir}/motion-notes.md for hover/transition/animation observations.

SKILL LIBRARY CONTEXT:
{skill_context — full content of relevant skills, max 1500 lines}

FOUNDATIONAL PRINCIPLE (apply to EVERY finding):
Every element on a page exists to serve a specific human in a specific moment.
Evaluate through 5 layers + meta-layer:
  Layer 1 — FOR WHOM: right audience? right emotional tone? right assumed knowledge?
  Layer 2 — WHAT: visitor's logic or creator's logic? right depth? nothing missing/excess?
  Layer 3 — HOW: right format for cognitive mode (scanning/reading/deciding/doing)? right sequence?
  Layer 4 — FEELING: visitor in control? familiar web patterns? not overwhelmed by total page load?
  Layer 5 — BEHAVIOR: interactions predictable? transparent (no dark patterns)? feedback on actions?
             mistakes forgivable? progress visible? time respected?
  Meta — JOURNEY: promise=reality? effort≤value? trust matches ask? next step clear? memorable?
Your module's technical checks are CONCRETE INSTANCES of this principle.
If a technical check passes but the principle is violated — that IS a finding.

PER-PAGE PURPOSE DATA:
Each page in discovery.json has `purpose`, `visitor`, and `key_question` fields.
Use these as your STARTING POINT for each page's HB1 heartbeat.
You may refine them based on your deeper analysis — if your understanding
differs from Discovery's, YOUR real-time assessment wins. Note discrepancies.

TOOLKIT APPROACH:
Your module's checks are a toolkit of common patterns, not a mandatory checklist.
For each page, select which checks are RELEVANT based on that page's purpose.
Checks not relevant to a page → note as "N/A for this page type" (do NOT run them).
If you encounter an element not in your toolkit → apply the Unknown Element Protocol.
Thresholds are DEFAULT indicators. You MAY override with principle-based reasoning,
but MUST justify: "Threshold {X} triggered/not triggered, because: {reasoning}."

BEHAVIOR STANDARDS (follow these throughout your analysis):
- Fresh eyes: each page independently, no anchoring to previous pages
- Visitor mind: 5 seconds as first-time visitor BEFORE any technical checks
  (for data-dense pages: "Can I find the best option in 5 sec? Is sort/filter clear?")
- Design intent: before visual FAIL, ask "could this be intentional?"
- State assumptions: tag every assumption explicitly [Assumption: ...]
- Confidence: tag findings [Certain], [Likely], or [Possible]
- Plain language: explain every UX term immediately
- Technical fast path: binary issues (broken link, missing alt) = short format, no 5-layer analysis
- Depth > breadth: after 25 findings, deepen top 10 instead of finding more
- 1 positive per 5 negatives: mandatory
- Anti-copy-paste: same issue on 3+ pages = ONE pattern finding
- Effort scale: quick fix / design change / development / architecture / strategic (+compliance for regulated)
- Score normalization: unique problems, not total instances
- Complexity effort: complex pages = deep, simple pages = quick scan
CONTEXTUAL INTELLIGENCE (read the context of what you see):
- Temporal: dynamic data = snapshot. Tag volatility. Evaluate PRESENTATION not DATA.
- Regulatory: detect licenses/disclaimers → stricter standards, conservative recommendations
- YMYL: health/finance/safety content → maximum E-E-A-T, credentials MUST be visible
- Revenue model: how does the site earn? Is it transparent to visitor? Affiliate = disclose.
- Variants: personalization/AB detected? Note "audit = default anonymous state"
- Data pages: tables/results/listings → comparison UX evaluation, not per-item checks
- Layer 4-5 violations: actively look for app banners, popups, fake urgency, pre-checked opts

MANDATORY HEARTBEATS (you MUST follow this protocol):
  [HB1] Before EACH page: write who the visitor is, what they need, their emotional state
  [HB2] After technical checks for a page, BEFORE writing findings: check principle violations
  [HB3] After every 5th finding: check if findings are specific or becoming generic
  [HB4] Before Module Score: final principle review of all findings
These markers [HB1-4] MUST appear in your report. Report is incomplete without them.

BUSINESS TYPE: {business_type}
Adapt your checks for this business type per the Module Applicability table in SKILL.md.
Skip checks that are domain-inappropriate (note as "N/A for {business_type}").

AUDIT INSTRUCTIONS:
Read the audit module instructions at:
~/.claude/plugins/bishx/skills/site/types/{module_type}.md

Follow them exactly. Analyze every page listed in the sitemap.
Do not economize on thoroughness.

FINDING TEMPLATE — include the FULL Finding Template content (from the Finding Template section of SKILL.md, sections 1-10) in every agent's spawn prompt. Do NOT just reference it — paste the entire template so the agent has it in context.
Sections 1-3, 6-7, 10 are REQUIRED. Sections 4-5, 8-9 write 'N/A' if inapplicable.

SCORING:
{scoring_rules — see Unified Scoring System section}

IMPORTANT: When your report is complete, add this marker as the VERY LAST line:
<!-- BISHX-SITE-REPORT-COMPLETE -->

Output: {run_dir}/{module}-report.md"
)
```

### Module → File Mapping

| Module | Type File | Report File | Tier | Browser |
|--------|-----------|-------------|------|---------|
| UX Design | `ux-design.md` | `ux-design-report.md` | A | No — uses cached screenshots + snapshots |
| Marketing Content | `marketing-content.md` | `marketing-content-report.md` | A | No — analyzes text from snapshots |
| SEO Technical | `seo-technical.md` | `seo-technical-report.md` | A | No — uses cached meta/schema data from discovery |
| SEO Content | `seo-content.md` | `seo-content-report.md` | A | No — analyzes content from snapshots |
| Information Architecture | `information-architecture.md` | `information-architecture-report.md` | A | No — analyzes sitemap + navigation from discovery |
| Brand Consistency | `brand-consistency.md` | `brand-consistency-report.md` | A | No — compares cached data across pages |

### Brand Consistency Modes

Based on business_type, Brand Consistency operates differently:
- **Standard** (default): full cross-page consistency evaluation
- **Chrome-only** (when business_type is "creative_portfolio" OR discovery.json.template_groups has zero content-area matches):
  - Evaluate site CHROME only: header, footer, navigation consistency across pages
  - Do NOT penalize content area variation on showcase/case-study pages
  - Report note: "Showcase pages evaluated for internal coherence, not cross-page consistency"
- **Multi-department** (when business_type is "government" OR >5 unique addresses detected):
  - Suppress NAP consistency FAIL
  - Check each department page has its OWN correct contact info
  - WARN (not FAIL) for cross-department info mismatch

| Conversion | `conversion.md` | `conversion-report.md` | A* | No (default). **Yes if business_type=ecommerce** — promoted to Tier B for checkout/cart testing |
| Accessibility | `accessibility.md` | `accessibility-report.md` | B | **Yes** — keyboard nav, focus testing, live ARIA |
| Performance | `performance.md` | `performance-report.md` | B | **Yes** — CWV measurement, resource timing |

\* Accessibility: full keyboard navigation testing on up to 15 key pages. Automated JS-only checks (landmarks, names, alt text, contrast, touch targets) on ALL pages.
\* Performance reports MUST include a "Measurement Environment" section stating: measurements are from a local Chromium browser with unthrottled network. Real-world performance on mobile/4G may be 2-3x worse.
\* Performance: full CWV measurement on up to 20 representative pages (same selection as interactive testing + one page per template group). Lightweight check (navigate + LCP only) on remaining pages. Do NOT measure full CWV on every page — this is operationally infeasible for sites >30 pages.
\* Conversion is Tier A by default but promoted to Tier B (live browser) when business_type is "ecommerce". In Tier B mode, Conversion runs in Wave 2 AFTER Accessibility, BEFORE Performance. It tests: checkout flow, cart interaction, product configuration (size/color selectors), filter/search functionality. The conversion.md type file handles both modes — check `{browser_access}` in the spawn prompt.

\* Performance thresholds by business_type:
  - **Default:** WARN >3MB, FAIL >5MB per page. Image FAIL >500KB above-fold.
  - **Creative/Portfolio:** WARN >8MB, FAIL >15MB. Image WARN >1MB, FAIL >3MB. Prioritize CWV over payload.
  - **Video pages (any type):** WARN >5MB, FAIL >10MB (already defined).
  Note: "Portfolio sites use heavy media content. CWV matters more than payload size."

### Module Filtering by Scope

Only spawn agents for modules listed in `state.json.selected_modules`.
- If user selected **"Full (Recommended)"** — all 9 modules.
- If **"Visual only"** — ux-design, brand-consistency, marketing-content.
- If **"SEO + Performance"** — seo-technical, seo-content, performance, accessibility.
- If **"Custom"** — whatever user picked in the follow-up multiSelect.

Skip modules not in `selected_modules`. Adjust `modules_total` accordingly.
Wave composition adapts: if a Tier B module is not selected, Wave 2 may be empty or have one module.

### Execution Order

```
Wave 1 (parallel):  UX Design + Marketing Content + SEO Technical +
                    SEO Content + IA + Brand Consistency + Conversion
                    (7 modules, all Tier A, no browser)
                    — filtered to only selected_modules

Wave 2 (sequential): Accessibility → Performance
                     (2 modules, Tier B, exclusive browser access)
                     — filtered to only selected_modules
```

Wave 2 starts AFTER Wave 1 completes. Within Wave 2, each module runs alone.
Accessibility runs first (it may discover interactive issues that Performance should note).

```
Wave 2 order (when Conversion is Tier B):
  Accessibility → Conversion → Performance
Wave 2 order (default):
  Accessibility → Performance
```

Update state.json:
- Do NOT update phase here — the stop hook already set it to "execute" during the ask→execute transition.
- `wave` → `1` (then `2` when Wave 1 completes)
- `modules_total` → `len(selected_modules)` (already set in ASK phase; do NOT hardcode 9)
- `modules_completed` → `[]` (append module name as each report appears)
- `agent_pending` → `true` (while agents are running)

When `modules_completed.length == modules_total` (all selected module reports exist) → set `agent_pending` to `false` → emit `<bishx-site-done>`

### Error Recovery

If an agent does not produce a report file within a reasonable time:
1. Note the module as failed in `state.json.modules_failed`
2. Exclude it from scoring (reduce `modules_total`)
3. Proceed with available reports
4. Include a "Module Failures" section in SITE-REVIEW.md listing modules that did not complete

Do NOT wait indefinitely for a single failed module — the audit continues with available data.

---

## Phase 2: SYNTHESIZE

**Actor:** Lead (main thread)

### 2.1 Read All Reports

Read every `*-report.md` from `{run_dir}/`.

### 2.2 Calculate Module Scores

Each module report contains a score (0-100). Extract them.

Calculate weighted total:

```
Site Score = Σ (module_score × module_weight)
```

Using weights from `discovery.json`.

### Grade Assignment

| Grade | Range | Label |
|-------|-------|-------|
| A | 85-100 | Excellent |
| B | 70-84 | Good |
| C | 55-69 | Needs Work |
| D | 40-54 | Poor |
| F | 0-39 | Critical |

### 2.3 Diff with Previous Run

Check for previous audit: `ls .bishx-site/` — find the most recent directory before current.

If found, read its `scores.json` and calculate diff:

```markdown
## Changes Since {previous_date}
Overall: {old_score} → {new_score} ({diff}) {▲/▼/→}

| Module | Previous | Current | Change |
|--------|----------|---------|--------|
| UX Design | 72 | 78 | +6 ▲ |
| Conversion | 65 | 60 | -5 ▼ REGRESSION |
| ... | ... | ... | ... |
```

If REGRESSION detected (score dropped by ≥3 points) — flag it prominently.

### 2.4 Deduplicate Findings

Two findings are **duplicates** if they reference:
- The **same page** AND the **same element/section** (e.g., both about the hero CTA on homepage)

Deduplication rules:
1. **Severity:** Take the higher severity (FAIL wins over WARN)
2. **Content:** Merge both visual specifications — keep the more detailed description from either module
3. **Modules:** List all modules that found the issue: "Found by: Conversion, UX Design"
4. **Deductions:** Per-module scores are NOT affected. Deduplication only affects SITE-REVIEW.md presentation.
5. **Numbering:** Deduplicated findings get ONE finding number in the final report.

Near-duplicates (same element, different aspect — e.g., Conversion checks CTA placement, Marketing Content checks CTA copy) are NOT duplicates. They are separate findings with a cross-reference link in Section 7.

Sort by priority: critical → high → medium → low.

### 2.5 Cross-Reference Related Findings

In SITE-REVIEW.md, add cross-module links to Section 7 of each finding:

Format: `**Cross-module:** see also finding #{N} ({module_name}) — {reason}`

Example: `**Cross-module:** see also finding #12 (Marketing Content) — same hero block, copy issue`

Link findings when:
- Same page element referenced by multiple modules (different aspects)
- One fix resolves or affects another finding
- Same root cause manifests in different modules

### 2.6 Contradiction Detection

Explicitly check: do any module recommendations CONTRADICT each other?
Common contradictions:
- UX "add whitespace" vs Conversion "more content above fold"
- Performance "reduce page weight" vs Marketing "add rich media for engagement"
- Accessibility "simplify layout" vs Brand "maintain visual complexity for brand identity"

When found → create a TRADE-OFF finding:
"Trade-off: {Module A} recommends {X}, {Module B} recommends {Y}.
Recommended compromise: {Z}. Priority depends on business goals."

### 2.7 Score Normalization

Apply pattern-based scoring:
- Same problem on N pages = 1 deduction (pattern), not N deductions
- Per-module scores reflect UNIQUE problem count
- Total site score uses normalized per-module scores

### 2.8 Motivation Framing

Prepare for SITE-REVIEW.md:
- Calculate: current score → score after quick wins → score after strategic changes
- Identify: top 3 quick wins (effort: quick fix, impact: high)
- Frame as improvement roadmap, not failure report

### Output: `{run_dir}/scores.json`

```json
{
  "total_score": 72,
  "grade": "B",
  "weights_used": { ... },
  "module_scores": {
    "ux_design": 78,
    "marketing_content": 65,
    "conversion": 70,
    "seo_technical": 80,
    "seo_content": 60,
    "accessibility": 75,
    "performance": 82,
    "information_architecture": 68,
    "brand_consistency": 72
  },
  "findings_count": { "critical": 2, "high": 8, "medium": 15, "low": 10 },
  "previous_run": "2026-03-20_14-30",
  "diff": { ... }
}
```

Update state.json: `updated_at` → now. Do NOT update phase — the stop hook handles the transition. Emit `<bishx-site-done>`

---

## Finding Template

Every finding across ALL modules MUST use this exact structure.
Sections 1-3, 6-7, 10 are **REQUIRED**. Sections 4-5, 8-9 may be "N/A" if genuinely inapplicable.

```markdown
#### 1. Current State
{Where: page, section, position (above/below fold)}
{Screenshot: link to file in run_dir/screenshots/}
{Description: size, color, spacing, surroundings}
{Content: text/media in the element}

#### 2. Problem
{Core issue: what is broken / suboptimal}
{Principle: which UX/marketing/psychology rule is violated — Fitts's Law, Hick's Law, Jakob's Law, Gestalt, F-pattern, 60-30-10, visual hierarchy, etc.}
{Scenario: what the user is trying to do and where they get stuck}
{Who is affected: new/returning, mobile/desktop, segment}
{Emotion: what the user feels — confusion, distrust, frustration, fatigue}
{Gaze pattern: where the eye goes, where it gets lost, F/Z-pattern violation}

#### 3. Solution — Visual Specification
- **Position:** where to move it — after which block, before which element, relative to viewport
- **Size:** relative to surroundings — "full content width", "1.5× larger than body"
- **Color role:** primary/secondary/accent/neutral, contrast with background, relationship to palette
- **Typography:** role in hierarchy (H1/H2/body/caption), weight (bold/medium/regular), line height
- **Spacing and breathing room:** space around it — "double top margin", "minimum distance from element X"
- **Grouping:** what to visually group with (Gestalt proximity), what to separate from
- **Content:** exact wording of text/headline/microcopy, tone, max length

#### 4. States and Interactions (N/A if inapplicable)
- **Default:** how it appears on load
- **Hover:** what changes (color, shadow, scale, cursor)
- **Active/pressed:** feedback on click
- **Focus:** keyboard navigation — outline, color
- **Disabled:** when and how
- **Loading:** what the user sees while loading
- **Empty:** what is shown with no data
- **Error:** how the error is shown
- **Mobile:** tap target, swipe, long press

#### 5. Responsiveness (N/A if inapplicable)
- **Desktop (1440+):** position in grid
- **Tablet (768-1439):** what reflows, what hides
- **Mobile (375-767):** order, stacks vs horizontal, sticky
- **Must be visible** on all breakpoints: {what}
- **OK to hide** on mobile: {what}

#### 6. Target Pattern
{UX pattern name: "sticky CTA bar", "split hero", "progressive disclosure accordion"}
{Why it fits: similar problem, proven effectiveness}
{What to adapt: how the pattern applies to this specific context}

#### 7. Impact Context
- **Related elements:** what else on the page needs to move/change because of this
- **Related findings in THIS module:** "also resolves #{other finding in this module}"
- **Cascade:** if we move A → what happens to B and C
- **Other pages:** same pattern elsewhere — change consistently?

> **Note:** Cross-module links (connections to findings from OTHER modules) are added during the SYNTHESIZE phase, not in module reports. The module agent references only findings within its own report.

#### 8. Psychology and Marketing (N/A if inapplicable)
- **Target emotion** after the change
- **Psychological trigger:** urgency/social proof/loss aversion/reciprocity/authority
- **Funnel position:** awareness → interest → desire → action — which stage the user is at
- **Expected behavior:** where they will go next, what they will click

#### 9. A/B Test Hypothesis (N/A if inapplicable)
- **Test:** current vs proposed
- **Metric:** CTR / scroll depth / bounce rate / conversion / time on page
- **Expected lift:** rough estimate and rationale
- **Minimum sample size:** for statistical significance

#### 10. Priority
- **Level:** critical / high / medium / low
- **Impact metric:** conversion / retention / bounce / trust / NPS
- **Scale:** % of audience affected
- **Effort:** small (single element) / medium (section) / large (page restructure)
- **ROI:** impact ÷ effort
```

---

## Phase 3: REPORT

**Actor:** Lead (main thread)

Generate the single output file: `{run_dir}/SITE-REVIEW.md`

This is the primary deliverable. It must be **exhaustive** — a designer or another agent
can execute every recommendation without asking a single question.

### Document Structure

```markdown
# Site Review: {site_name}

**URL:** {site_url}
**Date:** {date}
**Business Type:** {business_type}
**Overall Score:** {score}/100 (Grade {grade})

---

## Improvement Roadmap

**Current level:** {score}/100 (Grade {grade})

*Improvement forecast (diminishing returns — the higher the baseline score, the harder it is to grow):*
- Score 0-50: quick wins ~+15, strategic ~+25
- Score 50-70: quick wins ~+10, strategic ~+20
- Score 70-85: quick wins ~+5, strategic ~+10
- Score 85+: incremental improvements through A/B testing and UX research

**After quick wins (1-3 days):** ~{score + quickwin_estimate}/100
**After strategic changes (2-4 weeks):** ~{score + strategic_estimate}/100

### Top 3 Quick Wins
1. {finding} — effort: quick fix — estimated impact: +{N} points
2. {finding} — effort: quick fix — estimated impact: +{N} points
3. {finding} — effort: quick fix — estimated impact: +{N} points

---

## Score Dashboard

| Module | Score | Grade | Weight | Key Issue |
|--------|-------|-------|--------|-----------|
| UX Design | 78 | B | 20% | Visual hierarchy unclear on pricing |
| Marketing Content | 65 | C | 15% | Value prop buried below fold |
| ... | ... | ... | ... | ... |
| **Total** | **{score}** | **{grade}** | | |

{if diff exists}
## Changes Since Previous Audit ({date})
| Module | Previous | Current | Change | |
|--------|----------|---------|--------|-|
| ... | ... | ... | +N ▲ / -N ▼ | |
{end if}

---

## Critical Findings (Fix First)

### Finding #1: {short title}

{Use the Finding Template (see "## Finding Template" section above). All 10 numbered sections.}

### Finding #2: {title}
{...same template...}

---

## High Priority Findings
{...findings with priority=high, same template...}

## Medium Priority Findings
{...}

## Low Priority Findings
{...}

---

## Positive Highlights

{What the site does WELL — design decisions that work,
effective UX patterns, strengths. Minimum 3-5 positive highlights.}

---

## Summary

### Quick Wins (effort: small, impact: high+)
1. {finding #N} — {one line}
2. ...

### Strategic Changes (effort: medium-large, impact: critical-high)
1. {finding #N} — {one line}
2. ...

### Total Findings
| Priority | Count |
|----------|-------|
| Critical | {N} |
| High | {N} |
| Medium | {N} |
| Low | {N} |
| **Total** | **{N}** |
```

### Length Guidance

SITE-REVIEW.md should be actionable, not exhaustive.

- **Critical and High findings:** Full 10-section template. Every section filled.
- **Medium findings:** Abbreviated template — sections 1 (Current State), 2 (Problem), 3 (Solution), 10 (Priority) only. Sections 4-9 omitted.
- **Low findings:** One-paragraph summary: what's wrong, what to do, priority.

Target length: **30-50 pages** for a full 9-module audit.
Individual module reports retain full detail for all findings regardless of priority.

### Cross-referencing with Skill Library

At the end of SITE-REVIEW.md, add a section:

```markdown
## Recommended Skills for Implementation

For each group of findings, the following skill-library skills will help implement fixes:

| Finding Group | Skill | Command |
|---------------|-------|---------|
| CTA optimization (#3, #7, #12) | marketing/page-cro | Load skill for CRO guidance |
| Form improvements (#5, #8) | marketing/form-cro | Load skill for form optimization |
| Copy rewriting (#1, #4, #9) | marketing/copywriting | Load skill for copy framework |
| SEO fixes (#6, #11, #15) | marketing/seo-audit | Load skill for SEO checklist |
| Accessibility (#10, #14) | frontend/accessibility-design | Load skill for WCAG compliance |
| Design system (#2, #13) | frontend/tailwind-design-system | Load skill for token consistency |
```

Generate SITE-REVIEW.md. When complete, emit `<bishx-site-complete>` to end the session. Do NOT emit `<bishx-site-done>` during report phase.

---

## Phase COMPLETE

After emitting `<bishx-site-complete>`:
1. State is set to `active: false`, `phase: "complete"` by the stop hook
2. Active file `.bishx-site/active` is deleted by the stop hook
3. Lead presents final summary to user with overall score and grade

---

## State Machine

### State file: `.bishx-site/{session}/state.json`

```json
{
  "skill": "site",
  "active": true,
  "phase": "discover",
  "site_url": "",
  "business_type": "",
  "run_dir": ".bishx-site/{session}/",
  "modules_total": 0, // set by ASK phase
  "selected_modules": [],
  "modules_completed": [],
  "modules_failed": [],
  "wave": 0,
  "agent_pending": false,
  "waiting_for": "",
  "max_pages": 100,
  "pages_crawled": 0,
  "started_at": "ISO timestamp",
  "updated_at": "ISO timestamp"
}
```

### Phase Transitions

```
discover → ask → execute (wave 1 → wave 2) → synthesize → report → complete
```

- `discover` — cmux browser crawl, cache snapshots/screen reads, classify business
- `ask` — AskUserQuestion for scope confirmation (waiting_for = "scope_selection")
- `execute` — Wave 1: Tier A parallel (cache-based). Wave 2: Tier B sequential (live browser)
- `synthesize` — Aggregate scores, diff, cross-reference findings
- `report` — Generate SITE-REVIEW.md
- `complete` — Session done (terminal state)
- `cancelled` — Session cancelled by user (terminal state)

### Active file: `.bishx-site/active`

Contains the session name (e.g., `2026-03-27_15-30`).
Created at Phase 0 start. Deleted at completion or cancellation.

### Signal Protocol

- `<bishx-site-done>` — current phase complete, route to next
- `<bishx-site-complete>` — session complete, allow exit

### Key State Fields

- `agent_pending: true` — stop hook allows exit (agents working, don't nudge)
- `waiting_for: "scope_selection"` — stop hook allows exit (waiting for user input)
- `wave: 1|2` — which execution wave is active
- `modules_completed: ["ux-design", ...]` — append module name when report file appears

---

## Check Ownership Matrix

To prevent duplicate findings, each check has ONE owning module:

| Check | Owner | Others Do NOT Check |
|-------|-------|---------------------|
| Core Web Vitals (LCP, CLS, INP, TTFB, FCP) | Performance | SEO Technical |
| Heading hierarchy (H1 count, level skips) | SEO Technical | UX Design, SEO Content, Accessibility |
| Readability (Flesch-Kincaid, sentence length) | SEO Content | Marketing Content |
| Color contrast (WCAG ratios) | Accessibility | UX Design |
| Touch target size (44×44px) | Accessibility | Conversion |
| Navigation item count | Information Architecture | UX Design |
| CTA above fold | Conversion | Marketing Content |
| Meta tags (title, description, OG) | SEO Technical | SEO Content |
| Form usability | Conversion | Accessibility (only keyboard/ARIA aspect) |
| Audience-Content Fit (content serves right audience first) | Marketing Content | None |
| Local SEO (NAP, GBP, local schema) | SEO Technical | None |
| Phone CTA (tel: link, click-to-call) | Conversion | Marketing Content |

If a module encounters an issue in another module's domain → note it briefly as "See {module} report"
but do NOT score it in the current module's deductions.

**Multi-Department Entity:** When >5 unique addresses found across pages (government, large org):
- Do NOT FAIL on NAP inconsistency — different departments have different contacts
- Check each department page shows its OWN correct info
- WARN if a page shows info from a DIFFERENT department
- Suppress phone consistency checks (same as CallTracking exception)

### Additional Schema Types by Business Type

SEO Technical should check for these additional schema types based on business_type:
- **News/Media:** NewsArticle, VideoObject, AudioObject, Person (for authors)
- **Education/EdTech:** Course, Review, AggregateRating, EducationalOrganization
- **Classifieds/Listings:** Product (for listings), AggregateOffer, RealEstateListing

---

## Module Applicability — Illustrations, Not Rules

The table below shows EXAMPLES of how the Foundational Principle manifests
for different business types. These are illustrations to calibrate agent judgment,
NOT rules to follow mechanically.

The agent's PRIMARY guide is: per-page purpose + Foundational Principle.
These examples help when the agent is unsure how to apply the principle.

| Module | Government | Food Delivery | Creative/Portfolio |
|--------|-----------|---------------|-------------------|
| UX Design | Standard | Standard | Example: Motion focus 40% |
| Marketing Content | Example: information completeness, not persuasion | Standard | Example: case study storytelling |
| Conversion | Example: service findability + appeal form UX | Standard | Example: project inquiry flow only |
| SEO Technical | Standard | Standard | Standard |
| SEO Content | Standard, suppress FK for legal text | Standard | Standard |
| Accessibility | Example: add GOST checks | Standard | Standard |
| Performance | Standard | Standard | Example: media-heavy thresholds |
| Information Architecture | Standard (highest weight) | Standard | Standard |
| Brand Consistency | Example: multi-department tolerance | Standard | Example: chrome-only, skip showcase pages |

**Adaptation rules:**
- "Example" = illustration of how the principle applies differently; agent adapts per page purpose, notes "N/A for this page type" when inapplicable
- "Standard" = all checks apply as written
- Agents receive business_type in spawn prompt and adjust autonomously
- Do NOT produce findings for checks that are domain-inappropriate (e.g., "no social proof" on government sites)

---

## Rules

1. **Thorough discovery.** Crawl up to max_pages (default 100). Prioritize by navigation hierarchy.
2. **Two-tier execution.** Tier A (cache) runs parallel. Tier B (browser) runs sequential.
3. **No code.** Output is visual critique. No source inspection, no CSS suggestions, no className mentions.
4. **Finding template.** Every finding uses the SKILL.md template. Sections 1-3, 6-7, 10 REQUIRED. Sections 4-5, 8-9 may be "N/A" if inapplicable.
5. **Specific, not generic.** "Move the button from block X after element Y" — not "improve the CTA".
6. **Skill library is context, not gospel.** Skills provide expert knowledge; agents apply judgment.
7. **Screenshots are evidence.** Every finding references a screenshot from `{run_dir}/screenshots/`.
8. **Diff is mandatory.** If previous run exists, compare scores. Flag regressions (any score drop ≥3 points).
9. **All agents are Opus.** No cost-cutting on audit quality.
10. **Product context stays in run_dir.** Never write to project source tree.
11. **Adaptive weights.** Business type determines module importance.
12. **One deliverable.** Everything culminates in a single `SITE-REVIEW.md`.
13. **Positive highlights too.** Not just problems — acknowledge what works well.
14. **Report language.** All human-readable report files (*.md) in English. Technical terms (CTA, UX, SEO, WCAG) in English. Machine-readable files (*.json) use English keys and values.
15. **Unified scoring.** All modules: FAIL = −15, WARN = −5, starting from 100. No custom formulas.
16. **Check ownership.** Each check has one owner. No duplicate findings across modules.
17. **Report completion marker.** Every module report MUST end with `<!-- BISHX-SITE-REPORT-COMPLETE -->` as the last line. The stop hook verifies this marker to confirm the report is fully written, not partially saved from a crashed agent. The stop hook should verify this marker exists at the end of each report file before counting it as complete.
18. **Close browser when done.** `cmux close-surface --surface $SURFACE` MUST be called before writing SITE-REVIEW.md. Never leave browser panes open.
