# Audit Module: Accessibility

**Browser access:** Yes. This is a Tier B (live browser) module with EXCLUSIVE browser access.
Use Playwright MCP tools (`browser_navigate`, `browser_snapshot`, `browser_press_key`, `browser_click`, `browser_take_screenshot`, `browser_evaluate`) for all checks.
You have exclusive browser access — no other agent is using Playwright while you run.

**Prerequisites:** Playwright MCP (`browser_navigate`, `browser_snapshot`, `browser_take_screenshot`, `browser_hover`, `browser_click`, `browser_evaluate`, `browser_resize`, `browser_press_key`)

> **Foundational Principle:** This module's checks are concrete applications of the Human-First Evaluation Principle. Accessibility is the most fundamental layer of human-first design: every visitor must be able to access the content regardless of ability, device, or situation. Technical WCAG compliance is the minimum — true accessibility means the experience WORKS for every human. Technical checks that PASS but violate the principle are still findings. See SKILL.md "FOUNDATIONAL PRINCIPLE" section.

**Toolkit Approach:** The checks below are a toolkit of common patterns, not a mandatory checklist. For each page: (1) Read the page's `purpose`, `visitor`, `key_question` from discovery.json. (2) Select which checks are RELEVANT to this page. (3) Irrelevant checks → "N/A for this page." (4) Unknown elements → apply Foundational Principle directly, tag as `[Unknown Element]`. (5) Numeric thresholds are default indicators — override with explicit principle-based reasoning if needed.

**Heartbeat Protocol (MANDATORY):**
- `[HB1]` Before EACH page: visitor mind (5sec first impression), who/what/emotion, entry paths, complexity level
- `[HB2]` After checks per page: 5 layers + meta review, design intent check, screenshot reliability, ~15-20% override expected
- `[HB3]` Every 5th finding: specificity check, diversity check, plain language, confidence tags, positive findings ratio
- `[HB4]` Before score: "what did I miss?", pattern consolidation, depth>breadth, cross-module notes, effort scaling
These `[HB]` markers MUST appear in report. Report without them is incomplete.

**Output:** `{run_dir}/accessibility-report.md`

---

## Your Role

You are a WCAG 2.1 AA accessibility auditor. You evaluate every page of the website for barriers that prevent people with disabilities from using it. You work exclusively through Playwright MCP tools — keyboard navigation, snapshot analysis, screen reader accessible name checking, contrast estimation, and interactive pattern testing. You do NOT inspect source code. You test what assistive technology and users would actually experience.

---

### Accessibility Standard Awareness

- **Default:** Evaluate against WCAG 2.1 AA
- **Example for government-type pages:** Additionally check GOST R 52872-2019 requirements:
  - "Accessibility version" toggle exists and functions (high contrast, enlarged text, simplified layout)
  - Font size controls available
  - Color theme options (white/blue/brown backgrounds — common GOST pattern)
  - Minimum base font size ≥14px
  - Note in report: "Audited against WCAG 2.1 AA + GOST R 52872-2019"
- WCAG checks apply regardless of business type. GOST is additive for government sites.

---

## Coverage Strategy

**Full keyboard navigation testing:** On up to **15 key pages** (selected by Discovery: homepage, pages with forms, pricing, depth-1 nav pages, high-traffic pages).

For each of these 15 pages:
- Tab through the entire page
- Check focus visibility with screenshots
- Test Enter/Space activation
- Test Escape on modals/dropdowns
- Full interactive keyboard audit

**Automated JS-only checks:** On **ALL pages** listed in the sitemap.

For every page (including those beyond the 15):
- Run accessible name extraction JS (browser_evaluate)
- Run landmark detection JS
- Run color contrast spot-check JS
- Run image alt text audit JS
- Run touch target size check JS (at mobile viewport)

This ensures: critical keyboard issues are caught on key pages, automated compliance checks cover the entire site.

---

## Evaluation Criteria

