-- ============================================================
-- LESSON 1.03: WHERE — Filtering Data
-- ============================================================
-- SELECT gets columns. WHERE picks which ROWS you want.
-- If SELECT is "what do I want to see?" then WHERE is
-- "which records do I care about?"
-- ============================================================


-- ============================================================
-- BASIC COMPARISONS
-- ============================================================

-- Jobs in a specific location
SELECT
    job_id,
    job_title,
    job_location
FROM job_postings_fact
WHERE job_location = 'New York, NY'
LIMIT 10;
/*

┌────────┬──────────────────────────────────────────────────────────────┬──────────────┐
│ job_id │                          job_title                           │ job_location │
│ int32  │                           varchar                            │   varchar    │
├────────┼──────────────────────────────────────────────────────────────┼──────────────┤
│   4593 │ Data Analyst                                                 │ New York, NY │
│   4638 │ Marketing & Growth Data scientist                            │ New York, NY │
│   4796 │ Analytics & Data Science Data Engineer-NYC/Bridgewater, NJ   │ New York, NY │
│   4850 │ Data Engineer - 2568                                         │ New York, NY │
│   4967 │ Lead Applied Data Scientist                                  │ New York, NY │
│   4971 │ Instructor, Data Science                                     │ New York, NY │
│   5577 │ Senior Data Scientist - Now Hiring                           │ New York, NY │
│   5772 │ NYL Data Scientist/Statistician Internship                   │ New York, NY │
│   5867 │ Data Scientist / Machine Learning Engineer - Now Hiring      │ New York, NY │
│   5881 │ Software Engineer, Data Engineering, Ad Platform Engineering │ New York, NY │
├────────┴──────────────────────────────────────────────────────────────┴──────────────┤
│ 10 rows                                                                    3 columns │
└──────────────────────────────────────────────────────────────────────────────────────┘
*/


-- Jobs with salary above 150k
SELECT
    job_id,
    job_title,
    salary_year_avg
FROM job_postings_fact
WHERE salary_year_avg > 150000
LIMIT 10;
/*

┌────────┬───────────────────────────────────────────────────────────────────┬─────────────────┐
│ job_id │                             job_title                             │ salary_year_avg │
│ int32  │                              varchar                              │     double      │
├────────┼───────────────────────────────────────────────────────────────────┼─────────────────┤
│   4846 │ Data Engineer - Revenue Platforms                                 │        300000.0 │
│   5326 │ Staff Data Scientist                                              │        202500.0 │
│   5330 │ Data Engineer                                                     │        165000.0 │
│   5369 │ Data Engineer - Spark, Scala, Kafka, Flink                        │        175000.0 │
│   5578 │ Director, Data Science                                            │        175000.0 │
│   6351 │ Data Engineer                                                     │        165000.0 │
│   8506 │ Sr. Marketing Data Analyst                                        │        170000.0 │
│   8510 │ Data Scientist/Engineer - Bay Area Startup with GREAT benefits    │        210000.0 │
│   8698 │ Sr. Manager, Data Science - Corporate Audit and Security Services │        222589.0 │
│   8844 │ AIML - Sr Data Science Manager, AIML Data                         │        175000.0 │
├────────┴───────────────────────────────────────────────────────────────────┴─────────────────┤
│ 10 rows                                                                            3 columns │
└──────────────────────────────────────────────────────────────────────────────────────────────┘
*/

-- Comparison operators:
--   =    equal to
--   !=   not equal to (some databases use <>)
--   >    greater than
--   <    less than
--   >=   greater than or equal to
--   <=   less than or equal to


-- ============================================================
-- AND / OR — Combining Conditions
-- ============================================================

-- AND = both conditions must be true
SELECT
    job_id,
    job_title_short,
    salary_year_avg,
    job_location
FROM job_postings_fact
WHERE job_title_short = 'Data Engineer'
  AND salary_year_avg > 120000
