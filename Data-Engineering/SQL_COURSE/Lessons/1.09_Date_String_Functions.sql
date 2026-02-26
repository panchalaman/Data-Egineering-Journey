-- ============================================================
-- LESSON 1.09: Date & String Functions
-- ============================================================
-- Data rarely arrives in the format you need it. Dates come
-- as timestamps when you want months. Strings have extra
-- whitespace. Skills are stored as Python lists. These
-- functions are how you clean and reshape that data.
-- ============================================================


-- ============================================================
-- DATE FUNCTIONS
-- ============================================================

-- CURRENT_DATE / CURRENT_TIMESTAMP
SELECT
    CURRENT_DATE AS today,
    CURRENT_TIMESTAMP AS right_now;
/*

┌────────────┬───────────────────────────────┐
│   today    │           right_now           │
│    date    │   timestamp with time zone    │
├────────────┼───────────────────────────────┤
│ 2026-02-27 │ 2026-02-27 00:12:10.247251+01 │
└────────────┴───────────────────────────────┘

*/


-- DATE_TRUNC — Round Down to a Time Period
-- This is probably the most useful date function in data
-- engineering. It groups dates into months, quarters, years.

SELECT
    job_posted_date,
    DATE_TRUNC('month', job_posted_date) AS posted_month,
    DATE_TRUNC('quarter', job_posted_date) AS posted_quarter,
    DATE_TRUNC('year', job_posted_date) AS posted_year
FROM job_postings_fact
LIMIT 5;
/*

┌─────────────────────┬──────────────┬────────────────┬─────────────┐
│   job_posted_date   │ posted_month │ posted_quarter │ posted_year │
│      timestamp      │     date     │      date      │    date     │
├─────────────────────┼──────────────┼────────────────┼─────────────┤
│ 2023-01-01 00:00:04 │ 2023-01-01   │ 2023-01-01     │ 2023-01-01  │
│ 2023-01-01 00:00:22 │ 2023-01-01   │ 2023-01-01     │ 2023-01-01  │
│ 2023-01-01 00:00:24 │ 2023-01-01   │ 2023-01-01     │ 2023-01-01  │
│ 2023-01-01 00:00:27 │ 2023-01-01   │ 2023-01-01     │ 2023-01-01  │
│ 2023-01-01 00:00:38 │ 2023-01-01   │ 2023-01-01     │ 2023-01-01  │
└─────────────────────┴──────────────┴────────────────┴─────────────┘

*/
-- This is how I built the date dimension in Project 3. It allows me to group by month or quarter without extra date math. It also
-- gives me nice labels like "2023-Q1" for charts and dashboards.


-- Real use: monthly job posting trends
SELECT
    DATE_TRUNC('month', job_posted_date) AS month,
    COUNT(*) AS jobs_posted
FROM job_postings_fact
GROUP BY DATE_TRUNC('month', job_posted_date)
ORDER BY month;
/*

┌────────────┬─────────────┐
│   month    │ jobs_posted │
│    date    │    int64    │
├────────────┼─────────────┤
│ 2023-01-01 │       91872 │
│ 2023-02-01 │       64475 │
│ 2023-03-01 │       64209 │
│ 2023-04-01 │       62937 │
│ 2023-05-01 │       52042 │
│ 2023-06-01 │       61545 │
│ 2023-07-01 │       63760 │
│ 2023-08-01 │       75236 │
│ 2023-09-01 │       62363 │
│ 2023-10-01 │       66732 │
│ 2023-11-01 │       64385 │
│ 2023-12-01 │       57800 │
│ 2024-01-01 │       53145 │
│ 2024-02-01 │       55272 │
│ 2024-03-01 │       48442 │
│ 2024-04-01 │       43755 │
│ 2024-05-01 │       45555 │
│ 2024-06-01 │       41727 │
│ 2024-07-01 │       51152 │
│ 2024-08-01 │       47748 │
│ 2024-09-01 │       30215 │
│ 2024-10-01 │       19052 │
│ 2024-11-01 │       13779 │
│ 2024-12-01 │       34117 │
│ 2025-01-01 │       67650 │
│ 2025-02-01 │       84548 │
│ 2025-03-01 │       73505 │
│ 2025-04-01 │       44880 │
│ 2025-05-01 │       40404 │
│ 2025-06-01 │       33628 │
├────────────┴─────────────┤
│ 30 rows        2 columns │
└──────────────────────────┘

*/
-- This is a common pattern in data engineering: use DATE_TRUNC to group by time periods without worrying about the specific date math. It also gives you nice, clean date values to work with in downstream queries and dashboards.    

