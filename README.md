# Agents

Personal Claude Code skills and reference material.

## Skills

Run `./scripts/list-skills.sh` for the current list. Each skill is one folder with a `SKILL.md`; extended detail goes in `references/`, loaded on demand.

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

Use the `writing-for-agents` skill, then run `test-skill.sh` and `validate-skills.sh` on the target.
