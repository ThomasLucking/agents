---
name: stack-advisor
description: >
  Recommend the right tech stack for a given project idea, considering the developer's existing skills,
  the app's complexity, and realistic learning time for unfamiliar libraries. Always trigger this skill
  when Thomas asks things like "what tech should I use for X", "is Y a good fit for this project",
  "how hard is it to learn Z for this", "what stack do you recommend", "should I use X or Y for this app",
  or when scoping a new project and technology choices haven't been made yet. Also trigger when Thomas
  mentions a library he's never used and wants to know if it's worth learning for a specific project.
  Be pushy — if a new project is being discussed and stack hasn't been settled, always use this skill.
---

# Stack Advisor

Recommend the right tech stack for Thomas's project, accounting for his existing skills, the app's
actual requirements, and honest learning-time estimates for any unfamiliar technology.

---

## Thomas's Baseline Stack (no learning time needed)

| Layer       | Known tools                                         |
|-------------|-----------------------------------------------------|
| Frontend    | React, TanStack Router, TailwindCSS, TypeScript     |
| Backend     | Laravel (PHP), Elysia.js (Bun/TS)                  |
| DB          | PostgreSQL, SQLite, Drizzle ORM                     |
| Infra       | Docker (decent)                                     |
| Templating  | Blade (basic)                                       |

Thomas is **intermediate-to-senior** level. Skip beginner explanations. He learns fast but time is finite —
a weekend project cannot absorb a week of library learning.

---

## How to Produce a Recommendation

### 1. Extract Project Parameters

From the conversation, identify:
- **App type** — CRUD tool, real-time, data-heavy, public-facing, personal/internal
- **Scope** — weekend / medium (2–3 weeks) / ambitious
- **Key interactions** — forms, live updates, drag & drop, charts, file uploads, etc.
- **Deployment target** — local only, self-hosted, public

If any of these are unclear, ask **one focused question** before proceeding.

### 2. Identify Candidate Technologies

For each layer (frontend, backend, DB, extras), list 1–3 realistic options given the project type.
Pull from Thomas's known stack first. Only suggest unfamiliar tech if it provides a clear, non-trivial advantage.

### 3. Score Each Option

For each candidate, evaluate:

| Criterion         | What to assess                                               |
|-------------------|--------------------------------------------------------------|
| **Fit**           | Does it actually solve the core challenge of this app?       |
| **Familiarity**   | Is it in Thomas's known stack?                               |
| **Learning time** | If unfamiliar — realistic hours/days to be productive        |
| **Scope risk**    | Could learning this kill the weekend / blow the timeline?    |
| **Long-term value** | Is this worth learning beyond this project?               |

### 4. Learning Time Estimates

When recommending an unfamiliar library, always include a realistic estimate:

| Library / Tool     | Learning curve          | Time to productive     | Notes                                      |
|--------------------|-------------------------|------------------------|--------------------------------------------|
| Livewire 3         | Low                     | 2–4 hours              | Feels like Laravel, minimal new concepts   |
| Alpine.js          | Very low                | 1–2 hours              | Just sprinkled JS directives               |
| Inertia.js         | Low-medium              | 4–8 hours              | Needs mental model shift on routing        |
| Filament           | Low (with Laravel base) | 3–6 hours              | Admin panel, very batteries-included       |
| React Query        | Medium                  | 4–8 hours              | New caching mental model                   |
| Zustand            | Low                     | 1–3 hours              | Tiny API surface                           |
| Prisma             | Low-medium              | 3–5 hours              | Different from Drizzle but similar concept |
| tRPC               | Medium                  | 6–10 hours             | Type-safe API, needs full-stack TS setup   |
| SortableJS         | Low                     | 1–2 hours              | Drop-in drag & drop, pairs with Livewire   |
| Chart.js           | Low                     | 1–3 hours              | Simple charts, good docs                   |
| D3.js              | High                    | 2–5 days               | Only if custom/complex visualizations      |
| Next.js            | Medium                  | 1–2 days               | SSR mental model, file-based routing       |
| Nuxt               | Medium                  | 1–2 days               | Same but Vue                               |
| Pest (PHP testing) | Low                     | 2–4 hours              | Expressive, Laravel-native                 |

For any library NOT in this table, estimate based on: API surface size, quality of docs, similarity to known tools.

### 5. Output Format

Always produce:

```
## Recommended Stack

[One paragraph: what stack, why it fits this specific project]

### Layer-by-layer

| Layer      | Choice       | Reason                          | Learning time  |
|------------|--------------|---------------------------------|----------------|
| Backend    | Laravel      | Already known, good fit         | 0              |
| Frontend   | Blade + Livewire | Reactive without full SPA   | ~3h            |
| Styling    | Tailwind     | Already known                   | 0              |
| DB         | SQLite       | Personal tool, zero setup       | 0              |
| Extra      | Alpine.js    | Small interactions, no overhead | ~1h            |

### Weekend viability

[Honest assessment: can this be finished in the stated scope?
 Flag any library that adds >1 day of learning as a risk.]

### What to skip (and why)

[List technologies that might seem tempting but are overkill or risky for this scope]

### If you want to go further later

[Optional: what to add after the MVP works]
```

---

## Rules

- **Never recommend a full JS framework (React, Vue, Next) for a personal Laravel tool** unless there's
  a specific reason (real-time collaboration, complex client state). Blade + Livewire is almost always enough.
- **Flag scope risk explicitly.** If a library takes >4h to learn and the project is a weekend build, say so.
- **Don't pad the stack.** Every added technology is a risk. Recommend the minimum that gets the job done well.
- **SQLite over PostgreSQL for personal/local tools.** Zero setup, more than fast enough, easier to back up.
- **Prefer batteries-included over flexible** for apprentice/weekend projects — Filament over custom admin,
  Livewire over raw AJAX, Tailwind UI components over custom CSS.
- **If Thomas already knows the right tool, just confirm it** — don't invent alternatives for the sake of variety.