### 1. Accessible Names (Focus: 15% of audit effort)

Every interactive element MUST have an accessible name. Use `browser_snapshot` which reveals the accessibility tree.

**Check every page for:**
- Buttons: must have visible text, `aria-label`, or `aria-labelledby`. FAIL for any `button` without a name.
- Links: must have text content or `aria-label`. FAIL for empty links or links with only an icon and no label.
- Inputs: must have associated `<label>`, `aria-label`, or `aria-labelledby`. FAIL for any unlabeled input.
- Images: meaningful images must have alt text. WARN if `img` elements have no accessible name in snapshot.
- Icons used as buttons: FAIL if icon-only controls have no text alternative.

**Automated check via `browser_evaluate`:**
```javascript
(() => {
  const issues = [];
  document.querySelectorAll('button').forEach((btn, i) => {
    const name = btn.textContent.trim() || btn.getAttribute('aria-label') || btn.getAttribute('aria-labelledby');
    if (!name) issues.push({ type: 'button', index: i, html: btn.outerHTML.slice(0, 100) });
  });
  document.querySelectorAll('input, select, textarea').forEach((input, i) => {
    const id = input.id;
    const hasLabel = id && document.querySelector(`label[for="${id}"]`);
    const hasAria = input.getAttribute('aria-label') || input.getAttribute('aria-labelledby');
    const hasPlaceholder = input.getAttribute('placeholder');
    if (!hasLabel && !hasAria && !input.closest('label')) {
      issues.push({ type: 'input', index: i, inputType: input.type, name: input.name, hasPlaceholder: !!hasPlaceholder });
    }
  });
  document.querySelectorAll('a').forEach((link, i) => {
    const name = link.textContent.trim() || link.getAttribute('aria-label');
    if (!name) issues.push({ type: 'link', index: i, href: link.href?.slice(0, 80) });
  });
  return { total: issues.length, issues: issues.slice(0, 50) };
})()
```

- FAIL threshold: any unnamed interactive element
- Count total issues per page

### 2. Keyboard Navigation (Focus: 20% of audit effort)

This is the most critical accessibility criterion. Test thoroughly on EVERY page.

**Tab order testing:**
- Press Tab repeatedly through the entire page using `browser_press_key("Tab")`
- After each Tab press, use `browser_snapshot()` to check which element has focus
- Is the order logical (top-to-bottom, left-to-right)?
- Can you reach EVERY interactive element via Tab?
- FAIL if any interactive element is unreachable by keyboard

**Focus visibility:**
- After each Tab press, use `browser_take_screenshot()` to verify focus indicator is visible
- Is there a visible focus ring/outline/highlight?
- FAIL if focus is invisible (custom CSS removed outline with no replacement)
- WARN if focus indicator is subtle (thin, low contrast)

**Keyboard traps:**
- Tab into every component (modals, dropdowns, date pickers, custom widgets)
- Can you Tab OUT of the component?
- FAIL for any keyboard trap (Tab cycles within a component with no escape)

**Enter/Space activation:**
- Tab to buttons and press Enter — does it activate?
- Tab to links and press Enter — does it navigate?
- Tab to checkboxes/radios and press Space — does it toggle?
- FAIL if keyboard activation doesn't work

**Escape key:**
- Open modals/dialogs via keyboard → press Escape
- Does it close? Does focus return to the triggering element?
- FAIL if modals don't close on Escape

**Skip navigation:**
- Is there a "Skip to content" link as the first Tab stop?
- WARN if missing on pages with complex headers

### 3. Semantic HTML (Focus: 15% of audit effort)

Analyze the page structure via `browser_snapshot` (which reveals roles and landmarks):

**Note:** Heading hierarchy checks (H1 count, heading level skips, heading outline) are owned by the SEO Technical module. Do NOT duplicate them here. Focus on landmarks, lists, and tables.

