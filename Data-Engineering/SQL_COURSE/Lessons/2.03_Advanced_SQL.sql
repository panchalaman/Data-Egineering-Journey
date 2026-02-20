-- ============================================================
-- LESSON 2.03: Advanced SQL & Query Optimization
-- ============================================================
-- This is the stuff that comes up in interviews and real
-- pipeline work. Set operations, recursive queries, EXPLAIN,
-- and writing SQL that doesn't make your DBA want to quit.
-- ============================================================


-- ============================================================
-- SET OPERATIONS: UNION / INTERSECT / EXCEPT
-- ============================================================

-- UNION — Combine results from two queries (removes duplicates)
SELECT job_title_short FROM job_postings_fact WHERE job_title_short = 'Data Engineer'
UNION
SELECT job_title_short FROM job_postings_fact WHERE job_title_short = 'Data Analyst';
-- Returns 2 rows: 'Data Engineer', 'Data Analyst'

-- UNION ALL — Same but keeps duplicates (faster)
SELECT job_title_short, job_location
FROM job_postings_fact
WHERE job_title_short = 'Data Engineer'
UNION ALL
SELECT job_title_short, job_location
FROM job_postings_fact
WHERE job_title_short = 'Data Analyst';
-- Returns ALL rows from both queries.
-- Use UNION ALL unless you specifically need dedup.
-- It's faster because it skips the dedup step.

-- INTERSECT — Only rows that appear in BOTH queries
SELECT DISTINCT company_id
FROM job_postings_fact
WHERE job_title_short = 'Data Engineer'
INTERSECT
SELECT DISTINCT company_id
FROM job_postings_fact
WHERE job_title_short = 'Data Analyst';
-- Companies that hire BOTH Data Engineers AND Data Analysts.

-- EXCEPT — Rows in first query but NOT in second
SELECT DISTINCT company_id
FROM job_postings_fact
WHERE job_title_short = 'Data Engineer'
EXCEPT
SELECT DISTINCT company_id
FROM job_postings_fact
WHERE job_title_short = 'Data Analyst';
-- Companies that hire Data Engineers but NOT Data Analysts.

-- These are way cleaner than trying to do the same thing
-- with JOINs and NOT IN subqueries.


-- ============================================================
-- RECURSIVE CTEs
-- ============================================================
-- A CTE that references itself. Sounds wild but it's useful
-- for hierarchical data (org charts, category trees, etc.)

-- Classic example: generate a series of numbers
WITH RECURSIVE numbers AS (
    SELECT 1 AS n             -- anchor: starting point
    UNION ALL
    SELECT n + 1 FROM numbers -- recursive: keep adding 1
    WHERE n < 10              -- stop condition (IMPORTANT!)
)
SELECT * FROM numbers;
-- Without the WHERE, this runs forever. Always have a stop condition.

-- Generate a date series (useful for filling gaps in time series)
WITH RECURSIVE date_series AS (
    SELECT CAST('2023-01-01' AS DATE) AS dt
    UNION ALL
    SELECT dt + INTERVAL '1 month'
    FROM date_series
    WHERE dt < '2023-12-01'
)
SELECT dt FROM date_series;

-- Real use: fill gaps in monthly data
-- Sometimes months have zero postings. A simple GROUP BY
-- skips those months. Recursive CTE generates ALL months,
-- then LEFT JOIN to fill in the data.
WITH RECURSIVE all_months AS (
    SELECT CAST('2023-01-01' AS DATE) AS month_start
    UNION ALL
    SELECT CAST(month_start + INTERVAL '1 month' AS DATE)
    FROM all_months
    WHERE month_start < '2023-12-01'
),
monthly_de_jobs AS (
    SELECT
        CAST(DATE_TRUNC('month', job_posted_date) AS DATE) AS month_start,
        COUNT(*) AS job_count
    FROM job_postings_fact
    WHERE job_title_short = 'Data Engineer'
    GROUP BY CAST(DATE_TRUNC('month', job_posted_date) AS DATE)
)
SELECT
    am.month_start,
    COALESCE(mj.job_count, 0) AS job_count