LIMIT 10;
/*

┌────────┬─────────────────┬─────────────────┬───────────────────┐
│ job_id │ job_title_short │ salary_year_avg │   job_location    │
│ int32  │     varchar     │     double      │      varchar      │
├────────┼─────────────────┼─────────────────┼───────────────────┤
│   4846 │ Data Engineer   │        300000.0 │ Boston, NY        │
│   5330 │ Data Engineer   │        165000.0 │ Arlington, VA     │
│   5369 │ Data Engineer   │        175000.0 │ San Jose, CA      │
│   6351 │ Data Engineer   │        165000.0 │ Dearborn, MI      │
│   8474 │ Data Engineer   │        144481.5 │ St. Louis, MO     │
│   8720 │ Data Engineer   │        125000.0 │ Goleta, CA        │
│   8830 │ Data Engineer   │        125000.0 │ San Francisco, CA │
│   9580 │ Data Engineer   │        150000.0 │ Beaverton, OR     │
│   9936 │ Data Engineer   │        123600.0 │ Goodyear, AZ      │
│  10116 │ Data Engineer   │        123600.0 │ Glendale, AZ      │
├────────┴─────────────────┴─────────────────┴───────────────────┤
│ 10 rows                                              4 columns │
└────────────────────────────────────────────────────────────────┘
*/

-- OR = at least one condition must be true
SELECT
    job_id,
    job_title_short,
    job_location
FROM job_postings_fact
WHERE job_title_short = 'Data Engineer'
   OR job_title_short = 'Data Scientist'
LIMIT 10;
/*

┌────────┬─────────────────┬────────────────┐
│ job_id │ job_title_short │  job_location  │
│ int32  │     varchar     │    varchar     │
├────────┼─────────────────┼────────────────┤
│   4618 │ Data Engineer   │ Austin, TX     │
│   4638 │ Data Scientist  │ New York, NY   │
│   4639 │ Data Scientist  │ Anywhere       │
│   4640 │ Data Scientist  │ Vienna, VA     │
│   4641 │ Data Scientist  │ Washington, DC │
│   4642 │ Data Scientist  │ Edison, NJ     │
│   4643 │ Data Scientist  │ Raritan, NJ    │
│   4644 │ Data Scientist  │ Anywhere       │
│   4646 │ Data Scientist  │ Washington, DC │
│   4647 │ Data Scientist  │ Cambridge, MA  │
├────────┴─────────────────┴────────────────┤
│ 10 rows                         3 columns │
└───────────────────────────────────────────┘
*/

-- Combining AND + OR (use parentheses to be clear!)
SELECT
    job_id,
    job_title_short,
    salary_year_avg,
    job_work_from_home
FROM job_postings_fact
WHERE (job_title_short = 'Data Engineer'
       OR job_title_short = 'Data Analyst')
  AND salary_year_avg > 100000
LIMIT 10;
/*
┌────────┬─────────────────┬─────────────────┬────────────────────┐
│ job_id │ job_title_short │ salary_year_avg │ job_work_from_home │
│ int32  │     varchar     │     double      │      boolean       │
├────────┼─────────────────┼─────────────────┼────────────────────┤
│   4846 │ Data Engineer   │        300000.0 │ false              │
│   5330 │ Data Engineer   │        165000.0 │ false              │
│   5369 │ Data Engineer   │        175000.0 │ false              │
│   6351 │ Data Engineer   │        165000.0 │ false              │
│   8474 │ Data Engineer   │        144481.5 │ false              │
│   8720 │ Data Engineer   │        125000.0 │ false              │
│   8830 │ Data Engineer   │        125000.0 │ false              │
│   8841 │ Data Analyst    │        103781.0 │ false              │
│   9006 │ Data Analyst    │        111202.0 │ false              │
│   9059 │ Data Analyst    │        100500.0 │ false              │
├────────┴─────────────────┴─────────────────┴────────────────────┤
│ 10 rows                                               4 columns │
└─────────────────────────────────────────────────────────────────┘
*/  


-- Without parentheses, AND has higher precedence than OR.
-- This can give you unexpected results. Always use parentheses
-- when mixing AND and OR. Learned this the hard way.


-- ============================================================
-- IN — Cleaner Alternative to Multiple ORs
-- ============================================================

-- Instead of:
--   WHERE title = 'A' OR title = 'B' OR title = 'C'
-- You can write:

SELECT
    job_id,
    job_title_short,
    job_location
