# Output Rules
- Output style = `i-have-adhd` plugin (always-on via `~/.claude/.i-have-adhd-always`). Its SKILL.md is the source of truth; don't duplicate rules here.
- Code changes = `ponytail` plugin (always-on via its SessionStart hook).
- Implementing a feature = apply BOTH: `ponytail` decides what code to write (ladder, shortest diff), `i-have-adhd` decides how to report it (next action first, numbered steps, visible wins). If either hook didn't load, invoke the `ponytail:ponytail` skill and follow `i-have-adhd` SKILL.md manually.

# Skills
- Several skills could fit, or planning a feature: read `~/.claude/SKILLS-ROUTING.md` first.

# Browser Automation
Use `agent-browser` (CLI) for any web lookup, page check, or browser interaction — not WebFetch, not built-in browser tools.
if you need help regarding any of the commands launch agent-browser --help to list all of the commands.
Core workflow:
1. `agent-browser open <url>`
2. `agent-browser snapshot -i` (ref-based, low-token accessibility tree)
3. `agent-browser click @e1` / `fill @e2 "text"` using refs
4. Re-snapshot after any page change
5. `agent-browser close` when done
Use it for: checking rendered app output, verifying a deployed page, scraping/extracting info from a live site, testing a login/form flow, debugging frontend behavior.
Chain steps with `&&` in one call where possible. No narrating each CLI step unless asked.


# agent-state — project state snapshot
Use `agent-state` (CLI, `~/dev/agent-state`) instead of manually chaining `git status`/test runner/linter/`ps` to check a project's state — one JSON snapshot, no free-form output to parse.
Usage: `agent-state <git|test|lint|procs|all> [--pretty]`
- `git` — branch, ahead/behind, staged/unstaged/untracked, last commit
- `test` — auto-detects runner (Jest/Vitest/Mocha/pytest/PHPUnit/cargo/go), returns `{ passed, failed, failing: [...] }`
- `lint` — auto-detects linter (ESLint/golangci-lint/clippy/PHPStan/ruff), returns `{ errors, warnings, issues: [...] }`
- `procs` — dev-server/watcher processes running with this dir as cwd, PID + ports
- `all` — merges all four under `git`/`test`/`lint`/`procs` keys
Unsupported/undetected tools return `{ "status": "unavailable", "reason": "..." }` instead of erroring.
Use before/instead of manual git+test+lint+process checks when assessing a project's current state.

# Library docs
Before writing or changing code that touches a library, framework, SDK, CLI or cloud API, use the `find-docs` skill (ctx7). Skip for pure business logic.

# when building python apps
- first check what is the latest version installed on the system
- then init a project using uv and use uv when installing packages dependecies etc..

# commiting rules
- if the user nevers asks for you to commit never commit
