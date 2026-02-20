-- ============================================================
-- LESSON 2.02: DML & ETL Patterns
-- ============================================================
-- DML = Data Manipulation Language. INSERT, UPDATE, DELETE.
-- These are the verbs of data engineering — this is how data
-- actually moves through your pipeline.
--
-- If DDL builds the containers, DML fills them.
-- ============================================================


-- ============================================================
-- INSERT — Adding Data
-- ============================================================

-- Setup: create a table to work with
CREATE TABLE etl_demo (
    id INTEGER PRIMARY KEY,
    skill VARCHAR NOT NULL,
    demand_count INTEGER,
    avg_salary DECIMAL(10, 2),
    load_date DATE DEFAULT CURRENT_DATE
);


-- Single row insert
INSERT INTO etl_demo (id, skill, demand_count, avg_salary)
VALUES (1, 'SQL', 5000, 115000.00);

-- Multiple rows
INSERT INTO etl_demo (id, skill, demand_count, avg_salary)
VALUES
    (2, 'Python', 4500, 120000.00),
    (3, 'AWS', 3200, 125000.00),
    (4, 'Spark', 2100, 130000.00),
    (5, 'Tableau', 1800, 95000.00);

SELECT * FROM etl_demo;


-- ============================================================
-- INSERT INTO ... SELECT  (The ETL workhorse)
-- ============================================================
-- This is how you move transformed data between tables.
-- Query from one table, insert into another.

CREATE TABLE top_skills_mart (
    skill_name VARCHAR,
    demand_count INTEGER,
    avg_salary DECIMAL(10, 2),
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO top_skills_mart (skill_name, demand_count, avg_salary)
SELECT
    sd.skills,
    COUNT(*) AS demand_count,
    ROUND(AVG(jpf.salary_year_avg), 2) AS avg_salary
FROM skills_job_dim sjd
JOIN job_postings_fact jpf ON sjd.job_id = jpf.job_id
JOIN skills_dim sd ON sjd.skill_id = sd.skill_id
WHERE jpf.salary_year_avg IS NOT NULL
GROUP BY sd.skills
HAVING COUNT(*) >= 50
ORDER BY demand_count DESC;

SELECT * FROM top_skills_mart ORDER BY demand_count DESC LIMIT 10;

-- This is literally what Project 2 does:
--   1. Create a mart table (DDL)
--   2. INSERT INTO ... SELECT transformed data (DML)
--   3. Done. The mart is ready for dashboards.


-- ============================================================
-- UPDATE — Modifying Existing Rows
-- ============================================================

-- Simple update
UPDATE etl_demo
SET avg_salary = 118000.00
WHERE skill = 'SQL';

-- Update with a calculation
UPDATE etl_demo
SET avg_salary = avg_salary * 1.05  -- 5% raise
WHERE demand_count > 3000;

-- Always use WHERE with UPDATE!
-- Without WHERE, you update EVERY row. I've done this
-- exactly once in production. Never again.

SELECT * FROM etl_demo;


-- ============================================================
-- UPDATE with Subquery
-- ============================================================
-- Update one table based on data from another.

-- Refresh demand counts from the actual data:
UPDATE etl_demo
SET demand_count = (
    SELECT COUNT(*)
    FROM skills_job_dim sjd
    JOIN skills_dim sd ON sjd.skill_id = sd.skill_id
    WHERE sd.skills = etl_demo.skill
)
WHERE skill IN ('SQL', 'Python', 'AWS', 'Spark', 'Tableau');

SELECT * FROM etl_demo;


-- ============================================================
-- DELETE — Removing Rows
-- ============================================================

-- Delete specific rows
DELETE FROM etl_demo
WHERE demand_count < 2000;

-- Delete with subquery
DELETE FROM etl_demo
WHERE skill NOT IN (
    SELECT DISTINCT sd.skills
    FROM skills_job_dim sjd
    JOIN skills_dim sd ON sjd.skill_id = sd.skill_id
);

-- TRUNCATE — Delete ALL rows (faster than DELETE for big tables)
-- TRUNCATE TABLE etl_demo;
-- ^ This doesn't have a WHERE clause. It's all or nothing.

SELECT * FROM etl_demo;


-- ============================================================
-- UPSERT / MERGE (INSERT OR REPLACE)
-- ============================================================
-- This is the pattern for "insert if new, update if exists."
-- Critical for incremental ETL — you don't want duplicates,
-- but you also don't want to lose updates.

-- DuckDB supports INSERT OR REPLACE:
INSERT OR REPLACE INTO etl_demo (id, skill, demand_count, avg_salary)
VALUES (1, 'SQL', 5500, 118000.00);
-- If id=1 exists, it replaces the row. If not, it inserts.

-- INSERT OR IGNORE — skip if it already exists:
INSERT OR IGNORE INTO etl_demo (id, skill, demand_count, avg_salary)
VALUES (1, 'SQL', 9999, 999999.00);
-- This does nothing because id=1 already exists.

SELECT * FROM etl_demo WHERE skill = 'SQL';
-- Still shows the OR REPLACE values, not the OR IGNORE ones.


-- ============================================================
-- ETL PATTERN: Full Refresh
-- ============================================================
-- The simplest ETL pattern. Drop and rebuild.

-- Step 1: Drop old data
DROP TABLE IF EXISTS skills_demand_mart;

-- Step 2: Create fresh from source
CREATE TABLE skills_demand_mart AS
SELECT
    sd.skills AS skill_name,
    sd.type AS skill_type,
    COUNT(*) AS total_postings,
    COUNT(DISTINCT jpf.company_id) AS unique_companies,
    ROUND(AVG(jpf.salary_year_avg), 0) AS avg_salary,
    ROUND(MEDIAN(jpf.salary_year_avg), 0) AS median_salary,
    MIN(jpf.salary_year_avg) AS min_salary,
    MAX(jpf.salary_year_avg) AS max_salary
FROM skills_job_dim sjd
JOIN job_postings_fact jpf ON sjd.job_id = jpf.job_id
JOIN skills_dim sd ON sjd.skill_id = sd.skill_id
WHERE jpf.salary_year_avg IS NOT NULL
GROUP BY sd.skills, sd.type;

SELECT * FROM skills_demand_mart ORDER BY total_postings DESC LIMIT 10;

-- Pros: Simple, always consistent, no duplicates ever.
-- Cons: Slow for huge tables, loses history.
-- Use when: Table is small enough to rebuild, or data doesn't
--           need historical tracking.

DROP TABLE IF EXISTS skills_demand_mart;


-- ============================================================
-- ETL PATTERN: Incremental Load
-- ============================================================
-- Only process NEW data since the last run.
-- This is what you do when full refresh is too slow.

CREATE TABLE daily_job_counts (
    report_date DATE PRIMARY KEY,
    job_count INTEGER,
    avg_salary DECIMAL(10, 2),
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- First load: everything
INSERT INTO daily_job_counts (report_date, job_count, avg_salary)
SELECT
    CAST(job_posted_date AS DATE) AS report_date,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_year_avg), 2) AS avg_salary