FROM job_postings_fact
WHERE job_title_short IN ('Data Engineer', 'Data Scientist', 'Data Analyst')
LIMIT 10;
/*

┌────────┬─────────────────┬────────────────────┐
│ job_id │ job_title_short │    job_location    │
│ int32  │     varchar     │      varchar       │
├────────┼─────────────────┼────────────────────┤
│   4593 │ Data Analyst    │ New York, NY       │
│   4594 │ Data Analyst    │ Washington, DC     │
│   4595 │ Data Analyst    │ Fairfax, VA        │
│   4597 │ Data Analyst    │ Sunnyvale, CA      │
│   4598 │ Data Analyst    │ Torrance, CA       │
│   4599 │ Data Analyst    │ San Francisco, CA  │
│   4600 │ Data Analyst    │ Pleasanton, CA     │
│   4603 │ Data Analyst    │ Vandenberg AFB, CA │
│   4604 │ Data Analyst    │ Stanford, CA       │
│   4605 │ Data Analyst    │ Irvine, CA         │
├────────┴─────────────────┴────────────────────┤
│ 10 rows                             3 columns │
└───────────────────────────────────────────────┘
*/

-- NOT IN — everything EXCEPT these
SELECT
    job_id,
    job_title_short
FROM job_postings_fact
WHERE job_title_short NOT IN ('Data Engineer', 'Data Scientist')
LIMIT 10;
/*

┌────────┬─────────────────────┐
│ job_id │   job_title_short   │
│ int32  │       varchar       │
├────────┼─────────────────────┤
│   4593 │ Data Analyst        │
│   4594 │ Data Analyst        │
│   4595 │ Data Analyst        │
│   4596 │ Senior Data Analyst │
│   4597 │ Data Analyst        │
│   4598 │ Data Analyst        │
│   4599 │ Data Analyst        │
│   4600 │ Data Analyst        │
│   4601 │ Senior Data Analyst │
│   4602 │ Business Analyst    │
├────────┴─────────────────────┤
│ 10 rows            2 columns │
└──────────────────────────────┘
*/


-- IN is one of those things that makes SQL so much cleaner.
-- Use it whenever you're checking against a list of values.


-- ============================================================
-- BETWEEN — Range Filtering
-- ============================================================

-- Salary between 100k and 150k (inclusive on both ends)
SELECT
    job_id,
    job_title,
    salary_year_avg
FROM job_postings_fact
WHERE salary_year_avg BETWEEN 100000 AND 150000
LIMIT 10;
/*

┌────────┬────────────────────────────────────────────────────┬─────────────────┐
│ job_id │                     job_title                      │ salary_year_avg │
│ int32  │                      varchar                       │     double      │
├────────┼────────────────────────────────────────────────────┼─────────────────┤
│   4651 │ Data Scientist                                     │        110000.0 │
│   4833 │ Lead Data Scientist (Hybrid)                       │        120531.0 │
│   5123 │ Data Science Manager                               │        133500.0 │
│   5325 │ Data Scientist                                     │        125000.0 │
│   5333 │ Senior Data Engineer                               │        105000.0 │
│   6440 │ Marketing Data Scientist                           │        113000.0 │
│   6585 │ Lead Scientist, Data Science - Remote (Dallas, TX) │        129982.0 │
│   6629 │ Senior Data Engineer                               │        137150.0 │
│   8469 │ Data Scientist                                     │        123500.0 │
│   8474 │ Data Engineer                                      │        144481.5 │
├────────┴────────────────────────────────────────────────────┴─────────────────┤
│ 10 rows                                                             3 columns │
└───────────────────────────────────────────────────────────────────────────────┘
*/


-- Same as writing:
--   WHERE salary_year_avg >= 100000 AND salary_year_avg <= 150000
-- But BETWEEN is cleaner.

-- Works with dates too
SELECT
    job_id,
    job_title,
    job_posted_date
FROM job_postings_fact
WHERE job_posted_date BETWEEN '2023-01-01' AND '2023-03-31'
LIMIT 10;

