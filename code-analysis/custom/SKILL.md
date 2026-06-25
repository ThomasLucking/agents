---
name: custom-analysis
description: >
  Custom codebase analysis based on user-defined criteria. Trigger when the user asks to "analyze this for X", "check if code follows Y", "audit performance", "check security", "review API design", "check accessibility", "look at test coverage", or any request to review code against a specific lens or ruleset.
---

# Custom Codebase Analysis

**Goal:** Systematic, evidence-based analysis against whatever criteria the user specifies.

## Workflow

- [ ] Step 1: Confirm criteria — if vague, ask ONE focused question
- [ ] Step 2: Read project structure; target only files relevant to the criteria
- [ ] Step 3: Map each criterion to files and grep commands before sweeping
- [ ] Step 4: Analyze with evidence — cite file paths and line numbers
- [ ] Step 5: Output report
- [ ] Step 6: Verify — every fail cites real code, every pass was actually checked

**Criteria types:** Named standards (OWASP, 12-Factor, WCAG 2.1), personal checklists, performance profiles, security scopes, test coverage, ADR compliance.

Load `references/playbooks.md` for specific grep commands per audit type (security, performance, REST, test coverage, 12-factor, accessibility).

## Output template

```
## Custom Analysis: [Criteria Name]

Scope: X files analyzed, Y criteria checked

### Passing
- [criterion]: evidence from code

### Failing
- [criterion]: file:line — what's wrong — fix

### Needs Attention
- [criterion]: file:line — what's missing

| Criterion | Status | Severity |
|---|---|---|

### Priority Fixes
1. [Most impactful]

### What's Already Good
```

## Honesty rules

- Never fail without quoting offending code at file:line
- Never pass without actually verifying
- Never pad with generic advice not tied to actual code
- If nothing is wrong: say "no violations found" — don't invent issues
