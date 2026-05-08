
---
name: custom-analysis
description: >
  Custom codebase analysis based on specific criteria the user provides. Trigger this skill whenever
  the user says things like: "analyze this for X", "check if the code follows Y", "review the codebase
  for Z", "audit performance", "check security", "review my API design", "check accessibility",
  "look at test coverage", "audit my DB schema", or any request to review code against a specific
  lens or ruleset they define. This is the flexible, project-agnostic companion to codebase-analysis.
  The user drives the criteria — this skill drives the methodology.
---

# Custom Codebase Analysis — User-Defined Criteria

**Goal:** Systematic, evidence-based analysis against whatever criteria the user specifies.  
**Scope:** Any codebase, any stack, any dimension.

---

## Step 1 — Extract the Criteria

Before writing a single line of analysis, make sure the criteria are concrete.

If the user gave vague criteria (e.g., "check if the code is clean"), ask one focused question:

> "What does 'clean' mean for this project? (e.g., consistent naming, no magic numbers, max function length, no nested callbacks?)"

If the user gave specific criteria (e.g., "check REST API naming conventions"), proceed directly.

**Criteria can be:**
- A named standard (REST, WCAG 2.1, OWASP Top 10, 12-Factor App)
- A personal checklist the user provides
- A comparison against a reference implementation
- A performance profile (bundle size, query count, render cost)
- A security audit scope
- A test coverage audit
- A custom architectural decision record (ADR) compliance check

---

## Step 2 — Understand the Codebase

Before analyzing, always read the project:

```bash
# Structure
find . -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" \) \
  | grep -v node_modules | grep -v .git | sort

# Dependencies
cat package.json

# Entry points
cat README.md 2>/dev/null | head -50
```

Read the files most relevant to the criteria scope. Don't read everything — be targeted.

---

## Step 3 — Map Criteria to File Scope

Explicitly map each criterion to the files/areas where it applies before checking:

| Criterion | Where to Check | Tool |
|---|---|---|
| e.g. "no magic numbers" | All `.ts` files with raw numeric literals | `grep -rn '[0-9]\{3,\}' src/` |
| e.g. "REST naming" | Route definition files | `view` + manual |
| e.g. "no console.log in prod" | All source files | `grep -rn 'console\.' src/` |
| e.g. "DB indexes on FK columns" | Drizzle schema files | `view` schema |

Build this table mentally or explicitly before starting the sweep.

---

## Step 4 — Analyze Against Each Criterion

For each criterion:

1. **State what you're checking** — be explicit
2. **Show evidence** — quote file paths and line numbers, never abstract
3. **Pass / Fail / Partial** — give a clear verdict
4. **Explain why it matters** in this project's context
5. **Give a concrete fix** — not just "improve this"

### Common Criteria Playbooks

#### Security Audit (OWASP-aligned)
```bash
# Hardcoded secrets
grep -rn "password\|secret\|api_key\|token" src/ --include="*.ts" | grep -v ".env\|test\|mock"

# SQL injection surface (raw queries)
grep -rn "db.execute\|sql\`" src/

# Missing auth checks
grep -rn "fetch\|Bun.serve\|router.get" src/server/ | grep -v "auth\|middleware"
```
Check: input validation on all external inputs, auth on all protected routes, no secrets in source.

#### Performance Audit
```bash
# Bundle concerns (frontend)
cat vite.config.ts 2>/dev/null
# Check: code splitting, lazy routes, tree shaking

# DB query count (N+1 risk)
grep -rn "\.findMany\|\.select\|db\." src/ | wc -l

# Zustand over-subscription
grep -rn "useStore()" src/ | grep -v "state =>"  # full store subscriptions
```
Check: route-level code splitting, no N+1 in loops, selector granularity, no blocking queries on hot paths.

#### API Design Audit (REST)
```bash
grep -rn "pathname\|router\.\|\.get\|\.post\|\.put\|\.patch\|\.delete" src/server/routes/
```
Check: noun-based resource names (`/users` not `/getUsers`), consistent pluralization, proper HTTP verbs, meaningful status codes.

#### Test Coverage Audit
```bash
find . -name "*.test.ts" -o -name "*.spec.ts" | grep -v node_modules
bun test --coverage 2>/dev/null || echo "No test runner configured"
```
Check: coverage on business logic (services/repositories), not just trivial files; edge cases covered.

#### 12-Factor App Compliance
Check against each factor:
1. Codebase — one repo, one app?
2. Dependencies — all in `package.json`, nothing assumed in env?
3. Config — env vars only, no hardcoded config?
4. Backing services — DB/WS treated as attached resources?
5. Build/Release/Run — separated?
6. Processes — stateless? (check: in-memory session state, WebSocket connection state)
7. Port binding — self-contained?
8. Concurrency — can it scale horizontally? (check: WebSocket in-memory state)
9. Disposability — fast startup/shutdown? (check: `process.on('SIGTERM')`)
10. Dev/Prod parity — similar envs?
11. Logs — to stdout, not files?
12. Admin processes — run as one-off tasks?

#### Accessibility Audit (React UI)
```bash
grep -rn "alt=\|aria-\|role=\|tabIndex" src/components/
grep -rn "<img\|<button\|<input\|<a " src/components/
```
Check: all images have `alt`, interactive elements keyboard-accessible, form labels present, color not sole indicator.

---

## Step 5 — Output Format

Adapt the report structure to the criteria, but always include:

```
## 🎯 Custom Analysis: [Criteria Name]

### Scope
Files analyzed: X
Criteria checked: Y

### Results

#### Passing
- [criterion]: evidence from code

#### Failing  
- [criterion]: file:line — what's wrong — how to fix it

#### Needs Attention
- [criterion]: file:line — partial compliance — what's missing

### Summary Table
| Criterion | Status | Severity |
|---|---|---|

### Priority Fixes
1. [Most impactful fix]
2. ...

### What's Already Good
(Always include — honest positives)
```

---

## Step 6 — Honesty Rules

- **Never pad the report** with generic advice not tied to the actual code
- **Never fail something** without quoting the offending code
- **Never pass something** you didn't actually verify
- **If a file is too large to fully analyze**, say so and check the highest-risk sections
- **If a criterion is ambiguous**, ask for clarification rather than guessing the intent
- **If you find nothing wrong**, say "no violations found" — don't invent issues

---

## Step 7 — Verification Before Submitting

- [ ] Every "fail" cites an actual file path and line reference
- [ ] Every "pass" was actually checked, not assumed
- [ ] Package versions verified online if questioned (no "this might be beta" without checking)
- [ ] Fixes are actionable code-level suggestions, not vague advice
- [ ] Criteria scope was understood and confirmed before analysis started
