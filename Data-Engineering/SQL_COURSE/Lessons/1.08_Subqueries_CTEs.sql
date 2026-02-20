-- ============================================================
-- LESSON 1.08: Subqueries & CTEs
-- ============================================================
-- Sometimes you need the result of one query to feed into
-- another query. That's what subqueries and CTEs do.
--
-- CTEs (Common Table Expressions) changed how I write SQL.
-- Once you learn them, you'll never go back to writing
-- giant nested queries.
-- ============================================================


-- ============================================================
-- SUBQUERIES — A Query Inside a Query
-- ============================================================

-- Subquery in WHERE
-- "Show me jobs with salary above the overall average"
SELECT
    job_id,
    job_title,
    salary_year_avg
FROM job_postings_fact
WHERE salary_year_avg > (
    SELECT AVG(salary_year_avg)
    FROM job_postings_fact
    WHERE salary_year_avg IS NOT NULL
)
ORDER BY salary_year_avg DESC
LIMIT 10;

-- The inner query runs first, calculates the average salary,
-- then the outer query uses that value as a filter.


-- Subquery in WHERE with IN
-- "Show me jobs from the top 5 highest-hiring companies"
SELECT
    job_id,
    job_title,
    company_id
FROM job_postings_fact
WHERE company_id IN (
    SELECT company_id
    FROM job_postings_fact
    GROUP BY company_id
    ORDER BY COUNT(*) DESC
    LIMIT 5
)
LIMIT 20;


-- Subquery in SELECT
-- "Show each job's salary vs the average for its title"
SELECT
    job_id,
    job_title_short,
    salary_year_avg,
    (SELECT ROUND(AVG(salary_year_avg), 0)
     FROM job_postings_fact sub
     WHERE sub.job_title_short = main.job_title_short
       AND sub.salary_year_avg IS NOT NULL
    ) AS title_avg_salary,
    ROUND(salary_year_avg - (
        SELECT AVG(salary_year_avg)
        FROM job_postings_fact sub
        WHERE sub.job_title_short = main.job_title_short
          AND sub.salary_year_avg IS NOT NULL
    ), 0) AS diff_from_avg
FROM job_postings_fact AS main
WHERE salary_year_avg IS NOT NULL
ORDER BY diff_from_avg DESC
LIMIT 10;

-- This works but it's getting hard to read. Also, that subquery
-- runs for EVERY row, which can be slow. Enter CTEs...


-- ============================================================
-- CTEs — Common Table Expressions
-- ============================================================
-- A CTE is a named temporary result set. You define it at the
-- top with WITH, then use it like a regular table below.
--
-- Think of it as: "first calculate this, then use it."

-- Same query as above, but readable:
WITH title_averages AS (
    SELECT
        job_title_short,
        ROUND(AVG(salary_year_avg), 0) AS avg_salary
    FROM job_postings_fact
    WHERE salary_year_avg IS NOT NULL
    GROUP BY job_title_short
)
SELECT
    jpf.job_id,
    jpf.job_title_short,
    jpf.salary_year_avg,
    ta.avg_salary AS title_avg_salary,
    ROUND(jpf.salary_year_avg - ta.avg_salary, 0) AS diff_from_avg
FROM job_postings_fact AS jpf
INNER JOIN title_averages AS ta
    ON jpf.job_title_short = ta.job_title_short
WHERE jpf.salary_year_avg IS NOT NULL
ORDER BY diff_from_avg DESC
LIMIT 10;

-- SO much cleaner. The CTE calculates title averages once,
-- and then we just join to it.


-- ============================================================
-- MULTIPLE CTEs
-- ============================================================
-- You can chain multiple CTEs. Each one can reference the
-- ones defined before it.

WITH skill_demand AS (
    -- Step 1: Count demand per skill
    SELECT
        sd.skills AS skill_name,
        COUNT(*) AS demand_count
    FROM job_postings_fact AS jpf
    INNER JOIN skills_job_dim AS sjd ON jpf.job_id = sjd.job_id
    INNER JOIN skills_dim AS sd ON sjd.skill_id = sd.skill_id
    WHERE jpf.job_title_short = 'Data Engineer'
    GROUP BY sd.skills
),
skill_salary AS (
    -- Step 2: Average salary per skill
    SELECT
        sd.skills AS skill_name,
        ROUND(AVG(jpf.salary_year_avg), 0) AS avg_salary
    FROM job_postings_fact AS jpf
    INNER JOIN skills_job_dim AS sjd ON jpf.job_id = sjd.job_id
    INNER JOIN skills_dim AS sd ON sjd.skill_id = sd.skill_id
    WHERE jpf.job_title_short = 'Data Engineer'
      AND jpf.salary_year_avg IS NOT NULL
    GROUP BY sd.skills
)
-- Step 3: Combine demand and salary
SELECT
    d.skill_name,
    d.demand_count,
    s.avg_salary
