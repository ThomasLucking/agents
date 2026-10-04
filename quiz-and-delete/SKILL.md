---
name: quiz-and-delete
description: >
  Quizzes Thomas on why code (or a doc / web page) is implemented the way it is, then for each
  question he fails it explains the decision, deletes that code, and leaves short instructions
  so he can rewrite it himself. Invoke with /quiz-and-delete <file | dir | git diff | URL | pasted text>.
disable-model-invocation: true
argument-hint: "<file path | directory | 'diff' | URL>"
---

# Quiz and Delete

The aim is understanding the **design decisions**, not memorizing syntax. Thomas uses this skill to
show he actually understands code he wrote, or code that was generated for him.

Explanations are part of what he asked for here, so the global "no explanation" output rule does
**not** apply while the quiz is running. Use `[Thing][Action][Summary]` lines only in the final summary.

## 1. Resolve the source

| Argument | How to load it | Can delete? |
|---|---|---|
| File / directory path | Read the files | Yes |
| `diff` or nothing | `git diff` + `git diff --cached` + untracked files from `git status` | Yes |
| URL | `agent-browser open <url> && agent-browser get text body`, then `agent-browser close` | No |
| Pasted text | Use it as is | No |

When a directory or diff is large, rank the files by how much logic they hold (controllers, services,
models, JS modules) and quiz on the top 3–5. Skip config files, migrations that only add columns, views
that only lay out markup, and generated code.

## 2. Pull out the decisions

Read the code and list **implementation decisions**: places where the author picked one approach
over a reasonable alternative. Good targets:

- Why this function / class / layer exists at all (what would break or get worse without it)
- Why X instead of Y (a query scope instead of a raw `where`, a job instead of inline work, an
  Action class instead of controller logic, `debounce` instead of firing on every keystroke, a cache here)
- Why the data flows in this order (validate → normalize → embed → store)
- Why the edge case is handled here (null check, early return, fallback, transaction)
- Why this config value, threshold, or default

Do **not** ask about syntax, exact method signatures, variable names, line-by-line behavior, or
anything he could answer by reading the line aloud.

Choose **5–8 decisions** by default (or the number he asked for). Each one maps to an exact,
contiguous code region (file + line range) that would be deleted if he fails it. Keep the list to
yourself. Don't show it, because it gives away the answers.

## 3. Run the quiz: one question at a time

For each decision:

1. Show the relevant snippet (≤15 lines, `file:line` reference) **or** just name the function when the
   snippet would give the answer away.
2. Ask one open question. Templates:
   - "Why does `X` exist instead of doing this directly in `Y`?"
   - "Why `A` here and not `B`? What would go wrong with `B`?"
   - "What problem does this solve? What happens if it's removed?"
   - "Why does this step happen before that one?"
3. **Stop and wait for his answer.** Never ask the next question in the same turn.
4. Grade his answer:
   - **Pass**: gets the core reason, even with rough wording. Confirm it in one line and add any nuance he missed in one more line. The code stays.
   - **Partial**: right direction, but the key reason is missing. Give one hint and let him try once more. After that retry, grade Pass or Fail.
   - **Fail**: wrong, "I don't know", or he skips. Go to step 4.

Be strict about the *why*. An answer that only says *what* the code does ("it filters the chunks")
is a Partial at best.

## 4. On a fail: explain → delete → instruct

### 4a. Explain
Explain the decision briefly: what problem it solves, why the alternative is worse in **this**
codebase, and what would break without it. Keep it to 3–6 sentences. Link the official docs when a
framework feature is involved (check with `ctx7` first).

### 4b. Back up, then delete (deletable sources only)
1. Save the region before deleting it:
   `~/.claude/quiz-and-delete-backups/<repo-name>/<YYYY-MM-DD_HHMM>/<file-path-with-__>.<startLine>-<endLine>.txt`
   Untracked files can't be restored with git, so this backup is mandatory.
2. Delete the region, but keep the file parseable:
   - Whole function or method → keep the signature and return type, replace the body with
     `// TODO(quiz): <one-line goal>` plus a placeholder that compiles if needed
     (`throw new \LogicException('TODO(quiz)');` / `throw new Error('TODO(quiz)')`).
   - Block inside a function → replace it with `// TODO(quiz): <one-line goal>`.
   - Whole class or file → keep the class shell and its public method signatures, and stub the bodies.
   - Never delete code he passed on, and never touch files outside the quiz scope.
3. Use the comment syntax that fits the file (`{{-- --}}` in Blade, `/* */` in CSS).

### 4c. Mini instructions
Write instructions that guide him without handing over the solution:

```
### Rebuild: <decision name>  (<file>:<line>)
Goal: <what the code must achieve, one sentence>
Constraints: <the reason from the explanation that the solution has to respect>
Steps:
1. <hint-level step, e.g. "Add a query scope on Chunk that takes the excluded terms">
2. ...
Docs: <link>
Done when: <observable check: test name, behavior in the UI, tinker result>
```

3–6 steps. Name the Laravel/JS feature to use, but don't write the code. Append each block to
`<backup-dir>/INSTRUCTIONS.md` as well.

For URLs and pasted text, skip 4b and still give 4a and a short "re-read this section" note.

## 5. Wrap up

When the questions are done, print:

```
Score: X / N
[file:line][Kept|Deleted][decision, one line]
...
Backup + instructions: <backup-dir>
Restore all: cp from the backup dir, or `git checkout -- <file>` for tracked files
```

Ask whether he wants a second round on the decisions he failed once he has rebuilt them. Never commit.