/*

┌────────┬───────────────────────────────────────────┬─────────────────────┐
│ job_id │                 job_title                 │   job_posted_date   │
│ int32  │                  varchar                  │      timestamp      │
├────────┼───────────────────────────────────────────┼─────────────────────┤
│   4593 │ Data Analyst                              │ 2023-01-01 00:00:04 │
│   4594 │ Data Analyst                              │ 2023-01-01 00:00:22 │
│   4595 │ Data Analyst                              │ 2023-01-01 00:00:24 │
│   4596 │ Senior Data Analyst / Platform Experience │ 2023-01-01 00:00:27 │
│   4597 │ Data Analyst                              │ 2023-01-01 00:00:38 │
│   4598 │ Jr. Data Analyst                          │ 2023-01-01 00:00:38 │
│   4599 │ Data Analyst                              │ 2023-01-01 00:00:43 │
│   4600 │ Loyalty Data Analyst III                  │ 2023-01-01 00:00:51 │
│   4601 │ Senior data analyst                       │ 2023-01-01 00:00:57 │
│   4602 │ Business Analyst - Taxonomy/Ontology      │ 2023-01-01 00:00:57 │
├────────┴───────────────────────────────────────────┴─────────────────────┤
│ 10 rows                                                        3 columns │
└──────────────────────────────────────────────────────────────────────────┘
*/

-- ============================================================
-- LIKE — Pattern Matching on Text
-- ============================================================
-- Two wildcards:
--   %  = any number of characters (including zero)
--   _  = exactly one character

-- Job titles that START with "Senior"
SELECT
    job_id,
    job_title
FROM job_postings_fact
WHERE job_title LIKE 'Senior%'
LIMIT 10;
/*

┌────────┬─────────────────────────────────────────────┐
│ job_id │                  job_title                  │
│ int32  │                   varchar                   │
├────────┼─────────────────────────────────────────────┤
│   4596 │ Senior Data Analyst / Platform Experience   │
│   4601 │ Senior data analyst                         │
│   4627 │ Senior Data Analyst                         │
│   4628 │ Senior Data Analyst                         │
│   4635 │ Senior data engineer                        │
│   4645 │ Senior  Data Scientist                      │
│   4650 │ Senior Data Scientist                       │
│   4660 │ Senior Analyst, Data Science                │
│   4681 │ Senior IT Consultant Cloud/Data Engineering │
│   4686 │ Senior Data Scientist                       │
├────────┴─────────────────────────────────────────────┤
│ 10 rows                                    2 columns │
└──────────────────────────────────────────────────────┘
*/

-- Job titles that CONTAIN "engineer"
-- (ILIKE = case-insensitive version — not available in all databases)
SELECT
    job_id,
    job_title
FROM job_postings_fact
WHERE job_title ILIKE '%engineer%'
LIMIT 10;
/*

┌────────┬────────────────────────────────────────────────────────────────────┐
│ job_id │                             job_title                              │
│ int32  │                              varchar                               │
├────────┼────────────────────────────────────────────────────────────────────┤
│   4618 │ Data Engineering Manager                                           │
│   4635 │ Senior data engineer                                               │
│   4656 │ Stage Data Engineer AWS & Databricks (H/F)                         │
│   4657 │ DATA ENGINEER CONFIRM (H/F)                                        │
│   4658 │ Data Engineer (H/F)                                                │
│   4659 │ Data Engineer Senior Google Cloud Platform (F/H) - IBM Interactive │
│   4664 │ Data Engineer Strasbourg (F/H) - IBM Interactive                   │
│   4665 │ Data Engineer F/H                                                  │
│   4666 │ Stage : Data Engineer H/F                                          │
│   4668 │ Data Engineer [10] H/F (CDD)                                       │
├────────┴────────────────────────────────────────────────────────────────────┤
│ 10 rows                                                           2 columns │
└─────────────────────────────────────────────────────────────────────────────┘
*/

-- Job titles that END with "Engineer"
SELECT
    job_id,
    job_title
FROM job_postings_fact
WHERE job_title LIKE '%Engineer'
LIMIT 10;
/*

┌────────┬─────────────────────────────────────────────────────┐
│ job_id │                      job_title                      │
│ int32  │                       varchar                       │
├────────┼─────────────────────────────────────────────────────┤
│   4683 │ Data Engineer                                       │
│   4688 │ Field Engineer                                      │
│   4699 │ Data Engineer                                       │
│   4711 │ Data Engineer                                       │
│   4736 │ Data Warehouse Engineer                             │
│   4738 │ Data Processing and Automation-development Engineer │
│   4747 │ Principal Software Engineer                         │
│   4749 │ Cloud Database Engineer                             │
│   4750 │ Machine Learning Engineer                           │
│   4761 │ Senior/Lead Data Engineer                           │
├────────┴─────────────────────────────────────────────────────┤
│ 10 rows                                            2 columns │
└──────────────────────────────────────────────────────────────┘
*/


