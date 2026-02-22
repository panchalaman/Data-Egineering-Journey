-- ============================================================
-- 06_merge_refresh.sql
-- ============================================================
-- Author: Aman Panchal
--
-- This is the BETTER version of 05_incremental_refresh.sql.
--
-- The upsert pattern in script 05 works, but it's two separate
-- operations — an UPDATE and then an INSERT. That means two
-- passes through the data, two chances for something to go
-- wrong between statements, and no way to handle deletes.
--
-- MERGE INTO does everything in ONE atomic statement:
--   - UPDATE rows where priority changed
--   - INSERT rows that are new
--   - DELETE rows that no longer match any tracked role
--
-- In production, MERGE is what you'd actually use. I built
-- script 05 first because understanding UPDATE + INSERT
-- separately made MERGE click when I got here. You need to
-- see the problem before the solution makes sense.
--
-- Prerequisites:
--   - 04_initial_load.sql has been run at least once
--   - data_jobs database attached (MotherDuck)
--
-- Run: .read Data-types/4_Priority_Jobs_Pipeline/06_merge_refresh.sql
-- ============================================================

USE jobs_mart;

-- ============================================================
-- STEP 1: Stage the fresh data (same as script 05)
-- ============================================================
-- Nothing changes here — the staging pattern is the same
-- regardless of whether you're doing UPDATE+INSERT or MERGE.
-- You always want a clean snapshot of "what the source looks
-- like right now" before comparing it to the target.

CREATE OR REPLACE TEMP TABLE src_priority_jobs AS
SELECT
    jpf.job_id,
    jpf.job_title_short,
    cd.name AS company_name,
    jpf.job_posted_date,
    jpf.salary_year_avg,
    r.priority_lvl,
    CURRENT_TIMESTAMP AS updated_at
FROM
    data_jobs.job_postings_fact AS jpf
    LEFT JOIN data_jobs.company_dim AS cd
        ON jpf.company_id = cd.company_id
    INNER JOIN staging.priority_roles AS r
        ON jpf.job_title_short = r.role_name;

-- Sanity check
SELECT COUNT(*) AS staged_rows FROM src_priority_jobs;

-- ============================================================
-- STEP 2: MERGE — do everything in one statement
-- ============================================================
-- This is the part that replaces both the UPDATE and INSERT
-- from script 05. One statement, three behaviors:
--
-- WHEN MATCHED: The job_id already exists in our snapshot.
--   → Only update if priority_lvl actually changed.
--   → IS DISTINCT FROM handles NULLs correctly (same reason
--     as script 05 — regular != silently skips NULL changes).
--
-- WHEN NOT MATCHED: The job_id exists in source but not target.
--   → New job posting appeared that matches a tracked role.
--   → Insert it.
--
-- WHEN NOT MATCHED BY SOURCE: The job_id exists in target but
--   not in source anymore.
--   → This happens when you REMOVE a role from priority_roles.
--     For example, if you delete "Software Engineer" from the
--     config table, all those postings should be cleaned out
--     of the snapshot. Script 05 can't do this — it only
--     updates and inserts. Stale rows just sit there forever.
--   → Delete it.
--
-- That third clause is why MERGE is strictly better than the
-- UPDATE+INSERT pattern. Without it, your snapshot accumulates
-- orphaned data from roles you no longer track.

MERGE INTO main.priority_jobs_snapshot AS tgt
USING src_priority_jobs AS src
ON tgt.job_id = src.job_id

-- Case 1: Job already exists, but priority changed
WHEN MATCHED
    AND tgt.priority_lvl IS DISTINCT FROM src.priority_lvl
THEN UPDATE SET
    priority_lvl = src.priority_lvl,
    updated_at   = src.updated_at

-- Case 2: New job posting we haven't seen before
WHEN NOT MATCHED THEN INSERT (
    job_id,
    job_title_short,
    company_name,
    job_posted_date,
    salary_year_avg,
    priority_lvl,
    updated_at
) VALUES (
    src.job_id,
    src.job_title_short,
    src.company_name,
    src.job_posted_date,
    src.salary_year_avg,
    src.priority_lvl,
    src.updated_at
)

-- Case 3: Job exists in snapshot but no longer in source
-- (role was removed from priority_roles, or job no longer
-- matches after a config change)
WHEN NOT MATCHED BY SOURCE THEN DELETE;

-- ============================================================
-- STEP 3: Verify the refresh
-- ============================================================

SELECT
    job_title_short,
    COUNT(*) AS job_count,
    MIN(priority_lvl) AS priority_lvl,
    MAX(updated_at) AS last_refreshed
FROM main.priority_jobs_snapshot
GROUP BY job_title_short
ORDER BY job_count DESC;

SELECT COUNT(*) AS total_rows FROM main.priority_jobs_snapshot;

-- ============================================================
-- Cleanup
-- ============================================================
DROP TABLE IF EXISTS src_priority_jobs;

-- ============================================================
-- Why MERGE over UPDATE + INSERT?
-- ============================================================
-- 
-- Script 05 (UPDATE + INSERT):
--   + Easier to read if you're new to SQL
--   + Each step is independently debuggable
--   - Two passes through the data
--   - No way to handle deletes (stale rows accumulate)
--   - Not atomic — if INSERT fails after UPDATE, you're in
--     an inconsistent state
--
-- Script 06 (MERGE):
--   + One atomic statement — all or nothing
--   + Handles INSERT, UPDATE, and DELETE in one pass
--   + No orphaned data from removed roles
--   - Syntax is more complex on first read
--   - Not all databases support all three MERGE clauses
--     (DuckDB does, which is why I used it here)
--
-- In a job interview, if someone asks "how would you implement
-- an incremental load?" — start with the UPDATE+INSERT to show
-- you understand the logic, then mention MERGE as the
-- production approach. Shows depth.
-- ============================================================