FROM all_months am
LEFT JOIN monthly_de_jobs mj ON am.month_start = mj.month_start
ORDER BY am.month_start;
-- Now every month appears, even if it had zero postings.

-- DuckDB shortcut: generate_series
SELECT * FROM generate_series(
    CAST('2023-01-01' AS DATE),
    CAST('2023-12-01' AS DATE),
    INTERVAL '1 month'
);
-- Much easier if your database supports it.


-- ============================================================
-- PIVOT / UNPIVOT (Crosstab Queries)
-- ============================================================

-- Manual pivot with CASE + GROUP BY
-- (works in any SQL database)
SELECT
    DATE_TRUNC('month', job_posted_date) AS month,
    COUNT(CASE WHEN job_title_short = 'Data Engineer' THEN 1 END) AS data_engineer,
    COUNT(CASE WHEN job_title_short = 'Data Analyst' THEN 1 END) AS data_analyst,
    COUNT(CASE WHEN job_title_short = 'Data Scientist' THEN 1 END) AS data_scientist
FROM job_postings_fact
GROUP BY DATE_TRUNC('month', job_posted_date)
ORDER BY month;

-- DuckDB has a built-in PIVOT:
PIVOT job_postings_fact
ON job_title_short IN ('Data Engineer', 'Data Analyst', 'Data Scientist')
USING COUNT(*)
GROUP BY DATE_TRUNC('month', job_posted_date);
-- Way cleaner, but not available in every database.


-- ============================================================
-- LATERAL JOINS
-- ============================================================
-- A lateral join lets the subquery reference the outer table.
-- Think of it as a "for each row, run this subquery."

-- For each role, get the top 3 highest-paying jobs
SELECT
    roles.role,
    top_jobs.job_title,
    top_jobs.salary_year_avg
FROM (SELECT DISTINCT job_title_short AS role FROM job_postings_fact) roles,
LATERAL (
    SELECT job_title, salary_year_avg
    FROM job_postings_fact jpf
    WHERE jpf.job_title_short = roles.role
        AND jpf.salary_year_avg IS NOT NULL
    ORDER BY salary_year_avg DESC
    LIMIT 3
) top_jobs
ORDER BY roles.role, top_jobs.salary_year_avg DESC;

-- This is an alternative to the ROW_NUMBER + CTE pattern.
-- Some people find it more readable.


-- ============================================================
-- QUALIFY (DuckDB / Snowflake)
-- ============================================================
-- QUALIFY filters on window function results.
-- It's like HAVING but for window functions.

-- Without QUALIFY (the CTE way):
WITH ranked AS (
    SELECT
        job_title_short,
        salary_year_avg,
        ROW_NUMBER() OVER (
            PARTITION BY job_title_short
            ORDER BY salary_year_avg DESC
        ) AS rn
    FROM job_postings_fact
    WHERE salary_year_avg IS NOT NULL
)
SELECT * FROM ranked WHERE rn <= 3;

-- With QUALIFY (much cleaner):
SELECT
    job_title_short,
    salary_year_avg
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY job_title_short
    ORDER BY salary_year_avg DESC
) <= 3;

-- Same result, half the code. QUALIFY is not standard SQL
-- but DuckDB and Snowflake support it. Worth knowing if
-- you'll work with either.


-- ============================================================
-- EXPLAIN / EXPLAIN ANALYZE
-- ============================================================
-- This tells you HOW the database runs your query.
-- Essential for understanding performance.

EXPLAIN
SELECT
    sd.skills,
    COUNT(*) AS demand
FROM skills_job_dim sjd
JOIN skills_dim sd ON sjd.skill_id = sd.skill_id
GROUP BY sd.skills
ORDER BY demand DESC
LIMIT 10;

-- EXPLAIN shows the query PLAN (what it would do).
-- EXPLAIN ANALYZE actually RUNS it and shows timing.

EXPLAIN ANALYZE
SELECT
    sd.skills,
    COUNT(*) AS demand