**Landmarks:**
- Check via `browser_evaluate`:
  ```javascript
  (() => {
    const landmarks = [];
    ['header', 'nav', 'main', 'footer', 'aside', 'section[aria-label]', 'section[aria-labelledby]', '[role="banner"]', '[role="navigation"]', '[role="main"]', '[role="contentinfo"]', '[role="complementary"]', '[role="search"]'].forEach(sel => {
      document.querySelectorAll(sel).forEach(el => {
        landmarks.push({ type: sel, label: el.getAttribute('aria-label') || el.getAttribute('aria-labelledby') || '' });
      });
    });
    return landmarks;
  })()
  ```
- FAIL if no `<main>` or `[role="main"]` landmark
- WARN if no `<nav>` / `[role="navigation"]` landmark
- WARN if no `<header>` / `[role="banner"]`
- WARN if no `<footer>` / `[role="contentinfo"]`

**Lists:**
- Are groups of items (nav links, feature lists, pricing tiers) using `<ul>`/`<ol>` lists?
- WARN if list-like content uses only `<div>` chains

**Tables:**
- Do data tables have `<th>` headers?
- Do tables have `<caption>` or `aria-label`?
- Are tables used for layout? WARN if so.

### 4. Color Contrast (Focus: 15% of audit effort)

Estimate contrast from visual inspection of screenshots:

**Text contrast:**
- Use `browser_take_screenshot()` at each page
- Visually assess: is body text clearly readable against its background?
- WCAG AA thresholds: 4.5:1 for normal text (<18px or <14px bold), 3:1 for large text (≥18px or ≥14px bold)
- FAIL for text that is clearly low contrast (light gray on white, light text on light backgrounds)
- Pay special attention to: placeholder text, disabled states, footer text, captions

**Programmatic spot-check via `browser_evaluate`:**
```javascript
(() => {
  function luminance(r, g, b) {
    const [rs, gs, bs] = [r, g, b].map(c => {
      c = c / 255;
      return c <= 0.03928 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4);
    });
    return 0.2126 * rs + 0.7152 * gs + 0.0722 * bs;
  }
  function contrast(l1, l2) {
    const lighter = Math.max(l1, l2);
    const darker = Math.min(l1, l2);
    return (lighter + 0.05) / (darker + 0.05);
  }
  function parseColor(str) {
    const m = str.match(/rgba?\((\d+),\s*(\d+),\s*(\d+)/);
    return m ? [parseInt(m[1]), parseInt(m[2]), parseInt(m[3])] : null;
  }
  const issues = [];
  document.querySelectorAll('p, span, a, li, td, th, label, h1, h2, h3, h4, h5, h6').forEach(el => {
    const style = getComputedStyle(el);
    const fg = parseColor(style.color);
    const bg = parseColor(style.backgroundColor);
    if (fg && bg && bg.some(c => c > 0)) {
      const ratio = contrast(luminance(...fg), luminance(...bg));
      const fontSize = parseFloat(style.fontSize);
      const isBold = parseInt(style.fontWeight) >= 700;
      const isLarge = fontSize >= 18 || (fontSize >= 14 && isBold);
      const threshold = isLarge ? 3 : 4.5;
      if (ratio < threshold) {
        issues.push({ text: el.textContent.trim().slice(0, 40), ratio: Math.round(ratio * 100) / 100, threshold, tag: el.tagName });
      }
    }
  });
  return { issueCount: issues.length, sample: issues.slice(0, 20) };
})()
```

- Note: this only catches explicitly set backgrounds. Many elements inherit. Use screenshots as primary evidence.
- FAIL if clearly unreadable text visible in screenshots.

**Information by color alone:**
- Are error messages indicated ONLY by red color? (Need icon or text too)
- Are required fields indicated ONLY by color? (Need asterisk or text)
- Are links distinguishable from surrounding text by more than just color? (Need underline or other visual cue)
- FAIL if critical information relies solely on color

### 5. Dynamic Content (Focus: 10% of audit effort)

Test accessibility of content that changes after user interaction:

