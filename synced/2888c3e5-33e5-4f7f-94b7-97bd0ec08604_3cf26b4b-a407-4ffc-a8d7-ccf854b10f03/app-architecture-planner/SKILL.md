---
name: app-architecture-planner
description: >
  Produce a pre-build architecture planning document for a NEW app — folder structure,
  database schema, models/entities, feature-component breakdown, and a request-flow
  diagram — in Thomas's established ASCII-tree/box-diagram style. Use this whenever
  Thomas describes a new app or feature idea and wants to plan it out before writing
  code: "sketch the architecture for X", "plan the DB schema for X", "what would the
  folder structure look like for X", "lay out the models for X", or when he pastes a
  project idea and wants it broken into tables/models/components/routes. This is the
  PLANNING counterpart to schematic-writer (which documents architecture of code that
  already exists) — use app-architecture-planner when no code exists yet. Supports both
  of Thomas's stacks: Laravel + Livewire + Blade + Tailwind (+ SQLite/MySQL), and the
  full-stack TS stack (React + TanStack Router + Elysia.js + Bun SQL + PostgreSQL +
  Drizzle + Docker). Ask which stack if it isn't obvious from context.
---

# App Architecture Planner

Produce a complete, skimmable architecture-planning doc for an app that doesn't exist
yet — the kind of doc you'd write *before* opening an editor, so the shape of the app
is settled first. Same visual language as Thomas's other docs: ASCII trees, box-drawing
diagrams, minimal prose.

---

## When to use this vs. schematic-writer

- **app-architecture-planner** (this skill): no code exists yet. Output = folder
  structure + DB schema + models + component breakdown + request flow, for a NEW
  project or feature.
- **schematic-writer**: code already exists. Output = call graphs / data-flow of
  EXISTING components, in a more granular "who calls whom" style.

If Thomas pastes existing code and asks how it connects, that's schematic-writer, not
this skill. If he's describing an app idea that isn't built yet, it's this skill.

---

## Document Structure

