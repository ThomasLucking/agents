---
name: think-twice
description: >
  Pauses before expensive work to find the cheaper path. Use this skill before heavy computation,
  large code generation, repetitive data writing, or building more than what's needed — even if
  efficiency isn't mentioned explicitly. The goal is productive laziness: do less if less is enough.
---

# Think Twice

> "A great engineer is a lazy engineer. They find the clever shortcut." — Steve Jobs

Before charging ahead with the most obvious approach, pause and ask: IS THERE A SMARTER WAY?

Productive laziness is not about doing less. It's about never doing more than necessary.

The greedy approach: see task, start implementing, figure it out as you go.
The think-twice approach: see task, pause, find the clever path, implement only what's needed.

That one beat of reflection is the difference between a solution that costs 50,000 tokens and one that costs 50.

---

## The Checklist

Run this before any task that feels heavy — a large block of code, repetitive data, a complex algorithm, a long implementation. Stop at the first question that reveals a better path.

### 1. Am I solving the right problem?

Make sure the task is correctly understood before writing a single line.
- What is the user ACTUALLY trying to achieve?
- Am I about to solve a symptom instead of the root cause?
- Would a 2-sentence clarification save 200 lines of code?
- Do I fully understand what's being asked, or am I assuming?

### 2. Is there an existing solution?

Someone has almost certainly solved this before.
- Does a public API already expose this data or functionality at runtime? Prefer it — no maintenance, always up to date.
- Would a package (`npm install`, `pip install`) deliver this in 10 lines instead of 200?
- Is there an open dataset (CSV, JSON, SQLite) from a trusted source?
- Does the language's standard library already cover this?

### 3. Am I doing too much?

Scope creep is the enemy of efficiency.
- Does the user need ALL of this, or just a slice?
- Am I precomputing everything when I could compute on demand?
- Am I generating 100 cases when 3 examples would prove the point?
- YAGNI: if it's not needed RIGHT NOW, don't build it.
- Am I building more than what's needed today?

### 4. Is my approach the most direct one?

The obvious implementation is rarely the best one.
- Would a simpler data structure make the algorithm trivial?
- Is there a one-liner that replaces 50 lines of logic?
- Am I reaching for complexity when a lookup table would do?
- Can I reframe the problem so the solution becomes obvious?

### 5. Can I do this lazily?

Defer work until it's actually needed.
- Generate on demand instead of precomputing all cases.
- Paginate instead of loading everything.
- Cache results instead of recomputing.
- Render what's visible, not what exists.

### If no shortcut found

If none of the above reveals a better path, commit to the implementation — but scope it to the minimum that solves the problem today.

---

## Common Shortcuts

| Instead of... | Consider... |
|---|---|
| Implementing a complex feature from scratch | Checking if a library already does it |
| Hardcoding a large static dataset | Fetching it from an API at runtime |
| Generating all permutations upfront | Computing on demand with memoization |
| Building the full system now | Building only the part that's needed today |
| Writing a clever algorithm | Checking if a simpler data structure makes it trivial |
| Implementing auth, payments, maps from scratch | Using a well-established library or service |
| Generating many examples to prove a point | Using 2 or 3 representative cases |
| Preloading everything on startup | Loading lazily when actually needed |

---

## When NOT to Apply

Productive laziness has limits. Override it when:

- Security-critical code needs a vetted internal implementation — correctness demands it.
- A runtime API call adds unacceptable delay to a hot path — latency demands it.
- The environment is offline-first or zero-dependency — restrictions demand it.
- Adding a library would be overkill for 5 lines of trivial code — the shortcut costs more than the direct path.

In these cases, proceed — but state why you are taking the direct approach.
