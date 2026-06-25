---
name: db-insert-validator
description: >
  MySQL/MariaDB expert skill for validating and correcting INSERT statements derived from CSV or XLSX source files. Trigger when the user uploads CSV/XLSX data for import, asks if their data is correct before inserting, wants to validate against a schema PDF or ERD, mentions broken inserts, FK errors, type mismatches, or says "check my data", "validate my inserts", "fix my SQL", "will this insert work". Always trigger when both a schema/PDF and a data file are present.
---

# DB Insert Validator

Read schema from PDF → parse CSV/XLSX → validate every row → output corrected INSERTs and an error report.

## Workflow

- [ ] Step 1: Read schema PDF — extract tables, columns, types, constraints, FK relationships, CHECK rules
- [ ] Step 2: Parse data files — map headers to schema columns (case-insensitive, trim whitespace)
- [ ] Step 3: Validate each row (in order: type/format → NULL → FK → UNIQUE/PK → business rules)
- [ ] Step 4: Output error report then corrected SQL
- [ ] Step 5: Print final summary

## Step 3 — Validation Checks

| Check | Rule |
|---|---|
| INT / BIGINT | Whole number, within MySQL range |
| DECIMAL(p,s) | Numeric, correct precision/scale |
| VARCHAR(n) | Length ≤ n |
| DATE | `YYYY-MM-DD`, valid calendar date |
| DATETIME | `YYYY-MM-DD HH:MM:SS`, valid |
| ENUM | Value is one of the defined members |
| NOT NULL | Empty cell on a NOT NULL column → error |
| DEFAULT | Empty cell with DEFAULT → use default, no error |
| FK | Value must exist in parent table; if parent data not provided → `-- WARNING: FK not verified` |
| UNIQUE / PK | Track seen values within the file — flag duplicates |

## Step 4 — Output Format

**Error report (print first):**
```
=== VALIDATION REPORT ===
File: customers.csv | Rows: 24,381 | Errors: 47 | Warnings: 12

ROW   COLUMN       ERROR
----  -----------  ------------------------------------
12    email        NULL not allowed
45    country_id   FK value 99 not found in countries.id
```
Show first 50 errors for large files — note how many were truncated.

**Corrected SQL (valid rows):**
```sql
INSERT INTO `table_name` (`col1`, `col2`) VALUES
  ('val1', 42),
  ('val2', 7);
```
Batch up to 500 rows per INSERT. Wrap files > 1000 rows in `START TRANSACTION; ... COMMIT;`.

**Invalid rows** — comment out with reason:
```sql
-- ROW 45: FK violation on country_id=99
-- INSERT INTO `customers` (`name`, `country_id`) VALUES ('Alice', 99);
```

**Auto-corrections** — note inline:
```sql
-- ROW 12: birth_date reformatted '15/03/1990' → '1990-03-15'
```

## Step 5 — Final Summary

```
=== FINAL SUMMARY ===
Tables processed : 3
Total rows       : 26,842
Valid rows        : 26,790
Invalid rows      : 52
Auto-corrected    : 18
FK warnings       : 7
```

## Rules

- Never silently drop data — every invalid row appears as a comment in the SQL
- Preserve insertion order (FK dependencies)
- Escape strings with MySQL single-quote escaping (`'it''s'` not backslash)
- Use backticks for all table and column names
- Emit `NULL` (unquoted) for nullable empty cells
- For files > 20k rows, process in chunks and tell the user which chunk is being handled
