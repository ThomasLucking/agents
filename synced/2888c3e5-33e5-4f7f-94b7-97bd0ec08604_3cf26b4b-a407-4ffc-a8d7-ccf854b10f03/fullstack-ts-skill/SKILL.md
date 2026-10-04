---
name: fullstack-ts-skill
description: >
  Best practices, debugging, and clarification for Thomas's full-stack TypeScript stack:
  TanStack Router v1, React 19, Elysia.js, Bun SQL (bun:sql), PostgreSQL, and Docker.
  Trigger this skill whenever Thomas asks about: routing patterns, file-based routes, search params,
  route loaders, Elysia plugins, Elysia guards, Elysia context, typed routes, bun:sql queries,
  SQL tagged templates, prepared statements, PostgreSQL schema, Docker networking, container setup,
  "how do I do X in Elysia", "how does the router work", "is this the right way to do X", debugging
  fetch errors, backend/frontend type sharing, Zod validation in Elysia, or any architecture question
  involving these technologies. Also trigger when Thomas pastes code from any of these layers and asks
  for a review, clarification, or improvement. Be pushy — if the question touches any of these techs,
  use this skill.
---

# Full-Stack TypeScript Skill

Thomas's stack: **Elysia.js** backend (Bun runtime) · **bun:sql** for DB access · **PostgreSQL** · **TanStack Router v1** · **React 19** · **TailwindCSS** · **Docker Compose**

> This skill covers best practices, common pitfalls, debugging patterns, and architecture guidance. Read the relevant section(s) for the query at hand.

---

## Quick Reference Map

| Topic | Section |
|---|---|
| TanStack Router — routing, loaders, search params | §1 |
| React patterns for this stack | §2 |
| Elysia.js — plugins, guards, context, validation | §3 |
| `bun:sql` — queries, prepared statements, transactions | §4 |
| Backend/frontend type sharing | §5 |
| Docker + networking | §6 — or read `docker-postgres-skill` |
| Debugging checklist | §7 |

---

## §1 — TanStack Router v1

### File-based routing structure

```
src/routes/
├── __root.tsx          # Root layout — outlet + global providers
├── index.tsx           # /
├── _auth.tsx           # Layout route (no URL segment, prefixed with _)
├── _auth/
│   ├── dashboard.tsx   # /dashboard
│   └── settings.tsx    # /settings
└── posts/
    ├── index.tsx       # /posts
    └── $postId.tsx     # /posts/:postId
```

**Key rules:**
- `__root.tsx` must render `<Outlet />` — it's not optional
- Layout routes start with `_` (no URL segment added)
- Dynamic segments use `$` prefix (`$postId`, `$userId`)
- Index routes are `index.tsx`, not `[folder].tsx`

### Loaders — fetch data before render

```ts
// src/routes/posts/$postId.tsx
export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params }) => {
    const post = await fetchPost(params.postId)
    return { post }
  },
  component: PostPage,
})

function PostPage() {
  const { post } = Route.useLoaderData()
  return <div>{post.title}</div>
}
```

**Do not fetch inside the component** — this causes fetch-on-render (waterfall). Always use loaders.

### Search params — typed, not raw

```ts
export const Route = createFileRoute('/posts')({
  validateSearch: (search) =>
    z.object({
      page: z.number().default(1),
      query: z.string().optional(),
    }).parse(search),
  component: PostsPage,
})

function PostsPage() {
  const { page, query } = Route.useSearch()
  const navigate = Route.useNavigate()

  return (
    <button onClick={() => navigate({ search: (prev) => ({ ...prev, page: prev.page + 1 }) })}>
      Next
    </button>
  )
}
```

**Never use `useState` for search params** — they won't survive navigation or browser back/forward.

### Context — pass global data to routes

```ts
// main.tsx
const router = createRouter({
  routeTree,
  context: { auth: undefined! },
})

// __root.tsx
export const Route = createRootRouteWithContext<{ auth: AuthContext }>()({
  component: Root,
})
```

### Error and pending states

Every route should have these — don't leave them as the default blank screen:

```ts
export const Route = createFileRoute('/posts')({
  loader: fetchPosts,
  pendingComponent: () => <Spinner />,
  errorComponent: ({ error }) => <ErrorMessage error={error} />,
  component: Posts,
})
```

### Code splitting

```ts
export const Route = createFileRoute('/heavy-page')({
  component: lazyRouteComponent(() => import('../components/HeavyPage')),
})
```

