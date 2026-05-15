---
name: git-workflow
description: >
  Git workflow skill for apprentices — branching, PRs, merge conflicts, group project etiquette,
  commit hygiene, and rebasing. Activate when the user asks about git branching, how to structure
  commits, how to open a PR, how to resolve merge conflicts, how to keep a branch up to date, or
  asks anything like "how do I collaborate on git", "what branch should I use", "my branch is behind",
  "I have a merge conflict", "how do I write a good commit message", or "how do PRs work".
---

# Git Workflow

Practical git for a 1st-year apprentice working on group projects.

---

## Core Mental Model

Think of `main` (or `master`) as the **production-safe branch** — code only lands there when it's
reviewed and ready. You never push directly to it. Instead:

1. Branch off `main` → do your work → open a PR → get reviewed → merge.

That loop is the job.

---

## Branch Naming

Keep it short, lowercase, hyphen-separated, and tied to the work:

```
feature/user-login
fix/broken-nav-link
chore/update-readme
```

Prefixes that matter to teams:
- `feat/` — new functionality
- `fix/` — bug fixes
- `chore/` — non-code tasks (docs, deps, config)
- `hotfix/` — urgent production patches (branch off `main`, not your current work)

---

## The Daily Loop (group projects)

### 1. Start fresh from main

Always branch from an up-to-date `main`:

```bash
git switch main
git pull origin main
git switch -b feature/your-thing
```

### 2. Commit often, in small logical chunks

Don't commit one giant blob at the end of the day. Commit each logical unit of work as you go.

```bash
git add src/components/LoginForm.tsx
git commit -m "add basic login form layout"

git add src/api/auth.ts
git commit -m "wire up login form to auth endpoint"
```

### 3. Keep your branch up to date

While you work, `main` moves. Rebase regularly to avoid a painful conflict at PR time:

```bash
git fetch origin
git rebase origin/main
```

If conflicts appear during rebase, resolve them (see below), then:

```bash
git add <resolved-files>
git rebase --continue
```

### 4. Push and open a PR

```bash
git push origin feature/your-thing
```

Then open a pull request on GitHub/GitLab. Write a description — don't leave it blank.

---

## Writing Good Commit Messages

Follow this structure:

```
<type>: <short summary in present tense>

Optional: a sentence or two explaining WHY, not what.
```

**Good:**
```
fix: prevent login form from submitting with empty email
feat: add pagination to the posts index page
chore: upgrade eslint to v9
```

**Bad:**
```
stuff
fixed it
WIP
asdfgh
```

Rules:
- Present tense ("add" not "added")
- Max ~72 chars on the first line
- If the why isn't obvious, add a body
- One logical change per commit

---

## Merge Conflicts

A conflict happens when two people edited the same lines. Git can't decide which to keep — you have to.

### What a conflict looks like in the file:

```
<<<<<<< HEAD
const greeting = "Hello";
=======
const greeting = "Hi there";
>>>>>>> origin/main
```

- Everything between `<<<<<<< HEAD` and `=======` is **your version**
- Everything between `=======` and `>>>>>>>` is **the incoming version**

### How to resolve:

1. Open the file, decide what the correct code is
2. Delete the conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`) and the wrong version
3. Save the file
4. `git add <file>`
5. Continue (`git rebase --continue` or `git merge --continue`)

If you're completely lost:
```bash
git rebase --abort   # undo the rebase entirely, go back to where you were
```

### VS Code tip

VS Code highlights conflicts and gives you buttons: "Accept Current", "Accept Incoming", "Accept Both". Use them — don't edit the raw markers by hand unless you need to.

---

## PR Etiquette (group projects)

**Opening a PR:**
- Give it a clear title that describes the change, not "my changes"
- Write a short description: what does this do, and why?
- Link to the ticket/issue if there is one
- Mark it as a draft (`[Draft]` or GitHub's draft PR) if it's not ready for review

**Reviewing someone else's PR:**
- Be specific — "line 24: this will throw if `user` is null" beats "looks wrong"
- Suggest, don't demand — "could we use X here instead?" is friendlier than "change this"
- Approve when it's good enough, not when it's perfect
- Don't merge your own PRs unless the team has agreed it's OK for small chores

**Getting your PR reviewed:**
- Don't ping people immediately — give them a few hours
- If it's urgent, message in the team channel, don't DM-spam
- Respond to every comment, even if just "done" or "discussed in call"

---

## Common Situations

### "I pushed to main by accident"

Stop. Tell your team lead immediately. Don't try to rewrite history on `main` yourself — force-pushing a shared branch can delete other people's work.

### "My branch is way behind main"

```bash
git fetch origin
git rebase origin/main
```

If there are a lot of conflicts and the branch is old, consider whether it's easier to start fresh and re-apply your changes manually.

### "I committed to the wrong branch"

If you haven't pushed yet:
```bash
git checkout correct-branch
git cherry-pick <commit-hash>    # copy the commit across
git checkout wrong-branch
git reset HEAD~1                 # undo the commit on the wrong branch (keeps the changes)
```

### "I want to undo my last commit but keep the code"

```bash
git reset HEAD~1
```

Your changes stay in the working directory — you just un-committed them.

### "I want to throw away everything and match remote"

```bash
git fetch origin
git reset --hard origin/main
```

**Warning:** this destroys any uncommitted changes permanently.

### "I need to save my work without committing (context switch)"

```bash
git stash          # saves dirty state
git stash pop      # restores it later
```

---

## Rebase vs Merge

| | Rebase | Merge |
|---|---|---|
| History | Linear, clean | Preserves branch topology |
| When to use | Keeping a feature branch up to date with main | Merging a finished PR into main |
| Risk | Can cause problems if you rebase a branch others are using | Safe |
| Rule | Rebase **your own branches** only — never rebase shared branches |

On your own feature branch: `git rebase origin/main` — fine.
On `main` itself: never rebase, always merge (or squash merge via the PR UI).

---

## Quick Reference

```bash
git status                        # what's changed
git log --oneline -10             # last 10 commits
git diff                          # unstaged changes
git diff --staged                 # staged changes
git branch -a                     # all branches
git checkout -b feature/name      # create + switch branch
git fetch origin                  # get remote updates (doesn't change your files)
git pull origin main              # fetch + merge main into current branch
git rebase origin/main            # replay your commits on top of latest main
git stash / git stash pop         # shelve / restore dirty work
git reset HEAD~1                  # undo last commit, keep changes
git cherry-pick <hash>            # copy a specific commit to current branch
```
