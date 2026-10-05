# Agents — Claude Code Skills Repo

A personal collection of Claude Code skills and reference material for Thomas's stack.

## Structure

Each skill lives in its own subfolder with a `SKILL.md` file. Claude Code loads skills by finding `SKILL.md` files — **do not rename them**. Extended detail goes in `references/`, loaded on demand. Run `./scripts/list-skills.sh` for the current list.

- `SKILLS-ROUTING.md`: which skill to pick per job. Symlinked to `~/.claude/SKILLS-ROUTING.md`, which the global `CLAUDE.md` points to.
- `SKILLS.md`: audit of every installed skill (keep / removed / why). Symlinked to `~/.claude/SKILLS.md`.
- `global-CLAUDE.md`: the user-wide instructions. Symlinked to `~/.claude/CLAUDE.md`, so it loads in every project.

## Sync

`~/.claude/skills` is the source of truth. The launchd job `com.thomaslucking.skills-sync` runs `scripts/push-skill.sh` on every change there: rsync into this repo, then commit and push. It never deletes, so remove a skill in both places. Log: `~/.claude/skills-sync.log`.

- Never symlink a `~/.claude/skills` entry back into this repo: rsync fails with `unlinkat: Directory not empty` and nothing syncs.
- External skills (`~/.agents/skills`, installed with `npx skills`) stay symlinks; list the ones to skip in `.skillsignore`.
- `synced/` is claude.ai's copy of account skills; it is gitignored. Delete those on claude.ai, not here.
- `SKILLS.md`, `SKILLS-ROUTING.md` and `global-CLAUDE.md` live outside `~/.claude/skills`, so commit and push them by hand.

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
