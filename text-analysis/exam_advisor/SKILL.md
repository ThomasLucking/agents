---
name: exam-advisor
description: >
  Provide personalised revision strategies, study plans, and practice methods based on exam
  or assignment analysis. Trigger after [[instruction-analysis]] has broken down the criteria,
  or directly when the user asks how to revise, how to prepare, how to study, or how to practise
  for a specific topic or assessment. Also trigger on phrases like: "how should I revise this",
  "make me a study plan", "what's the best way to practice", "how do I prepare for this exam",
  "I have X days to revise", "where do I start", "what should I focus on", or "how do I implement
  this concept". Always tailor advice to the specific topics identified in [[instruction-analysis]]
  when available.
---

# Exam Advisor

**Goal:** Turn exam analysis into a concrete, personalised revision and practice plan.  
**Input:** The topic list and mark scheme notes from [[instruction-analysis]] (or the user's
own description of what they need to learn).

---

## Step 1 — Assess Starting Point

Before recommending anything, find out where the user is:

Ask (or infer from context):
1. **How much time do they have?** (days, weeks, hours per day)
2. **What's their current confidence per topic?** (0–10 or "no idea / some idea / comfortable")
3. **What's the exam format?** (essay, multiple choice, practical, problem-solving, mixed)
4. **Have they seen past papers?** (yes / no / some)
5. **What's worked for them before?** (if mentioned — use it; don't prescribe a method they hate)

If the user is in a hurry or low on time, skip asking and go straight to the triage plan (Step 2b).

---

## Step 2 — Choose the Right Strategy

### 2a — If they have enough time (2+ weeks)

Build a full spaced-repetition plan:

```
Week 1: Initial exposure — read, watch, take notes on all topics
Week 2: Active recall — flashcards, self-testing, practice problems
Week 3+: Spaced review — revisit weak topics, do past papers, mark yourself
Final 48h: Light review only — no new material
```

### 2b — If time is tight (under 2 weeks)

**Triage the topic list** from [[instruction-analysis]] into three buckets:

| Bucket | Criteria | Action |
|---|---|---|
| **Must know** | High marks, frequently examined, user has zero knowledge | Prioritise immediately |
| **Should know** | Medium marks or lower confidence | Cover if time allows |
| **Nice to know** | Low marks, likely implicit | Only touch if everything else is solid |

Give the user a day-by-day schedule built around Must Know topics first.

### 2c — If the exam is practical or implementation-based

Skip passive revision entirely. Go straight to doing:

1. Build or implement the thing from scratch (no notes)
2. Compare output to requirements
3. Identify gaps — go back and study only those gaps
4. Repeat

---

## Step 3 — Match Technique to Exam Type

### Essay / long-answer exams

The only way to prepare is to write. Use this loop:

1. **Recall dump** — without notes, write everything you know about a topic in 5 minutes
2. **Check** — open notes, see what you missed
3. **Targeted re-read** — read only the sections covering gaps
4. **Timed answer** — write a full answer under exam conditions
5. **Mark it** — use the mark scheme or ask an AI to evaluate it against the criteria

Repeat for each key topic. Do at least one full timed mock.

### Multiple choice / short answer

Focus on recognition, not just recall:

- Use flashcards (Anki or a simple paper deck)
- Do practice question banks — mark immediately after each question
- Review wrong answers first — understand why, not just what the right answer is
- Cluster questions by topic to identify weak areas

### Problem-solving / calculation-based

Worked examples beat re-reading theory:

1. Study one worked example until you understand each step
2. Cover the solution and re-do it
3. Do a new problem of the same type without help
4. Check — if wrong, diagnose which step failed
5. Move on only when you can do 3 in a row correctly

### Practical / implementation

Build a minimal working version of each concept:

- Set a 20-minute timer per concept
- If you can't get it working in 20 min, look up only the specific thing you're stuck on
- Keep a "gap log" — a running list of things you needed to look up
- Review the gap log the night before

---

## Step 4 — Build the Study Plan

Output a concrete day-by-day schedule. Format:

```
STUDY PLAN — [Subject]
Total time available: [X days / Y hours per day]
─────────────────────────────────────────────

Day 1 — [Date or Day Label]
  Focus: [Topic 1] — [Topic 2]
  Tasks:
    □ [Specific activity — e.g. "Write a recall dump on X for 10 min"]
    □ [Specific activity — e.g. "Do 20 flashcard reps on Y"]
    □ [Specific activity — e.g. "Write a timed answer to past paper Q3"]
  Target time: [hours]

Day 2 — ...
  ...

Day [n-1] — Buffer + weak topics
  Focus: Whatever scored lowest in self-tests
  Tasks:
    □ Re-test weakest topic
    □ Write one more timed answer

Day [n] — Final review (light)
  Focus: High-level recap only
  Tasks:
    □ Read your own notes / recall dumps from Day 1
    □ No new material
    □ Rest
```

---

## Step 5 — Practice Advice by Concept Type

### Theoretical concepts (laws, models, frameworks)

- Explain it out loud to an imaginary person (Feynman technique)
- Draw a diagram or mind map from memory
- Connect it to a real-world example — examiners reward application

### Procedural / step-by-step processes

- Write the steps from memory, in order
- Identify the step you always forget — make a mnemonic or highlight it
- Practise the process end-to-end, not just the individual steps

### Comparative / analytical topics

- Make a comparison table from memory
- State your judgement first ("X is more effective than Y because…"), then support it
- Write at least two counter-arguments and refute them — this is what top-band answers do

### Coding / technical implementation

- Code it without autocomplete for the first pass
- Use the docs only when completely stuck — note what you looked up
- Write a short comment explaining *why* each major section works, not just what it does
- Test edge cases, not just the happy path

---

## Quick Reference — Revision Techniques

| Technique | Best for | Time cost |
|---|---|---|
| Active recall / flashcards | Facts, definitions, terminology | Low |
| Timed past paper answers | Essays, long-answer | High |
| Worked example re-doing | Calculation, problem-solving | Medium |
| Feynman technique | Understanding complex concepts | Low–Medium |
| Spaced repetition (Anki) | Any factual content over 2+ weeks | Low per session |
| Mind mapping from memory | Checking breadth of knowledge | Low |
| Build from scratch | Practical / coding / implementation | High |
| Peer teaching | Any topic — forces you to expose gaps | Medium |

---

## Cross-reference

Always pair this skill with [[instruction-analysis]].  
Run [[instruction-analysis]] first to get the topic list and mark scheme — then return here
to build the revision and practice plan around exactly what the exam is testing.
