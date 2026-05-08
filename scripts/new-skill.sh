#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

# ── Collect inputs ────────────────────────────────────────────────────────────

if [ $# -ge 2 ]; then
  DOMAIN="$1"
  FOLDER="$2"
else
  echo "=== New Skill ==="
  echo ""
  read -rp "Domain (e.g. laravel, code-analysis): " DOMAIN
  read -rp "Skill folder name (e.g. inertia, custom):  " FOLDER
fi

if [ $# -ge 3 ]; then
  SKILL_NAME="$3"
else
  read -rp "Skill name (frontmatter 'name' field):      " SKILL_NAME
fi

if [ $# -ge 4 ]; then
  DESCRIPTION="$4"
else
  read -rp "One-line trigger description:               " DESCRIPTION
fi

# ── Validate inputs ───────────────────────────────────────────────────────────

if [ -z "$DOMAIN" ] || [ -z "$FOLDER" ] || [ -z "$SKILL_NAME" ] || [ -z "$DESCRIPTION" ]; then
  echo "ERROR: all fields are required."
  exit 1
fi

SKILL_DIR="$ROOT/$DOMAIN/$FOLDER"
SKILL_FILE="$SKILL_DIR/SKILL.md"

if [ -d "$SKILL_DIR" ]; then
  echo "ERROR: directory already exists: $SKILL_DIR"
  exit 1
fi

# ── Create skill ──────────────────────────────────────────────────────────────

mkdir -p "$SKILL_DIR"

cat > "$SKILL_FILE" <<SKILLEOF
---
name: $SKILL_NAME
description: >
  $DESCRIPTION
---

# $(echo "$SKILL_NAME" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2); print}')

<!-- Add skill content here -->
SKILLEOF

echo ""
echo "Created: $SKILL_FILE"

# ── Validate & list ───────────────────────────────────────────────────────────

echo ""
"$ROOT/scripts/validate-skills.sh"

echo ""
"$ROOT/scripts/list-skills.sh"
