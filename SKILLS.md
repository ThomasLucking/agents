# My agent setup: skills, plugins and workflow

**Status:** inventory, analysis and workflow as of 2026-10-05. Format copied from `azimut/docs/SKILLS.md`.

## TL;DR

- **Goals:**
  - learn while the agent writes code (school + Jobtrek);
  - code that stays small and reviewable;
  - one obvious skill per job, not three that overlap.
- **Base: [mattpocock/skills](https://github.com/mattpocock/skills)**, installed with `npx skills` into `~/.agents/skills/` and symlinked into `~/.claude/skills/` (lock: `~/.agents/.skill-lock.json`).
- **mattpocock chain repaired 2026-10-05:** added `setup-matt-pocock-skills`, `code-review`, `prototype`, `wizard`, `pr`, `retro`, `handoff`, `writing-for-agents`; updated 10 skills (`domain-modeling` now writes `GLOSSARY.md`); removed `writing-great-skills` (deleted upstream). My old reviewer is now `code-review-deep`.
- `implement` was removed (it commits). Use `agent-implement-generic`.
- **Cleaned 2026-10-05:** 9 dead symlinks removed (`exam-advisor`, `codebase-analysis`, `custom-analysis`, and 3 wrong-depth links in `~/Agents`). The `~/Agents` repo has the deletions uncommitted.

## 1. Sources at a glance

| Source | Where | What it brings | Verdict |
| --- | --- | --- | --- |
| **mattpocock/skills** | `~/.agents/skills` | grilling, domain modelling, spec → tickets → implement, tdd, debugging | **Base.** Update deliberately; upstream renames often. |
| **My own skills** | `~/Agents/*`, `~/agentic-engineering/*`, plain folders in `~/.claude/skills` | Stack-specific (Laravel, Bun/Drizzle), learning, schematics, PR comments | **Keep.** Dedupe with the `anthropic-skills:*` copies. |
| **`anthropic-skills:*`** | claude.ai sync | Copies of my skills + docx/pdf/pptx/xlsx | **Keep the office ones.** The copies drift from the local ones. |
| **Other packs** | `~/.agents/skills` | shadcn, vue, laravel-owasp, improve, agent-browser | **Keep**, stack-specific. |
| **ponytail** plugin | marketplace | Always-on "do less", review/audit/debt skills | **Keep for side projects.** Fights `codebase-design` on deep-module projects. |
| **i-have-adhd** plugin | marketplace | Always-on output shape | **Keep.** |
| **vibe-wise** plugin | marketplace | `learn`, `reset` | **Decide** vs `quiz-and-delete` (§2, Learning). |

## 2. Skills by job

Legend:
- **Keep**: use as is.
- **Add**: install from upstream.
- **Merge**: overlaps another skill; keep one.
- **Fix**: broken, misnamed or out of date.
- **Manual**: `disable-model-invocation: true` (only runs when I type it, costs no context).

### Plan and specify

| Skill | Verdict | Note |
| --- | --- | --- |
| `grilling` | Keep | The primitive. Asks in rounds, recommends an answer per question. |
| `grill-with-docs` | Keep, Manual | = `grilling` + `domain-modeling`. Use on any real project. |
| `grill-me` | Removed | Was a one-line wrapper; call `/grilling`. |
| `anthropic-skills:grill` | Merge → `grilling` | Synced copy. |
| `domain-modeling` | Keep | Writes `GLOSSARY.md` + `docs/adr/` (updated 2026-10-05). |
| `prototype` | Keep | Throwaway UI or state-model prototype before the spec. |
| `to-spec` | Keep, Manual | Synthesises the conversation, agrees test seams, publishes a GitHub issue. |
| `to-tickets` | Keep, Manual | Vertical slices with blocking edges, labelled `ready-for-agent`. |
| `setup-matt-pocock-skills` | Keep, Manual | Run once per repo: issue tracker, labels, domain docs (creates `docs/agents/*.md`, like Azimut). Without it `to-spec`/`to-tickets` stop. |
| `app-architecture-planner`, `stack-advisor` | Keep | New app, no code yet. |

### Build

| Skill | Verdict | Note |
| --- | --- | --- |
| `tdd` | Keep | Red → green at seams agreed up front. Refactoring is left to `code-review`. |
| `codebase-design` | Keep | Deep-module vocabulary; `tdd` and `improve-codebase-architecture` call it. |
| `implement` | Removed | It commits; `agent-implement-generic` replaces it. |
| `agent-implement-generic` | Keep | Review step uses `code-review-deep`. `name:` is `fix-simple-issues-implementer*`, folder is `agent-implement-*`. Same job as `implement` for one GitHub issue, in a worktree, without committing. Keep these as my "safe" `implement`. |
| `planner` + `implementer` agents | Keep | Multi-file work only. |
| `find-docs` | Keep | Same job as the ctx7 rule in `CLAUDE.md`. |
| `wizard` | Keep | Bash wizard for steps only I can do (secrets, OAuth apps, hosting dashboards). |
| `laravel-best-practices`, `vue-best-practices`, `shadcn`, `shadcn-vue`, `frontend-design`, `fullstack-ts-skill`, `docker-postgres-skill` | Keep | Stack-specific. Add `paths:` where possible. |
| `think-twice` | Removed → ponytail | Same "do less" idea as the always-on plugin. |

### Review and audit

| Question | Skill |
| --- | --- |
| Does the diff match my standards **and** the issue? | `code-review` (mattpocock, two axes; `implement` and `tdd` call it) |
| Is the diff correct, secure, fast? (5 axes) | `code-review-deep` (mine; `pr-review` and `agent-implement-*` call it) |
| Post findings on a GitHub PR | `pr-review` |
| Is the diff over-engineered? | `ponytail:ponytail-review` |
| Whole repo, over-engineering | `ponytail:ponytail-audit` |
| Where should modules get deeper? | `improve-codebase-architecture` (Manual) |
| Handoff plans for another agent | `improve` |
| Laravel security | `laravel-owasp-security` |

### Debug

| Skill | Verdict | Note |
| --- | --- | --- |
| `diagnosing-bugs` | Keep | No hypothesis before a red, tight feedback loop. The best skill in the set. |
| `agent-browser` | Keep | Browser feedback loops and UI checks. |

### Docs, diagrams, PRs

| Skill | Verdict | Note |
| --- | --- | --- |
| `pr` | Keep | Writes the PR body. |
| `docs-coherence` | Keep, Manual | Mine (2026-10-05). Audits `docs/` for contradictions, stale/wrong claims, opinions stated as facts; read-only report. |
| `schematic-writer` | Keep | Existing code → ASCII schematic. |
| `mermaid` | Keep | Diagram as code. (`diagram-design` removed.) |
| `docx`, `pdf`, `pptx`, `xlsx` | Keep | When a file format is required. |

### Learning

| Skill | Verdict | Note |
| --- | --- | --- |
| `quiz-and-delete` | Keep, Manual | **Main learning step**: quiz on the code the agent wrote, delete what I can't explain, rewrite it. |
| `thomas-learning` | Keep | Quick "explain X". |
| `teach` | Keep, Manual | Multi-session course in its own folder (mission, lessons, records). Different job from `thomas-learning`, not a duplicate. |
| `vibe-wise:learn` | Decide | Overlaps `quiz-and-delete`. Keep one. |
| `anthropic-skills:learn`, `anthropic-skills:thomas-learning` | Merge | Synced copies. |
| `copy-test-practice` | Keep | Module 117. |

### Session and meta

| Skill | Verdict | Note |
| --- | --- | --- |
| `retro` | Keep, Manual | End of a feature: what went wrong → lesson → gate. |
| `handoff` | Keep, Manual | Compact a long session into a doc for a fresh agent. |
| `writing-for-agents` | Keep | Skills, AGENTS.md, CLAUDE.md. Replaced `writing-great-skills`. |
| `prompt-improver`, `find-skills` | Keep | |
| `project-ideas` | Keep | Delete the `anthropic-skills:` copy. |

Skip from upstream: `ask-matt` (router; this file is my router), `implement-spec`, `wayfinder` (too much ceremony solo), `triage` (no incoming issues), `setup-pre-commit`, `scaffold-exercises`, `migrate-to-shoehorn`, `in-progress/*`.

## 3. Workflow

### Once per repo

1. `/setup-matt-pocock-skills`: GitHub issues, labels, `GLOSSARY.md` + `docs/adr/`.
2. Write `AGENTS.md` (≤ ~800 words, pointers only) and a one-line `CLAUDE.md`: `@AGENTS.md`.

### Per feature

| # | Step | Skill | Output |
| --- | --- | --- | --- |
| 1 | **Grill** the idea | `/grill-with-docs` | Shared understanding, `GLOSSARY.md` terms, ADRs |
| 2 | **Prototype** if a UI or state model is unclear | `prototype` | Throwaway code, the decision it answered |
| 3 | **Spec** | `/to-spec` | GitHub issue: user stories, test seams, out of scope |
| 4 | **Tickets** | `/to-tickets` | Vertical slices, `ready-for-agent` |
| 5 | **Build** one ticket | `agent-implement-generic` (no commit) | `tdd` at the agreed seams, then `code-review` |
| 6 | **Check** | `ponytail-review`, `agent-browser` on the running app | Diff without bloat, UI seen working |
| 7 | **Learn** | `/quiz-and-delete` on the diff | Code I can explain |
| 8 | **Ship** | `pr`, then `pr-review` | PR body + inline comments |
| 9 | **Retro** | `/retro` | Same mistake twice = lint rule, type, hook or CI check. `CLAUDE.md` line last. |

Shortcuts:
- **Small fix:** skip 1–4. Write the issue by hand, go to step 5.
- **Bug:** `diagnosing-bugs` replaces 1–4; its regression test becomes the `tdd` red.
- **Messy existing code:** `/improve-codebase-architecture` → it grills you → `/to-spec`.
- **Long session:** `/handoff` before the context fills up.

## 4. Keeping skills current

```bash
npx skills update -g -y     # mattpocock and other packs
npx skills add mattpocock/skills -g -a claude-code -y -s <name>
```

Upstream renames often: read the "deleted upstream" warning after each update.

## 5. Practices (from `azimut/docs/PRACTICES.md`)

**Core idea: a rule holds only when a script, type or check enforces it.** Prose rules erode, for agents as much as for people. Skills say *how* to work; gates make sure it happened.

### Gate before prose

Order of preference when a rule matters, or an agent breaks it twice:

1. **Type** or schema: the wrong code doesn't compile.
2. **Lint rule** or test: fails locally and in CI.
3. **Hook** or **permission rule**: blocks or feeds the error back to the agent.
4. **Line in `CLAUDE.md` / `AGENTS.md`**: last resort.

### My `CLAUDE.md` rules, as gates

| Rule today (prose) | Gate |
| --- | --- |
| "Never commit unless asked" | `permissions.ask: ["Bash(git commit*)", "Bash(git push*)"]` in `~/.claude/settings.json`: I approve each one. |
| "Use ctx7 before library code" | Keep `find-docs` (model-invoked). Can't be fully gated; pin the version instead of `@latest`. |
| "Use agent-browser, not WebFetch" | `permissions.deny: ["WebFetch"]`. |
| Secrets stay out of context | `permissions.deny: ["Read(./.env)", "Read(./.env.*)"]`. |
| Python via `uv` | `permissions.deny: ["Bash(pip install*)", "Bash(pip3 install*)"]`. |

### Per project (copy from `PRACTICES.md` §4)

- `AGENTS.md` holds the instructions (≤ ~800 words, pointers only); `CLAUDE.md` is one line: `@AGENTS.md`.
- Commit `.claude/settings.json`: `ask` before edits to lint config, CI and `.claude/**`, so the agent can't loosen its own checks.
- Hooks, few and tested:
  - **PostToolUse** on `Edit|Write`: format + lint the edited file, exit 2 so the errors go back to Claude.
  - **Stop**: type check, exit 2 on failure; check `stop_hook_active` to avoid loops.
- `.claude/rules/*.md` with `paths:` instead of "remember to read X".
- One `gate` script, run by the pre-push hook **and** CI.

### Skills hygiene

- `disable-model-invocation: true` on heavy, hand-run skills: zero context until typed.
- `paths:` on stack skills so they load only on matching files.
- No MCP by default; CLIs add no tool schemas to every session.
- Per-turn injected reminders cost tokens every turn. My always-on plugins (ponytail, i-have-adhd) are the exception I accept; don't add more.

### Verify, then measure

- Facts about libraries or tools: checked against docs or the registry, with the date written down. Never from memory.
- New complexity (cache, queue, sync engine, new skill or tool) only after a **measured trigger**. Until then, the simple version plus a note on what would trigger the upgrade.

## 6. Open questions

- [x] **`code-review` conflict:** option (a), done 2026-10-05.
- [ ] **Built-in `/code-review` is shadowed** by the mattpocock skill of the same name. Fine unless I want the built-in one.
- [ ] **ponytail vs deep modules:** turn ponytail off per project (`enabledPlugins` in that repo's `.claude/settings.json`)?
- [ ] **ctx7 `@latest`** in `CLAUDE.md`: pin a version, or rely on `find-docs` only?
- [ ] **Synced `anthropic-skills:*` copies:** delete them on claude.ai, or stop editing the local ones?
- [ ] **`paths:` scoping** for the Laravel / Vue / shadcn skills.
- [ ] **Commit** the `~/Agents` symlink deletions (6 `D`) and the `~/agentic-engineering` edits (2 `M`).
