# Priority Jobs Snapshot Pipeline

A mini ETL pipeline that tracks job postings by role priority. It started as me messing around with DDL/DML commands and type casting, and turned into a proper pipeline with staging, initial loads, and incremental refreshes.

The core idea: given a list of roles I care about (Data Engineer = priority 1, Software Engineer = priority 3), pull every matching job posting from the data warehouse, snapshot it, and keep it updated with an upsert pattern.

## What This Project Covers

This isn't a massive data platform. It's a focused exercise in the fundamentals that every ETL pipeline is built on:

- **DDL** — CREATE DATABASE, CREATE SCHEMA, CREATE TABLE, ALTER TABLE
- **DML** — INSERT INTO, UPDATE, DELETE patterns
- **Data types** — CAST, type mismatches, DOUBLE vs DECIMAL, TIMESTAMP vs DATE
- **Schema evolution** — renaming tables/columns, changing types (boolean → integer)
- **Staging pattern** — temp tables as scratch pads before writing to production
- **Upsert pattern** — UPDATE existing rows + INSERT new ones (incremental ETL)
- **Idempotency** — CREATE OR REPLACE, IF EXISTS, scripts that run cleanly every time

## Pipeline Architecture

```
MotherDuck (read-only)                    jobs_mart (local, writable)
┌─────────────────────┐                  ┌──────────────────────────┐
│ job_postings_fact   │──┐               │ staging.                 │
│ company_dim         │  │   JOIN +      │   priority_roles          │
│ skills_dim          │  ├──────────────►│     (config table)       │
│ skills_job_dim      │  │   INSERT      │                          │
└─────────────────────┘  │               │ main.                    │
                         └──────────────►│   priority_jobs_snapshot  │
                                         │     (production table)    │
                                         └──────────────────────────┘
```

## File Structure

```
4_Priority_Jobs_Pipeline/
├── 01_setup_database.sql            # Create database & schemas
├── 02_create_priority_roles.sql     # Build the priority config table
├── 02b_schema_evolution.sql         # (Optional) ALTER TABLE journey
├── 03_data_type_exploration.sql     # Understand source data types
├── 04_initial_load.sql              # Full load — create & populate snapshot
├── 05_incremental_refresh.sql       # Upsert — update changed, insert new
├── 06_merge_refresh.sql             # MERGE INTO — single-statement upsert + deletes
├── run_pipeline.sh                  # Run everything in one command
└── README.md                        # You're reading it
```

Run order: `01` → `02` → `04` (initial), then `05` or `06` for refreshes. Script `06` is the better approach — it uses MERGE INTO to handle updates, inserts, AND deletes in one atomic statement. Script `05` shows the manual UPDATE+INSERT pattern for comparison. Scripts `02b` and `03` are learning references — you don't need them for the pipeline to work.

## How to Run

### Option A: One script at a time (recommended for learning)

```bash
# Connect to DuckDB with MotherDuck
duckdb md:data_jobs

# Then inside DuckDB, run each file:
.read Data-types/4_Priority_Jobs_Pipeline/01_setup_database.sql
.read Data-types/4_Priority_Jobs_Pipeline/02_create_priority_roles.sql
.read Data-types/4_Priority_Jobs_Pipeline/04_initial_load.sql

# Later, to refresh (pick one):
.read Data-types/4_Priority_Jobs_Pipeline/05_incremental_refresh.sql   # UPDATE+INSERT approach
.read Data-types/4_Priority_Jobs_Pipeline/06_merge_refresh.sql         # MERGE INTO (recommended)
```

### Option B: Run the whole pipeline

```bash
bash Data-types/4_Priority_Jobs_Pipeline/run_pipeline.sh
```

## Key Concepts I Learned

### The INSERT INTO Mistake

My first version had a bare `SELECT` after `CREATE TABLE` and wondered why the table was empty:

```sql
-- WRONG — this just prints to screen
CREATE TABLE my_table (...);
SELECT ... FROM source_data;

-- RIGHT — this actually loads data
CREATE TABLE my_table (...);
INSERT INTO my_table
SELECT ... FROM source_data;

-- ALSO RIGHT — CTAS does both in one step
CREATE TABLE my_table AS
SELECT ... FROM source_data;
```

Sounds obvious in hindsight. Took me an embarrassingly long time to spot it.

### The Upsert Pattern (Two Approaches)

Production ETL doesn't rebuild tables from scratch every run. It uses upsert. I built two versions to understand the progression:

**Script 05 — UPDATE + INSERT (the manual way):**

```sql
-- 1. Stage fresh data in a temp table
CREATE TEMP TABLE src AS SELECT ... FROM source;

-- 2. UPDATE rows that changed
UPDATE target SET col = src.col
FROM src
WHERE target.id = src.id
    AND target.col IS DISTINCT FROM src.col;

-- 3. INSERT rows that are new
INSERT INTO target
SELECT src.*
FROM src LEFT JOIN target ON src.id = target.id
WHERE target.id IS NULL;
```

**Script 06 — MERGE INTO (the production way):**

```sql
MERGE INTO target AS tgt
USING source AS src
ON tgt.id = src.id

WHEN MATCHED AND tgt.col IS DISTINCT FROM src.col
    THEN UPDATE SET col = src.col

WHEN NOT MATCHED
    THEN INSERT VALUES (src.*)

WHEN NOT MATCHED BY SOURCE
    THEN DELETE;
```

MERGE is strictly better: one atomic statement, one pass through the data, and it handles deletes (stale rows from removed roles get cleaned up automatically). The `IS DISTINCT FROM` operator matters in both — regular `!=` doesn't handle NULLs correctly, which means changed rows get silently skipped.

### Schema Evolution

Tables change. That's reality. The priority_roles table went through three phases:

1. Started as `preferred_roles` with just `role_id` and `role_name`
2. Added a `preferred_role` BOOLEAN column
3. Renamed table → `priority_roles`, renamed column → `priority_lvl`, changed type → INTEGER

All done with ALTER TABLE, no data loss. See `02b_schema_evolution.sql` for the full journey.

### Read-Only Databases

When you connect with `duckdb md:data_jobs`, the MotherDuck database is read-only. You can't CREATE tables on it. The workaround is to create a local database (`jobs_mart`) for your writable tables and reference MotherDuck tables with the `data_jobs.` prefix in your queries.

## The Data

Source tables (from MotherDuck, read-only):
- `data_jobs.job_postings_fact` — 787K+ job postings with salaries, locations, dates
- `data_jobs.company_dim` — company names and links

Config table (local, writable):
- `staging.priority_roles` — 3 roles with priority levels

Output table (local, writable):
- `main.priority_jobs_snapshot` — filtered job postings for tracked roles, with priority levels and refresh timestamps

## What I'd Do Next

If I were extending this into a real pipeline:

- **Add more roles** — the priority_roles table is just 3 rows. Easy to expand.
- **Schedule it** — wrap the MERGE refresh script in a cron job or Airflow DAG.
- **Add data quality checks** — row count assertions, null checks, duplicate detection.
- **Track history** — add a `snapshot_date` column to keep historical snapshots instead of overwriting.
- **Alerting** — notify when high-priority roles spike in postings (market signal).