-- EXTRACT — Pull Out Date Parts
SELECT
    job_posted_date,
    EXTRACT(YEAR FROM job_posted_date) AS year,
    EXTRACT(MONTH FROM job_posted_date) AS month,
    EXTRACT(DAY FROM job_posted_date) AS day,
    EXTRACT(DOW FROM job_posted_date) AS day_of_week
    -- 0=Sunday, 1=Monday, ..., 6=Saturday
FROM job_postings_fact
LIMIT 5;
/*

┌─────────────────────┬───────┬───────┬───────┬─────────────┐
│   job_posted_date   │ year  │ month │  day  │ day_of_week │
│      timestamp      │ int64 │ int64 │ int64 │    int64    │
├─────────────────────┼───────┼───────┼───────┼─────────────┤
│ 2023-01-01 00:00:04 │  2023 │     1 │     1 │           0 │
│ 2023-01-01 00:00:22 │  2023 │     1 │     1 │           0 │
│ 2023-01-01 00:00:24 │  2023 │     1 │     1 │           0 │
│ 2023-01-01 00:00:27 │  2023 │     1 │     1 │           0 │
│ 2023-01-01 00:00:38 │  2023 │     1 │     1 │           0 │
└─────────────────────┴───────┴───────┴───────┴─────────────┘

*/
-- This is how I built the date dimension in Project 3. It allows me to group by month or quarter without extra date math. It also gives me nice labels like "2023-Q1" for charts and dashboards.

-- Which day of the week gets the most postings?
SELECT
    EXTRACT(DOW FROM job_posted_date) AS day_of_week,
    CASE EXTRACT(DOW FROM job_posted_date)
        WHEN 0 THEN 'Sunday'
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
    END AS day_name,
    COUNT(*) AS job_count
FROM job_postings_fact
GROUP BY day_of_week
ORDER BY day_of_week;
/*

┌─────────────┬───────────┬───────────┐
│ day_of_week │ day_name  │ job_count │
│    int64    │  varchar  │   int64   │
├─────────────┼───────────┼───────────┤
│           0 │ Sunday    │    163698 │
│           1 │ Monday    │    229040 │
│           2 │ Tuesday   │    263832 │
│           3 │ Wednesday │    261925 │
│           4 │ Thursday  │    261468 │
│           5 │ Friday    │    255544 │
│           6 │ Saturday  │    180423 │
└─────────────┴───────────┴───────────┘

*/
-- Interesting! Tuesday and Wednesday are the most popular days for job postings, while Sunday is the least popular. This could be useful for timing your job search or understanding hiring patterns.


-- DATE_DIFF — Time Between Dates (DuckDB syntax)
SELECT
    job_posted_date,
    CURRENT_DATE AS today,
    DATE_DIFF('day', job_posted_date, CURRENT_DATE) AS days_ago,
    DATE_DIFF('month', job_posted_date, CURRENT_DATE) AS months_ago
FROM job_postings_fact
LIMIT 5;


-- Date Arithmetic
SELECT
    job_posted_date,
    job_posted_date + INTERVAL '30 days' AS plus_30_days,
    job_posted_date - INTERVAL '1 month' AS minus_1_month
FROM job_postings_fact
LIMIT 5;


-- CASTING strings to dates
SELECT
    CAST('2024-03-15' AS DATE) AS date_value,
    CAST('2024-03-15 10:30:00' AS TIMESTAMP) AS timestamp_value;


-- ============================================================
-- STRING FUNCTIONS
-- ============================================================

-- LENGTH
SELECT
    job_title,
    LENGTH(job_title) AS title_length
FROM job_postings_fact
LIMIT 5;


-- UPPER / LOWER
SELECT
    job_title,
    UPPER(job_title) AS screaming,
    LOWER(job_title) AS whisper
FROM job_postings_fact
LIMIT 5;


-- TRIM — Remove Whitespace
SELECT
    TRIM('   hello   ') AS trimmed,
    LTRIM('   hello   ') AS left_trimmed,
    RTRIM('   hello   ') AS right_trimmed;
-- You'd be surprised how often string data has trailing
-- spaces. Trim everything when loading data.


-- REPLACE
SELECT
    job_location,
    REPLACE(job_location, 'United States', 'US') AS short_location
FROM job_postings_fact
WHERE job_location LIKE '%United States%'
LIMIT 5;


