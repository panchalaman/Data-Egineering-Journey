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

-- Jobs with salary above 150k
SELECT
    job_id,
    job_title,
    salary_year_avg
FROM job_postings_fact
WHERE salary_year_avg > 150000
LIMIT 10;

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

-- OR = at least one condition must be true
SELECT
    job_id,
    job_title_short,
    job_location
FROM job_postings_fact
WHERE job_title_short = 'Data Engineer'
   OR job_title_short = 'Data Scientist'
LIMIT 10;

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

-- NOT IN — everything EXCEPT these
SELECT
    job_id,
    job_title_short
FROM job_postings_fact
WHERE job_title_short NOT IN ('Data Engineer', 'Data Scientist')
LIMIT 10;

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

-- Job titles that CONTAIN "engineer"
-- (ILIKE = case-insensitive version — not available in all databases)
SELECT
    job_id,
    job_title
FROM job_postings_fact
WHERE job_title ILIKE '%engineer%'
LIMIT 10;

-- Job titles that END with "Engineer"
SELECT
    job_id,
    job_title
FROM job_postings_fact
WHERE job_title LIKE '%Engineer'
LIMIT 10;

-- NOT LIKE — exclude patterns
SELECT
    job_id,
    job_title
FROM job_postings_fact
WHERE job_title NOT LIKE '%Senior%'
  AND job_title_short = 'Data Engineer'
LIMIT 10;


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

-- Jobs that DO list a salary
SELECT
    job_id,
    job_title,
    salary_year_avg
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
LIMIT 10;


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
