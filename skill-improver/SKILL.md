---
name: skill-improver
description: >
  Audits and rewrites one or more existing skills in this repo to maximize efficiency: trims bloat, tightens the description for reliable triggering, adds missing gotchas, and restructures oversized SKILL.md files into references/ for proper progressive disclosure. Trigger on "improve this skill", "clean up my skills", "audit my skills", "make skill X more efficient", "apply best practices to this skill", or "review SKILL.md for progressive disclosure".
---

# Skill Improver

Rewrite existing skills against the [agentskills.io](https://agentskills.io/skill-creation/best-practices)
spec and best practices — not from scratch, from what's already there. Optimize for
correct triggering and minimum wasted context per activation.

## Workflow

- [ ] Step 1: Resolve targets — if the user named a skill, find its `SKILL.md`; if not, run
  `./scripts/list-skills.sh` and ask which one(s). For "audit everything," process one skill at a time.
- [ ] Step 2: Read the full skill directory (`SKILL.md` + everything under `references/`, `scripts/`,
  `assets/`) — a skill that looks bloated may already have good progressive disclosure you shouldn't undo.
- [ ] Step 3: Run `./scripts/validate-skills.sh` (spec compliance) and `./scripts/test-skill.sh <path>`
  (quality signals) on the target. Note every failure before touching content.
- [ ] Step 4: Score the skill against the Audit Checklist below. Write down concrete findings, not vague
  impressions — "description doesn't state when NOT to trigger, conflicts with X" beats "description weak."
- [ ] Step 5: Apply fixes, highest-value first: broken triggering > frontmatter spec violations > bloat/context
  waste > missing gotchas > structural polish. Don't fix what isn't broken — a skill that already scores well
  on a dimension needs no changes there.
- [ ] Step 6: Re-run `./scripts/validate-skills.sh` and `./scripts/test-skill.sh <path>` to confirm the edit
  didn't regress compliance.
- [ ] Step 7: Report using the Output Format below.

## Audit Checklist

**Frontmatter (spec-hard requirements — any failure here is a bug, fix first)**
- `name` matches parent directory name exactly, lowercase, hyphens only, no leading/trailing/consecutive hyphens, ≤64 chars
- File is literally named `SKILL.md` — case-sensitive. `find . -name "SKILL.md"` and this repo's own
  `validate-skills.sh` (`find . -name "*.md"`) both silently skip a wrong-case file; it will never load.
- `description` ≤1024 chars, states both *what* the skill does and *when* to use it

**Triggering quality (per [Optimizing descriptions](https://agentskills.io/skill-creation/optimizing-descriptions))**
- Imperative framing ("Use this skill when…"), not a feature-list summary
- Names concrete trigger phrases/scenarios, including ones where the user won't name the domain outright
- States what it does *not* cover if it sits near an adjacent skill (prevents wrong-skill activation)
- No unresolved `[[link]]` to a skill name that doesn't exist in this repo

**Context economy ("Spending context wisely")**
- Cuts anything the model already knows (what a PDF is, how HTTP works) — keep only what's project-specific
- SKILL.md body stays under ~500 lines / ~5000 tokens; anything larger belongs in `references/`
- Every `references/*.md` pointer says *when* to load it ("read X if Y"), never a bare "see references/"
- References are one level deep from SKILL.md — no reference-to-reference chains

**Calibrating control**
- Fragile/sequence-sensitive steps are prescriptive (exact commands, "do not add flags")
- Flexible steps explain *why*, not just *what*, so the agent can adapt to variation
- Multiple valid tools/approaches collapse to one default with a one-line escape hatch, not a menu
- Instructions teach a reusable procedure, not just the answer to one past instance of the task

**Structural patterns (apply only where they fit — not every skill needs all of these)**
- A `## Gotchas` section holding concrete, non-obvious corrections (not generic advice)
- Multi-step workflows use a `- [ ] Step N` checklist
- Fixed output formats are given as a literal template, not prose description
- Destructive/batch operations follow plan → validate → execute, not direct execution

## Output Format

Report per skill audited, in this repo's existing terse convention:

```
[<skill-name>][<n> findings — <m> fixed]
- [Frontmatter|Triggering|Context|Control|Structure][what was wrong][what changed]
- ...
```

If a skill scores clean on a dimension, don't list it — report deltas, not the full checklist.

## Gotchas

- `./scripts/validate-skills.sh` walks `find . -name "*.md"` — this is case-sensitive even on
  case-insensitive filesystems (APFS), so a stray `SKILL.MD` passes silently instead of erroring. Always
  also run `find . -iname "SKILL.md"` once per audit pass to catch wrong-case files the validator misses.
- `new-skill.sh` requires a non-empty `<domain>` positional arg even for a flat, top-level skill (no
  subdomain) — pass `.` as the domain to scaffold directly under repo root.
- A skill's `description` frontmatter is the *only* thing loaded at startup for every skill in context.
  Improving the SKILL.md body does nothing for a skill that never triggers — always check triggering before
  spending effort on body content.
- Don't rewrite a skill's domain-specific facts (stack versions, gotchas, conventions) from general
  knowledge — those came from the user's real usage. Only restructure, trim, or clarify; ask before
  replacing factual content you can't verify against the codebase.
