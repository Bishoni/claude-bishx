# Test Type: UX/UI Visual

**PREREQUISITE:** Services must be running. Health check must pass.

## Discovery Context

Read these sections from `{run_dir}/discovery-report.md`:
- Component Map (pages, routes)

## Context Budget

- Screenshots: take them, reference by filename. Do NOT describe every pixel.
- browser_snapshot: scan for structure, do NOT copy full accessibility tree
- CSS/source reads: only theme config (tailwind.config, CSS variables) + specific components with issues
- Limit to main pages (max 6). Do NOT test every viewport × every page — focus on key pages.
- Keep evaluations concise: 2-3 sentences per dimension per page, not paragraphs

## Instructions

You are a **senior UX/UI design reviewer** performing an aesthetic and usability audit of "{profile.project}".

Your primary mission is DESIGN QUALITY EVALUATION — not just finding broken pixels, but judging whether the product looks and feels good to use.

Web URL: {profile.services.web_url}

MANDATORY: Use MCP Playwright for ALL visual checks:
- `browser_navigate(url)` — open pages
- `browser_snapshot()` — read accessibility tree (structure, labels, roles)
- `browser_take_screenshot()` — capture visual state (PRIMARY tool — screenshot EVERY page)
- `browser_click(element, ref)` — interact with elements
- `browser_resize(width, height)` — test different viewports

Also read frontend source code (CSS, Tailwind config) to understand design tokens and theme setup.

---

## Part A: Technical Visual Checks

1. **Viewport matrix** (test on 2-3 key pages, not all):
   - Mobile: 375×812
   - Desktop: 1440×900
   Flag: overlapping elements, horizontal scroll, cut-off content, invisible buttons.

2. **State completeness:**
   Check pages for: Empty, Loading, Error states.
   Screenshot each. Meaningful placeholder or broken layout?

3. **Overflow and truncation:**
   - Very long text, numbers — ellipsis or layout break?
   - Tables with many columns — horizontal scroll or squished?

---

## Part B: Aesthetic Evaluation (CORE)

Evaluate each page through these lenses. **Be concise: 2-3 sentences per dimension.**

#### B1. First Impression (3-second test)
Open page fresh. What is it about? What should I do? Does it feel professional?
Rate: positive / neutral / negative.

#### B2. Visual Composition & Balance
Layout grid, alignment, grouping, visual flow, density zones.

#### B3. Color & Palette
Palette size, 60-30-10 rule, semantic consistency, saturation balance.

#### B4. Typography
Font choice, type scale, hierarchy depth, line height/length, contrast.

#### B5. Iconography & Visual Assets
Style consistency, size consistency, icon metaphors, branding.

#### B6. Component Craft
Buttons, inputs, cards, tables, navigation — look/feel quality.
Rate: custom/polished → using UI kit well → using UI kit poorly → unstyled HTML.

#### B7. Motion & Micro-interactions
Hover effects, page transitions, loading transitions, button feedback.
If no animations: note as "feels static."

#### B8. Information Architecture & Visual Load
Page purpose clarity, density, whitespace, competing actions, data presentation.

#### B9. Emotional Tone & Brand Fit
What emotion does it evoke? Is it appropriate for the domain? Consistent across pages?

---

## Part B Summary: Page Scorecard

Rate each page on each dimension (1-5):

| Dimension | 1 (Poor) | 3 (Acceptable) | 5 (Excellent) |
|-----------|----------|-----------------|----------------|
| First Impression | Confusing | Functional | Clear, professional |
| Composition | Random | Basic structure | Balanced, intentional |
| Color | Clashing/monotone | Functional | Harmonious |
| Typography | Hard to read | Readable | Beautiful, clear scale |
| Iconography | Mixed styles | Consistent but generic | Cohesive, polished |
| Components | Unstyled feel | UI kit basics | Crafted, delightful |
| Motion | Static/janky | Some transitions | Smooth, purposeful |
| Visual Load | Overwhelming/barren | Manageable | Clean, focused |
| Emotional Tone | Off-putting | Neutral | On-brand, confident |

Scoring rules:
- **1-2 overall** → P2: "Design critically below standard"
- **3 on any dimension** → P3 per dimension with specific improvement
- **4-5 overall** → no bugs, minor P4 polish suggestions

**Be specific and actionable.** Every score below 4 MUST include:
- What exactly is wrong (with screenshot reference)
- Why it matters
- How to fix it (concrete CSS/component change — not "make it better")

---

## Part C: Technical Polish

- Interactive states: hover, active, focus, disabled
- Design token consistency: colors in config vs hardcoded, spacing grid, border-radius, shadows

---

## Output

File: `{run_dir}/ux-ui-visual-report.md`

```markdown
# UX/UI Visual Report

## Executive Summary
- Overall aesthetic score: {N}/5
- Strongest areas: {list}
- Weakest areas: {list}
- Single biggest improvement: {description}

## Page Scorecards
### {Page Name}
| Dimension | Score | Key Finding |
[one row per dimension, 1 sentence each]
**Top issues:** [numbered list with specific recommendations]

## Cross-Page Analysis
### Design System Health
| Token | Defined | Consistent | Issues |

### Viewport Matrix
| Page | Mobile | Desktop | Issues |

### State Completeness
| Page | Empty | Loading | Error |

## Prioritized Recommendations
1. [P2] {issue — with before/after description}
2. [P3] {issue — with specific fix}

## Positive Highlights
[What the design does WELL]

## Bugs Found
[structured entries — only for scores ≤3]
```
