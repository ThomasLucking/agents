# Analysis Playbooks

## Security (OWASP-aligned)

```bash
grep -rn "password\|secret\|api_key\|token" src/ --include="*.ts" | grep -v ".env\|test\|mock"
grep -rn "db.execute\|sql\`" src/
grep -rn "fetch\|Bun.serve\|router.get" src/server/ | grep -v "auth\|middleware"
```
Check: input validation on all external inputs, auth on all protected routes, no secrets in source.

## Performance

```bash
cat vite.config.ts 2>/dev/null
grep -rn "\.findMany\|\.select\|db\." src/ | wc -l
grep -rn "useStore()" src/ | grep -v "state =>"
```
Check: route-level code splitting, no N+1 in loops, selector granularity, no blocking queries on hot paths.

## REST API Design

```bash
grep -rn "pathname\|router\.\|\.get\|\.post\|\.put\|\.patch\|\.delete" src/server/routes/
```
Check: noun-based resource names (`/users` not `/getUsers`), consistent pluralization, proper HTTP verbs, meaningful status codes.

## Test Coverage

```bash
find . -name "*.test.ts" -o -name "*.spec.ts" | grep -v node_modules
bun test --coverage 2>/dev/null || echo "No test runner configured"
```
Check: coverage on business logic (services/repositories), not trivial files; edge cases covered.

## 12-Factor App

1. Codebase — one repo, one app?
2. Dependencies — all in `package.json`, nothing assumed in env?
3. Config — env vars only, no hardcoded config?
4. Backing services — DB/WS treated as attached resources?
5. Build/Release/Run — separated?
6. Processes — stateless? (check: in-memory session state, WebSocket connection state)
7. Port binding — self-contained?
8. Concurrency — horizontally scalable? (check: WebSocket in-memory state)
9. Disposability — fast startup/shutdown? (check: `process.on('SIGTERM')`)
10. Dev/Prod parity — similar envs?
11. Logs — to stdout, not files?
12. Admin processes — run as one-off tasks?

## Accessibility (React UI)

```bash
grep -rn "alt=\|aria-\|role=\|tabIndex" src/components/
grep -rn "<img\|<button\|<input\|<a " src/components/
```
Check: all images have `alt`, interactive elements keyboard-accessible, form labels present, color not sole indicator.
