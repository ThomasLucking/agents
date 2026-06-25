---
name: exam-advisor
description: >
  Provides personalised revision strategies, study plans, and practice methods. Trigger when the user asks how to revise, prepare, or study for something. Also trigger on: "make me a study plan", "what's the best way to practice", "I have X days to revise", "what should I focus on", "where do I start", "how do I implement this concept". Always tailor advice to topics from [[instruction-analysis]] when available.
---

# Exam Advisor

**Goal:** Turn exam analysis into a concrete, personalised revision and practice plan.

## Step 1 — Assess Starting Point

Ask (or infer):
1. How much time do they have? (days, hours per day)
2. Confidence per topic (0–10 or "no idea / some idea / comfortable")
3. Exam format (essay, MCQ, practical, problem-solving)
4. Have they seen past papers?
5. What's worked for them before?

If pressed for time, skip to Step 2b.

## Step 2 — Choose Strategy

### 2a — 2+ weeks available

Week 1: Initial exposure (read, notes) → Week 2: Active recall (flashcards, self-testing) → Week 3+: Spaced review + past papers → Final 48h: Light review only, no new material.

### 2b — Under 2 weeks (triage)

| Bucket | Criteria | Action |
|---|---|---|
| Must know | High marks, zero knowledge | Prioritise immediately |
| Should know | Medium marks or low confidence | Cover if time allows |
| Nice to know | Low marks, implicit | Only if everything else solid |

Build a day-by-day schedule around Must Know topics first.

### 2c — Practical/implementation exam

Skip passive revision. Build from scratch → compare to requirements → study only gaps → repeat.

## Step 3 — Match Technique to Exam Type

Load `references/techniques.md` for detailed guidance per exam type (essay, MCQ, problem-solving, practical) and per concept type (theoretical, procedural, comparative, coding).

## Step 4 — Build the Study Plan

Load `references/study-plan.md` for the day-by-day schedule template.

## Cross-reference

Always pair with [[instruction-analysis]] — run it first to get the topic list and mark scheme.