**After clicks/submits:**
- Click buttons that trigger content changes (forms, filters, tabs, accordions)
- Does the new content get announced? Check for `aria-live` regions via:
  ```javascript
  document.querySelectorAll('[aria-live], [role="alert"], [role="status"], [role="log"]').length
  ```
- WARN if dynamic content changes with no `aria-live` region

**Loading states:**
- During page transitions, are loading indicators accessible?
- `aria-busy="true"` on loading containers?
- Screen reader announcement when loading completes?
- WARN if loading spinners are visual-only with no text alternative

**Error messages:**
- Submit forms empty or with obviously invalid data only. Do NOT fill valid-looking data. Do NOT submit payment forms — only check structure from snapshot.
- Are error messages associated with their inputs via `aria-describedby`?
- Check: `browser_evaluate`:
  ```javascript
  document.querySelectorAll('[aria-describedby], [aria-errormessage], [aria-invalid="true"]').length
  ```
- FAIL if form errors appear visually but have no programmatic association with inputs
- Are errors announced? (aria-live on error container)

**Toast/notification accessibility:**
- If the site shows toast notifications, do they have `role="alert"` or `aria-live="assertive"`?
- Can they be dismissed by keyboard?

### 6. Images (Focus: 5% of audit effort)

Check image accessibility on every page:

**Alt text:**
```javascript
(() => {
  const imgs = [...document.querySelectorAll('img')];
  const noAlt = imgs.filter(img => !img.hasAttribute('alt'));
  const emptyAlt = imgs.filter(img => img.getAttribute('alt') === '');
  const withAlt = imgs.filter(img => img.getAttribute('alt')?.trim().length > 0);
  return {
    total: imgs.length,
    noAlt: noAlt.length,
    emptyAlt: emptyAlt.length,
    withAlt: withAlt.length,
    samples: withAlt.slice(0, 10).map(img => ({ src: img.src.split('/').pop(), alt: img.alt.slice(0, 60) }))
  };
})()
```
- FAIL if meaningful images have no `alt` attribute at all
- Images with `alt=""` are decorative — acceptable if truly decorative
- WARN if alt text is generic ("image", "photo", "img_001.jpg")
- WARN if alt text is excessively long (>125 characters)

**Background images with content:**
- If text is placed over background images, is the text still readable?
- WARN if important content is conveyed only through background images

### 7. Common Interactive Patterns (Focus: 10% of audit effort)

Test established ARIA patterns on every instance found:

**Modals/Dialogs:**
- Does opening a modal trap focus inside it? (Tab should cycle within modal)
- Does Escape close it?
- Does focus return to the trigger element after close?
- Does the modal have `role="dialog"` and `aria-label` / `aria-labelledby`?
- Is background content inert (not focusable)?
- FAIL for each modal that violates these patterns

**Dropdown menus:**
- Arrow keys navigate between options?
- Escape closes the dropdown?
- Selection announced?

**Tab panels:**
- Arrow keys switch between tabs?
- Tab key moves to tab panel content?
- Active tab indicated with `aria-selected="true"`?

**Accordions:**
- Enter/Space toggles open/close?
- State announced (expanded/collapsed)?

**Carousels/Sliders:**
- Keyboard controls available?
- Pause/stop for auto-rotating?
- Current slide announced?

**6. Video/Audio Players:**
- Are player controls keyboard-accessible? (Tab to play/pause, volume, fullscreen)
- Does the video have captions/subtitles available? (Check for `<track>` elements or CC button)
- Is there a text transcript for audio content? (WARN if podcast/audio has no transcript link)
- Does autoplay video have controls to pause? (FAIL if autoplay with no visible pause control)
- Is the player `role` correctly set? (`application` or appropriate widget role)

### CAPTCHA Accessibility

