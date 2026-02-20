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
/*

┌─────────┬─────────────────────────────────────┬─────────────────┐
│ job_id  │              job_title              │ salary_year_avg │
│  int32  │               varchar               │     double      │
├─────────┼─────────────────────────────────────┼─────────────────┤
│  870113 │ Data Engineer - Hadoop              │         15000.0 │
│  752133 │ Data Engineer - Hadoop              │         15000.0 │
│ 1102607 │ Content Analyst                     │         15000.0 │
│  320963 │ Operations Analyst                  │         16500.0 │
│ 1598320 │ Data analytics                      │         16800.0 │
│ 1251749 │ Salesforce Data Specialist          │         17772.0 │
│ 1094624 │ Data Analyst/Engineer - 20305160609 │         18000.0 │
│ 1111592 │ Lead Data Engineer                  │         18000.0 │
│ 1583442 │ Data Analyst                        │         19000.0 │
│ 1254928 │ Consultant Engineer  -Paris         │         19200.0 │
├─────────┴─────────────────────────────────────┴─────────────────┤
│ 10 rows                                               3 columns │
└─────────────────────────────────────────────────────────────────┘
*/


-- Sort by salary, highest first
SELECT
    job_id,
    job_title,
    salary_year_avg
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
ORDER BY salary_year_avg DESC
LIMIT 10;
/*

┌─────────┬───────────────────────────────────────────────────────────────────────────────────────────────────────────────┬─────────────────┐
│ job_id  │                                                   job_title                                                   │ salary_year_avg │
│  int32  │                                                    varchar                                                    │     double      │
├─────────┼───────────────────────────────────────────────────────────────────────────────────────────────────────────────┼─────────────────┤
│  296745 │ Data Scientist                                                                                                │        960000.0 │
│ 1231950 │ Data Science Manager - Messaging and Inferred Identity DSE at Netflix in Los Gatos, California, United States │        920000.0 │
│  673003 │ Senior Data Scientist                                                                                         │        890000.0 │
│ 1575798 │ Machine Learning Engineer                                                                                     │        875000.0 │
│ 1007105 │ Machine Learning Engineer/Data Scientist                                                                      │        870000.0 │
│  856772 │ Data Scientist                                                                                                │        850000.0 │
│ 1591743 │ AI/ML (Artificial Intelligence/Machine Learning) Engineer                                                     │        800000.0 │
│ 1443865 │ Senior Data Engineer (MDM team), DTG                                                                          │        800000.0 │
│ 1574285 │ Data Scientist , Games [Remote]                                                                               │        680000.0 │
│  142665 │ Data Analyst                                                                                                  │        650000.0 │
├─────────┴───────────────────────────────────────────────────────────────────────────────────────────────────────────────┴─────────────────┤
│ 10 rows                                                                                                                         3 columns │
└───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

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
/*

┌──────────────────┬─────────────────┬─────────────────────┐
│ job_title_short  │ salary_year_avg │    job_location     │
│     varchar      │     double      │       varchar       │
├──────────────────┼─────────────────┼─────────────────────┤
│ Business Analyst │        390000.0 │ Russia              │
│ Business Analyst │        387460.0 │ San Mateo, CA       │
│ Business Analyst │        286000.0 │ Menlo, GA           │
│ Business Analyst │        268500.0 │ New York, NY        │
│ Business Analyst │        264000.0 │ Anywhere            │
│ Business Analyst │        264000.0 │ Anywhere            │
│ Business Analyst │        264000.0 │ Anywhere            │
│ Business Analyst │        257937.0 │ Albany, NY          │
│ Business Analyst │        257500.0 │ California          │
│ Business Analyst │        250000.0 │ Menlo Park, CA      │
│ Business Analyst │        250000.0 │ Anywhere            │
│ Business Analyst │        243500.0 │ Toronto, ON, Canada │
│ Business Analyst │        230000.0 │ Anywhere            │
│ Business Analyst │        229000.0 │ Anywhere            │
│ Business Analyst │        226000.0 │ San Francisco, CA   │
│ Business Analyst │        220000.0 │ Anywhere            │
│ Business Analyst │        220000.0 │ Laurel, MD          │
│ Business Analyst │        214500.0 │ Anywhere            │
│ Business Analyst │        214500.0 │ Anywhere            │
│ Business Analyst │        214000.0 │ Raritan, NJ         │
├──────────────────┴─────────────────┴─────────────────────┤
│ 20 rows                                        3 columns │
└──────────────────────────────────────────────────────────┘
*/


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
/*

┌──────────────────┬─────────────────┬─────────────────────┐
│ job_title_short  │ salary_year_avg │    job_location     │
│     varchar      │     double      │       varchar       │
├──────────────────┼─────────────────┼─────────────────────┤
│ Business Analyst │        390000.0 │ Russia              │
│ Business Analyst │        387460.0 │ San Mateo, CA       │
│ Business Analyst │        286000.0 │ Menlo, GA           │
│ Business Analyst │        268500.0 │ New York, NY        │
│ Business Analyst │        264000.0 │ Anywhere            │
│ Business Analyst │        264000.0 │ Anywhere            │
│ Business Analyst │        264000.0 │ Anywhere            │
│ Business Analyst │        257937.0 │ Albany, NY          │
│ Business Analyst │        257500.0 │ California          │
│ Business Analyst │        250000.0 │ Menlo Park, CA      │
│ Business Analyst │        250000.0 │ Anywhere            │
│ Business Analyst │        243500.0 │ Toronto, ON, Canada │
│ Business Analyst │        230000.0 │ Anywhere            │
│ Business Analyst │        229000.0 │ Anywhere            │
│ Business Analyst │        226000.0 │ San Francisco, CA   │
│ Business Analyst │        220000.0 │ Anywhere            │
│ Business Analyst │        220000.0 │ Laurel, MD          │
│ Business Analyst │        214500.0 │ Anywhere            │
│ Business Analyst │        214500.0 │ Anywhere            │
│ Business Analyst │        214000.0 │ San Francisco, CA   │
├──────────────────┴─────────────────┴─────────────────────┤
│ 20 rows                                        3 columns │
└──────────────────────────────────────────────────────────┘
*/


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
/*

┌───────────────────────────┬──────────┐
│           title           │  salary  │
│          varchar          │  double  │
├───────────────────────────┼──────────┤
│ Data Scientist            │ 960000.0 │
│ Data Scientist            │ 920000.0 │
│ Senior Data Scientist     │ 890000.0 │
│ Machine Learning Engineer │ 875000.0 │
│ Data Scientist            │ 870000.0 │
│ Data Scientist            │ 850000.0 │
│ Senior Data Engineer      │ 800000.0 │
│ Machine Learning Engineer │ 800000.0 │
│ Data Scientist            │ 680000.0 │
│ Data Analyst              │ 650000.0 │
├───────────────────────────┴──────────┤
│ 10 rows                    2 columns │
└──────────────────────────────────────┘
*/


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
/*

┌─────────┬───────────────────────────────────────────────────────────────────────────────────────────────────────────────┬─────────────────┐
│ job_id  │                                                   job_title                                                   │ salary_year_avg │
│  int32  │                                                    varchar                                                    │     double      │
├─────────┼───────────────────────────────────────────────────────────────────────────────────────────────────────────────┼─────────────────┤
│  296745 │ Data Scientist                                                                                                │        960000.0 │
│ 1231950 │ Data Science Manager - Messaging and Inferred Identity DSE at Netflix in Los Gatos, California, United States │        920000.0 │
│  673003 │ Senior Data Scientist                                                                                         │        890000.0 │
│ 1575798 │ Machine Learning Engineer                                                                                     │        875000.0 │
│ 1007105 │ Machine Learning Engineer/Data Scientist                                                                      │        870000.0 │
│  856772 │ Data Scientist                                                                                                │        850000.0 │
│ 1443865 │ Senior Data Engineer (MDM team), DTG                                                                          │        800000.0 │
│ 1591743 │ AI/ML (Artificial Intelligence/Machine Learning) Engineer                                                     │        800000.0 │
│ 1574285 │ Data Scientist , Games [Remote]                                                                               │        680000.0 │
│  142665 │ Data Analyst                                                                                                  │        650000.0 │
├─────────┴───────────────────────────────────────────────────────────────────────────────────────────────────────────────┴─────────────────┤
│ 10 rows                                                                                                                         3 columns │
└───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
-- This sorts by monthly salary even though we only show annual salary.


-- ============================================================
-- LIMIT & OFFSET — Paging Through Results
-- ============================================================

-- First 10 results
SELECT
    job_id,
    job_title
FROM job_postings_fact
LIMIT 10;
/*

┌────────┬───────────────────────────────────────────┐
│ job_id │                 job_title                 │
│ int32  │                  varchar                  │
├────────┼───────────────────────────────────────────┤
│   4593 │ Data Analyst                              │
│   4594 │ Data Analyst                              │
│   4595 │ Data Analyst                              │
│   4596 │ Senior Data Analyst / Platform Experience │
│   4597 │ Data Analyst                              │
│   4598 │ Jr. Data Analyst                          │
│   4599 │ Data Analyst                              │
│   4600 │ Loyalty Data Analyst III                  │
│   4601 │ Senior data analyst                       │
│   4602 │ Business Analyst - Taxonomy/Ontology      │
├────────┴───────────────────────────────────────────┤
│ 10 rows                                  2 columns │
└────────────────────────────────────────────────────┘
*/

