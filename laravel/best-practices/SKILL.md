---
name: laravel-best-practices
description: >
  Trigger when writing, reviewing, or debugging Laravel code. Enforces framework conventions:
  thin controllers, Form Requests for validation, Eloquent over raw queries, and proper use of
  built-in features. Also trigger on questions about Laravel architecture or "how do I do X in Laravel".
---

## Core conventions
- Use Eloquent over raw queries; use query scopes for reusable filters
- Controllers stay thin — move business logic to Service classes
- Use Form Requests for validation, never validate in controllers directly

## Gotchas
- Soft-deleted models require `withTrashed()` or results silently exclude them
- `->get()` always returns a Collection, never null — check `->isEmpty()` not null
- Mass assignment requires `$fillable` or `$guarded` — forgetting causes silent failures

## References (load on demand)
- Read `references/eloquent-patterns.md` if writing or reviewing Eloquent queries, scopes, casts, or model events
- Read `references/eloquent-relationships.md` if defining or querying model relationships or pivot tables
- Read `references/validation.md` if writing Form Requests or validation rules
- Read `references/security-checklist.md` if the task involves auth, authorization, CSRF, or user input
- Read `references/performance-tips.md` if the task involves N+1 queries, caching, or chunking large datasets
- Read `references/queues.md` if writing jobs, dispatching, batching, or configuring queue workers
- Read `references/mail.md` if sending emails, building Mailables, or configuring mail drivers
- Read `references/notifications.md` if sending notifications across mail, database, SMS, or Slack channels
