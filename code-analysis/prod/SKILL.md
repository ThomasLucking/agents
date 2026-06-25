---
name: codebase-analysis
description: >
  Production-level codebase analysis for a Bun + React + TanStack Router + Zustand + Drizzle ORM + PostgreSQL stack. Trigger when the user asks to review code, analyze the codebase, check for issues, audit architecture, find repetitions, check SOLID principles, or generally "look at" the project. Run a thorough, opinionated, production-grade review.
---

# Codebase Analysis — Bun / React / TanStack Router / Zustand / Drizzle + PostgreSQL

**Stack:** Bun HTTP + WebSockets · PostgreSQL · Drizzle ORM · Zustand v5 · React 19 · TanStack Router v1

## Phases

- [ ] Phase 0: Verify package versions — never flag without checking online
- [ ] Phase 1: Gather context — structure, git log, dependencies
- [ ] Phase 2: Run all analysis dimensions (2.1–2.6)
- [ ] Phase 3: Library suggestions (only if threshold met)
- [ ] Phase 4: Format report
- [ ] Phase 5: Verify before submitting

## Phase 0 — Verify First

```bash
cat package.json | grep -E '"(bun|drizzle-orm|zustand|@tanstack/react-router|react)"'
```

If unsure about a Docker image tag or package version, search online before flagging it as beta/invalid.

## Phase 1 — Gather Context

```bash
find . -type f -name "*.ts" -o -name "*.tsx" | grep -v node_modules | sort
git log --oneline -30
```

Read: `package.json`, `drizzle.config.ts`, server entry, main router file, store files.

## Phase 2 — Analysis Dimensions

**2.1 Repetition & DRY** — Flag any block appearing 2+ times: duplicated fetch/query logic, Drizzle queries that could be repository functions, repeated Zustand selectors, identical error-handling blocks, WS message parsing.

**2.2 Simplification** — Zustand doing async that belongs in route loaders/TanStack Query; manual `fetch()` where `useQuery` fits; N+1 Drizzle queries solvable with RQBv2 `with:`; WS handlers using if/else instead of a dispatch map.

**2.3 Organization** — Load `references/structure.md` to check against expected directory layout. Flag: server logic in entry file, schema mixed with query logic, Zustand god objects.

**2.4 SOLID** — Load `references/solid.md` for principle-by-principle checks against the stack.

**2.5 Anti-patterns** — Load `references/anti-patterns.md` for Bun HTTP, Bun WS, Drizzle, Zustand v5, and TanStack Router gotchas.

**2.6 Commit Convention** — Run `git log --oneline -30`, check against `<type>(<scope>): <desc>`. Report compliance % and violation examples.

## Phase 3 — Library Suggestions

Only suggest if the codebase demonstrates the problem at meaningful scale:
- 10+ routes with repeated middleware → Hono
- 3+ routes with manual validation → Zod/Valibot
- Any API data in Zustand → TanStack Query
- 3+ async Zustand actions with loading/error states → TanStack Query

## Phase 4 — Output Format

```
## Codebase Analysis Report

### Critical Issues (fix before production)
- [ISSUE] description — file:line — fix

### Warnings (should fix soon)
### Improvements (nice to have)

### SOLID Assessment
| Principle | Score (1-5) | Key Finding |
|---|---|---|

### Commit Convention
Compliance: X/30 — violations: ...

### What's Done Well
```

## Phase 5 — Verification

- [ ] Package versions confirmed — no assumed beta flags
- [ ] All issues cite file paths and line numbers
- [ ] SOLID findings tied to actual code, not abstract
- [ ] Commit analysis from actual git history
- [ ] Library suggestions backed by observed evidence