---

## §2 — React 19 patterns

### Avoid `useEffect` for data fetching

With TanStack Router loaders, you almost never need `useEffect` for fetching. If you find yourself writing `useEffect(() => { fetch(...) }, [id])`, move it to the route loader instead.

### Refs in React 19

`forwardRef` is no longer needed — `ref` is a regular prop:

```tsx
function Input({ ref, ...props }) {
  return <input ref={ref} {...props} />
}
```

### Forms — uncontrolled or React 19 actions

```tsx
function Form() {
  async function action(formData: FormData) {
    'use server' // or handle client-side
    const name = formData.get('name')
  }
  return (
    <form action={action}>
      <input name="name" />
      <button type="submit">Submit</button>
    </form>
  )
}
```

### Keep components thin

Components should render — services/loaders should fetch. If a component has more than one `useState` tracking loading/error/data, it should be a loader.

---

## §3 — Elysia.js

### Plugin pattern — group by domain

```ts
// src/plugins/posts.ts
import { Elysia, t } from 'elysia'
import { db } from '../db'

export const postsPlugin = new Elysia({ prefix: '/posts' })
  .get('/', async () => db.query.posts.findMany())
  .get('/:id', async ({ params }) => {
    const post = await db.query.posts.findFirst({ where: eq(posts.id, Number(params.id)) })
    if (!post) throw new NotFoundError()
    return post
  })
  .post('/', async ({ body }) => db.insert(posts).values(body).returning(), {
    body: t.Object({ title: t.String(), content: t.String() }),
  })

// src/index.ts
const app = new Elysia()
  .use(postsPlugin)
  .listen(3001)
```

**Never put all routes in `index.ts`** — it becomes unmanageable fast.

### Guards — auth/validation at group level

```ts
const authGuard = new Elysia({ name: 'auth-guard' })
  .derive(async ({ headers, error }) => {
    const token = headers.authorization?.replace('Bearer ', '')
    if (!token) throw error(401, 'Unauthorized')
    const user = await verifyToken(token)
    return { user }
  })

export const protectedRoutes = new Elysia()
  .use(authGuard)
  .get('/me', ({ user }) => user)
```

### Schema validation — always use `t` (TypeBox)

```ts
.post('/login', async ({ body }) => login(body), {
  body: t.Object({
    email: t.String({ format: 'email' }),
    password: t.String({ minLength: 8 }),
  }),
  response: t.Object({
    token: t.String(),
  }),
})
```

Elysia validates at the TypeBox level — it's faster than Zod and the types are inferred automatically. You get `body` fully typed with no extra work.

### Error handling

```ts
new Elysia()
  .error({ NotFoundError, ValidationError })
  .onError(({ code, error, set }) => {
    if (code === 'NotFoundError') {
      set.status = 404
      return { message: error.message }
    }
  })
```

### `derive` vs `decorate` vs `state`

| API | Use for | Runs per |
|---|---|---|
| `derive` | Computed from request context (auth user, parsed token) | Request |
| `decorate` | Shared stateless utilities (logger, helper fns) | Setup |
| `state` | Shared mutable state (in-memory counters, cache) | Setup |

```ts
new Elysia()
  .decorate('logger', logger)          // available as ctx.logger
  .state('requestCount', 0)            // available as ctx.store.requestCount
  .derive(({ request }) => ({          // available as ctx.requestId
    requestId: crypto.randomUUID(),
  }))
```

---

## §4 — `bun:sql` (Bun native SQL)

### Setup

```ts
import { SQL } from 'bun:sql'

export const sql = new SQL({
  url: process.env.DATABASE_URL,
})
```

> `DATABASE_URL` must use the Docker service name inside containers: `postgres://user:pass@db:5432/mydb`

### Tagged template queries

```ts
const users = await sql`SELECT * FROM users WHERE id = ${userId}`
// ✅ Parameters are automatically escaped — no SQL injection risk
// ✅ Returns typed array

const user = await sql`SELECT * FROM users WHERE email = ${email} LIMIT 1`
// Returns User[] — access as user[0]
```

**Never interpolate with string concatenation:**
```ts
// ❌ SQL injection risk
const users = await sql`SELECT * FROM users WHERE name = '${name}'`

// ✅ Parameterized
const users = await sql`SELECT * FROM users WHERE name = ${name}`
```

### Prepared statements — for hot paths

