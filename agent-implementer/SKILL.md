---
name: fix-simple-issues-implementer
description: >
  Implements a single, well-scoped GitHub issue in an isolated worktree,
  validates it, logs it for human review, and has a Haiku agent review the
  diff. Trigger on "fix issue #42", "implement issue 17", or an issue
  labeled "Agent". Never commit or open a PR.
---

## Purpose

Take one issue, implement it in isolation, hand it back review-ready. The
human owns the commit and the PR.

## Workflow

### 1. Worktree

All worktrees live under a `worktrees/` folder at the repo root — one per
issue, so parallel work never collides:

```bash
git worktree add worktree/<project>-issue-<N> -b fix/issue-<N>
```

Get it runnable so you can verify, not just read:

```bash
./vendor/bin/sail up -d
npm run dev   # separate terminal
```

### 2. Implement

Stay inside the issue's scope. Use the `grill` skill — don't guess — when:

- acceptance criteria or expected behavior are ambiguous
- two reasonable approaches exist and the issue doesn't pick one
- technical detail is missing (schema, API shape, edge cases)
- mid-way you find the issue is bigger than stated (expand, split, or stop?)

### 3. Validate

Both must be clean before it's done:

```bash
./vendor/bin/pint
./vendor/bin/phpstan analyse
```
### 5. Review pass

when you are reviewing you must use the skill 'code-review' to do so.

```
Agent(subagent_type: "general-purpose", model: "haiku",
      description: "Review issue #<N> changes",
      prompt: <see the `agent-diff-reviewer` skill>)
```

Give it the worktree path, the issue number, and the log path. Wait for its
report. Fix anything it flags as a correctness bug, then re-run pint and
phpstan. Append unresolved or rejected findings to the log under
`## Review notes` with a one-line reason.

### 6. Stop

Leave everything uncommitted. No `git commit`, no PR — that's the human's
call.
