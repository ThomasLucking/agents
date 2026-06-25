---
name: docker-postgres-debug
description: >
  Docker Compose + PostgreSQL environment analysis and error diagnosis for Thomas's Bun/Elysia.js + Drizzle + React + PostgreSQL stack. Trigger on: docker-compose errors, container crashes, backend not connecting to DB, localhost resolution issues, .env misconfiguration, DATABASE_URL errors, ENOTFOUND errors, Drizzle connection errors, healthcheck issues, or when reviewing docker-compose.yml, Dockerfile, or .env files.
---

# Docker + PostgreSQL Skill

**Stack:** Bun backend (Elysia.js + Drizzle ORM), Vite/React frontend, PostgreSQL 18.3, single multi-stage Dockerfile, one docker-compose.yml, one .env.

## Rule #1: Never Use `localhost` Inside Docker

`localhost` inside a container = the container itself. Always use the service name.

| Context | Wrong | Right |
|---|---|---|
| DB connection from backend | `localhost:5432` | `db:5432` |
| API from a container | `localhost:3001` | `backend:3001` |

`VITE_*` vars are resolved by the browser (host machine) — `localhost` IS correct there.

## Canonical .env Structure

```env
POSTGRES_USER=myuser
POSTGRES_PASSWORD=mypassword
POSTGRES_DB=mydb
DATABASE_URL=postgres://myuser:mypassword@db:5432/mydb
BACKEND_PORT=3001
BACKEND_HOST=0.0.0.0   # must bind to 0.0.0.0, not localhost
VITE_API_URL=http://localhost:3001
VITE_WS_URL=ws://localhost:3001/ws
```

Load `references/canonical-configs.md` for the full Dockerfile and docker-compose.yml templates.

## Common Errors & Fixes

| Error | Cause | Fix |
|---|---|---|
| `ENOTFOUND localhost` | Service-to-service call using `localhost` | Replace with service name in `.env` |
| Drizzle fails immediately on startup | Backend starts before DB is ready | `depends_on.db.condition: service_healthy` |
| `db_data` doesn't persist | Volume path missing `/data` | Use `/var/lib/postgresql/data` |
| Backend crashes on code change | DB connection not retried on restart | `restart: unless-stopped` + lazy DB init |
| `node_modules` from host overrides container's | Bind mount `.:/app` overwrites everything | Add anonymous volume `- /app/node_modules` |
| Frontend can't reach backend in browser | `VITE_API_URL=http://backend:3001` | Use `http://localhost:3001` for `VITE_*` |
| `links:` in compose file | Old approach — unnecessary | Remove — shared `networks:` is sufficient |

## Debug Checklist

1. Service-to-service calls use service names (not `localhost`)?
2. DB volume path ends in `/data`?
3. Backend binding to `0.0.0.0`?
4. `depends_on.db.condition: service_healthy` on backend service?
5. Anonymous volume `- /app/node_modules` after bind mount?
6. `VITE_*` URLs use `localhost` (browser context)?
7. `COPY package.json && bun install` before `COPY . .` in Dockerfile?
8. Postgres image pinned to exact version (e.g. `18.3` not `18`)?
