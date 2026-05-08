# Agents

Personal Claude Code skills and reference material.

## Skills

| Skill | Trigger | Description |
|---|---|---|
| `laravel-inertia-snippets` | Inertia, useForm, usePage, `Inertia::render` | Best practices for Laravel 11 + Inertia.js v2/v3 + React |
| `laravel-best-practices` | "how do I implement X in Laravel", reviewing Laravel code | Laravel 12 — use what the framework already provides |
| `codebase-analysis` | "review code", "audit architecture", "analyze codebase" | Production-grade review for Bun/React/Drizzle/Zustand stack |
| `custom-analysis` | "analyze this for X", "audit X", "review X" | User-defined codebase analysis against any criteria |
| `thomas-learning` | "explain X", "how does X work", "teach me X" | Personal learning guide — explanations pitched at intermediate level |

## Structure

```
laravel/
  inertia/SKILL.md            # Laravel + Inertia.js v2/v3 + React
  best-practices/SKILL.md     # Laravel 12 built-in features reference

code-analysis/
  custom/SKILL.md             # Custom criteria analysis (any stack)
  prod/SKILL.md               # Production analysis (Bun/React/Drizzle/Zustand)

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