Always produce sections in this order (skip any that aren't relevant to the app):

1. **Title + stack line** — app name, one-line purpose, and the exact stack (frameworks,
   language, DB, styling)
2. **App Structure** — folder/file tree of the whole app
3. **Database Schema** — one block per table
4. **Models / Entities** — fillable fields, casts, relations (Laravel) or
   types/schema definitions + relations (Drizzle/TS)
5. **Feature / Component Breakdown** — one block per page or major component: state,
   actions, what it renders
6. **Request Flow** — a box diagram showing how a request moves from browser → routing
   → components/handlers → DB
7. **Notes / Where to Extend** — short prose bullets: natural extension points,
   deliberately deferred features (auth, multi-user, etc.), things kept simple on purpose

---

## Output Format

### 1. App Structure (folder tree)

```
app/
│
├─ Models/
│   ├─ Project.php
│   └─ Task.php
│
├─ Livewire/
│   └─ TaskManager.php   ← Tasks tab
│
resources/views/
└─ livewire/
    └─ task-manager.blade.php

routes/web.php
└─ GET /    → PlannerController@index
```

Rules:
- Use `│  ├─  └─` box-drawing characters consistently
- Annotate non-obvious files/folders inline with `←` (e.g. `← optional, add auth later`)
- Group by top-level concern (Models, Livewire/Controllers, views, routes) — not a raw
  `tree` dump; only show what's relevant to understanding the app

### 2. Database Schema (one block per table)

```
tasks
─────────────────────────────────────────
id            integer   PK
project_id    integer   FK → projects.id
title         string
priority      enum      urgent | normal | someday
planned_date  date      nullable  ← null = unplanned/backlog
is_done       boolean   default false
created_at
updated_at
```

Rules:
- Column name, type, then constraints/notes aligned in loose columns
- Mark PK/FK explicitly; use `←` for anything non-obvious (nullable meaning, defaults)
- Keep `created_at` / `updated_at` (or `createdAt`/`updatedAt`) as the last two rows if
  the stack auto-manages timestamps

### 3. Models / Entities

Laravel style:

```
Task
│
├─ $fillable   project_id, title, priority, planned_date, is_done
├─ $casts      is_done → boolean
│              planned_date → date
│
└─ RELATIONS
    └─ belongsTo Project
```

Drizzle/TS style:

```
tasks (pgTable)
│
├─ COLUMNS     id, projectId, title, priority, plannedDate, isDone
├─ TYPES       priority: pgEnum('urgent'|'normal'|'someday')
│
└─ RELATIONS
    └─ tasks.projectId → projects.id  (many-to-one)
```

### 4. Feature / Component Breakdown

One block per page/feature, same tree style as schematic-writer:

```
WeekPlanner
│
├─ STATE
│   ├─ $weekStart         Carbon  ← Monday of current week
│   └─ $backlog           Task[]  ← tasks where planned_date is null
│
├─ ACTIONS
│   ├─ previousWeek()     → $weekStart->subWeek() → reload
│   └─ assignTask($id, $date)   → Task::find → planned_date = $date
│
└─ RENDER
    week-planner.blade.php
    └─ @foreach $days   → <x-day-column>
```

For the TS stack, swap `$state`/Livewire actions for `useState`/route
loaders/Elysia handlers as appropriate, same tree shape.

### 5. Request Flow (box diagram)

```
┌─────────────────┐   GET /    ┌─────────────────┐
│     Browser     │ ─────────→ │PlannerController│
└─────────────────┘            └────────┬────────┘
                                        │ returns view('planner')
                                        ↓
                               ┌─────────────────┐
                               │  app.blade.php  │
                               └────────┬────────┘
                          ┌─────────────┴──────────────┐
                          ↓                             ↓
               ┌──────────────────┐        ┌───────────────────┐
               │  TaskManager     │        │   WeekPlanner      │
               └──────────────────┘        └───────────────────┘
                        │                           │
                   reads/writes                reads/writes
                        ↓                           ↓
               ┌──────────────────────────────────────────────┐
               │                  Database                    │
               └──────────────────────────────────────────────┘
```

Rules:
- Use `┌ ┐ └ ┘ │ ─` for boxes, `→ ← ↑ ↓` for arrows, label arrows with a verb
- One box per logical layer (browser, router/controller, layout, feature
  components/handlers, DB) — don't go deeper than that here, the Feature Breakdown
  section already covers component internals

### 6. Notes / Where to Extend

Short prose bullets only — this is the one section that isn't a diagram:

```
- Add `User` model + auth to make it multi-user later — models just need a `user_id` FK
- `order` column enables manual reordering without drag & drop (up/down buttons)
- Drag & drop: add SortableJS on top of Livewire once the core is working
```

---

## Style Rules

- `## ` headings with `---` horizontal rules between sections, same as the reference doc
- Inline code for field/column/function names
- Use `←` to explain a non-obvious value or a deliberate simplification
- Everything is a tree, table, or box diagram except section 6 — no explanatory prose
  paragraphs elsewhere
- Keep the whole doc skimmable in under a minute — this is a planning artifact, not a spec

---

## Gathering Input

Before writing, identify:
- **What's the app / feature, in one sentence?**
- **Which stack?** Laravel + Livewire, or the TS stack (React + TanStack Router +
  Elysia + Bun SQL + PostgreSQL + Drizzle)? Ask if not stated or obvious from context.
- **What are the core entities/tables?** (and their relations)
- **What are the main pages/features?** (these become the Feature Breakdown blocks)
- **Anything explicitly out of scope for v1?** (auth, multi-user, etc. — goes in Notes)

If Thomas gives a rough idea in prose, extract these answers directly rather than
asking all five questions — only ask what's genuinely missing or ambiguous (usually
just the stack, if unclear). Prefer producing a complete first draft over blocking on
questions.
