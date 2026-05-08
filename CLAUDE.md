# Agents — Claude Code Skills Repo

A personal collection of Claude Code skills and reference material for Thomas's stack.

## Structure

Each skill lives in its own subfolder with a `SKILL.md` file. Claude Code loads skills by finding `SKILL.md` files — **do not rename them**.

```
laravel/
  inertia/SKILL.md          # Laravel 11+ + Inertia.js v2/v3 + React patterns
  best-practices/SKILL.md   # Laravel 12 — use what the framework already provides

code-analysis/
  custom/SKILL.md           # User-defined codebase analysis (any stack, any criteria)
  prod/SKILL.md             # Production-level analysis for Bun/React/Drizzle/Zustand stack

thomas-learning/
  SKILL.md                  # Personal learning guide — explains concepts at intermediate level
```

## Adding a New Skill

1. Create a new folder: `mkdir <domain>/<skill-name>`
2. Add a `SKILL.md` with valid frontmatter (see existing skills for the pattern)
3. Run `./scripts/validate-skills.sh` to confirm it's well-formed
4. Run `./scripts/list-skills.sh` to verify it appears in the registry

## Scripts

| Script | Purpose |
|---|---|
| `./scripts/validate-skills.sh` | Lint all skill files — checks naming and required frontmatter |
| `./scripts/list-skills.sh` | Print all registered skills with name and file path |

## Conventions

- One skill per folder — multiple `SKILL.md` files in the same folder won't both load
- Required frontmatter fields: `name`, `description`
- The pre-commit hook runs `validate-skills.sh` automatically on every commit
