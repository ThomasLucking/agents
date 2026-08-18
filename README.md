# Agents

Personal Claude Code skills and reference material.

## Skills

| Skill | Path | Description |
|---|---|---|
| `fix-simple-issues-implementer` | `agent-implementer/` | Implement a single labeled GitHub issue in an isolated worktree, review-ready |
| `agent-diff-reviewer` | `agent-diff-reviewer/` | Haiku sub-agent that reviews an implementer agent's diff before a human sees it |
| `codebase-analysis` | `code-analysis/prod/` | Production-grade review for Bun/React/TanStack/Zustand/Drizzle/PostgreSQL stack |
| `custom-analysis` | `code-analysis/custom/` | User-defined codebase analysis against any criteria or lens |
| `grilling-designs` | `grill/` | Stress-test a plan or design by relentless questioning until shared understanding |
| `laravel-best-practices` | `laravel/best-practices/` | Laravel 12 — use what the framework already provides |
| `project-ideas` | `project-ideas/` | Generate original project ideas tailored to Thomas's stack |
| `prompt-improver` | `prompt-improver/` | Rewrite a draft AI prompt using prompt-engineering best practices |
| `schematic-writer` | `schematics/` | Architecture schematics, call graphs, and data flow docs |
| `skill-improver` | `skill-improver/` | Audit and rewrite this repo's own skills against agentskills.io best practices |
| `think-twice` | `think-twice/` | Pause before expensive work to find the cheaper path |
| `thomas-learning` | `thomas-learning/` | Concept explanations pitched at intermediate-to-senior level |

## Structure

Each skill has a concise `SKILL.md` core (under 100 lines) with extended detail in `references/` files loaded on demand.

```
agent-implementer/
  SKILL.md                    # fix-simple-issues-implementer: worktree → implement → validate → log → review

agent-diff-reviewer/
  SKILL.md                    # Read-only diff review, spawned by agent-implementer step 5

code-analysis/
  custom/
    SKILL.md                  # Custom criteria analysis (any stack)
    references/playbooks.md   # Grep commands per audit type
  prod/
    SKILL.md                  # Production analysis (Bun/React/Drizzle/Zustand)
    references/anti-patterns.md
    references/solid.md
    references/structure.md

grill/
  SKILL.md                    # Design stress-tester

laravel/
  best-practices/
    SKILL.md                  # Laravel 12 built-in features reference
    references/                # Eloquent, validation, security, queues, mail, notifications

project-ideas/
  SKILL.md                    # Project idea generator

prompt-improver/
  SKILL.md                    # AI prompt rewriter
  references/principles.md    # Full prompting-principle catalog with before/after pairs

schematics/
  SKILL.md                    # Architecture schematic writer

skill-improver/
  SKILL.md                    # Audits/rewrites skills in this repo for efficiency and spec compliance

think-twice/
  SKILL.md                    # Cheaper-path check before heavy/repetitive work

thomas-learning/
  SKILL.md                    # Personal learning skill
```

## Adding a New Skill

Run the scaffold script — it handles folder creation, frontmatter, validation, and listing in one step:

```bash
./scripts/new-skill.sh <domain> <folder> <name> <description>
```

Pass `.` as `<domain>` for a flat, top-level skill (no subdomain), e.g. `./scripts/new-skill.sh . my-skill my-skill "..."`.

Or run it with no arguments for interactive prompts. After it runs, open the generated `SKILL.md` and fill in the skill content.

## Scripts

| Script | Purpose |
|---|---|
| `./scripts/new-skill.sh <domain> <folder> <name> <desc>` | Scaffold a new skill — validates name format, creates SKILL.md, optionally creates references/ |
| `./scripts/validate-skills.sh` | Spec compliance check — name format, description length, line count, placeholders. Runs on every commit. |
| `./scripts/test-skill.sh <skill-dir>` | Quality check — description trigger keywords, referenced files exist, progressive disclosure, body content |
| `./scripts/list-skills.sh` | Print all registered skills with name and path |

### Workflow for creating a skill

```bash
# 1. Scaffold
./scripts/new-skill.sh laravel hooks laravel-hooks "Trigger on Laravel lifecycle hook questions"

# 2. Fill in the SKILL.md body

# 3. Quality check
./scripts/test-skill.sh laravel/hooks

# 4. Spec compliance (also runs automatically on commit)
./scripts/validate-skills.sh
```

`new-skill.sh` accepts all four arguments positionally, or runs interactively with no arguments.

### Workflow for improving a skill

Use the `skill-improver` skill directly in conversation ("improve the X skill", "audit my skills") — it runs
`validate-skills.sh` and `test-skill.sh` against the target, checks it against the [agentskills.io](https://agentskills.io/skill-creation/best-practices)
checklist, and applies fixes.