FROM skills_job_dim sjd
JOIN skills_dim sd ON sjd.skill_id = sd.skill_id
GROUP BY sd.skills
ORDER BY demand DESC
LIMIT 10;

-- What to look for in the output:
--   - Seq Scan vs Index Scan (sequential is slow for big tables)
--   - Hash Join vs Nested Loop (hash is usually better)
--   - Sort operations (expensive for large results)
--   - Filter percentages (how many rows get eliminated)


-- ============================================================
-- QUERY OPTIMIZATION TIPS
-- ============================================================

-- 1. Filter early, join late
-- BAD: join everything, then filter
SELECT jpf.*, cd.name
FROM job_postings_fact jpf
JOIN company_dim cd ON jpf.company_id = cd.company_id
WHERE jpf.job_title_short = 'Data Engineer';

-- BETTER: filter first in CTE, then join
WITH de_jobs AS (
    SELECT * FROM job_postings_fact
    WHERE job_title_short = 'Data Engineer'
)
SELECT dj.*, cd.name
FROM de_jobs dj
JOIN company_dim cd ON dj.company_id = cd.company_id;
-- Most query optimizers do this automatically, but being
-- explicit helps readability and sometimes performance.


-- 2. Use EXISTS instead of IN for large subqueries
-- SLOW for large lists:
SELECT * FROM company_dim
WHERE company_id IN (
    SELECT company_id FROM job_postings_fact
);

-- FASTER:
SELECT * FROM company_dim cd
WHERE EXISTS (
    SELECT 1 FROM job_postings_fact jpf
    WHERE jpf.company_id = cd.company_id
);
-- EXISTS stops at the first match. IN builds the full list.


-- 3. Avoid SELECT * in production
-- SELECT * reads every column. If you only need 3 columns,
-- only select those 3. Less data to read = faster queries.


-- 4. Be careful with DISTINCT
-- DISTINCT sorts and deduplicates the ENTIRE result.
-- If you need distinct values from one column, GROUP BY
-- is often better:
-- Slow: SELECT DISTINCT col1, col2, col3 FROM big_table
-- Better: SELECT col1 FROM big_table GROUP BY col1


-- 5. Use LIMIT during development
-- Always add LIMIT when exploring. Don't pull a billion
-- rows to see what the data looks like.


-- 6. Watch out for cartesian joins
-- If you forget the ON clause, you get every row × every row.
-- With two 100K-row tables, that's 10 billion rows.
-- Your database will not be happy.


-- ============================================================
-- STRING PATTERN MATCHING: LIKE vs SIMILAR TO vs REGEXP
-- ============================================================

-- LIKE (basic, most common)
SELECT DISTINCT job_title
FROM job_postings_fact
WHERE job_title LIKE '%Senior%Data%Engineer%'
LIMIT 10;

-- ILIKE (case-insensitive, DuckDB/PostgreSQL)
SELECT DISTINCT job_title
FROM job_postings_fact
WHERE job_title ILIKE '%senior%data%engineer%'
LIMIT 10;

-- REGEXP_MATCHES (regex, for complex patterns)
SELECT DISTINCT job_title
FROM job_postings_fact
WHERE REGEXP_MATCHES(job_title, '(Sr|Senior).*Data.*Engineer')
LIMIT 10;


-- ============================================================
-- GROUPING SETS / CUBE / ROLLUP
-- ============================================================
-- When you need multiple levels of aggregation in one query.

-- GROUPING SETS — specific combinations
SELECT
    job_title_short,
    job_location,
    COUNT(*) AS job_count
FROM job_postings_fact
WHERE job_title_short IN ('Data Engineer', 'Data Analyst')
GROUP BY GROUPING SETS (
    (job_title_short, job_location),  -- by role + location
    (job_title_short),                 -- by role only
    ()                                 -- grand total
)
ORDER BY job_title_short NULLS LAST, job_location NULLS LAST
LIMIT 30;

-- ROLLUP — hierarchical subtotals
SELECT
    job_title_short,
    EXTRACT(YEAR FROM job_posted_date) AS year,
    EXTRACT(MONTH FROM job_posted_date) AS month,
    COUNT(*) AS job_count
