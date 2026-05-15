---
name: project-ideas
description: Generate original, creative project ideas tailored to Thomas's tech stack (React, TanStack Router, Laravel, Elysia.js, TypeScript, PostgreSQL, Drizzle ORM, TailwindCSS). Trigger this skill whenever Thomas asks for project ideas, wants something to build, says "I don't know what to build", asks for inspiration, says "suggest a project", "what should I build next", "give me an app idea", or any variation. Also trigger when Thomas mentions wanting to practice a specific technology and needs a project to do it with. Be pushy about using this skill — if the request is about building something or finding inspiration, use it.
---

# Project Idea Generator

Generate **original** project ideas for Thomas. Avoid the classics (todo app, weather app, blog, e-commerce clone). Push toward ideas that are genuinely interesting, have a real use case, or have a creative twist.

## Thomas's Stack

- **Frontend**: React, TanStack Router, TailwindCSS, TypeScript
- **Backend**: Laravel (PHP) or Elysia.js (Bun/TS)
- **DB**: PostgreSQL + Drizzle ORM
- **Interests**: App architecture, note-taking tools, UI design

## How to Generate Ideas

### 1. Understand the Request
- Is Thomas asking for general ideas, or practicing a specific technology?
- Does he want a small project (weekend) or something more substantial?
- Any domain preference (productivity, games, tools, social, data)?

If unclear, ask **one** question before generating. Otherwise generate directly.

### 2. Generate 3–5 Ideas

For each idea, provide:
- **Name** — short and catchy
- **Concept** — 1–2 sentences. What makes it original?
- **Core challenge** — the interesting technical problem it involves
- **Stack fit** — which parts of the stack get exercised

### 3. Originality Rules

Avoid:
- Todo apps, weather apps, note clones (unless there's a genuinely novel twist)
- Straight CRUD with no interesting data model or UX challenge
- "X for Y" clones of well-known apps

Push toward:
- Apps with non-trivial data relationships or real-time elements
- Tools Thomas himself would actually use
- Ideas that explore an underexplored niche
- Projects with an interesting algorithmic or architectural core

### 4. Calibrate to Scope

| Scope | Description |
|-------|-------------|
| **Weekend** | 1–2 models, one interesting feature, deployable fast |
| **Medium** | 3–5 models, interesting data model, a few polished features |
| **Ambitious** | Real product-level idea, complex architecture, long runway |

Default to **medium** unless stated otherwise.

---

## Example Output Shape

```
### 🗂 Flashcard Spaced-Repetition CLI + Web Hybrid
A personal SRS (spaced-repetition system) where decks are edited in the terminal 
but reviewed in a polished web UI. Cards support markdown + code blocks.

**Core challenge**: SM-2 scheduling algorithm, syncing terminal edits to the DB in real time.
**Stack fit**: Elysia.js for the API + file watcher, React + TanStack Router for the web UI, Drizzle for card + review history schema.
```
