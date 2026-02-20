-- ============================================================
-- LESSON 1.05: GROUP BY & Aggregate Functions
-- ============================================================
-- This is where SQL gets powerful. Instead of looking at
-- individual rows, you start asking questions about groups
-- of rows: "How many?", "What's the average?", "What's
-- the highest?"
--
-- If you've ever made a pivot table in Excel, GROUP BY
-- is the SQL version of that.
-- ============================================================


-- ============================================================
-- AGGREGATE FUNCTIONS — The Building Blocks
-- ============================================================
-- These functions take many rows and collapse them into one value.

-- How many job postings are there total?
SELECT COUNT(*) AS total_postings
FROM job_postings_fact;

-- How many have salaries listed?
SELECT COUNT(salary_year_avg) AS postings_with_salary
FROM job_postings_fact;
-- COUNT(*) counts all rows
-- COUNT(column) counts rows where that column is NOT NULL
-- This difference matters!

-- Basic aggregate functions
SELECT
    COUNT(*) AS total_jobs,
    COUNT(salary_year_avg) AS jobs_with_salary,
    AVG(salary_year_avg) AS avg_salary,
    MIN(salary_year_avg) AS min_salary,
    MAX(salary_year_avg) AS max_salary,
    SUM(salary_year_avg) AS sum_salary
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL;

-- MEDIAN (available in DuckDB, not all databases)
SELECT
    MEDIAN(salary_year_avg) AS median_salary
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL;

-- ROUND — because nobody wants to see 134,276.384729
SELECT
    ROUND(AVG(salary_year_avg), 2) AS avg_salary,
    ROUND(MEDIAN(salary_year_avg), 0) AS median_salary
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL;


-- ============================================================
-- GROUP BY — Aggregating by Category
-- ============================================================
-- "Count/average/sum... PER WHAT?"
-- GROUP BY answers that question.

-- How many jobs per job title?
SELECT
    job_title_short,
    COUNT(*) AS job_count
FROM job_postings_fact
GROUP BY job_title_short
ORDER BY job_count DESC;

-- Average salary per job title
SELECT
    job_title_short,
    ROUND(AVG(salary_year_avg), 0) AS avg_salary,
    COUNT(*) AS job_count
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
GROUP BY job_title_short
ORDER BY avg_salary DESC;

-- THE GOLDEN RULE:
-- Every column in SELECT must either:
--   1. Be in the GROUP BY clause, OR
--   2. Be inside an aggregate function (COUNT, AVG, etc.)
--
-- This won't work:
--   SELECT job_title_short, job_location, COUNT(*)
--   FROM job_postings_fact
--   GROUP BY job_title_short
--
-- Because job_location isn't grouped or aggregated.
-- The database wouldn't know WHICH location to show.


-- ============================================================
-- GROUP BY Multiple Columns
-- ============================================================
-- You can group by more than one column to get more specific
-- breakdowns.

-- Jobs per title AND location
SELECT
    job_title_short,
    job_location,
    COUNT(*) AS job_count
FROM job_postings_fact
GROUP BY job_title_short, job_location
ORDER BY job_count DESC
LIMIT 20;

-- Remote vs non-remote breakdown per title
SELECT
    job_title_short,
    job_work_from_home,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_year_avg), 0) AS avg_salary
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
GROUP BY job_title_short, job_work_from_home
ORDER BY job_title_short, job_work_from_home;


-- ============================================================
-- HAVING — Filtering Groups
-- ============================================================
-- WHERE filters individual rows BEFORE grouping.
-- HAVING filters groups AFTER aggregation.
--
-- Think of it this way:
--   WHERE  = "which rows go into the groups?"
--   HAVING = "which groups do I want to see?"

-- Job titles with more than 1000 postings
SELECT
    job_title_short,
    COUNT(*) AS job_count
FROM job_postings_fact
GROUP BY job_title_short
HAVING COUNT(*) > 1000
ORDER BY job_count DESC;

-- Titles where the average salary is above 120k
SELECT
    job_title_short,
    ROUND(AVG(salary_year_avg), 0) AS avg_salary,
    COUNT(*) AS job_count
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
GROUP BY job_title_short
HAVING AVG(salary_year_avg) > 120000
ORDER BY avg_salary DESC;

-- WHERE + HAVING together
-- "For remote jobs only, which titles have avg salary > 130k?"
SELECT
    job_title_short,
    ROUND(AVG(salary_year_avg), 0) AS avg_salary,
    COUNT(*) AS job_count
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
  AND job_work_from_home = TRUE
GROUP BY job_title_short
HAVING AVG(salary_year_avg) > 130000
ORDER BY avg_salary DESC;


-- ============================================================
-- COUNT DISTINCT
-- ============================================================
-- COUNT(*) counts rows. COUNT(DISTINCT column) counts
-- unique values.

-- How many unique companies are posting jobs?
SELECT
    COUNT(DISTINCT company_id) AS unique_companies
FROM job_postings_fact;

-- Unique companies per job title
SELECT
    job_title_short,
    COUNT(DISTINCT company_id) AS unique_companies,
    COUNT(*) AS total_postings
FROM job_postings_fact
GROUP BY job_title_short
ORDER BY unique_companies DESC;


-- ============================================================
-- STRING_AGG — Concatenating Grouped Values
-- ============================================================
-- Sometimes you want to combine text values in a group.

-- List all locations for each job title (comma-separated)
SELECT
    job_title_short,
    STRING_AGG(DISTINCT job_country, ', ') AS countries
FROM job_postings_fact
GROUP BY job_title_short;

-- This is really useful in data engineering when you need
-- to denormalize data — turning multiple rows into one.


-- ============================================================
-- COMMON MISTAKES WITH GROUP BY
-- ============================================================

-- 1. Forgetting GROUP BY when using aggregates with other columns
--    WRONG:  SELECT job_title_short, COUNT(*) FROM table
--    RIGHT:  SELECT job_title_short, COUNT(*) FROM table GROUP BY job_title_short

-- 2. Using WHERE instead of HAVING for aggregate conditions
--    WRONG:  WHERE COUNT(*) > 10
--    RIGHT:  HAVING COUNT(*) > 10

-- 3. Using column alias in HAVING (varies by database)
--    In DuckDB/PostgreSQL: HAVING job_count > 10  ← works
--    In MySQL/others: HAVING COUNT(*) > 10         ← safer


-- ============================================================
-- TRY THIS
-- ============================================================
-- 1. Find the average salary for each job_country (top 10 by avg salary)
--
-- 2. Which job locations have more than 500 postings?
--    (Show location and count, sorted by count descending)
--
-- 3. For Data Engineer jobs only, find the average and median
--    salary per country, but only countries with 50+ postings
