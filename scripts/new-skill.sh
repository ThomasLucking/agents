#!/usr/bin/env bash
# Scaffold a new skill directory with a compliant SKILL.md.
# Usage (non-interactive): ./scripts/new-skill.sh <domain> <folder> <name> <description>
# Usage (interactive):      ./scripts/new-skill.sh
#
# After running, open the generated SKILL.md and fill in the skill body.
# Run ./scripts/test-skill.sh <path> when done to check quality.
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
  read -rp "Trigger description (1–3 sentences):        " DESCRIPTION
fi

# ── Validate inputs ───────────────────────────────────────────────────────────

if [ -z "$DOMAIN" ] || [ -z "$FOLDER" ] || [ -z "$SKILL_NAME" ] || [ -z "$DESCRIPTION" ]; then
  echo "ERROR: all fields are required."
  exit 1
fi

# Name must be lowercase alphanumeric + hyphens, no leading/trailing/consecutive hyphens, max 64 chars
if ! echo "$SKILL_NAME" | grep -qE '^[a-z0-9]([a-z0-9-]*[a-z0-9])?$'; then
  echo "ERROR: name '$SKILL_NAME' is invalid."
  echo "       Use lowercase letters, numbers, and hyphens only."
  echo "       No uppercase, spaces, leading/trailing hyphens."
  exit 1
fi
if echo "$SKILL_NAME" | grep -qE '--'; then
  echo "ERROR: name '$SKILL_NAME' contains consecutive hyphens."
  exit 1
fi
if [ ${#SKILL_NAME} -gt 64 ]; then
  echo "ERROR: name '$SKILL_NAME' exceeds 64 characters."
  exit 1
fi
if [ ${#DESCRIPTION} -gt 1024 ]; then
  echo "ERROR: description exceeds 1024 characters (${#DESCRIPTION})."
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

# Title-case the skill name for the heading
TITLE=$(echo "$SKILL_NAME" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2); print}')

cat > "$SKILL_FILE" <<SKILLEOF
---
name: $SKILL_NAME
description: >
  $DESCRIPTION
---

# $TITLE

## Workflow

<!-- Step-by-step instructions for the agent -->

## Gotchas

<!-- Non-obvious facts, edge cases, or corrections to mistakes agents commonly make -->
SKILLEOF

# ── References scaffold (optional) ───────────────────────────────────────────

if [ $# -lt 4 ]; then
  echo ""
  read -rp "Create references/ scaffold for extended detail? [y/N]: " CREATE_REFS
else
  CREATE_REFS="n"
fi

if [[ "${CREATE_REFS:-n}" =~ ^[Yy]$ ]]; then
  mkdir -p "$SKILL_DIR/references"
  cat >> "$SKILL_FILE" <<REFSEOF

## References

<!-- Tell the agent when to load each file, e.g.: -->
<!-- Load \`references/guide.md\` for detailed reference material -->
REFSEOF

  cat > "$SKILL_DIR/references/guide.md" <<GUIDEEOF
# $TITLE — Reference Guide

<!-- Move detailed reference material here to keep SKILL.md concise.
     The agent loads this file on demand based on the instruction in SKILL.md. -->
GUIDEEOF

  echo "Created: $SKILL_DIR/references/guide.md"
fi

echo ""
echo "Created: $SKILL_FILE"

# ── Validate & list ───────────────────────────────────────────────────────────

echo ""
"$ROOT/scripts/validate-skills.sh"

echo ""
echo "Next: fill in $SKILL_FILE, then run:"
echo "  ./scripts/test-skill.sh $DOMAIN/$FOLDER"
