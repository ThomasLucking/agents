# Stack-Specific Anti-Patterns

## Bun HTTP

- ❌ Manual router with `if/else` on `url.pathname` at scale → use Hono (production-stable on Bun)
- ❌ No request validation (Zod/Valibot on incoming bodies)
- ❌ WebSocket handlers inside `fetch()` instead of `websocket: {}` block
- ✅ Auth handled in `fetch()` before `server.upgrade()` — verify this pattern is present

## Bun WebSockets

- ❌ Iterating all clients manually instead of `ws.publish()` / `ws.subscribe()`
- ❌ No `idleTimeout` configured (stale connections accumulate)
- ❌ Missing `drain` handler (backpressure unhandled)
- ❌ No typed `WebSocketData` interface on the connection

## PostgreSQL + Drizzle ORM

- `serial` vs `integer().generatedAlwaysAsIdentity()` — latter is the 2025 standard
- `drizzle-zod` / `drizzle-valibot` moved into `drizzle-orm` in v1.x — no separate package needed
- N+1 patterns — use Drizzle RQBv2 `with:` instead of nested loops
- `db.execute(sql\`...\`)` where a type-safe builder call would work
- Missing indexes on foreign keys and frequent filter columns

## Zustand v5

- ❌ Default export removed in v4+ — must use `{ create }`
- ❌ Server/API response data in Zustand — belongs in TanStack Query
- ❌ `const everything = useMyStore()` — subscribe to the needed slice only
- ❌ One giant god store — split by domain (auth, ui, [feature])
- ❌ Actions defined outside the store creator
- ✅ `shallow` from `zustand/shallow` used for object comparisons?

## TanStack Router v1

- ❌ Data fetching inside components (fetch-on-render) instead of route `loader`s
- ❌ URL search params managed with `useState` instead of `validateSearch`
- ❌ Missing `ErrorBoundary` / `pendingComponent` on routes
- ❌ Code splitting not enabled — non-critical routes should use `lazy()`
- ✅ Prefer file-based routing over code-based for discoverability
