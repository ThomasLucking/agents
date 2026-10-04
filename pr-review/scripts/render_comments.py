#!/usr/bin/env python3
"""Render code-review findings as Greptile-style PR comments.

Usage:
    render_comments.py findings.json [--repo owner/name] [--pr 12] [--branch feat/x]
                       [--commit SHA] [--diff pr.diff] [--review-json review.json] [--post]

findings.json:
    [{"path": "app/Foo.php", "start_line": 33, "end_line": 39,
      "title": "Short bold title", "body": "What breaks, when, and why."}]

Prints the markdown for every finding to stdout, separated by `---`.
With --review-json, also writes a GitHub "create review" payload
(inline comments). With --diff, findings whose lines are not commentable in
the PR diff are moved into the review body instead of being inline comments
(GitHub rejects the whole review with 422 otherwise).
With --post, sends the payload through the GitHub REST API via
`gh api repos/OWNER/REPO/pulls/PR/reviews`, authenticated as the gh user,
and prints the created review URL to stderr.
"""

import argparse
import json
import re
import subprocess
import sys
from urllib.parse import quote

CLAUDE_BASE = "https://app.greptile.com/ide/claude-code"
CODEX_BASE = "https://app.greptile.com/api/ide/codex"
BADGES = "https://greptile-static-assets.s3.amazonaws.com/badges"
FOOTER = "For each issue above, determine whether it is valid and should be fixed. If so, fix it directly."


def line_label(finding: dict) -> str:
    start = finding["start_line"]
    end = finding.get("end_line") or start
    return str(start) if start == end else f"{start}-{end}"


def fix_prompt(finding: dict) -> str:
    return (
        "This is a comment left during a code review.\n"
        f"Path: {finding['path']}\n"
        f"Line: {line_label(finding)}\n\n"
        "Comment:\n"
        f"**{finding['title']}** {finding['body']}\n\n"
        "---\n\n"
        f"{FOOTER}"
    )


def badge(name: str, href: str, alt: str) -> str:
    return (
        f'<a href="{href}"><picture>'
        f'<source media="(prefers-color-scheme: dark)" srcset="{BADGES}/{name}Dark.svg?v=7">'
        f'<source media="(prefers-color-scheme: light)" srcset="{BADGES}/{name}.svg?v=7">'
        f'<img alt="{alt}" src="{BADGES}/{name}.svg?v=7"></picture></a>'
    )


def render(finding: dict, repo: str, pr: str, branch: str) -> str:
    prompt = fix_prompt(finding)
    codex_prompt = (
        f'IMPORTANT: Work in the repository "{repo}" on the existing branch "{branch}". '
        "Checkout that branch — do NOT create a new branch or open a new PR. "
        f'Push your changes to "{branch}".\n\n{prompt}'
    )
    tail = f"&repo={quote(repo, safe='')}&pr={pr}&platform=github"
    claude_href = f"{CLAUDE_BASE}?prompt={quote(prompt, safe='')}{tail}"
    codex_href = f"{CODEX_BASE}?prompt={quote(codex_prompt, safe='')}{tail}"

    return (
        f"**{finding['title']}** {finding['body']}\n\n"
        "<details><summary>Prompt To Fix With AI</summary>\n\n"
        "`````markdown\n"
        f"{prompt}\n"
        "`````\n"
        "</details>\n\n"
        f"{badge('FixInClaude', claude_href, 'Fix in Claude Code')} "
        f"{badge('FixInCodex', codex_href, 'Fix in Codex')}"
    )


def commentable_lines(diff_text: str) -> dict:
    """Map each file path to the set of head-side line numbers present in the diff."""
    lines_by_path: dict = {}
    path = None
    new_line = 0
    for raw in diff_text.splitlines():
        if raw.startswith("+++ "):
            target = raw[4:].strip()
            path = None if target == "/dev/null" else re.sub(r"^b/", "", target)
            if path is not None:
                lines_by_path.setdefault(path, set())
            continue
        if raw.startswith("@@"):
            match = re.search(r"\+(\d+)(?:,(\d+))?", raw)
            new_line = int(match.group(1)) if match else 0
            continue
        if path is None or raw.startswith(("--- ", "diff --git", "index ", "\\")):
            continue
        if raw.startswith("+") or raw.startswith(" "):
            lines_by_path[path].add(new_line)
            new_line += 1
    return lines_by_path


def is_commentable(finding: dict, lines_by_path: dict) -> bool:
    valid = lines_by_path.get(finding["path"], set())
    start = finding["start_line"]
    end = finding.get("end_line") or start
    return start in valid and end in valid


def post_review(repo: str, pr: str, payload_path: str) -> int:
    result = subprocess.run(
        ["gh", "api", "--method", "POST", f"repos/{repo}/pulls/{pr}/reviews", "--input", payload_path],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        sys.stderr.write(result.stderr or result.stdout)
        return result.returncode
    review = json.loads(result.stdout)
    sys.stderr.write(f"posted: {review.get('html_url', '')}\n")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("findings")
    parser.add_argument("--repo", default="")
    parser.add_argument("--pr", default="")
    parser.add_argument("--branch", default="")
    parser.add_argument("--commit", default="")
    parser.add_argument("--diff")
    parser.add_argument("--review-json")
    parser.add_argument("--post", action="store_true")
    args = parser.parse_args()

    if args.post and not (args.review_json and args.repo and args.pr):
        parser.error("--post requires --review-json, --repo and --pr")

    with open(args.findings) as handle:
        findings = json.load(handle)

    bodies = [render(f, args.repo, args.pr, args.branch) for f in findings]
    print("\n\n---\n\n".join(bodies))

    if args.review_json:
        lines_by_path = None
        if args.diff:
            with open(args.diff) as handle:
                lines_by_path = commentable_lines(handle.read())

        comments = []
        outside_diff = []
        for finding, body in zip(findings, bodies):
            if lines_by_path is not None and not is_commentable(finding, lines_by_path):
                outside_diff.append(f"#### `{finding['path']}` line {line_label(finding)}\n\n{body}")
                continue
            comment = {"path": finding["path"], "line": finding.get("end_line") or finding["start_line"], "side": "RIGHT", "body": body}
            if finding.get("end_line") and finding["end_line"] != finding["start_line"]:
                comment["start_line"] = finding["start_line"]
                comment["start_side"] = "RIGHT"
            comments.append(comment)

        summary = f"Code review: {len(findings)} finding(s)."
        if outside_diff:
            summary += "\n\n---\n\n" + "\n\n---\n\n".join(outside_diff)
        payload = {"event": "COMMENT", "body": summary, "comments": comments}
        if args.commit:
            payload["commit_id"] = args.commit
        with open(args.review_json, "w") as handle:
            json.dump(payload, handle, indent=2)

        if args.post:
            return post_review(args.repo, args.pr, args.review_json)

    return 0


if __name__ == "__main__":
    sys.exit(main())
