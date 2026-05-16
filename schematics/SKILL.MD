---
name: schematic-writer
description: >
  Produces architecture schematics and call-graph documentation in the style of Thomas's
  existing codebase docs. Use this skill whenever Thomas asks for a "schematic", "architecture doc",
  "call graph", "data flow diagram", or says things like "document how X works", "write a schematic
  for X", "map out the flow of X", or "explain the architecture of X in schematic form".
  Also trigger when Thomas pastes code and asks how the pieces connect, or wants a
  side-by-side comparison between two components/pages.
---

# Schematic Writer

Produce clean, ASCII-tree architecture schematics in the style of Thomas's existing docs,
plus one optional visual box diagram showing component-to-component call relationships.

---

## Output Format

### 1. ASCII Tree Schematics (primary)

Use the established style from Thomas's codebase:

```
ComponentA
│
├─ READ from store
│   └─ useStore(s => s.value)
│
├─ DERIVED
│   └─ selector(state) → Result[]
│        │
│        ├─ 1. STEP   description
│        └─ 2. STEP   description
│
└─ RENDER
    result.map(item => <Component />)
```

Rules:
- Use `│  ├─  └─` box-drawing characters consistently
- Annotate key logic inline with `←`, `→`, `⚠`, `✓`, `✗`
- Number sequential steps (1. COPY, 2. FILTER, 3. SORT…)
- Add `⚠` warnings for inconsistencies or gotchas
- Keep lines under ~80 chars; wrap with indentation

### 2. Side-by-Side Comparison Table (when two components share logic)

```
                        ComponentA              ComponentB
─────────────────────── ─────────────────────── ───────────────────────
Source data             state.all               state.all
User scoping            none                    t.userId === userId
Filter X                ✓                       ✓
Field used              adminLevel ?? level     level only  ⚠
```

### 3. Re-render / Trigger Table (when reactive state is involved)

```
Store write             Selector re-runs?   Component re-renders?
─────────────────────── ─────────────────── ─────────────────────
setData(new list)        yes                 yes (array changed)
setFilter(…)             yes                 yes
```

### 4. Box Diagram (one per schematic, optional but encouraged)

A simple ASCII rectangle diagram showing **who calls whom**:

```
┌─────────────────┐        calls         ┌─────────────────┐
│   ComponentA    │ ──────────────────→  │   useStoreX     │
└─────────────────┘                      └─────────────────┘
         │                                        │
         │ dispatches                             │ returns
         ↓                                        ↓
┌─────────────────┐                      ┌─────────────────┐
│   setTickets()  │                      │   Ticket[]      │
└─────────────────┘                      └─────────────────┘
```

Rules for box diagram:
- Use `┌ ┐ └ ┘ │ ─` for boxes
- Use `→ ←  ↑ ↓` for arrows; label them with a verb ("calls", "dispatches", "returns", "reads")
- Keep it high-level — one box per logical unit (component, store, API, WebSocket…)
- Place it **after** the detailed ASCII trees, as a visual summary

---

## Document Structure

Always produce sections in this order (skip any that aren't relevant):

1. **Title + context line** — what pages/stack this covers
2. **Data Entry Point** — where data originates (loader, API, WebSocket…)
3. **Store / State Shape** — fields, persistence, actions
4. **Per-component Call Graphs** — one tree per component
5. **Side-by-Side Comparison** — if 2+ components share logic
6. **Re-render Triggers** — if reactive state is involved
7. **Box Diagram** — visual call/data-flow summary
8. **Notes / Where to extend** — optional, for future work hints

---

## Style Rules

- Write headings with `## ` and `---` horizontal rules between sections
- Use inline code for store keys, field names, function names: `statusFilter`, `getFilteredTickets`
- Use `←` after a value to explain its origin: `adminLevel ?? level  ← admin override wins`
- Prefer trees over prose for anything sequential or hierarchical
- Only write prose for "Notes / Where to extend" — everything else is visual

---

## Gathering Input

Before writing, identify:
- **What are the components/pages involved?**
- **Where does the data come from?** (loader, API call, WebSocket, prop…)
- **Is there shared state?** (Zustand store, Context, prop drilling…)
- **Are there derived/computed values?** (selectors, useMemo…)
- **Any known gotchas or inconsistencies** to flag with ⚠?

If the user pastes code, extract these answers from the code directly.
If anything is ambiguous, ask one focused question before proceeding.