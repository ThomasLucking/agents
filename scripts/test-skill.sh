#!/usr/bin/env bash
# Quality check for skill implementation.
# Usage:
#   ./scripts/test-skill.sh              — check all skills
#   ./scripts/test-skill.sh <skill-dir>  — check one skill (e.g. laravel/best-practices)
#
# Checks description quality, body content, referenced files, and progressive disclosure.
# Exit 1 if any failures found.
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

TOTAL_PASS=0
TOTAL_FAIL=0
TOTAL_WARN=0
SKILL_COUNT=0

pass() { echo "  [PASS] $*"; TOTAL_PASS=$((TOTAL_PASS + 1)); }
fail() { echo "  [FAIL] $*"; TOTAL_FAIL=$((TOTAL_FAIL + 1)); }
warn() { echo "  [WARN] $*"; TOTAL_WARN=$((TOTAL_WARN + 1)); }

# Extract a frontmatter field (handles inline values and YAML block scalars > and |)
extract_field() {
  local file="$1" field="$2"
  awk -v f="$field" '
    /^---/{ fm++; next }
    fm != 1 { next }
    $0 ~ "^" f ":" {
      sub("^" f ":[[:space:]]*(>|\\|)?[[:space:]]*", "")
      buf = $0; in_f = 1; next
    }
    in_f && /^[[:space:]]/{
      line = $0; gsub(/^[[:space:]]+/, "", line)
      buf = buf " " line; next
    }
    in_f { exit }
    END { gsub(/^[[:space:]]+|[[:space:]]+$/, "", buf); print buf }
  ' "$file" | tr -s ' '
}

check_skill() {
  local dir="$1"
  local file="$dir/SKILL.md"
  [ -f "$file" ] || return

  SKILL_COUNT=$((SKILL_COUNT + 1))
  local name
  name=$(extract_field "$file" "name")
  echo ""
  echo "── $dir [$name] ──"

  # 1. Description length
  local desc
  desc=$(extract_field "$file" "description")
  local desc_len=${#desc}

  if [ "$desc_len" -lt 50 ]; then
    fail "description: $desc_len chars — too short, needs more trigger context (aim for 80+)"
  else
    pass "description: $desc_len chars"
  fi

  # 2. Description has trigger keywords
  if echo "$desc" | grep -qiE '(trigger|use when|activate when|trigger on)'; then
    pass "description: has trigger keywords"
  else
    warn "description: no trigger keywords — add 'Trigger when...' or 'Use when...' so agents know when to activate"
  fi

  # 3. Body is non-empty and not placeholder
  if grep -q "Add skill content here" "$file" 2>/dev/null; then
    fail "body: placeholder text not replaced — fill in the skill instructions"
  fi

  local body_lines
  body_lines=$(awk '/^---/{f++; next} f==2{print}' "$file" | grep -cv '^[[:space:]]*$' || true)
  if [ "$body_lines" -lt 3 ]; then
    fail "body: only $body_lines non-blank lines — skill has no real instructions"
  else
    pass "body: $body_lines non-blank lines of content"
  fi

  # 4. Line count advisory
  local total_lines
  total_lines=$(wc -l < "$file")
  if [ "$total_lines" -gt 500 ]; then
    fail "size: $total_lines lines — exceeds 500 limit; move detail to references/"
  elif [ "$total_lines" -gt 200 ]; then
    warn "size: $total_lines lines — consider decomposing detail into references/"
  else
    pass "size: $total_lines lines"
  fi

  # 5. Referenced files exist
  local ref_ok=0 ref_bad=0
  while IFS= read -r ref; do
    [ -n "$ref" ] || continue
    local abs_path="$dir/$ref"
    if [ -f "$abs_path" ]; then
      ref_ok=$((ref_ok + 1))
    else
      fail "missing file: $ref (referenced in SKILL.md but not found)"
      ref_bad=$((ref_bad + 1))
    fi
  done < <(grep -oE '(references|scripts|assets)/[a-zA-Z0-9._/-]+' "$file" | sort -u || true)

  if [ "$ref_ok" -gt 0 ] && [ "$ref_bad" -eq 0 ]; then
    pass "file references: all $ref_ok referenced file(s) exist"
  fi

  # 6. Progressive disclosure: if references/ dir exists, SKILL.md should say when to load each file
  if [ -d "$dir/references" ]; then
    local ref_file_count load_directives
    ref_file_count=$(find "$dir/references" -name "*.md" | wc -l | tr -d ' ')
    load_directives=$(grep -icE '(load|read)[[:space:]]+.?references/' "$file" || true)

    if [ "$load_directives" -gt 0 ]; then
      pass "progressive disclosure: $load_directives load directive(s) covering references/ ($ref_file_count file(s))"
    else
      warn "progressive disclosure: references/ has $ref_file_count file(s) but SKILL.md doesn't say when to load them — add: Load \`references/foo.md\` when..."
    fi
  fi
}

# Targets: arg or all skills
if [ $# -ge 1 ]; then
  check_skill "$1"
else
  while IFS= read -r f; do
    check_skill "$(dirname "$f")"
  done < <(find . -name "SKILL.md" -not -path "./.git/*" | sort)
fi

echo ""
echo "══════════════════════════════════════════════"
printf " %d skill(s)  ·  %d passed  ·  %d warnings  ·  %d failed\n" \
  "$SKILL_COUNT" "$TOTAL_PASS" "$TOTAL_WARN" "$TOTAL_FAIL"
echo "══════════════════════════════════════════════"

if [ "$TOTAL_FAIL" -gt 0 ]; then
  echo " Fix failures above before considering the skill done."
  exit 1
elif [ "$TOTAL_WARN" -gt 0 ]; then
  echo " Warnings are non-blocking but worth addressing."
fi
