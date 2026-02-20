-- ============================================================
-- LESSON 1.07: JOINs — Combining Tables
-- ============================================================
-- Real data lives in multiple tables. JOINs are how you
-- bring them together. This is one of the most important
-- things you'll ever learn in SQL.
--
-- If you only learn ONE thing well from this course, make
-- it JOINs. Every query in data engineering touches them.
-- ============================================================


-- ============================================================
-- WHY DO WE NEED JOINS?
-- ============================================================
-- Our data is split across tables:
--
--   job_postings_fact  → has company_id (just a number)
--   company_dim        → has company_id AND company name
--
-- To see the company NAME with the job posting, you need
-- to JOIN these tables together.
--
-- This is called "normalization" — data is split into
-- separate tables to avoid duplication. JOINs reconnect it.
-- ============================================================


-- ============================================================
-- INNER JOIN — Only Matching Rows
-- ============================================================
-- Returns rows that have a match in BOTH tables.
-- If a job posting has no matching company, it's excluded.
-- If a company has no job postings, it's excluded.

SELECT
    jpf.job_id,
    jpf.job_title_short,
    jpf.salary_year_avg,
    cd.name AS company_name
FROM job_postings_fact AS jpf
INNER JOIN company_dim AS cd
    ON jpf.company_id = cd.company_id
WHERE jpf.salary_year_avg IS NOT NULL
ORDER BY jpf.salary_year_avg DESC
LIMIT 10;

-- The ON clause says HOW the tables connect.
-- jpf.company_id = cd.company_id means "match rows where
-- the company_id is the same in both tables."


-- ============================================================
-- LEFT JOIN — All Left, Matching Right
-- ============================================================
-- Returns ALL rows from the left table (job_postings_fact),
-- plus matching rows from the right table (company_dim).
-- If there's no match, the right side columns are NULL.

SELECT
    jpf.job_id,
    jpf.job_title_short,
    cd.name AS company_name
FROM job_postings_fact AS jpf
LEFT JOIN company_dim AS cd
    ON jpf.company_id = cd.company_id
LIMIT 10;

-- LEFT JOIN is probably the one I use most. It's safe —
-- you don't lose rows from your main table even if the
-- lookup table is missing data.

-- To find rows with NO match (orphan records):
SELECT
    jpf.job_id,
    jpf.job_title,
    jpf.company_id
FROM job_postings_fact AS jpf
LEFT JOIN company_dim AS cd
    ON jpf.company_id = cd.company_id
WHERE cd.company_id IS NULL;
-- This finds job postings whose company doesn't exist in
-- the company table. Great for data quality checks.


-- ============================================================
-- RIGHT JOIN — All Right, Matching Left
-- ============================================================
-- The mirror of LEFT JOIN. All rows from the RIGHT table,
-- with matching rows from the left.

SELECT
    jpf.job_id,
    jpf.job_title_short,
    cd.company_id,
    cd.name AS company_name
FROM job_postings_fact AS jpf
RIGHT JOIN company_dim AS cd
    ON jpf.company_id = cd.company_id
LIMIT 10;

-- Honestly, I rarely use RIGHT JOIN. You can always rewrite
-- it as a LEFT JOIN by swapping the table order. Most people
-- find LEFT JOIN more intuitive.


-- ============================================================
-- FULL OUTER JOIN — Everything From Both
-- ============================================================
-- Returns ALL rows from BOTH tables. NULLs fill in wherever
-- there's no match on either side.

SELECT
    jpf.job_id,
    jpf.job_title_short,
    cd.company_id,
    cd.name AS company_name
FROM job_postings_fact AS jpf
FULL OUTER JOIN company_dim AS cd
    ON jpf.company_id = cd.company_id
LIMIT 10;

-- FULL OUTER JOIN is great for finding mismatches between
-- two tables — "what's in A but not B, and vice versa?"


-- ============================================================
-- THE JOIN CHEAT SHEET
-- ============================================================
/*
   Think of two tables A and B overlapping like a Venn diagram:

   INNER JOIN   → Only the overlap (matching rows in both)
   LEFT JOIN    → All of A + overlap
   RIGHT JOIN   → Overlap + all of B
   FULL JOIN    → All of A + overlap + all of B

   +--------+--------+
   |   A    | A ∩ B  |    B   |
   +--------+--------+--------+
   LEFT JOIN = A + A∩B
   RIGHT JOIN = A∩B + B
   INNER JOIN = A∩B only
   FULL JOIN = A + A∩B + B
*/


