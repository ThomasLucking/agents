# Agents — Claude Code Skills Repo

A personal collection of Claude Code skills and reference material for Thomas's stack.

## Structure

Each skill lives in its own subfolder with a `SKILL.md` file. Claude Code loads skills by finding `SKILL.md` files — **do not rename them**.

```
code-analysis/
  custom/SKILL.md             # User-defined codebase analysis (any stack, any criteria)
  prod/SKILL.md               # Production-level analysis for Bun/React/Drizzle/Zustand stack

db-insert-validator/
  SKILL.md                    # Validate/fix INSERTs from CSV/XLSX against MySQL/MariaDB schema

docker-postgres-skill/
  SKILL.md                    # Docker Compose + PostgreSQL environment diagnosis

git/
  workflow/SKILL.md           # Branching, PRs, merge conflicts, commit hygiene

grill/
  SKILL.md                    # Stress-test plans and designs by relentless questioning

laravel/
  best-practices/SKILL.md    # Laravel 12 — use what the framework already provides
  inertia/SKILL.md            # Laravel + Inertia.js v2/v3 + React patterns

project-ideas/
  SKILL.md                    # Generate project ideas tailored to Thomas's stack

schematics/
  SKILL.md                    # Architecture schematics, call graphs, data flow docs

text-analysis/
  exam_advisor/SKILL.md       # Personalised revision strategies and study plans
  instruction_analysis/SKILL.md  # Break down exam questions, rubrics, assignment briefs

thomas-learning/
  SKILL.md                    # Personal learning guide — intermediate-to-senior level
```

## Adding a New Skill

Run the scaffold script — it handles folder creation, frontmatter, validation, and listing in one step:

```bash
./scripts/new-skill.sh <domain> <folder> <name> <description>
```

Or run it with no arguments for interactive prompts. After it runs, open the generated `SKILL.md` and fill in the skill content.

## Scripts

| Script | Purpose |
|---|---|
| `./scripts/validate-skills.sh` | Lint all skill files — checks naming and required frontmatter |
| `./scripts/list-skills.sh` | Print all registered skills with name and file path |

## Conventions

- One skill per folder — multiple `SKILL.md` files in the same folder won't both load
- Required frontmatter fields: `name`, `description`
- The pre-commit hook runs `validate-skills.sh` automatically on every commit