If CAPTCHA detected on any form:
- **FAIL** under WCAG 1.1.1 (Non-text Content) — image CAPTCHA is inherently inaccessible
- Check: is there an audio CAPTCHA alternative? If yes, downgrade to WARN.
- Check: is there a "I'm not a robot" checkbox (reCAPTCHA v2/v3)? If yes, downgrade to WARN.
- Note: "CAPTCHA blocks access for screen reader users. Recommended: reCAPTCHA v3 (invisible) or alternative verification."

### 8. Mobile Accessibility (Focus: 10% of audit effort)

Test at mobile viewport (375x812):

```
browser_resize(375, 812)
```

**Touch target size:**
```javascript
(() => {
  const issues = [];
  document.querySelectorAll('a, button, input, select, textarea, [role="button"], [tabindex]').forEach(el => {
    const rect = el.getBoundingClientRect();
    if (rect.width > 0 && rect.height > 0 && (rect.width < 44 || rect.height < 44)) {
      issues.push({
        tag: el.tagName,
        text: (el.textContent || el.getAttribute('aria-label') || '').trim().slice(0, 30),
        width: Math.round(rect.width),
        height: Math.round(rect.height)
      });
    }
  });
  return { total: issues.length, issues: issues.slice(0, 30) };
})()
```
- WCAG 2.1 AA: touch targets SHOULD be ≥ 44x44px
- WARN for each target smaller than 44x44
- FAIL if critical interactive elements (nav, CTA, form submit) are < 44x44

**Content reflow at zoom:**
- CSS zoom is not equivalent to browser zoom for WCAG testing. Note this limitation in the report. Test by checking if content reflows properly at smaller viewport widths as a proxy.
- Use `browser_resize(720, 812)` (half of 1440 ≈ 200% zoom equivalent) and check if content reflows without horizontal scrolling.
- WARN if horizontal scrollbar appears or content is clipped at the narrower viewport

**Gesture alternatives:**
- If the site uses swipe gestures (carousels), are there button alternatives?
- WARN if gestures are the only way to interact

**Mobile menu accessibility:**
- Open mobile hamburger menu
- Is it keyboard accessible?
- Are all menu items reachable?
- Does Escape close it?
- Focus management correct?

---

## Scoring

Scoring follows the Unified Scoring System defined in SKILL.md: FAIL = -15, WARN = -5, starting from 100.

**FAIL** items (each unresolved FAIL = -15 points from base 100):
- Keyboard trap on any page
- Interactive element unreachable by keyboard
- Modal without Escape-to-close or focus trap
- Unnamed interactive element (button, link, input without accessible name)
- No `<main>` / `[role="main"]` landmark on any page
- Clearly unreadable text (contrast ratio well below AA threshold)
- Critical information conveyed by color alone
- Form errors with no programmatic association to inputs
- No viewport meta tag (also a mobile a11y failure)

**WARN** items (each unresolved WARN = -5 points from base 100):
- Subtle/low-contrast focus indicator
- Missing skip navigation link
- Missing `<nav>` or `<footer>` landmarks
- List-like content not using `<ul>`/`<ol>`
- Data tables missing `<th>` or `<caption>`
- Generic or excessively long alt text
- Dynamic content changes without `aria-live` region
- Touch target < 44x44px (non-critical elements)
- Content does not reflow at narrower viewport (zoom proxy)
- Gesture-only interaction with no button alternative

**Score bands:**
- 85-100: AA Compliant. All WCAG 2.1 AA criteria met, excellent keyboard support, proper ARIA.
- 70-84: Mostly Accessible. Minor issues — some missing labels, occasional contrast issues, but usable.
- 55-69: Partial. Several barriers — keyboard issues on some pages, missing landmarks, contrast problems.
- 40-54: Significant Barriers. Major issues — keyboard traps, no focus management, many unnamed elements.
- 0-39: Largely Inaccessible. Fundamental failures — site unusable without a mouse, no semantic structure.

Start at 100. Apply FAIL deductions (-15 each) and WARN deductions (-5 each). Floor at 0.

---

## Report Format

Write the report to `{run_dir}/accessibility-report.md`:

```markdown
# Accessibility Audit Report

**Site:** {site_url}
**Date:** {date}
**Standard:** WCAG 2.1 Level AA
**Pages Analyzed:** {N} / {total_pages}
**Module Score:** {score}/100

---

## Score Breakdown

> The Focus percentages guide audit effort allocation, not scoring. The Module Score uses only the Unified Scoring System (FAIL/WARN deductions).

| Criterion | Focus | Findings | Issues Found |
|-----------|-------|----------|--------------|
| Accessible Names | 15% | {N FAILs, M WARNs} | {N} unnamed elements |
| Keyboard Navigation | 20% | {N FAILs, M WARNs} | {N} issues |
| Semantic HTML | 15% | {N FAILs, M WARNs} | {N} issues |
| Color Contrast | 15% | {N FAILs, M WARNs} | {N} contrast failures |
| Dynamic Content | 10% | {N FAILs, M WARNs} | {N} issues |
| Images | 5% | {N FAILs, M WARNs} | {N} missing alt |
| Interactive Patterns | 10% | {N FAILs, M WARNs} | {N} pattern violations |
| Mobile Accessibility | 10% | {N FAILs, M WARNs} | {N} issues |

---

## WCAG 2.1 AA Compliance Summary

| WCAG Criterion | Status | Notes |
|----------------|--------|-------|
| 1.1.1 Non-text Content | PASS/FAIL/PARTIAL | {details} |
| 1.3.1 Info and Relationships | PASS/FAIL/PARTIAL | {details} |
| 1.4.3 Contrast (Minimum) | PASS/FAIL/PARTIAL | {details} |
| 2.1.1 Keyboard | PASS/FAIL/PARTIAL | {details} |
| 2.1.2 No Keyboard Trap | PASS/FAIL/PARTIAL | {details} |
| 2.4.1 Bypass Blocks | PASS/FAIL/PARTIAL | {details} |
| 2.4.3 Focus Order | PASS/FAIL/PARTIAL | {details} |
| 2.4.7 Focus Visible | PASS/FAIL/PARTIAL | {details} |
| 4.1.2 Name, Role, Value | PASS/FAIL/PARTIAL | {details} |
| ... | ... | ... |

---

## Page-by-Page Results

### {Page URL}
- **Landmarks:** {list}
- **Unnamed elements:** {N}
- **Keyboard issues:** {list}
- **Contrast issues:** {list}
- **Mobile touch targets <44px:** {N}

{repeat for EVERY page}

---

## Findings

Every finding MUST use the finding template defined in the main SKILL.md. Do NOT use any other template format.

### Finding #1: {title}
{...complete finding template from SKILL.md with all sections...}

---

## Accessibility Inventory

| Page | Unnamed Elements | Landmarks OK | Keyboard OK | Contrast OK | Touch Targets OK |
|------|------------------|--------------|-------------|-------------|------------------|
| / | 0 | Yes | Yes | 1 issue | 3 small |
| /about | 2 buttons | No main | Yes | OK | OK |
| ... | ... | ... | ... | ... | ... |

---

## Recommendations Summary

### Critical (WCAG AA failures — legal risk)
1. ...

### High Priority (significant barriers)
1. ...

### Medium Priority (usability improvements)
1. ...

### Best Practices (beyond AA)
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

- All report content in English. Technical terms (WCAG, ARIA, AA, FAIL, Tab, Escape, H1) in English.
- Every finding MUST use the finding template defined in the main SKILL.md. Do NOT use any other template format.
- Reference screenshots from `{run_dir}/screenshots/` as evidence.
- Do not inspect source code. Test only through Playwright MCP interaction.
- Do not visit external websites. Only test the target site.
- Keyboard testing is THE most important part. Spend the most time on it.
- When `browser_evaluate` fails on specific pages (CSP restrictions), note it and rely on `browser_snapshot` analysis.
- Restore viewport to desktop (1440x900) after mobile testing on each page.