-- NOT LIKE — exclude patterns
SELECT
    job_id,
    job_title
FROM job_postings_fact
WHERE job_title NOT LIKE '%Senior%'
  AND job_title_short = 'Data Engineer'
LIMIT 10;
/*

┌────────┬──────────────────────────────────────────────────────────────┐
│ job_id │                          job_title                           │
│ int32  │                           varchar                            │
├────────┼──────────────────────────────────────────────────────────────┤
│   4618 │ Data Engineering Manager                                     │
│   4656 │ Stage Data Engineer AWS & Databricks (H/F)                   │
│   4657 │ DATA ENGINEER CONFIRM (H/F)                                  │
│   4658 │ Data Engineer (H/F)                                          │
│   4664 │ Data Engineer Strasbourg (F/H) - IBM Interactive             │
│   4665 │ Data Engineer F/H                                            │
│   4666 │ Stage : Data Engineer H/F                                    │
│   4668 │ Data Engineer [10] H/F (CDD)                                 │
│   4670 │ CDI - Lead Data Engineer (Média) (F/H)                       │
│   4682 │ Data Engineer working with OSIsoft PI and other SQL based... │
├────────┴──────────────────────────────────────────────────────────────┤
│ 10 rows                                                     2 columns │
└───────────────────────────────────────────────────────────────────────┘
*/


-- ============================================================
-- IS NULL / IS NOT NULL (Revisited)
-- ============================================================
-- Already covered in Lesson 1.02, but it's a WHERE clause
-- feature so it belongs here too.

-- Jobs that don't list a salary (very common in real data)
SELECT
    job_id,
    job_title,
    salary_year_avg
FROM job_postings_fact
WHERE salary_year_avg IS NULL
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

-- Jobs that DO list a salary
SELECT
    job_id,
    job_title,
    salary_year_avg
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
LIMIT 10;
/*

┌────────┬───────────────────────────────────┬─────────────────┐
│ job_id │             job_title             │ salary_year_avg │
│ int32  │              varchar              │     double      │
├────────┼───────────────────────────────────┼─────────────────┤
│   4651 │ Data Scientist                    │        110000.0 │
│   4699 │ Data Engineer                     │         65000.0 │
│   4804 │ Hospitality Operations Analyst    │         90000.0 │
│   4810 │ Data Analytics Professional       │         55000.0 │
│   4833 │ Lead Data Scientist (Hybrid)      │        120531.0 │
│   4846 │ Data Engineer - Revenue Platforms │        300000.0 │
│   5089 │ Junior Data Analyst               │         51000.0 │
│   5123 │ Data Science Manager              │        133500.0 │
│   5321 │ HR Data Analyst                   │         77500.0 │
│   5325 │ Data Scientist                    │        125000.0 │
├────────┴───────────────────────────────────┴─────────────────┤
│ 10 rows                                            3 columns │
└──────────────────────────────────────────────────────────────┘
*/


-- ============================================================
-- COMMON MISTAKES WITH WHERE
-- ============================================================

-- 1. Using = with NULL (doesn't work!)
--    WRONG:  WHERE salary_year_avg = NULL
--    RIGHT:  WHERE salary_year_avg IS NULL

-- 2. Forgetting quotes around strings
--    WRONG:  WHERE job_location = New York
--    RIGHT:  WHERE job_location = 'New York, NY'

-- 3. AND vs OR precedence
--    WRONG:  WHERE a = 1 OR b = 2 AND c = 3
--            (this is actually: a = 1 OR (b = 2 AND c = 3))
--    RIGHT:  WHERE (a = 1 OR b = 2) AND c = 3


-- ============================================================
-- TRY THIS
-- ============================================================
-- 1. Find all remote Data Engineer jobs (job_work_from_home = TRUE)
--    with salary > 130,000
--
-- 2. Find jobs in either 'New York, NY' or 'San Francisco, CA'
--    using IN
--
-- 3. Find all job titles that contain the word "Lead" (any case)
