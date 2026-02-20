-- ============================================================
-- LESSON 1.04: ORDER BY & LIMIT — Sorting and Paging
-- ============================================================
-- Once you've selected and filtered data, you usually want
-- it in a specific order. ORDER BY handles that. LIMIT
-- controls how many rows come back.
-- ============================================================


-- ============================================================
-- BASIC SORTING
-- ============================================================

-- Sort by salary, lowest first (ASC is the default)
SELECT
    job_id,
    job_title,
    salary_year_avg
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
ORDER BY salary_year_avg
LIMIT 10;

-- Sort by salary, highest first
SELECT
    job_id,
    job_title,
    salary_year_avg
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
ORDER BY salary_year_avg DESC
LIMIT 10;

-- ASC = ascending (A→Z, 1→100, earliest→latest) — default
-- DESC = descending (Z→A, 100→1, latest→earliest)


-- ============================================================
-- SORTING BY MULTIPLE COLUMNS
-- ============================================================
-- When the first column has ties, the second column breaks them.

SELECT
    job_title_short,
    salary_year_avg,
    job_location
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
ORDER BY job_title_short ASC, salary_year_avg DESC
LIMIT 20;

-- This sorts alphabetically by title first, then within each
-- title, shows highest salaries first.


-- ============================================================
-- SORTING BY COLUMN POSITION
-- ============================================================
-- You can refer to columns by their position in the SELECT.
-- Position 1 = first column, 2 = second, etc.

SELECT
    job_title_short,
    salary_year_avg,
    job_location
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
ORDER BY 1 ASC, 2 DESC
LIMIT 20;

-- Same result as above. Some people prefer this for quick work.
-- I use column names in anything that'll be saved or shared —
-- it's easier for someone else (or future me) to understand.


-- ============================================================
-- SORTING BY ALIASES
-- ============================================================
-- You can sort by a column alias you defined in SELECT.

SELECT
    job_title_short AS title,
    salary_year_avg AS salary
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
ORDER BY salary DESC
LIMIT 10;


-- ============================================================
-- SORTING BY EXPRESSIONS
-- ============================================================
-- You can sort by a calculated value even if it's not in SELECT.

SELECT
    job_id,
    job_title,
    salary_year_avg
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
ORDER BY salary_year_avg / 12 DESC     -- sort by monthly salary
LIMIT 10;


-- ============================================================
-- LIMIT & OFFSET — Paging Through Results
-- ============================================================

-- First 10 results
SELECT
    job_id,
    job_title
FROM job_postings_fact
LIMIT 10;

-- Skip the first 10, then show the next 10
SELECT
    job_id,
    job_title
FROM job_postings_fact
LIMIT 10
OFFSET 10;

-- OFFSET is useful for paging through results.
-- LIMIT 10 OFFSET 0  → rows 1-10  (page 1)
-- LIMIT 10 OFFSET 10 → rows 11-20 (page 2)
-- LIMIT 10 OFFSET 20 → rows 21-30 (page 3)

-- In data engineering, I use LIMIT a LOT for testing queries
-- on large tables. Write your query with LIMIT 10 first,
-- make sure it works, then remove the LIMIT for the full run.


-- ============================================================
-- TOP-N PATTERN
-- ============================================================
-- One of the most common patterns in SQL:
-- "Give me the top N of something"

-- Top 5 highest-paying jobs
SELECT
    job_id,
    job_title,
    salary_year_avg
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
ORDER BY salary_year_avg DESC
LIMIT 5;

-- Top 10 most recent job postings
SELECT
    job_id,
    job_title,
    job_posted_date
FROM job_postings_fact
ORDER BY job_posted_date DESC
LIMIT 10;

-- You'll use this pattern constantly. It's basically:
-- SELECT → FROM → WHERE → ORDER BY DESC → LIMIT N


-- ============================================================
-- NULLS IN SORTING
-- ============================================================
-- By default, NULLs sort to the end in ascending order
-- and to the beginning in descending order.
-- You can control this:

-- Put NULLs first
SELECT
    job_id,
    job_title,
    salary_year_avg
FROM job_postings_fact
ORDER BY salary_year_avg ASC NULLS FIRST
LIMIT 10;

-- Put NULLs last (even in descending order)
SELECT
    job_id,
    job_title,
    salary_year_avg
FROM job_postings_fact
ORDER BY salary_year_avg DESC NULLS LAST
LIMIT 10;


-- ============================================================
-- TRY THIS
-- ============================================================
-- 1. Find the 10 lowest-paying Data Engineer jobs
--    (must have a salary listed)
--
-- 2. Find the 20 most recently posted remote jobs,
--    sorted by date (most recent first)
--
-- 3. Show all distinct job_title_short values sorted
--    alphabetically