FROM job_postings_fact
WHERE CAST(job_posted_date AS DATE) <= '2023-06-30'
GROUP BY CAST(job_posted_date AS DATE);

-- Incremental: only new dates
INSERT OR REPLACE INTO daily_job_counts (report_date, job_count, avg_salary)
SELECT
    CAST(job_posted_date AS DATE) AS report_date,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_year_avg), 2) AS avg_salary
FROM job_postings_fact
WHERE CAST(job_posted_date AS DATE) > '2023-06-30'
GROUP BY CAST(job_posted_date AS DATE);

-- The key is the WHERE clause filters to only new data.
-- INSERT OR REPLACE handles the "what if we re-run" case.

SELECT COUNT(*) FROM daily_job_counts;

DROP TABLE IF EXISTS daily_job_counts;


-- ============================================================
-- ETL PATTERN: Staging → Transform → Load
-- ============================================================
-- The full pipeline pattern used in Project 3.
-- Data flows through stages:

-- Stage 1: Raw/Staging (copy source data as-is)
CREATE TEMP TABLE stg_jobs AS
SELECT * FROM job_postings_fact
WHERE job_title_short = 'Data Engineer';

-- Stage 2: Transformed (clean and reshape)
CREATE TEMP TABLE tfm_jobs AS
SELECT
    job_id,
    TRIM(job_title) AS job_title,
    LOWER(job_title_short) AS role,
    COALESCE(salary_year_avg, 0) AS salary,
    SPLIT_PART(job_location, ',', 1) AS city,
    CASE
        WHEN job_work_from_home = true THEN 'Remote'
        ELSE 'On-site'
    END AS work_type,
    DATE_TRUNC('month', job_posted_date) AS posted_month
FROM stg_jobs;

-- Stage 3: Load into final mart
CREATE TABLE de_jobs_mart AS
SELECT
    posted_month,
    work_type,
    COUNT(*) AS job_count,
    ROUND(AVG(CASE WHEN salary > 0 THEN salary END), 0) AS avg_salary
FROM tfm_jobs
GROUP BY posted_month, work_type;

SELECT * FROM de_jobs_mart ORDER BY posted_month, work_type;

