-- ============================================================
-- LESSON 1.06: CASE WHEN — Conditional Logic
-- ============================================================
-- CASE WHEN is SQL's version of if/else. It lets you create
-- new columns based on conditions — categorizing data,
-- creating flags, bucketing values. You'll use this constantly
-- in data transformations.
-- ============================================================


-- ============================================================
-- BASIC CASE WHEN
-- ============================================================

-- Categorize jobs by salary level
SELECT
    job_id,
    job_title,
    salary_year_avg,
    CASE
        WHEN salary_year_avg >= 200000 THEN 'Very High'
        WHEN salary_year_avg >= 150000 THEN 'High'
        WHEN salary_year_avg >= 100000 THEN 'Medium'
        WHEN salary_year_avg >= 70000 THEN 'Low'
        ELSE 'Entry Level'
    END AS salary_tier
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
ORDER BY salary_year_avg DESC
LIMIT 20;

-- How it works:
-- SQL checks each WHEN condition top to bottom.
-- As soon as one is TRUE, it uses that THEN value and stops.
-- If nothing matches, it uses ELSE.
-- ELSE is optional, but without it you get NULL for non-matches.


-- ============================================================
-- CASE WHEN WITH GROUP BY
-- ============================================================
-- This is where CASE WHEN gets really useful — combining it
-- with aggregation to create summary reports.

-- Count of jobs per salary tier
SELECT
    CASE
        WHEN salary_year_avg >= 200000 THEN 'Very High (200k+)'
        WHEN salary_year_avg >= 150000 THEN 'High (150-200k)'
        WHEN salary_year_avg >= 100000 THEN 'Medium (100-150k)'
        WHEN salary_year_avg >= 70000 THEN 'Low (70-100k)'
        ELSE 'Entry (<70k)'
    END AS salary_tier,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_year_avg), 0) AS avg_salary_in_tier
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
GROUP BY salary_tier
ORDER BY avg_salary_in_tier DESC;


-- ============================================================
-- CONDITIONAL AGGREGATION (Pivot-style)
-- ============================================================
-- This is a powerful technique — use CASE inside aggregate
-- functions to create pivot table-like output.

-- Remote vs on-site counts per job title
SELECT
    job_title_short,
    COUNT(*) AS total_jobs,
    COUNT(CASE WHEN job_work_from_home = TRUE THEN 1 END) AS remote_jobs,
    COUNT(CASE WHEN job_work_from_home = FALSE THEN 1 END) AS onsite_jobs
FROM job_postings_fact
GROUP BY job_title_short
ORDER BY total_jobs DESC;

-- Percentage of remote jobs per title
SELECT
    job_title_short,
    COUNT(*) AS total_jobs,
    ROUND(
        100.0 * COUNT(CASE WHEN job_work_from_home = TRUE THEN 1 END)
        / COUNT(*),
        1
    ) AS remote_pct
FROM job_postings_fact
GROUP BY job_title_short
ORDER BY remote_pct DESC;

-- This is how I built boolean flag conversions in the
-- data mart projects. Instead of TRUE/FALSE, you convert
-- to 1/0 for aggregation:

SELECT
    job_title_short,
    SUM(CASE WHEN job_work_from_home = TRUE THEN 1 ELSE 0 END) AS remote_count,
    SUM(CASE WHEN job_no_degree_mention = TRUE THEN 1 ELSE 0 END) AS no_degree_count,
    SUM(CASE WHEN job_health_insurance = TRUE THEN 1 ELSE 0 END) AS has_insurance_count
FROM job_postings_fact
GROUP BY job_title_short
ORDER BY job_title_short;


-- ============================================================
-- SIMPLE CASE (Matching a Single Value)
-- ============================================================
-- When you're just checking one column against specific values,
-- you can use the simpler syntax:

SELECT
    job_title_short,
    CASE job_title_short
        WHEN 'Data Engineer' THEN 'Engineering'
        WHEN 'Data Scientist' THEN 'Science'
        WHEN 'Data Analyst' THEN 'Analytics'
        WHEN 'Machine Learning Engineer' THEN 'ML/AI'
        ELSE 'Other'
    END AS department,
    COUNT(*) AS job_count
FROM job_postings_fact
GROUP BY job_title_short
ORDER BY job_count DESC;


-- ============================================================
-- NULL HANDLING WITH CASE & COALESCE
-- ============================================================

-- Replace NULL salaries with a message
SELECT
    job_id,
    job_title,
    CASE
        WHEN salary_year_avg IS NULL THEN 'Not disclosed'
        ELSE CAST(salary_year_avg AS VARCHAR)
    END AS salary_display
FROM job_postings_fact
LIMIT 20;

-- COALESCE is a shortcut for the "replace NULL" pattern.
-- It returns the first non-NULL value from a list.

SELECT
    job_id,
    job_title,
    COALESCE(salary_year_avg, 0) AS salary_or_zero,
    COALESCE(salary_hour_avg, salary_year_avg / 2080, 0) AS hourly_rate
FROM job_postings_fact
LIMIT 20;

-- COALESCE(a, b, c) = use a if not NULL, else b, else c
-- Super handy when you have multiple fallback columns.


-- ============================================================
-- DATA ENGINEERING USE CASE: Creating Flags for a Mart
-- ============================================================
-- This pattern shows up all the time when building data marts.
-- You transform raw boolean/text data into useful categories.

SELECT
    job_title_short AS role,
    CASE
        WHEN job_work_from_home = TRUE THEN 'Remote'
        WHEN job_location LIKE '%Anywhere%' THEN 'Remote'
        ELSE 'On-site'
    END AS work_type,
    CASE
        WHEN salary_year_avg >= 150000 THEN 'Senior'
        WHEN salary_year_avg >= 100000 THEN 'Mid'
        WHEN salary_year_avg IS NOT NULL THEN 'Junior'
        ELSE 'Unknown'
    END AS seniority_guess,
    salary_year_avg
FROM job_postings_fact
WHERE job_title_short = 'Data Engineer'
  AND salary_year_avg IS NOT NULL
ORDER BY salary_year_avg DESC
LIMIT 20;


-- ============================================================
-- TRY THIS
-- ============================================================
-- 1. Create salary buckets ($50k increments) and count jobs
--    in each bucket
--
-- 2. For each job_title_short, calculate the percentage of jobs
--    that have a salary listed vs. not listed
--
-- 3. Create a "job_quality_score" column that awards:
--    +1 for having health insurance
--    +1 for being remote
--    +1 for not requiring a degree
--    +1 for salary > 100k
--    Then group by score and count jobs
