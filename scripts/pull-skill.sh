#!/usr/bin/env bash
# pull-skill.sh — pull latest from GitHub, then mirror this repo's skill dirs
# into ~/.claude/skills. Run manually after pulling remote changes, or pass
# --auto to skip confirmation (used by the post-push hook).

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_DEST="$HOME/.claude/skills"
AUTO=false

for arg in "$@"; do
  [[ "$arg" == "--auto" ]] && AUTO=true
done

if [ ! -d "$REPO_DIR/.git" ]; then
  echo "Not a git repo: $REPO_DIR"
  exit 1
fi

if [ "$AUTO" = false ]; then
  echo "Pulling latest from remote..."
  git -C "$REPO_DIR" pull
fi

mkdir -p "$SKILLS_DEST"

RSYNC_ARGS=(
  -av
  --exclude='.git/'
  --exclude='.claude/'
  --exclude='scripts/'
  --exclude='CLAUDE.md'
  --exclude='README.md'
  --exclude='.gitignore'
  --exclude='*.tmp'
  --exclude='.DS_Store'
)

if [ "$AUTO" = false ]; then
  echo ""
  echo "--- Preview of changes (dry run) ---"
  rsync "${RSYNC_ARGS[@]}" -n "$REPO_DIR/" "$SKILLS_DEST/"
  echo "-------------------------------------"
  echo ""
  read -p "Apply these changes to ~/.claude/skills? [y/N] " confirm
  [[ "$confirm" =~ ^[Yy]$ ]] || { echo "Cancelled."; exit 0; }
fi

rsync "${RSYNC_ARGS[@]}" "$REPO_DIR/" "$SKILLS_DEST/"
echo "Synced: $REPO_DIR → $SKILLS_DEST"