FROM skill_demand AS d
INNER JOIN skill_salary AS s
    ON d.skill_name = s.skill_name
WHERE d.demand_count >= 100
ORDER BY s.avg_salary DESC
LIMIT 15;

-- This is the same approach I used in the EDA project.
-- Break complex analysis into clear, named steps.


-- ============================================================
-- CTEs vs SUBQUERIES — When to Use Which
-- ============================================================
/*
   USE CTEs WHEN:
   - You need the same result in multiple places
   - The query has multiple logical steps
   - You want readable, maintainable code
   - You're building data pipelines (always CTEs)

   USE SUBQUERIES WHEN:
   - It's a simple one-off filter (WHERE x IN (subquery))
   - The subquery is short and self-contained
   - You're doing a quick ad-hoc check

   In practice, I use CTEs about 90% of the time.
   They make code easier to debug — you can run each CTE
   independently to check its output.
*/


-- ============================================================
-- EXISTS — Does a Match Exist?
-- ============================================================
-- EXISTS is a special subquery that returns TRUE/FALSE.
-- It's faster than IN for large datasets.

-- Find companies that have at least one Data Engineer posting
SELECT
    cd.company_id,
    cd.name AS company_name
FROM company_dim AS cd
WHERE EXISTS (
    SELECT 1
    FROM job_postings_fact AS jpf
    WHERE jpf.company_id = cd.company_id
      AND jpf.job_title_short = 'Data Engineer'
)
LIMIT 10;

-- NOT EXISTS — find companies with NO Data Engineer postings
SELECT
    cd.company_id,
    cd.name AS company_name
FROM company_dim AS cd
WHERE NOT EXISTS (
    SELECT 1
    FROM job_postings_fact AS jpf
    WHERE jpf.company_id = cd.company_id
      AND jpf.job_title_short = 'Data Engineer'
)
LIMIT 10;


-- ============================================================
-- DERIVED TABLES (Subquery in FROM)
-- ============================================================
-- You can put a subquery in the FROM clause. It acts as
-- a temporary table.

SELECT
    title_stats.job_title_short,
    title_stats.avg_salary,
    title_stats.job_count
FROM (
    SELECT
        job_title_short,
        ROUND(AVG(salary_year_avg), 0) AS avg_salary,
        COUNT(*) AS job_count
    FROM job_postings_fact
    WHERE salary_year_avg IS NOT NULL
    GROUP BY job_title_short
) AS title_stats
WHERE title_stats.job_count > 100
ORDER BY title_stats.avg_salary DESC;

-- This is basically a CTE written inline. CTEs are almost
-- always more readable, but you'll see this pattern in older
-- SQL code.


-- ============================================================
-- REAL PATTERN: Incremental Analysis with CTEs
-- ============================================================
-- Here's how I use CTEs in actual data engineering work.
-- Each step transforms data a bit more.

WITH raw_data AS (
    -- Step 1: Get the base data we need
    SELECT
        jpf.job_id,
        jpf.job_title_short,
        jpf.salary_year_avg,
        jpf.job_posted_date,
        cd.name AS company_name
    FROM job_postings_fact AS jpf
    LEFT JOIN company_dim AS cd
        ON jpf.company_id = cd.company_id
    WHERE jpf.salary_year_avg IS NOT NULL
      AND jpf.job_title_short = 'Data Engineer'
),
monthly_stats AS (
    -- Step 2: Aggregate by month
    SELECT
        DATE_TRUNC('month', job_posted_date) AS month,
        COUNT(*) AS jobs_posted,
        ROUND(AVG(salary_year_avg), 0) AS avg_salary
    FROM raw_data
    GROUP BY DATE_TRUNC('month', job_posted_date)
)
-- Step 3: Final output
SELECT
    month,
    jobs_posted,
    avg_salary
FROM monthly_stats
ORDER BY month;


-- ============================================================
-- TRY THIS
-- ============================================================
-- 1. Use a subquery to find all jobs with salaries above
--    the median salary (MEDIAN function in DuckDB)
--
-- 2. Write a CTE that finds the top 10 skills by demand count,
--    then join it with salary data to see each skill's
--    average salary alongside its demand rank
--
-- 3. Use EXISTS to find skills that appear in Data Engineer
--    postings but NOT in Data Analyst postings
