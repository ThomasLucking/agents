# AI Tutor Brief Template

Use this template when the user runs `/generate-ai-brief`. Fill each section from the current analysis, then write the completed file to disk.

```markdown
# AI Tutor Brief — [Subject / Exam Name]

## Context

- **Exam / Assignment:** [title or description]
- **Module / Course:** [if known]
- **Date generated:** [today's date]

## What this exam is asking

[Paste the original question or task here]

## Command word interpretation

[Command word] means the student must [explanation of cognitive operation required].

## Topics the student must cover

| # | Topic | Why it's needed | Priority |
|---|---|---|---|
| 1 | [topic] | [reason] | High / Medium / Low |

## Mark scheme notes

[Summarise the mark allocation and what top-band answers include]

## Common mistakes to avoid

- [mistake 1]
- [mistake 2]

## How to use this brief

You are acting as a tutor helping the student prepare for this specific assessment.
Use the topics table above to guide sessions. When the student practises an answer,
evaluate it against the mark scheme notes and flag any missing elements.
Start each session by asking the student which topic they want to focus on.
If they are unsure, begin with the highest-priority topic in the table.

## Revision approach recommended

[Pull from [[exam-advisor]] — e.g. active recall, timed past papers, spaced repetition]
```
