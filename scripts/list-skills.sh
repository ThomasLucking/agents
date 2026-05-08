#!/usr/bin/env bash
set -euo pipefail

skills=$(find . -name "SKILL.md" -not -path "./.git/*" | sort)
count=$(echo "$skills" | grep -c . || true)

echo "=== Skills ($count registered) ==="
echo ""

while IFS= read -r file; do
  name=$(awk '/^---/{f=!f; next} f && /^name:/{sub(/^name:[[:space:]]*/, ""); print; exit}' "$file")
  # Collapse the YAML block scalar into one line for display
  description=$(awk '
    /^---/{block++; next}
    block==1 && /^description:/{
      sub(/^description:[[:space:]]*(>)?[[:space:]]*/, "")
      if (length($0)) { desc=$0 }
      in_desc=1; next
    }
    in_desc && /^[[:space:]]/{
      line=$0; gsub(/^[[:space:]]+/, "", line)
      if (desc) desc=desc " " line; else desc=line
      next
    }
    in_desc { exit }
    END { print desc }
  ' "$file" | tr -s ' ' | cut -c1-100)

  echo "  name:  $name"
  echo "  file:  $file"
  echo "  desc:  $description"
  echo ""
done <<< "$skills"
