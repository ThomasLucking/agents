# Agents

Personal Claude Code skills and reference material.

## Skills

| Skill | Path | Description |
|---|---|---|
| `codebase-analysis` | `code-analysis/prod/` | Production-grade review for Bun/React/TanStack/Zustand/Drizzle/PostgreSQL stack |
| `custom-analysis` | `code-analysis/custom/` | User-defined codebase analysis against any criteria or lens |
| `db-insert-validator` | `db-insert-validator/` | Validate and fix INSERT statements derived from CSV/XLSX against a MySQL/MariaDB schema |
| `docker-postgres-debug` | `docker-postgres-skill/` | Docker Compose + PostgreSQL environment diagnosis and error triage |
| `grilling-designs` | `grill/` | Stress-test a plan or design by relentless questioning until shared understanding |
| `Laravel Best Practices` | `laravel/best-practices/` | Laravel 12 — use what the framework already provides |
| `project-ideas` | `project-ideas/` | Generate original project ideas tailored to Thomas's stack |
| `schematic-writer` | `schematics/` | Architecture schematics, call graphs, and data flow docs |
| `exam-advisor` | `text-analysis/exam_advisor/` | Personalised revision strategies and study plans |
| `instruction-analysis` | `text-analysis/instruction_analysis/` | Break down exam questions, rubrics, and assignment briefs |
| `thomas-learning` | `thomas-learning/` | Concept explanations pitched at intermediate-to-senior level |

## Structure

Each skill has a concise `SKILL.md` core (under 100 lines) with extended detail in `references/` files loaded on demand.

```
code-analysis/
  custom/
    SKILL.md                  # Custom criteria analysis (any stack)
    references/playbooks.md   # Grep commands per audit type
  prod/
    SKILL.md                  # Production analysis (Bun/React/Drizzle/Zustand)
    references/anti-patterns.md
    references/solid.md
    references/structure.md

db-insert-validator/
  SKILL.md                    # CSV/XLSX → MySQL INSERT validation

docker-postgres-skill/
  SKILL.md                    # Docker Compose + PostgreSQL debugging
  references/canonical-configs.md  # Dockerfile and docker-compose.yml templates

grill/
  SKILL.md                    # Design stress-tester

laravel/
  best-practices/
    SKILL.md                  # Laravel 12 built-in features reference
    references/               # Eloquent, validation, security, queues, mail, notifications

project-ideas/
  SKILL.md                    # Project idea generator

schematics/
  SKILL.md                    # Architecture schematic writer

text-analysis/
  exam_advisor/
    SKILL.md                  # Revision strategy and study planning
    references/techniques.md
    references/study-plan.md
  instruction_analysis/
    SKILL.md                  # Exam/rubric breakdown
    references/ai-brief-template.md

thomas-learning/
  SKILL.md                    # Personal learning skill
```

## Scripts

```bash
./scripts/new-skill.sh <domain> <folder> <name> <description>  # Scaffold a new skill, then validate and list
./scripts/validate-skills.sh                                    # Lint all skill files — runs automatically on git commit
./scripts/list-skills.sh                                        # Print all registered skills
```

`new-skill.sh` accepts all four arguments positionally, or runs interactively if you omit them:

```bash
# Non-interactive
./scripts/new-skill.sh laravel hooks laravel-hooks "Trigger on Laravel lifecycle hook questions"

# Interactive
./scripts/new-skill.sh
# > Domain: laravel
# > Skill folder name: hooks
# > Skill name: laravel-hooks
# > One-line trigger description: Trigger on Laravel lifecycle hook questions
```