-- Skip the first 10, then show the next 10
SELECT
    job_id,
    job_title
FROM job_postings_fact
LIMIT 10
OFFSET 10;
/*

┌────────┬───────────────────────────────────────────────────────────┐
│ job_id │                         job_title                         │
│ int32  │                          varchar                          │
├────────┼───────────────────────────────────────────────────────────┤
│   4603 │ Technical Data Analyst / Designer -- 2207/2000            │
│   4604 │ Neuroscience Research Data Analyst                        │
│   4605 │ Data Analyst                                              │
│   4606 │ BI Data Analyst                                           │
│   4607 │ EDI Data Analyst                                          │
│   4608 │ Data Analyst for Member Contact Center                    │
│   4609 │ BI Data Analyst                                           │
│   4610 │ Data Analyst, Partner Operations (Ecosystem Partnerships) │
│   4611 │ Guidewire Policy Data Analyst                             │
│   4612 │ Sr. Data Analyst                                          │
├────────┴───────────────────────────────────────────────────────────┤
│ 10 rows                                                  2 columns │
└────────────────────────────────────────────────────────────────────┘
*/

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
/*

┌─────────┬───────────────────────────────────────────────────────────────────────────────────────────────────────────────┬─────────────────┐
│ job_id  │                                                   job_title                                                   │ salary_year_avg │
│  int32  │                                                    varchar                                                    │     double      │
├─────────┼───────────────────────────────────────────────────────────────────────────────────────────────────────────────┼─────────────────┤
│  296745 │ Data Scientist                                                                                                │        960000.0 │
│ 1231950 │ Data Science Manager - Messaging and Inferred Identity DSE at Netflix in Los Gatos, California, United States │        920000.0 │
│  673003 │ Senior Data Scientist                                                                                         │        890000.0 │
│ 1575798 │ Machine Learning Engineer                                                                                     │        875000.0 │
│ 1007105 │ Machine Learning Engineer/Data Scientist                                                                      │        870000.0 │
└─────────┴───────────────────────────────────────────────────────────────────────────────────────────────────────────────┴─────────────────┘
*/
-- This is the classic "top-N" pattern: filter, sort by a metric, and limit to the top N results.