-- This staging pattern means:
-- - Source data is never modified
-- - Each step is independently testable
-- - If something breaks, you know exactly where
-- - You can re-run any stage without starting over

DROP TABLE IF EXISTS de_jobs_mart;


-- ============================================================
-- IDEMPOTENT OPERATIONS
-- ============================================================
-- "Idempotent" means you can run the same operation multiple
-- times and get the same result. This is CRITICAL in ETL.
--
-- Good (idempotent):
--   CREATE TABLE IF NOT EXISTS ...
--   DROP TABLE IF EXISTS ...
--   INSERT OR REPLACE INTO ...
--   CREATE OR REPLACE VIEW ...
--
-- Bad (NOT idempotent):
--   CREATE TABLE ... (fails if table exists)
--   INSERT INTO ... (duplicates rows on re-run)
--   DROP TABLE ... (fails if table doesn't exist)
--
-- Rule: Every script should be safe to run twice.
-- Build pipelines so they survive failures and re-runs.


-- ============================================================
-- TRANSACTIONS
-- ============================================================
-- Transactions group operations so they ALL succeed or ALL fail.
-- No half-done states.

BEGIN TRANSACTION;

    CREATE TABLE IF NOT EXISTS transaction_demo (
        id INTEGER PRIMARY KEY,
        value VARCHAR
    );

    INSERT OR REPLACE INTO transaction_demo VALUES (1, 'first');
    INSERT OR REPLACE INTO transaction_demo VALUES (2, 'second');

COMMIT;

SELECT * FROM transaction_demo;

-- If anything between BEGIN and COMMIT fails, everything
-- rolls back. The table goes back to how it was before.

-- ROLLBACK manually:
BEGIN TRANSACTION;
    INSERT OR REPLACE INTO transaction_demo VALUES (3, 'third');
    -- Oops, something went wrong
ROLLBACK;

SELECT * FROM transaction_demo;
-- Row 3 is NOT there. The rollback undid it.

DROP TABLE IF EXISTS transaction_demo;


-- ============================================================
-- PUTTING IT ALL TOGETHER: Mini ETL Pipeline
-- ============================================================

-- This mimics what build_dw_marts.sql does in Project 2.

-- 1. Create mart tables
CREATE TABLE IF NOT EXISTS company_hiring_mart (
    company_name VARCHAR,
    total_postings INTEGER,
    avg_salary DECIMAL(10, 2),
    top_role VARCHAR,
    last_posting DATE
);

-- 2. Clear old data (for full refresh)
DELETE FROM company_hiring_mart;

-- 3. Load fresh data
INSERT INTO company_hiring_mart
WITH company_stats AS (
    SELECT
        cd.name AS company_name,
        COUNT(*) AS total_postings,
        ROUND(AVG(jpf.salary_year_avg), 2) AS avg_salary,
        MAX(CAST(jpf.job_posted_date AS DATE)) AS last_posting
    FROM job_postings_fact jpf
    JOIN company_dim cd ON jpf.company_id = cd.company_id
    WHERE jpf.salary_year_avg IS NOT NULL
    GROUP BY cd.name
    HAVING COUNT(*) >= 5
),
top_roles AS (
    SELECT
        cd.name AS company_name,
        jpf.job_title_short,
        ROW_NUMBER() OVER (
            PARTITION BY cd.name
            ORDER BY COUNT(*) DESC
        ) AS rn
    FROM job_postings_fact jpf
    JOIN company_dim cd ON jpf.company_id = cd.company_id
    GROUP BY cd.name, jpf.job_title_short
)
SELECT
    cs.company_name,
    cs.total_postings,
    cs.avg_salary,
    tr.job_title_short AS top_role,
    cs.last_posting
FROM company_stats cs
JOIN top_roles tr ON cs.company_name = tr.company_name AND tr.rn = 1;

-- 4. Verify
SELECT * FROM company_hiring_mart
ORDER BY total_postings DESC
LIMIT 20;

-- Clean up
DROP TABLE IF EXISTS company_hiring_mart;
DROP TABLE IF EXISTS etl_demo;
DROP TABLE IF EXISTS top_skills_mart;


-- ============================================================
-- TRY THIS
-- ============================================================
-- 1. Build a full-refresh mart called "monthly_trends" that has:
--    month, role, job_count, avg_salary, unique_companies
--    Make the whole script idempotent (safe to re-run).
--
-- 2. Create a staging pipeline:
--    a. Stage raw Data Analyst jobs into a temp table
--    b. Transform: clean location, add salary band, truncate dates
--    c. Load into a final aggregated mart
--
-- 3. Build an incremental load:
--    First load all jobs before July 2023,
--    then "incrementally" load the rest using INSERT OR REPLACE.
