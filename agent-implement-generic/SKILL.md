---
name: fix-simple-issues-implementer-generic
description: >
  Implements a single, well-scoped GitHub issue in an isolated worktree,
  validates it, and has an Opus agent run /code-review-deep on the diff.
  Stack-agnostic — detects the project's own test/lint/format tooling
  instead of assuming Laravel. Trigger on "fix issue #42", "implement
  issue 17", or an issue labeled "Agent". Never commit or open a PR.
---

## Purpose

Take one issue, implement it in isolation, hand it back review-ready. The
human owns the commit and the PR.

## Workflow

### 1. Worktree

All worktrees live under a `worktrees/` folder at the repo root — one per
issue, so parallel work never collides:

```bash
git worktree add worktrees/<project>-issue-<N> -b fix/issue-<N>
```

Get it runnable so you can verify, not just read. Use whatever this
project actually uses to start — check for `docker-compose.yml`,
`Makefile`, `package.json` scripts, `Procfile`, etc., and run the
project's own dev/start command in the worktree (e.g. `docker compose up
-d`, `make dev`, `npm run dev`, `poetry run <cmd>`). If unsure, use
`agent-state procs` to see what's already running, or ask.

Laravel/Sail: `./vendor/bin/sail up -d`, then `npm run dev` in a separate
terminal; validate with `pint`, `phpstan analyse`, `sail artisan test`.

### 2. Implement (TDD)

Test-first, not test-after: a test written against code that already
exists tends to describe whatever was built rather than pin down what was
required. Ambiguity in the issue also surfaces earlier this way — writing
a concrete test forces you to commit to an interpretation before any code
exists to anchor you to it.

**2a. Write failing tests first.**

Read the relevant files first — existing patterns, interfaces, naming —
so the tests aren't written blind against an API that doesn't exist yet.
This is a read-through, not an implementation pass; don't write
production code here.

Use the `grill-with-docs` skill — don't guess — when writing the test
makes any of this apparent:

- acceptance criteria or expected behavior are ambiguous
- two reasonable approaches exist and the issue doesn't pick one
- technical detail is missing (schema, API shape, edge cases)
- the issue is bigger than stated (expand, split, or stop?)

Use the Skill tool to load the `tdd` skill and follow it to write or
extend tests that pin down the issue's acceptance criteria.

Run the tests and confirm they fail (red). A test that doesn't fail
before the fix isn't testing anything — flag it and rewrite it.

**2b. Implement.**

Write the minimum code needed to make the tests pass (green), staying
inside the issue's scope. Don't expand beyond what the tests require.

If implementation reveals scope beyond what the tests anticipated, stop and use grill-with-docs rather than expanding silently.

### 3. Validate

Detect the project's own tooling rather than assuming a stack. Prefer
`agent-state test` and `agent-state lint` (auto-detects Jest, Vitest,
Mocha, pytest, PHPUnit, cargo, go, ESLint, golangci-lint, clippy, PHPStan,
ruff, etc.) — run `agent-state all --pretty` first if unsure what's
available. Fall back to reading `package.json` scripts, `Makefile`
targets, or config files (`pyproject.toml`, `Cargo.toml`, `composer.json`)
to find the project's format/lint/typecheck/test commands.

All of the following must be clean before it's done (skip any that don't
apply to this stack):

- **format** — e.g. `prettier --check`, `pint`, `black --check`, `gofmt -l`, `cargo fmt --check`
- **lint / static analysis** — e.g. `eslint`, `phpstan analyse`, `ruff check`, `clippy`, `golangci-lint run`
- **tests** — e.g. `npm test`, `pytest`, `cargo test`, `go test ./...`, `sail artisan test`

### 4. Review pass

Spawn a review agent that chains into the `/code-review-deep` skill itself —
don't inline its instructions here:

```
Agent(subagent_type: "general-purpose", model: "opus",
      description: "Review issue #<N> changes",
      prompt: "Use the Skill tool to load the `code-review-deep` skill, then
                follow it against the diff in worktree <worktree path>
                for issue #<N>.")
```

Give it the worktree path and the issue number. Wait for its report. Fix
every **Critical** and **Important** finding, then re-run the project's
format, lint, and test commands from step 3.

### 5. Stop

Leave everything uncommitted. No `git commit`, no PR — that's the human's
call.
