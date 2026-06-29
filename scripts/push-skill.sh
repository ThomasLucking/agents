#!/usr/bin/env bash
# push-skill.sh — sync changes from ~/.claude/skills back into this repo and
# push to GitHub. Triggered automatically by the launchd watcher, or run
# manually. External skills listed in .skillsignore are excluded.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_SRC="$HOME/.claude/skills"
IGNORE_FILE="$REPO_DIR/.skillsignore"

RSYNC_ARGS=(
  -av
  --exclude='.git/'
  --exclude='.claude/'
  --exclude='*.tmp'
  --exclude='.DS_Store'
)

if [ -f "$IGNORE_FILE" ]; then
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ "$line" =~ ^#|^[[:space:]]*$ ]] && continue
    line="${line%/}"
    RSYNC_ARGS+=(--exclude="${line}/")
  done < "$IGNORE_FILE"
fi

rsync "${RSYNC_ARGS[@]}" "$SKILLS_SRC/" "$REPO_DIR/"

git -C "$REPO_DIR" add -A

if git -C "$REPO_DIR" diff --cached --quiet; then
  echo "No changes to push."
  exit 0
fi

git -C "$REPO_DIR" commit -m "chore(skills): sync from ~/.claude/skills"
git -C "$REPO_DIR" push
echo "Pushed to GitHub."
