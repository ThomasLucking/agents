---
name: pr-review
description: Reviews a GitHub pull request by running the /code-review-deep skill on its diff, then posts every finding as a Greptile-style inline PR review comment (bold title, "Prompt To Fix With AI" block, Fix in Claude Code / Fix in Codex buttons) through the GitHub API under the user's own gh account. Trigger on "review my PR", "review PR #12", "pr-review", or "/pr-review".
---

# PR Review

Run `/code-review-deep` against a PR's diff, render each finding in the Greptile comment format, and post them as one GitHub review from the user's account (whoever `gh` is authenticated as). No severity badge (no P1/P2).

## 1. Resolve the PR

- Argument given (number or URL) → use it. Otherwise use the PR for the current branch.
- Collect metadata:
  ```bash
  gh pr view <PR> --json number,headRefName,headRefOid,baseRefName,url,title
  gh repo view --json nameWithOwner -q .nameWithOwner
  gh pr diff <PR> > <scratchpad>/pr.diff
  gh api user -q .login
  ```
- No PR found → `[PR][Blocked][No pull request for this branch]` and stop.
- `gh api user` fails → `[gh][Blocked][Not authenticated — run `! gh auth login`]` and stop.

## 2. Run the code review

Invoke the `code-review-deep` skill with the Skill tool, passing the PR diff and title as the review target. Review only lines changed in the diff.

Keep only **Critical** and **Important** findings that you have verified against the actual code (read the file, confirm the failure scenario). Drop Suggestions unless the user asked for them.

## 3. Write findings JSON

Write to the scratchpad directory (`findings.json`):

```json
[
  {
    "path": "resources/js/composables/useAssignmentRequests.ts",
    "start_line": 33,
    "end_line": 39,
    "title": "Requests never reach validators",
    "body": "When a coach submits a request, this code stores it only in that coach's browser ..."
  }
]
```

Rules for each finding:
- `path` repo-relative; `start_line`/`end_line` are line numbers in the PR's head version and must fall inside the diff.
- `title`: 3–6 words, states the consequence, no trailing period.
- `body`: plain prose, 2–4 sentences: the concrete scenario → what goes wrong for the user/system. No code fences, no fix instructions, no hedging.

## 4. Render and post

```bash
python3 ~/.claude/skills/pr-review/scripts/render_comments.py <scratchpad>/findings.json \
  --repo <owner/name> --pr <number> --branch <headRefName> --commit <headRefOid> \
  --diff <scratchpad>/pr.diff --review-json <scratchpad>/review.json --post
```

- The script writes the review payload and sends it with `gh api --method POST repos/<owner/name>/pulls/<number>/reviews`, so the review and its inline comments are authored by the `gh` user.
- `commit_id` pins comments to the reviewed head SHA. Findings whose lines are not in the diff are moved into the review body instead of being dropped (GitHub would otherwise reject the whole review with 422).
- The event is always `COMMENT` (GitHub forbids `APPROVE`/`REQUEST_CHANGES` on your own PR).
- On success the script prints `posted: <review url>` to stderr.

Report:
- Posted → `[PR #<n>][Posted][<inline count> inline comments, <body count> in review body — <review url>]`
- Zero findings → do not post; `[PR #<n>][Reviewed][No issues found]`
- `gh api` error → `[PR #<n>][Blocked][<GitHub error message>]`; `review.json` stays in the scratchpad for a retry.

## 5. Dry run (only on request)

If the user asks to preview, not post, or for "paste-ready" output: drop `--post` and output the script's stdout verbatim (one block per finding, separated by `---`).