```ts
const getUserById = sql`SELECT * FROM users WHERE id = ${'id'}`.prepare('get_user_by_id')

// Later, in a request handler:
const user = await getUserById.execute({ id: userId })
```

Use prepared statements for queries that run on every request.

### Transactions

```ts
await sql.begin(async (tx) => {
  await tx`INSERT INTO orders (user_id, total) VALUES (${userId}, ${total})`
  await tx`UPDATE balances SET amount = amount - ${total} WHERE user_id = ${userId}`
})
// Rolls back automatically if any query throws
```

### Common PostgreSQL patterns

```ts
// Returning inserted row
const [row] = await sql`
  INSERT INTO posts (title, content, author_id)
  VALUES (${title}, ${content}, ${authorId})
  RETURNING *
`

// JSON aggregation
const result = await sql`
  SELECT u.id, u.name,
    json_agg(p.*) FILTER (WHERE p.id IS NOT NULL) AS posts
  FROM users u
  LEFT JOIN posts p ON p.author_id = u.id
  GROUP BY u.id
`

// Upsert
await sql`
  INSERT INTO sessions (user_id, token, expires_at)
  VALUES (${userId}, ${token}, ${expiresAt})
  ON CONFLICT (user_id) DO UPDATE
    SET token = EXCLUDED.token, expires_at = EXCLUDED.expires_at
`
```

### Type casting

`bun:sql` returns plain JS objects. Define a type or use `as`:

```ts
type User = { id: number; name: string; email: string }
const users = await sql`SELECT * FROM users` as User[]
```

---

## §5 — Backend/Frontend Type Sharing

### Elysia Eden Treaty (recommended)

Elysia generates a fully-typed client from your app definition — no code gen, no manual sync:

```ts
// backend: src/index.ts
export type App = typeof app  // export the app type

// frontend: src/lib/api.ts
import { treaty } from '@elysiajs/eden'
import type { App } from '../../backend/src'

export const api = treaty<App>('http://localhost:3001')

// Usage — fully typed:
const { data, error } = await api.posts.get()
const { data: post } = await api.posts({ id: '1' }).get()
```

This is the zero-maintenance way. No schema duplication.

### Shared types (if not using Eden)

Keep shared types in a `packages/shared` or `src/shared/types.ts` that both sides import:

```ts
// src/shared/types.ts
export type Post = {
  id: number
  title: string
  content: string
  authorId: number
  createdAt: Date
}
```

**Never copy-paste types between backend and frontend.**

---

## §6 — Docker

> For Docker Compose + PostgreSQL specifics, also read the `docker-postgres-skill`.

Quick reminders for this stack:
- Backend `DATABASE_URL` must use the **service name** as host: `@db:5432`
- `VITE_API_URL` uses `localhost` because it's resolved by the browser
- Backend must bind to `0.0.0.0`, not `localhost`
- Always use `depends_on: db: condition: service_healthy`

---

## §7 — Debugging Checklist

When something is broken, run through this before asking:

### Frontend (TanStack Router / React)

- [ ] Is data fetched in a loader, not in `useEffect`?
- [ ] Are search params typed with `validateSearch`?
- [ ] Is the route file in the right folder and named correctly?
- [ ] Is `__root.tsx` rendering `<Outlet />`?
- [ ] Is the router tree generated/updated? (`bun run routes:generate` or equivalent)

### Backend (Elysia)

- [ ] Is the plugin registered on the app with `.use()`?
- [ ] Is body validation defined with `t.Object(...)` in the route options?
- [ ] Is `derive` used for per-request context, not `decorate`?
- [ ] Is the error handler registered before routes that throw?
- [ ] Does the response match the declared `response` schema?

### Database (`bun:sql`)

- [ ] Is `DATABASE_URL` using the correct host (`db` in Docker, `localhost` outside)?
- [ ] Are all parameters passed as template interpolations, not string concatenations?
- [ ] Is a transaction used for multi-query writes?
- [ ] Is the returned value an array? (`sql\`...\`` always returns `T[]`)

### General

- [ ] Is `.env` loaded? (`Bun.env` reads it automatically, but check the key names)
- [ ] Is the Docker service healthy before the backend starts?
- [ ] Are CORS headers set for cross-origin browser requests?

```ts
new Elysia()
  .use(cors({
    origin: process.env.FRONTEND_URL ?? 'http://localhost:5173',
    credentials: true,
  }))
```
