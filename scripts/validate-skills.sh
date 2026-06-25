#!/usr/bin/env bash
# Spec compliance check for all SKILL.md files.
# Runs automatically as a pre-commit hook.
# Usage: ./scripts/validate-skills.sh
set -euo pipefail

ERRORS=0
WARNINGS=0
CHECKED=0

while IFS= read -r file; do
  # Only process files that have skill frontmatter (name: field inside ---)
  if ! awk '/^---/{f=!f; next} f && /^name:/{found=1; exit} END{exit !found}' "$file" 2>/dev/null; then
    continue
  fi

  CHECKED=$((CHECKED + 1))
  filename=$(basename "$file")

  # Must be named SKILL.md
  if [ "$filename" != "SKILL.md" ]; then
    echo "  ERROR: skill file must be named SKILL.md — found: $file"
    ERRORS=$((ERRORS + 1))
    continue
  fi

  # ── name field ────────────────────────────────────────────────────────────
  name=$(awk '/^---/{f=!f; next} f && /^name:/{sub(/^name:[[:space:]]*/, ""); print; exit}' "$file")

  if [ -z "$name" ]; then
    echo "  ERROR: empty 'name' field — $file"
    ERRORS=$((ERRORS + 1))
  else
    # Lowercase alphanumeric + hyphens only, no leading/trailing/consecutive hyphens
    if ! echo "$name" | grep -qE '^[a-z0-9]([a-z0-9-]*[a-z0-9])?$'; then
      echo "  ERROR [$name]: name must be lowercase a-z/0-9 and hyphens — $file"
      ERRORS=$((ERRORS + 1))
    elif [[ "$name" == *"--"* ]]; then
      echo "  ERROR [$name]: name contains consecutive hyphens — $file"
      ERRORS=$((ERRORS + 1))
    fi

    if [ ${#name} -gt 64 ]; then
      echo "  ERROR [$name]: name exceeds 64 characters (${#name}) — $file"
      ERRORS=$((ERRORS + 1))
    fi
  fi

  # ── description field ─────────────────────────────────────────────────────
  if ! awk '/^---/{f=!f; next} f && /^description:/{found=1; exit} END{exit !found}' "$file"; then
    echo "  ERROR: missing 'description' field — $file"
    ERRORS=$((ERRORS + 1))
  else
    # Extract full description value (handles YAML block scalars > and |)
    desc=$(awk '
      /^---/{ fm++; next }
      fm != 1 { next }
      /^description:/{ sub(/^description:[[:space:]]*(>|\|)?[[:space:]]*/, ""); buf=$0; in_d=1; next }
      in_d && /^[[:space:]]/{ line=$0; gsub(/^[[:space:]]+/,"",line); buf=buf" "line; next }
      in_d{ exit }
      END{ print buf }
    ' "$file" | tr -s ' ')
    if [ ${#desc} -gt 1024 ]; then
      echo "  ERROR: description exceeds 1024 chars (${#desc}) — $file"
      ERRORS=$((ERRORS + 1))
    fi
  fi

  # ── line count ────────────────────────────────────────────────────────────
  line_count=$(wc -l < "$file")
  if [ "$line_count" -gt 500 ]; then
    echo "  WARN:  $line_count lines (recommended max 500) — decompose into references/ — $file"
    WARNINGS=$((WARNINGS + 1))
  fi

  # ── placeholder body ──────────────────────────────────────────────────────
  if grep -q "Add skill content here" "$file" 2>/dev/null; then
    echo "  WARN:  placeholder body not filled in — $file"
    WARNINGS=$((WARNINGS + 1))
  fi

done < <(find . -name "*.md" -not -path "./.git/*" | sort)

echo ""
if [ "$ERRORS" -gt 0 ]; then
  echo "validate-skills: $ERRORS error(s), $WARNINGS warning(s) across $CHECKED skill(s). Fix errors before committing."
  exit 1
elif [ "$WARNINGS" -gt 0 ]; then
  echo "validate-skills: $CHECKED skill file(s) OK ($WARNINGS warning(s))."
else
  echo "validate-skills: $CHECKED skill file(s) OK."
fi