-- SUBSTRING / LEFT / RIGHT
SELECT
    job_title,
    SUBSTRING(job_title, 1, 20) AS first_20_chars,
    LEFT(job_title, 10) AS first_10,
    RIGHT(job_title, 5) AS last_5
FROM job_postings_fact
LIMIT 5;


-- SPLIT_PART — Split a string by delimiter
SELECT
    job_location,
    SPLIT_PART(job_location, ',', 1) AS city,
    SPLIT_PART(job_location, ',', 2) AS state_or_country
FROM job_postings_fact
WHERE job_location LIKE '%,%'
LIMIT 10;
-- Handy for parsing "City, State" formatted locations.


-- CONCAT / ||
SELECT
    job_title_short || ' | ' || job_location AS combined,
    CONCAT(job_title_short, ' at ', job_location) AS also_combined
FROM job_postings_fact
LIMIT 5;


-- ============================================================
-- STRING_SPLIT + UNNEST — Parsing Lists
-- ============================================================
-- This is the technique I used in Project 3.
-- Skills were stored as Python lists: "['SQL', 'Python', 'AWS']"
-- We need to parse that into individual rows.

-- Simulate it:
SELECT UNNEST(STRING_SPLIT('SQL,Python,AWS,Spark', ',')) AS skill;

-- More realistic — cleaning up Python list format:
SELECT
    TRIM(
        REPLACE(
            REPLACE(
                UNNEST(STRING_SPLIT('["SQL", "Python", "AWS"]', ',')),
                '[', ''
            ),
            ']', ''
        )
    ) AS skill;

-- In the real pipeline, this goes from:
--   one row with skills = "['SQL', 'Python', 'AWS']"
-- to:
--   three rows: SQL, Python, AWS
-- That's normalization via string parsing.


-- ============================================================
-- TYPE CASTING
-- ============================================================
-- Converting between data types.

SELECT
    CAST(salary_year_avg AS INTEGER) AS salary_int,
    CAST(salary_year_avg AS VARCHAR) AS salary_text,
    CAST('2024-01-15' AS DATE) AS date_val,
    CAST('42' AS INTEGER) AS number_val
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
LIMIT 5;

-- DuckDB shorthand (also works in PostgreSQL):
SELECT
    salary_year_avg::INTEGER AS salary_int,
    salary_year_avg::VARCHAR AS salary_text
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
LIMIT 5;


-- ============================================================
-- MATH FUNCTIONS
-- ============================================================

SELECT
    salary_year_avg,
    ROUND(salary_year_avg, 0) AS rounded,
    ROUND(salary_year_avg, -3) AS rounded_to_thousands,
    CEIL(salary_year_avg) AS ceiling,
    FLOOR(salary_year_avg) AS floor,
    ABS(-42) AS absolute_value,
    LN(salary_year_avg) AS natural_log
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
LIMIT 5;

-- I used LN() in the EDA project to create an "optimal score"
-- that combined log-transformed demand with median salary.
-- Log transformation helps normalize skewed distributions.


-- ============================================================
-- PUTTING IT TOGETHER: A Real Data Cleaning Pipeline
-- ============================================================

WITH cleaned_data AS (
    SELECT
        job_id,
        TRIM(job_title) AS job_title,
        LOWER(job_title_short) AS role,
        SPLIT_PART(job_location, ',', 1) AS city,
        TRIM(SPLIT_PART(job_location, ',', 2)) AS state_or_country,
        DATE_TRUNC('month', job_posted_date) AS posted_month,
        EXTRACT(YEAR FROM job_posted_date) AS posted_year,
        COALESCE(salary_year_avg, 0) AS salary,
        CASE
            WHEN salary_year_avg IS NULL THEN 'Not Disclosed'
            WHEN salary_year_avg >= 150000 THEN 'High'
            WHEN salary_year_avg >= 100000 THEN 'Mid'
            ELSE 'Entry'
        END AS salary_band
    FROM job_postings_fact
)
SELECT *
FROM cleaned_data
WHERE salary > 0
ORDER BY salary DESC
LIMIT 20;


-- ============================================================
-- TRY THIS
-- ============================================================
-- 1. Find the monthly trend of Data Engineer postings
--    (month, count) sorted by month
--
-- 2. Parse job_location into city and state/country columns,
--    and find the top 10 cities by posting count
--
-- 3. Calculate how many days each job has been posted
--    (from job_posted_date to CURRENT_DATE), and find
--    the average "age" of open positions by job title