-- Top 10 most recent job postings
SELECT
    job_id,
    job_title,
    job_posted_date
FROM job_postings_fact
ORDER BY job_posted_date DESC
LIMIT 10;
/*

┌─────────┬───────────────────────────────────────────────────────────────────────────────────────────────────┬─────────────────────┐
│ job_id  │                                             job_title                                             │   job_posted_date   │
│  int32  │                                              varchar                                              │      timestamp      │
├─────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┼─────────────────────┤
│ 1620522 │ Principal Data Scientist- Entity/ID Resolution & Recommender Systems                              │ 2025-06-30 07:16:42 │
│ 1620521 │ Junior Data Analyst / Developer, Nature for Water Facility                                        │ 2025-06-30 07:12:09 │
│ 1620520 │ Data Analyst - Moldova                                                                            │ 2025-06-30 07:11:10 │
│ 1620519 │ DATA ENGINEER                                                                                     │ 2025-06-30 07:11:05 │
│ 1620518 │ Tutor-Reviewer For Data Science Program                                                           │ 2025-06-30 07:08:26 │
│ 1620516 │ Senior Data Scientist                                                                             │ 2025-06-30 07:07:45 │
│ 1620517 │ Data Science Manager                                                                              │ 2025-06-30 07:07:45 │
│ 1620515 │ Systems Assurance and Data Analytics Engineer                                                     │ 2025-06-30 07:02:42 │
│ 1620513 │ Data Analyst/ Compliance Analytics & Monitoring Officer (Transaction Monitoring, AML/CTF) (f/m/d) │ 2025-06-30 07:00:45 │
│ 1620514 │ Data Analyst                                                                                      │ 2025-06-30 07:00:45 │
├─────────┴───────────────────────────────────────────────────────────────────────────────────────────────────┴─────────────────────┤
│ 10 rows                                                                                                                 3 columns │
└───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
-- This is the same pattern but sorted by date instead of salary.

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
/*

┌────────┬───────────────────────────────────────────┬─────────────────┐
│ job_id │                 job_title                 │ salary_year_avg │
│ int32  │                  varchar                  │     double      │
├────────┼───────────────────────────────────────────┼─────────────────┤
│   4593 │ Data Analyst                              │            NULL │
│   4594 │ Data Analyst                              │            NULL │
│   4595 │ Data Analyst                              │            NULL │
│   4596 │ Senior Data Analyst / Platform Experience │            NULL │
│   4597 │ Data Analyst                              │            NULL │
│   4598 │ Jr. Data Analyst                          │            NULL │
│   4599 │ Data Analyst                              │            NULL │
│   4600 │ Loyalty Data Analyst III                  │            NULL │
│   4601 │ Senior data analyst                       │            NULL │
│   4602 │ Business Analyst - Taxonomy/Ontology      │            NULL │
├────────┴───────────────────────────────────────────┴─────────────────┤
│ 10 rows                                                    3 columns │
└──────────────────────────────────────────────────────────────────────┘    
*/
-- This puts all the NULL salaries at the top, even though it's ASC.

