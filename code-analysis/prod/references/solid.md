# SOLID Principles — Stack-Specific Checks

## S — Single Responsibility

- Each Bun route handler should do one thing: validate → call service → return response
- Zustand stores should not mix UI state with domain state
- Drizzle schema files should not contain query logic

## O — Open/Closed

- WebSocket message handlers: adding a new message type should not require modifying existing handlers
- Check: is there a dispatch map, or a growing `if/else` chain?

## L — Liskov Substitution

- TypeScript: are interface contracts honored across implementations?
- Are `InferSelectModel<typeof table>` types used consistently, or ad-hoc `any`?

## I — Interface Segregation

- `const store = useMyStore()` subscribes to everything — bad
- `const x = useMyStore(s => s.x)` subscribes to one slice — good
- Flag: components that subscribe to an entire store

## D — Dependency Inversion

- Server routes should depend on service functions, not directly on `db`
- DB queries should live in repository functions, not scattered in route handlers
