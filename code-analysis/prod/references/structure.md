# Expected Project Structure

```
src/
├── server/
│   ├── index.ts            # Bun.serve() entry — routing only, no logic
│   ├── routes/             # One file per domain (users.ts, posts.ts)
│   ├── ws/
│   │   ├── handlers.ts     # Message dispatch map
│   │   └── rooms.ts        # Room/subscription management
│   └── middleware/         # Auth, CORS, logging
├── db/
│   ├── schema/             # One file per table domain
│   ├── migrations/         # Drizzle-kit generated
│   └── index.ts            # Single drizzle() instance export
├── stores/                 # Zustand — one store per domain, not one giant store
├── routes/                 # TanStack Router file-based routes
│   ├── __root.tsx
│   └── _auth/
├── components/
└── lib/                    # Shared utils, types, validators
```

Flag deviations: server logic in entry file, schema mixed with query logic, Zustand stores as god objects.
