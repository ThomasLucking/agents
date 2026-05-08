#!/usr/bin/env bash
set -euo pipefail

ERRORS=0
CHECKED=0

# Check every .md file that contains skill frontmatter (has a 'name:' field inside ---)
while IFS= read -r file; do
  # Determine if this file has frontmatter with a name field
  if awk '/^---/{f=!f; next} f && /^name:/{found=1; exit} END{exit !found}' "$file" 2>/dev/null; then
    CHECKED=$((CHECKED + 1))
    filename=$(basename "$file")

    # Must be named SKILL.md
    if [ "$filename" != "SKILL.md" ]; then
      echo "ERROR: skill file must be named SKILL.md — found: $file"
      ERRORS=$((ERRORS + 1))
    fi

    # Must have a non-empty name field
    name=$(awk '/^---/{f=!f; next} f && /^name:/{sub(/^name:[[:space:]]*/, ""); print; exit}' "$file")
    if [ -z "$name" ]; then
      echo "ERROR: missing or empty 'name' field in $file"
      ERRORS=$((ERRORS + 1))
    fi

    # Must have a description field
    if ! awk '/^---/{f=!f; next} f && /^description:/{found=1; exit} END{exit !found}' "$file"; then
      echo "ERROR: missing 'description' field in $file"
      ERRORS=$((ERRORS + 1))
    fi
  fi
done < <(find . -name "*.md" -not -path "./.git/*" | sort)

echo ""
if [ $ERRORS -gt 0 ]; then
  echo "validate-skills: $ERRORS error(s) across $CHECKED skill file(s). Fix before committing."
  exit 1
else
  echo "validate-skills: $CHECKED skill file(s) OK."
fi