-- ============================================================
-- MULTI-TABLE JOINS
-- ============================================================
-- This is where things get real. In data engineering, you
-- often join 3, 4, even 5 tables together.

-- Join job postings → skills bridge → skills dimension
-- This gets us the actual skill NAMES for each job
SELECT
    jpf.job_id,
    jpf.job_title_short,
    sd.skills AS skill_name
FROM job_postings_fact AS jpf
INNER JOIN skills_job_dim AS sjd
    ON jpf.job_id = sjd.job_id
INNER JOIN skills_dim AS sd
    ON sjd.skill_id = sd.skill_id
LIMIT 20;

-- What happened:
-- 1. Start with job_postings_fact
-- 2. JOIN to the bridge table (skills_job_dim) to find
--    which skill_ids belong to each job
-- 3. JOIN to skills_dim to get the actual skill names

-- This is the STAR SCHEMA pattern — fact table in the center,
-- joined out to dimension tables through bridge tables.


-- Full query: jobs with company names AND skill names
SELECT
    jpf.job_id,
    jpf.job_title_short,
    cd.name AS company_name,
    sd.skills AS skill_name,
    jpf.salary_year_avg
FROM job_postings_fact AS jpf
INNER JOIN company_dim AS cd
    ON jpf.company_id = cd.company_id
INNER JOIN skills_job_dim AS sjd
    ON jpf.job_id = sjd.job_id
INNER JOIN skills_dim AS sd
    ON sjd.skill_id = sd.skill_id
WHERE jpf.salary_year_avg IS NOT NULL
ORDER BY jpf.salary_year_avg DESC
LIMIT 20;


-- ============================================================
-- SELF JOIN
-- ============================================================
-- A table joined to itself. Sounds weird, but it's useful
-- for comparing rows within the same table.

-- Compare each job's salary to the average salary for its title
SELECT
    a.job_id,
    a.job_title_short,
    a.salary_year_avg AS job_salary,
    ROUND(b.avg_salary, 0) AS title_avg_salary,
    ROUND(a.salary_year_avg - b.avg_salary, 0) AS diff_from_avg
FROM job_postings_fact AS a
INNER JOIN (
    SELECT
        job_title_short,
        AVG(salary_year_avg) AS avg_salary
    FROM job_postings_fact
    WHERE salary_year_avg IS NOT NULL
    GROUP BY job_title_short
) AS b
    ON a.job_title_short = b.job_title_short
WHERE a.salary_year_avg IS NOT NULL
ORDER BY diff_from_avg DESC
LIMIT 10;


-- ============================================================
-- CROSS JOIN
-- ============================================================
-- Every row from A combined with every row from B.
-- No ON condition. Produces a cartesian product.

-- If A has 10 rows and B has 5 rows, you get 50 rows.
-- Use with caution on large tables!

-- Generate all combinations of titles and locations
SELECT
    titles.job_title_short,
    locations.job_country
FROM (SELECT DISTINCT job_title_short FROM job_postings_fact) AS titles
CROSS JOIN (SELECT DISTINCT job_country FROM job_postings_fact LIMIT 5) AS locations
LIMIT 20;


-- ============================================================
-- JOIN GOTCHAS
-- ============================================================

-- 1. DUPLICATE ROWS
--    If table B has multiple matches for one row in A,
--    you'll get multiple rows in the output. This happens
--    with bridge tables — one job has many skills, so
--    joining creates one row per skill per job.

-- 2. ACCIDENTALLY MULTIPLYING ROWS
--    If you join on a non-unique column, you can accidentally
--    create way more rows than you expected. Always check
--    row counts before and after joins.

-- 3. THE IMPORTANCE OF THE ON CLAUSE
--    Forgetting the ON clause or using the wrong column
--    creates a CROSS JOIN (every row × every row). Your
--    query will either error out or return millions of rows.


-- ============================================================
-- TRY THIS
-- ============================================================
-- 1. LEFT JOIN job_postings_fact to company_dim and find
--    the top 10 companies by number of job postings
--
-- 2. Join all three tables (fact → bridge → skills) and find
--    the 10 most common skills mentioned across all postings
--
-- 3. Find companies that have jobs posted but where
--    company_dim has no matching record (orphan check)
