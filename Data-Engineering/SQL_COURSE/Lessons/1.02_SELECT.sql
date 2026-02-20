-- ============================================================
-- LESSON 1.02: SELECT — Your First Query
-- ============================================================
-- SELECT is the most fundamental SQL statement. It's how you
-- ask the database to show you data. Every query you'll ever
-- write starts here.
-- ============================================================


-- The simplest possible query: "show me everything"
-- The * means "all columns"

SELECT *
FROM job_postings_fact;

-- That probably returned a LOT of rows. Let's limit it.
-- LIMIT restricts how many rows come back.

SELECT *
FROM job_postings_fact
LIMIT 10;

-- Much better. Now let's pick specific columns instead of *.
-- In real work, you almost never use * — you pick what you need.

SELECT
    job_id,
    job_title,
    job_location,
    salary_year_avg
FROM job_postings_fact
LIMIT 10;


-- ============================================================
-- ALIASES: Renaming Columns with AS
-- ============================================================
-- Column names from databases are often ugly or unclear.
-- AS lets you rename them in the output.

SELECT
    job_id,
    job_title AS title,
    job_location AS location,
    salary_year_avg AS avg_salary
FROM job_postings_fact
LIMIT 10;

-- You can also skip the AS keyword — it's optional.
-- But I always use it because it's clearer.

SELECT
    job_id,
    job_title title           -- works, but less readable
FROM job_postings_fact
LIMIT 5;


-- ============================================================
-- TABLE ALIASES
-- ============================================================
-- When table names are long, you give them short aliases.
-- This becomes essential when you start joining tables.

SELECT
    jpf.job_id,
    jpf.job_title,
    jpf.job_location
FROM job_postings_fact AS jpf
LIMIT 5;

-- "jpf" is just a shorthand for "job_postings_fact"
-- You'll see this pattern everywhere in these lessons.


-- ============================================================
-- DISTINCT — Remove Duplicates
-- ============================================================
-- Sometimes you want to see unique values only.

-- What job title categories exist?
SELECT DISTINCT job_title_short
FROM job_postings_fact;

-- What countries have job postings?
SELECT DISTINCT job_country
FROM job_postings_fact
LIMIT 20;

-- DISTINCT on multiple columns means unique COMBINATIONS
SELECT DISTINCT
    job_title_short,
    job_country
FROM job_postings_fact
LIMIT 20;


-- ============================================================
-- EXPRESSIONS & CALCULATIONS
-- ============================================================
-- You can do math and transformations right in SELECT.

-- Convert annual salary to monthly
SELECT
    job_id,
    job_title,
    salary_year_avg AS annual_salary,
    salary_year_avg / 12 AS monthly_salary
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
LIMIT 10;

-- String concatenation (joining text together)
SELECT
    job_id,
    job_title_short || ' at ' || job_location AS job_summary
FROM job_postings_fact
LIMIT 10;


-- ============================================================
-- NULL VALUES
-- ============================================================
-- NULL means "unknown" or "missing." It's not zero, it's not
-- an empty string — it's the absence of a value.
--
-- This matters A LOT in data engineering. Many salary fields
-- or optional fields will be NULL.

-- Find rows where salary is missing
SELECT
    job_id,
    job_title,
    salary_year_avg
FROM job_postings_fact
WHERE salary_year_avg IS NULL
LIMIT 10;

-- Find rows where salary EXISTS
SELECT
    job_id,
    job_title,
    salary_year_avg
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
LIMIT 10;

-- IMPORTANT: You can NOT use = NULL or != NULL
-- These don't work:
--   WHERE salary_year_avg = NULL     ← WRONG
--   WHERE salary_year_avg != NULL    ← WRONG
-- Always use IS NULL / IS NOT NULL


-- ============================================================
-- TRY THIS
-- ============================================================
-- 1. Select just the job_title and job_country columns,
--    limited to 15 rows
--
-- 2. Find all DISTINCT values of job_title_short
--
-- 3. Select job_id, job_title, and calculate what a 10% raise
--    on salary_year_avg would be (only where salary exists)
