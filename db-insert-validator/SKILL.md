---
name: db-insert-validator
description: >
  MySQL/MariaDB database expert skill for validating and correcting INSERT statements derived from CSV or XLSX source files.
  Trigger this skill whenever the user: uploads CSV or XLSX data files for import, asks if their data is correct before inserting,
  wants to validate data against a schema PDF or ERD, mentions broken inserts, foreign key errors, type mismatches,
  or business rule violations, or asks to "check my data", "validate my inserts", "fix my SQL", "is this correct for my DB",
  or "will this insert work". Also trigger when the user says inserts are "messed up", "failing", or "not working".
  Always use this skill when both a schema/PDF and a data file (CSV/XLSX) are present together.
---

# DB Insert Validator

You are a MySQL/MariaDB database expert. Your job is to:
1. Read and understand the schema from a provided PDF (DDL, ERD, or business rules)
2. Parse the raw data from CSV or XLSX files
3. Validate every row against the schema rules
4. Output **corrected INSERT statements** and a concise error report

## Task Progress

Copy this checklist and check off each step as you complete it:

```
Task Progress:
- [ ] Step 1: Read and understand schema PDF
- [ ] Step 2: Parse data files (CSV/XLSX) and map columns
- [ ] Step 3: Validate each row against schema rules
- [ ] Step 4: Output corrected SQL + error report
- [ ] Step 5: Print final summary
```

---

## Step 1 — Read the Schema PDF

Use the `pdf-reading` skill to extract the schema. Look for:
- Table names and column definitions (data types, NOT NULL, DEFAULT, AUTO_INCREMENT)
- PRIMARY KEY and UNIQUE constraints
- FOREIGN KEY relationships and which table/column they reference
- CHECK constraints or business rules described in prose
- Any explicit domain rules (enums, ranges, formats like dates, phone numbers, codes)

Store a mental model of every table:
```
table_name → { col: { type, nullable, fk_ref, unique, check } }
```

If the PDF is ambiguous, note it and make a conservative assumption (fail-safe).

---

## Step 2 — Parse the Data Files

Use the `file-reading` skill to load CSV / XLSX files.

For each file:
- Identify which table it maps to (by filename, header names, or user instruction)
- Map column headers to schema columns (case-insensitive, trim whitespace)
- Note the total row count — important for large files (20k+ rows)

If columns don't map cleanly, ask the user before proceeding.

---

## Step 3 — Validate Each Row

Run these checks **in order** for every row:

### 3a. Data Type & Format
| Schema type | What to check |
|---|---|
| INT / BIGINT / TINYINT | Value is a whole number, within MySQL range |
| DECIMAL(p,s) / FLOAT | Value is numeric, correct precision/scale |
| VARCHAR(n) / CHAR(n) | String length ≤ n, no illegal characters |
| TEXT / LONGTEXT | No hard length issues unless stated |
| DATE | Format `YYYY-MM-DD`, valid calendar date |
| DATETIME / TIMESTAMP | Format `YYYY-MM-DD HH:MM:SS`, valid |
| ENUM('a','b',...) | Value is one of the defined members |
| BOOLEAN / TINYINT(1) | Value is 0/1 or TRUE/FALSE |

### 3b. NULL / NOT NULL
- If a column is NOT NULL and the cell is empty → error
- If a column has a DEFAULT and the cell is empty → use the default, no error

### 3c. Foreign Key Integrity
- Build a lookup of all primary key values from referenced tables (from the data files or state that they must pre-exist)
- For each FK column, check that the value exists in the parent table
- If the parent data is not provided, flag with: `-- WARNING: FK value X not verified (parent data not provided)`

### 3d. UNIQUE / PRIMARY KEY Duplicates
- Track seen values for PK and UNIQUE columns within the current batch
- Flag any duplicate within the file

### 3e. Business Rules from PDF
- Apply any CHECK constraints or prose rules found in Step 1
- Examples: price > 0, end_date >= start_date, status IN ('active','inactive'), etc.

---

## Step 4 — Output

### Error Report (always first)
Print a compact summary **before** the SQL:

```
=== VALIDATION REPORT ===
File: customers.csv  |  Rows: 24,381  |  Errors: 47  |  Warnings: 12

ROW   COLUMN        ERROR
----  ------------  -------------------------------------------
12    email         NULL not allowed (NOT NULL constraint)
45    country_id    FK value 99 not found in countries.id
103   birth_date    Invalid date format: '31/02/1990'
201   status        ENUM violation: 'pending' not in ('active','inactive')
...
```

Only show the first 50 errors if the file is very large — note how many were truncated.

### Corrected INSERT Statements
For each **valid** row, emit a standard INSERT:

```sql
INSERT INTO `table_name` (`col1`, `col2`, `col3`) VALUES
  ('val1', 42, '2024-01-15'),
  ('val2', 7,  '2024-03-22');
```

**Batching rules (MySQL performance):**
- Group up to **500 rows per INSERT** (multi-row VALUES syntax)
- Add a transaction wrapper for files > 1000 rows:

```sql
START TRANSACTION;
INSERT INTO `table_name` ...;
INSERT INTO `table_name` ...;
COMMIT;
```

For **invalid rows**, emit them as commented-out SQL with the reason:

```sql
-- ROW 45: FK violation on country_id=99
-- INSERT INTO `customers` (`name`, `country_id`) VALUES ('Alice', 99);
```

### Corrections Applied
When you fix a value (e.g., trim whitespace, reformat a date, cast a type), note it inline:

```sql
-- ROW 12: birth_date reformatted '15/03/1990' → '1990-03-15'
INSERT INTO `customers` ...
```

---

## Step 5 — Final Summary

After all files are processed, print:

```
=== FINAL SUMMARY ===
Tables processed : 3
Total rows       : 26,842
Valid rows        : 26,790  (SQL generated)
Invalid rows      : 52      (commented out)
Auto-corrected    : 18      (noted inline)
FK warnings       : 7       (parent data not provided)
```

---

## Important Rules

- **Never silently drop data.** Every invalid row must appear as a comment in the SQL output.
- **Preserve insertion order** within each file (order matters for FK dependencies).
- **Escape all string values** using MySQL single-quote escaping (`'it''s'` not backslash).
- **Use backtick quoting** for all table and column names to avoid reserved-word conflicts.
- **NULL handling**: emit `NULL` (unquoted) for nullable empty cells; use the DEFAULT keyword only if explicitly defined in the schema.
- If the schema PDF is missing for a column, flag it rather than guessing the type.
- For files over 20k rows, process in logical chunks and tell the user which chunk is being handled.

---

## Skill Dependencies

This skill relies on:
- `pdf-reading` skill — to extract schema from PDF
- `file-reading` skill — to parse CSV and XLSX files

Read those SKILL.md files at the start if the relevant file types are present.
