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
/*

┌─────────┬───────────────────────────┬─────────────────┬─────────────────────────────────────────────┐
│ job_id  │      job_title_short      │ salary_year_avg │                company_name                 │
│  int32  │          varchar          │     double      │                   varchar                   │
├─────────┼───────────────────────────┼─────────────────┼─────────────────────────────────────────────┤
│  296745 │ Data Scientist            │        960000.0 │ East River Electric Power Cooperative, Inc. │
│ 1231950 │ Data Scientist            │        920000.0 │ Netflix                                     │
│  673003 │ Senior Data Scientist     │        890000.0 │ MSP Staffing  LTD                           │
│ 1575798 │ Machine Learning Engineer │        875000.0 │ KesarWeb                                    │
│ 1007105 │ Data Scientist            │        870000.0 │ Goldman Tech Resourcing                     │
│  856772 │ Data Scientist            │        850000.0 │ 3G HR SERVICES                              │
│ 1443865 │ Senior Data Engineer      │        800000.0 │ Pure Storage                                │
│ 1591743 │ Machine Learning Engineer │        800000.0 │ Health Information Systems Program          │
│ 1574285 │ Data Scientist            │        680000.0 │ Netflix                                     │
│  142665 │ Data Analyst              │        650000.0 │ Mantys                                      │
├─────────┴───────────────────────────┴─────────────────┴─────────────────────────────────────────────┤
│ 10 rows                                                                                   4 columns │
└─────────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

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
/*

┌────────┬─────────────────────┬────────────────────────┐
│ job_id │   job_title_short   │      company_name      │
│ int32  │       varchar       │        varchar         │
├────────┼─────────────────────┼────────────────────────┤
│   4593 │ Data Analyst        │ Metasys Technologies   │
│   4594 │ Data Analyst        │ Guidehouse             │
│   4595 │ Data Analyst        │ Protask                │
│   4596 │ Senior Data Analyst │ Atria Wealth Solutions │
│   4597 │ Data Analyst        │ ICONMA, LLC            │
│   4598 │ Data Analyst        │ Aquent                 │
│   4599 │ Data Analyst        │ Adyen                  │
│   4600 │ Data Analyst        │ Albertsons Companies   │
│   4601 │ Senior Data Analyst │ Panda Restaurant Group │
│   4602 │ Business Analyst    │ Diverse Lynx           │
├────────┴─────────────────────┴────────────────────────┤
│ 10 rows                                     3 columns │
└───────────────────────────────────────────────────────┘
*/

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
/*
┌────────┬───────────┬────────────┐
│ job_id │ job_title │ company_id │
│ int32  │  varchar  │   int32    │
├────────┴───────────┴────────────┤
│             0 rows              │
└─────────────────────────────────┘
*/
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
/*

┌────────┬─────────────────────┬────────────┬────────────────────────┐
│ job_id │   job_title_short   │ company_id │      company_name      │
│ int32  │       varchar       │   int32    │        varchar         │
├────────┼─────────────────────┼────────────┼────────────────────────┤
│   4593 │ Data Analyst        │       4593 │ Metasys Technologies   │
│   4594 │ Data Analyst        │       4594 │ Guidehouse             │
│   4595 │ Data Analyst        │       4595 │ Protask                │
│   4596 │ Senior Data Analyst │       4596 │ Atria Wealth Solutions │
│   4597 │ Data Analyst        │       4597 │ ICONMA, LLC            │
│   4598 │ Data Analyst        │       4598 │ Aquent                 │
│   4599 │ Data Analyst        │       4599 │ Adyen                  │
│   4600 │ Data Analyst        │       4600 │ Albertsons Companies   │
│   4601 │ Senior Data Analyst │       4601 │ Panda Restaurant Group │
│   4602 │ Business Analyst    │       4602 │ Diverse Lynx           │
├────────┴─────────────────────┴────────────┴────────────────────────┤
│ 10 rows                                                  4 columns │
└────────────────────────────────────────────────────────────────────┘
*/

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
/*

┌────────┬─────────────────────┬────────────┬────────────────────────┐
│ job_id │   job_title_short   │ company_id │      company_name      │
│ int32  │       varchar       │   int32    │        varchar         │
├────────┼─────────────────────┼────────────┼────────────────────────┤
│   4593 │ Data Analyst        │       4593 │ Metasys Technologies   │
│   4594 │ Data Analyst        │       4594 │ Guidehouse             │
│   4595 │ Data Analyst        │       4595 │ Protask                │
│   4596 │ Senior Data Analyst │       4596 │ Atria Wealth Solutions │
│   4597 │ Data Analyst        │       4597 │ ICONMA, LLC            │
│   4598 │ Data Analyst        │       4598 │ Aquent                 │
│   4599 │ Data Analyst        │       4599 │ Adyen                  │
│   4600 │ Data Analyst        │       4600 │ Albertsons Companies   │
│   4601 │ Senior Data Analyst │       4601 │ Panda Restaurant Group │
│   4602 │ Business Analyst    │       4602 │ Diverse Lynx           │
├────────┴─────────────────────┴────────────┴────────────────────────┤
│ 10 rows                                                  4 columns │
└────────────────────────────────────────────────────────────────────┘
*/
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
/*

┌────────┬─────────────────────┬────────────┐
│ job_id │   job_title_short   │ skill_name │
│ int32  │       varchar       │  varchar   │
├────────┼─────────────────────┼────────────┤
│   4593 │ Data Analyst        │ sql        │
│   4594 │ Data Analyst        │ sql        │
│   4594 │ Data Analyst        │ python     │
│   4594 │ Data Analyst        │ r          │
│   4595 │ Data Analyst        │ sql        │
│   4596 │ Senior Data Analyst │ sql        │
│   4597 │ Data Analyst        │ sql        │
│   4597 │ Data Analyst        │ python     │
│   4599 │ Data Analyst        │ r          │
│   4599 │ Data Analyst        │ python     │
│   4599 │ Data Analyst        │ sql        │
│   4600 │ Data Analyst        │ sql        │
│   4600 │ Data Analyst        │ python     │
│   4600 │ Data Analyst        │ r          │
│   4604 │ Data Analyst        │ go         │
│   4604 │ Data Analyst        │ python     │
│   4604 │ Data Analyst        │ matlab     │
│   4607 │ Data Analyst        │ sql        │
│   4607 │ Data Analyst        │ crystal    │
│   4610 │ Data Analyst        │ sql        │
├────────┴─────────────────────┴────────────┤
│ 20 rows                         3 columns │
└───────────────────────────────────────────┘
*/

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
/*

┌────────┬───────────────────────┬─────────────────────────────────────────────┬────────────┬─────────────────┐
│ job_id │    job_title_short    │                company_name                 │ skill_name │ salary_year_avg │
│ int32  │        varchar        │                   varchar                   │  varchar   │     double      │
├────────┼───────────────────────┼─────────────────────────────────────────────┼────────────┼─────────────────┤
│ 296745 │ Data Scientist        │ East River Electric Power Cooperative, Inc. │ c++        │        960000.0 │
│ 296745 │ Data Scientist        │ East River Electric Power Cooperative, Inc. │ java       │        960000.0 │
│ 296745 │ Data Scientist        │ East River Electric Power Cooperative, Inc. │ r          │        960000.0 │
│ 296745 │ Data Scientist        │ East River Electric Power Cooperative, Inc. │ python     │        960000.0 │
│ 673003 │ Senior Data Scientist │ MSP Staffing  LTD                           │ docker     │        890000.0 │
│ 673003 │ Senior Data Scientist │ MSP Staffing  LTD                           │ linux      │        890000.0 │
│ 673003 │ Senior Data Scientist │ MSP Staffing  LTD                           │ keras      │        890000.0 │
│ 673003 │ Senior Data Scientist │ MSP Staffing  LTD                           │ plotly     │        890000.0 │
│ 673003 │ Senior Data Scientist │ MSP Staffing  LTD                           │ matplotlib │        890000.0 │
│ 673003 │ Senior Data Scientist │ MSP Staffing  LTD                           │ azure      │        890000.0 │
│ 673003 │ Senior Data Scientist │ MSP Staffing  LTD                           │ pyspark    │        890000.0 │
│ 673003 │ Senior Data Scientist │ MSP Staffing  LTD                           │ pandas     │        890000.0 │
│ 673003 │ Senior Data Scientist │ MSP Staffing  LTD                           │ pytorch    │        890000.0 │
│ 673003 │ Senior Data Scientist │ MSP Staffing  LTD                           │ databricks │        890000.0 │
│ 673003 │ Senior Data Scientist │ MSP Staffing  LTD                           │ java       │        890000.0 │
│ 673003 │ Senior Data Scientist │ MSP Staffing  LTD                           │ c#         │        890000.0 │
│ 673003 │ Senior Data Scientist │ MSP Staffing  LTD                           │ kubernetes │        890000.0 │
│ 673003 │ Senior Data Scientist │ MSP Staffing  LTD                           │ git        │        890000.0 │
│ 673003 │ Senior Data Scientist │ MSP Staffing  LTD                           │ sql        │        890000.0 │
│ 673003 │ Senior Data Scientist │ MSP Staffing  LTD                           │ python     │        890000.0 │
├────────┴───────────────────────┴─────────────────────────────────────────────┴────────────┴─────────────────┤
│ 20 rows                                                                                           5 columns │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

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
/*

┌─────────┬───────────────────────────┬────────────┬──────────────────┬───────────────┐
│ job_id  │      job_title_short      │ job_salary │ title_avg_salary │ diff_from_avg │
│  int32  │          varchar          │   double   │      double      │    double     │
├─────────┼───────────────────────────┼────────────┼──────────────────┼───────────────┤
│  296745 │ Data Scientist            │   960000.0 │         134324.0 │      825676.0 │
│ 1231950 │ Data Scientist            │   920000.0 │         134324.0 │      785676.0 │
│ 1575798 │ Machine Learning Engineer │   875000.0 │         137332.0 │      737668.0 │
│ 1007105 │ Data Scientist            │   870000.0 │         134324.0 │      735676.0 │
│  673003 │ Senior Data Scientist     │   890000.0 │         156391.0 │      733609.0 │
│  856772 │ Data Scientist            │   850000.0 │         134324.0 │      715676.0 │
│ 1591743 │ Machine Learning Engineer │   800000.0 │         137332.0 │      662668.0 │
│ 1443865 │ Senior Data Engineer      │   800000.0 │         149222.0 │      650778.0 │
│  142665 │ Data Analyst              │   650000.0 │          93223.0 │      556777.0 │
│ 1574285 │ Data Scientist            │   680000.0 │         134324.0 │      545676.0 │
├─────────┴───────────────────────────┴────────────┴──────────────────┴───────────────┤
│ 10 rows                                                                   5 columns │
└─────────────────────────────────────────────────────────────────────────────────────┘
*/
-- This compares each job's salary to the average for that title.
-- The subquery (aliased as b) calculates the average salary
-- for each job title, and then we join it back to the main table
-- to compare.

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
/*

┌───────────────────────────┬─────────────┐
│      job_title_short      │ job_country │
│          varchar          │   varchar   │
├───────────────────────────┼─────────────┤
│ Data Engineer             │ Ecuador     │
│ Data Engineer             │ Argentina   │
│ Data Engineer             │ Slovakia    │
│ Data Engineer             │ Norway      │
│ Data Engineer             │ New Zealand │
│ Senior Data Analyst       │ Ecuador     │
│ Senior Data Analyst       │ Argentina   │
│ Senior Data Analyst       │ Slovakia    │
│ Senior Data Analyst       │ Norway      │
│ Senior Data Analyst       │ New Zealand │
│ Machine Learning Engineer │ Ecuador     │
│ Machine Learning Engineer │ Argentina   │
│ Machine Learning Engineer │ Slovakia    │
│ Machine Learning Engineer │ Norway      │
│ Machine Learning Engineer │ New Zealand │
│ Cloud Engineer            │ Ecuador     │
│ Cloud Engineer            │ Argentina   │
│ Cloud Engineer            │ Slovakia    │
│ Cloud Engineer            │ Norway      │
│ Cloud Engineer            │ New Zealand │
├───────────────────────────┴─────────────┤
│ 20 rows                       2 columns │
└─────────────────────────────────────────┘
*/
-- CROSS JOIN is rarely used in data engineering, but it can
-- be useful for generating combinations or doing certain types of analysis.


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