FROM job_postings_fact
WHERE job_title_short = 'Data Engineer'
GROUP BY ROLLUP (
    job_title_short,
    EXTRACT(YEAR FROM job_posted_date),
    EXTRACT(MONTH FROM job_posted_date)
)
ORDER BY year NULLS LAST, month NULLS LAST
LIMIT 30;
-- Gives you: month-level, year-level, and grand total rows.


-- ============================================================
-- PRACTICAL: Full Analytics Query
-- ============================================================
-- Combining everything into a real-world analytics query.

WITH monthly_skills AS (
    SELECT
        DATE_TRUNC('month', jpf.job_posted_date) AS month,
        sd.skills AS skill_name,
        COUNT(*) AS demand_count,
        ROUND(AVG(jpf.salary_year_avg), 0) AS avg_salary
    FROM skills_job_dim sjd
    JOIN job_postings_fact jpf ON sjd.job_id = jpf.job_id
    JOIN skills_dim sd ON sjd.skill_id = sd.skill_id
    WHERE
        jpf.job_title_short = 'Data Engineer'
        AND jpf.salary_year_avg IS NOT NULL
    GROUP BY DATE_TRUNC('month', jpf.job_posted_date), sd.skills
),
ranked_skills AS (
    SELECT
        month,
        skill_name,
        demand_count,
        avg_salary,
        ROW_NUMBER() OVER (
            PARTITION BY month
            ORDER BY demand_count DESC
        ) AS skill_rank,
        LAG(demand_count) OVER (
            PARTITION BY skill_name
            ORDER BY month
        ) AS prev_month_demand,
        demand_count - LAG(demand_count) OVER (
            PARTITION BY skill_name
            ORDER BY month
        ) AS demand_change
    FROM monthly_skills
)
SELECT
    month,
    skill_name,
    demand_count,
    avg_salary,
    skill_rank,
    demand_change,
    CASE
        WHEN demand_change > 0 THEN 'Growing'
        WHEN demand_change < 0 THEN 'Declining'
        WHEN demand_change = 0 THEN 'Stable'
        ELSE 'N/A'
    END AS trend
FROM ranked_skills
WHERE skill_rank <= 5
ORDER BY month, skill_rank;

-- This query tells you:
-- For each month, what are the top 5 in-demand skills for
-- Data Engineers, and are they growing or declining?
-- That's the kind of analysis that makes a portfolio stand out.


-- ============================================================
-- TRY THIS
-- ============================================================
-- 1. Use UNION to combine Data Engineer and Data Scientist
--    job postings into one result set, then count by location.
--
-- 2. Write an EXPLAIN ANALYZE for a query that joins all 4
--    tables. Read the output and see which step takes longest.
--
-- 3. Use a recursive CTE to generate all months in 2023,
--    then LEFT JOIN to monthly job counts to see if there
--    are any months with zero postings.
--
-- 4. Write a query using GROUPING SETS that shows:
--    a) Count of jobs by role and location
--    b) Count by role only
--    c) Grand total
--    All in one result set.


-- ============================================================
-- WHAT'S NEXT?
-- ============================================================
-- You've now covered the complete SQL toolkit for data
-- engineering. The Lessons section covers:
--
-- Part 1 (Querying):
--   1.01 What Is SQL
--   1.02 SELECT
--   1.03 WHERE
--   1.04 ORDER BY
--   1.05 GROUP BY
--   1.06 CASE WHEN
--   1.07 JOINS
--   1.08 Subqueries & CTEs
--   1.09 Date & String Functions
--   1.10 Window Functions
--   1.11 JOINs (practice)
--   1.12 Order of Execution
--
-- Part 2 (Building):
--   2.01 DDL & Data Modeling
--   2.02 DML & ETL Patterns
--   2.03 Advanced SQL & Query Optimization
--
-- Now go build something. The Projects folder has 3 real
-- projects that use everything from these lessons:
--   Project 1: Exploratory Data Analysis
--   Project 2: Data Warehouse & Mart Build
--   Project 3: Flat File to Warehouse Pipeline