-- Put NULLs last (even in descending order)
SELECT
    job_id,
    job_title,
    salary_year_avg
FROM job_postings_fact
ORDER BY salary_year_avg DESC NULLS LAST
LIMIT 10;
/*

┌─────────┬───────────────────────────────────────────────────────────────────────────────────────────────────────────────┬─────────────────┐
│ job_id  │                                                   job_title                                                   │ salary_year_avg │
│  int32  │                                                    varchar                                                    │     double      │
├─────────┼───────────────────────────────────────────────────────────────────────────────────────────────────────────────┼─────────────────┤
│  296745 │ Data Scientist                                                                                                │        960000.0 │
│ 1231950 │ Data Science Manager - Messaging and Inferred Identity DSE at Netflix in Los Gatos, California, United States │        920000.0 │
│  673003 │ Senior Data Scientist                                                                                         │        890000.0 │
│ 1575798 │ Machine Learning Engineer                                                                                     │        875000.0 │
│ 1007105 │ Machine Learning Engineer/Data Scientist                                                                      │        870000.0 │
│  856772 │ Data Scientist                                                                                                │        850000.0 │
│ 1443865 │ Senior Data Engineer (MDM team), DTG                                                                          │        800000.0 │
│ 1591743 │ AI/ML (Artificial Intelligence/Machine Learning) Engineer                                                     │        800000.0 │
│ 1574285 │ Data Scientist , Games [Remote]                                                                               │        680000.0 │
│  142665 │ Data Analyst                                                                                                  │        650000.0 │
├─────────┴───────────────────────────────────────────────────────────────────────────────────────────────────────────────┴─────────────────┤
│ 10 rows                                                                                                                         3 columns │
└───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

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
