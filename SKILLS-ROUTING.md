# Skill routing

Read when several skills could fit, or when planning a feature. Pick one skill per job from the tables below. If a skill isn't listed, its own description decides.

## Pick by job

| Job | Use | Not |
| --- | --- | --- |
| Stress-test a plan or idea | `grilling` | |
| Pin a domain term, write an ADR | `domain-modeling` | |
| Unclear UI or state model | `prototype` | |
| New app, no code yet | `app-architecture-planner` | |
| Write code test-first | `tdd` | |
| Design a module interface or seam | `codebase-design` | |
| One GitHub issue, end to end | `agent-implement-generic` | |
| Bug, error, regression, slowness | `diagnosing-bugs` | guessing a fix first |
| Library / framework API | `find-docs` | memory |
| Explain or teach a concept ("what is X", "how does X work") | `thomas-learning` | `anthropic-skills:learn`, `anthropic-skills:thomas-learning` |
| Anything in a browser | `agent-browser` | WebFetch |
| Steps only the human can do (secrets, dashboards) | `wizard` | |
| PR body | `pr` | |
| Edit a skill, AGENTS.md or CLAUDE.md | `writing-for-agents` | |

## Review: pick by question

| Question | Use |
| --- | --- |
| Does the diff follow the repo's standards and match its issue/spec? | `code-review` |
| Is the diff correct, secure, fast? (5 axes, Critical/Important severities) | `code-review-deep` |
| Post findings as inline comments on a GitHub PR | `pr-review` |
| Is the diff over-engineered? | `ponytail:ponytail-review` |
| Handoff plans for another agent | `improve` |
| Laravel security | `laravel-owasp-security` |

## Feature workflow

The user runs the steps marked *(user)*; those skills are user-invoked and you cannot call them. Suggest the command when that step is next.

1. `/grill-with-docs` *(user)*: shared understanding, glossary, ADRs.
2. `prototype`: only if a UI or state model is unclear.
3. `/to-spec` *(user)*: GitHub issue with user stories and test seams.
4. `/to-tickets` *(user)*: vertical slices.
5. Build one ticket: `agent-implement-generic`. Never commit.
6. Check: `ponytail:ponytail-review`, then `agent-browser` on the running app.
7. `/quiz-and-delete` *(user)* on the diff.
8. `pr`, then `pr-review`.
9. `/retro` *(user)*.

Shortcuts: a bug starts at `diagnosing-bugs` (its regression test is the first `tdd` red). A small fix starts at step 5. Messy existing code: suggest `/improve-codebase-architecture` *(user)*.

## Other user-invoked skills

Suggest, don't call: `/setup-matt-pocock-skills` (once per repo, before `/to-spec`), `/handoff` (long session), `/teach` (multi-session course), `/docs-coherence` (docs contradict each other or the code).
