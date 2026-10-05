# Agents — Claude Code Skills Repo

A personal collection of Claude Code skills and reference material for Thomas's stack.

## Structure

Each skill lives in its own subfolder with a `SKILL.md` file. Claude Code loads skills by finding `SKILL.md` files — **do not rename them**.

Run `./scripts/list-skills.sh` for the current list. Each skill is one folder with a `SKILL.md`; extended detail goes in `references/`, loaded on demand.

## Adding a New Skill

Run the scaffold script — it handles folder creation, frontmatter, validation, and listing in one step:

```bash
./scripts/new-skill.sh <domain> <folder> <name> <description>
```

Or run it with no arguments for interactive prompts. After it runs, open the generated `SKILL.md` and fill in the skill content.

## Scripts

| Script | Purpose |
|---|---|
| `./scripts/new-skill.sh <domain> <folder> <name> <desc>` | Scaffold a new skill with spec-compliant frontmatter |
| `./scripts/validate-skills.sh` | Spec compliance check — runs automatically on every commit |
| `./scripts/test-skill.sh [skill-dir]` | Quality check a skill: description, referenced files, progressive disclosure |
| `./scripts/list-skills.sh` | Print all registered skills |

### Skill creation workflow

```bash
./scripts/new-skill.sh <domain> <folder> <name> <description>  # scaffold
# fill in SKILL.md body
./scripts/test-skill.sh <domain>/<folder>                       # quality check
./scripts/validate-skills.sh                                    # spec compliance
```

## Conventions

- One skill per folder — multiple `SKILL.md` files in the same folder won't both load
- Required frontmatter fields: `name`, `description`
- The pre-commit hook runs `validate-skills.sh` automatically on every commit
