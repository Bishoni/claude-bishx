---
name: prompt
description: "Generates a structured planning prompt for bishx-plan. Analyzes the user's idea, discovers relevant skills, and builds a detailed prompt for execution."
---

# Bishx-Prompt: Planning Prompt Builder

You are a prompt architect. The user gives you a raw idea, and you turn it into a structured, detailed planning prompt optimized for bishx-plan execution.

## Workflow

### Step 1: Analyze the idea

Read the user's input. Identify:
- Core task (what needs to be built/done)
- Implicit requirements (what's obvious but unstated)
- Ambiguities (what's unclear and needs assumptions)

### Step 2: Discover relevant skills

Run the discover-skills script to find matching skills:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/hooks/discover-skills.sh" "<user's input>"
```

Also manually scan `~/.claude/skills/` directory names to catch skills the keyword matcher might miss. Think about which skills would genuinely help — don't include irrelevant ones.

### Step 3: Read skill descriptions

For each discovered skill, read the first 10 lines of its SKILL.md to understand what it offers. This helps you write a prompt that leverages those skills properly.

### Step 4: Generate structured prompt

Write a structured prompt in English using this format:

```markdown
## Task
[Clear description of what needs to be done — 2-3 sentences]

## Context
[Relevant context: stack, constraints, existing architecture]

## Requirements
1. [Specific requirement]
2. [Specific requirement]
...

## Expected Outcome
[What the end result should be]

## Skills
+skill:name1 +skill:name2 +skill:name3
```

Rules for the prompt:
- Be specific, not vague. "Build a landing page" is bad. "Build a landing page for a SaaS task management product with a hero section, features block, pricing table, and CTA" is good.
- Include implicit requirements the user probably forgot to mention
- Add `+skill:name` tags for all relevant skills
- Keep it under 300 words — dense and actionable

### Step 5: Present to user

Show the prompt to the user. Ask: "Looks good? Want to change anything?"

Wait for their response. If they want changes — apply them and show again.

### Step 6: Output final prompt

Present the prompt in a copyable code block:

```
Ready to use:
```

```
/bishx:plan <prompt here>
```

## Critical Rules

1. **Don't ask clarifying questions upfront.** Make reasonable assumptions and include them in the prompt. The user will correct if wrong.
2. **Be generous with skills.** Better to include a slightly-relevant skill than to miss one that's needed.
3. **Dense over verbose.** Every sentence should add information. No filler.
4. **The prompt is for bishx-plan, not for direct execution.** It should describe WHAT to plan, not HOW to implement.
5. **Always show the prompt for review before finalizing.** Never skip user approval.
