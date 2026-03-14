-- ============================================================
-- LESSON 1.10: Window Functions
-- ============================================================
-- Window functions are probably the single most important
-- concept that separates "I know SQL" from "I actually build
-- data pipelines with SQL." They let you do calculations
-- ACROSS rows without collapsing them into groups.
--
-- GROUP BY gives you one row per group.
-- Window functions keep every row but add computed columns.
--
-- Every window function follows this pattern:
--   FUNCTION() OVER (PARTITION BY ... ORDER BY ...)
-- ============================================================


-- ============================================================
-- ROW_NUMBER — Assign Sequential Numbers
-- ============================================================

-- Number each job posting by salary (highest first)
SELECT
    job_title_short,
    salary_year_avg,
    ROW_NUMBER() OVER (ORDER BY salary_year_avg DESC) AS salary_rank
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
LIMIT 15;
/*

┌───────────────────────────┬─────────────────┬─────────────┐
│      job_title_short      │ salary_year_avg │ salary_rank │
│          varchar          │     double      │    int64    │
├───────────────────────────┼─────────────────┼─────────────┤
│ Data Scientist            │        960000.0 │           1 │
│ Data Scientist            │        920000.0 │           2 │
│ Senior Data Scientist     │        890000.0 │           3 │
│ Machine Learning Engineer │        875000.0 │           4 │
│ Data Scientist            │        870000.0 │           5 │
│ Data Scientist            │        850000.0 │           6 │
│ Senior Data Engineer      │        800000.0 │           7 │
│ Machine Learning Engineer │        800000.0 │           8 │
│ Data Scientist            │        680000.0 │           9 │
│ Data Analyst              │        650000.0 │          10 │
│ Data Scientist            │        640000.0 │          11 │
│ Data Engineer             │        640000.0 │          12 │
│ Data Scientist            │        585000.0 │          13 │
│ Data Scientist            │        550000.0 │          14 │
│ Data Engineer             │        525000.0 │          15 │
├───────────────────────────┴─────────────────┴─────────────┤
│ 15 rows                                         3 columns │
└───────────────────────────────────────────────────────────┘
*/

-- ROW_NUMBER + PARTITION BY
-- Rank salaries WITHIN each job title
SELECT
    job_title_short,
    company_id,
    salary_year_avg,
    ROW_NUMBER() OVER (
        PARTITION BY job_title_short
        ORDER BY salary_year_avg DESC
    ) AS rank_within_role
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
ORDER BY job_title_short, rank_within_role
LIMIT 20;
/*

┌──────────────────┬────────────┬─────────────────┬──────────────────┐
│ job_title_short  │ company_id │ salary_year_avg │ rank_within_role │
│     varchar      │   int32    │     double      │      int64       │
├──────────────────┼────────────┼─────────────────┼──────────────────┤
│ Business Analyst │     951196 │        390000.0 │                1 │
│ Business Analyst │       5987 │        387460.0 │                2 │
│ Business Analyst │       6334 │        286000.0 │                3 │
│ Business Analyst │       5429 │        268500.0 │                4 │
│ Business Analyst │     365247 │        264000.0 │                5 │
│ Business Analyst │     365247 │        264000.0 │                6 │
│ Business Analyst │     365247 │        264000.0 │                7 │
│ Business Analyst │     324715 │        257937.0 │                8 │
│ Business Analyst │     301981 │        257500.0 │                9 │
│ Business Analyst │       6334 │        250000.0 │               10 │
│ Business Analyst │     722748 │        250000.0 │               11 │
│ Business Analyst │      13226 │        243500.0 │               12 │
│ Business Analyst │    1089315 │        230000.0 │               13 │
│ Business Analyst │      18678 │        229000.0 │               14 │
│ Business Analyst │     928629 │        226000.0 │               15 │
│ Business Analyst │     252621 │        220000.0 │               16 │
│ Business Analyst │      39393 │        220000.0 │               17 │
│ Business Analyst │       5765 │        214500.0 │               18 │
│ Business Analyst │       5765 │        214500.0 │               19 │
│ Business Analyst │       9445 │        214000.0 │               20 │
├──────────────────┴────────────┴─────────────────┴──────────────────┤
│ 20 rows                                                  4 columns │
└────────────────────────────────────────────────────────────────────┘
*/
-- The classic pattern: "Top N per group"
-- Get the highest-paying posting for each role
WITH ranked AS (
    SELECT
        job_title_short,
        job_title,
        salary_year_avg,
        ROW_NUMBER() OVER (
            PARTITION BY job_title_short
            ORDER BY salary_year_avg DESC
        ) AS rn
    FROM job_postings_fact
    WHERE salary_year_avg IS NOT NULL
)
SELECT *
FROM ranked
WHERE rn = 1
ORDER BY salary_year_avg DESC;
/*

┌───────────────────────────┬────────────────────────────────────────────────┬─────────────────┬───────┐
│      job_title_short      │                   job_title                    │ salary_year_avg │  rn   │
│          varchar          │                    varchar                     │     double      │ int64 │
├───────────────────────────┼────────────────────────────────────────────────┼─────────────────┼───────┤
│ Data Scientist            │ Data Scientist                                 │        960000.0 │     1 │
│ Senior Data Scientist     │ Senior Data Scientist                          │        890000.0 │     1 │
│ Machine Learning Engineer │ Machine Learning Engineer                      │        875000.0 │     1 │
│ Senior Data Engineer      │ Senior Data Engineer (MDM team), DTG           │        800000.0 │     1 │
│ Data Analyst              │ Data Analyst                                   │        650000.0 │     1 │
│ Data Engineer             │ Manager, Content Data Engineering              │        640000.0 │     1 │
│ Software Engineer         │ PhD Computer Scientist/Software Developer $1M+ │        425000.0 │     1 │
│ Senior Data Analyst       │ SVP, Data Analytics                            │        425000.0 │     1 │
│ Business Analyst          │ Старший продуктовый аналитик                   │        390000.0 │     1 │
│ Cloud Engineer            │ Platform and Technical Communications Lead     │        305000.0 │     1 │
├───────────────────────────┴────────────────────────────────────────────────┴─────────────────┴───────┤
│ 10 rows                                                                                    4 columns │
└──────────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
-- This "Top N per group" pattern is super common in analytics:
-- - Top 3 products by sales in each category
-- - Top 5 customers by revenue in each region
-- - Highest-rated movies in each genre
-- - etc.

-- This pattern comes up ALL THE TIME:
--   1. Assign row numbers within partitions
--   2. Wrap in CTE
--   3. Filter where rn = 1 (or rn <= 3 for top 3, etc.)
-- I used this in almost every analytics project.


-- ============================================================
-- RANK vs DENSE_RANK vs ROW_NUMBER
-- ============================================================

-- The difference matters when there are ties:
--   ROW_NUMBER: 1, 2, 3, 4    (no ties, always unique)
--   RANK:       1, 2, 2, 4    (ties skip numbers)
--   DENSE_RANK: 1, 2, 2, 3    (ties don't skip)

SELECT
    job_title_short,
    salary_year_avg,
    ROW_NUMBER() OVER (ORDER BY salary_year_avg DESC) AS row_num,
    RANK()       OVER (ORDER BY salary_year_avg DESC) AS rank,
    DENSE_RANK() OVER (ORDER BY salary_year_avg DESC) AS dense_rank
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
LIMIT 15;
/*

┌───────────────────────────┬─────────────────┬─────────┬───────┬────────────┐
│      job_title_short      │ salary_year_avg │ row_num │ rank  │ dense_rank │
│          varchar          │     double      │  int64  │ int64 │   int64    │
├───────────────────────────┼─────────────────┼─────────┼───────┼────────────┤
│ Data Scientist            │        960000.0 │       1 │     1 │          1 │
│ Data Scientist            │        920000.0 │       2 │     2 │          2 │
│ Senior Data Scientist     │        890000.0 │       3 │     3 │          3 │
│ Machine Learning Engineer │        875000.0 │       4 │     4 │          4 │
│ Data Scientist            │        870000.0 │       5 │     5 │          5 │
│ Data Scientist            │        850000.0 │       6 │     6 │          6 │
│ Machine Learning Engineer │        800000.0 │       7 │     7 │          7 │
│ Senior Data Engineer      │        800000.0 │       8 │     7 │          7 │
│ Data Scientist            │        680000.0 │       9 │     9 │          8 │
│ Data Analyst              │        650000.0 │      10 │    10 │          9 │
│ Data Engineer             │        640000.0 │      11 │    11 │         10 │
│ Data Scientist            │        640000.0 │      12 │    11 │         10 │
│ Data Scientist            │        585000.0 │      13 │    13 │         11 │
│ Data Scientist            │        550000.0 │      14 │    14 │         12 │
│ Data Engineer             │        525000.0 │      15 │    15 │         13 │
├───────────────────────────┴─────────────────┴─────────┴───────┴────────────┤
│ 15 rows                                                          5 columns │
└────────────────────────────────────────────────────────────────────────────┘
*/

-- For "top N per group" queries, I almost always use
-- ROW_NUMBER because I want exactly N results.
-- RANK/DENSE_RANK are better when you want to handle
-- ties explicitly (like "everyone tied for 3rd place").


-- ============================================================
-- LAG and LEAD — Access Previous/Next Rows
-- ============================================================

-- LAG looks at the PREVIOUS row, LEAD looks NEXT.
-- This is how you calculate period-over-period changes.

-- Monthly posting counts with month-over-month change
WITH monthly_counts AS (
    SELECT
        DATE_TRUNC('month', job_posted_date) AS month,
        COUNT(*) AS job_count
    FROM job_postings_fact
    GROUP BY DATE_TRUNC('month', job_posted_date)
)
SELECT
    month,
    job_count,
    LAG(job_count) OVER (ORDER BY month) AS prev_month_count,
    job_count - LAG(job_count) OVER (ORDER BY month) AS mom_change,
    ROUND(
        100.0 * (job_count - LAG(job_count) OVER (ORDER BY month))
        / LAG(job_count) OVER (ORDER BY month),
        1
    ) AS mom_pct_change
FROM monthly_counts
ORDER BY month;
/*

  ORDER BY month;
┌────────────┬───────────┬──────────────────┬────────────┬────────────────┐
│   month    │ job_count │ prev_month_count │ mom_change │ mom_pct_change │
│    date    │   int64   │      int64       │   int64    │     double     │
├────────────┼───────────┼──────────────────┼────────────┼────────────────┤
│ 2023-01-01 │     91872 │             NULL │       NULL │           NULL │
│ 2023-02-01 │     64475 │            91872 │     -27397 │          -29.8 │
│ 2023-03-01 │     64209 │            64475 │       -266 │           -0.4 │
│ 2023-04-01 │     62937 │            64209 │      -1272 │           -2.0 │
│ 2023-05-01 │     52042 │            62937 │     -10895 │          -17.3 │
│ 2023-06-01 │     61545 │            52042 │       9503 │           18.3 │
│ 2023-07-01 │     63760 │            61545 │       2215 │            3.6 │
│ 2023-08-01 │     75236 │            63760 │      11476 │           18.0 │
│ 2023-09-01 │     62363 │            75236 │     -12873 │          -17.1 │
│ 2023-10-01 │     66732 │            62363 │       4369 │            7.0 │
│ 2023-11-01 │     64385 │            66732 │      -2347 │           -3.5 │
│ 2023-12-01 │     57800 │            64385 │      -6585 │          -10.2 │
│ 2024-01-01 │     53145 │            57800 │      -4655 │           -8.1 │
│ 2024-02-01 │     55272 │            53145 │       2127 │            4.0 │
│ 2024-03-01 │     48442 │            55272 │      -6830 │          -12.4 │
│ 2024-04-01 │     43755 │            48442 │      -4687 │           -9.7 │
│ 2024-05-01 │     45555 │            43755 │       1800 │            4.1 │
│ 2024-06-01 │     41727 │            45555 │      -3828 │           -8.4 │
│ 2024-07-01 │     51152 │            41727 │       9425 │           22.6 │
│ 2024-08-01 │     47748 │            51152 │      -3404 │           -6.7 │
│ 2024-09-01 │     30215 │            47748 │     -17533 │          -36.7 │
│ 2024-10-01 │     19052 │            30215 │     -11163 │          -36.9 │
│ 2024-11-01 │     13779 │            19052 │      -5273 │          -27.7 │
│ 2024-12-01 │     34117 │            13779 │      20338 │          147.6 │
│ 2025-01-01 │     67650 │            34117 │      33533 │           98.3 │
│ 2025-02-01 │     84548 │            67650 │      16898 │           25.0 │
│ 2025-03-01 │     73505 │            84548 │     -11043 │          -13.1 │
│ 2025-04-01 │     44880 │            73505 │     -28625 │          -38.9 │
│ 2025-05-01 │     40404 │            44880 │      -4476 │          -10.0 │
│ 2025-06-01 │     33628 │            40404 │      -6776 │          -16.8 │
├────────────┴───────────┴──────────────────┴────────────┴────────────────┤
│ 30 rows                                                       5 columns │
└─────────────────────────────────────────────────────────────────────────┘
*/

-- LEAD example — what's the NEXT month look like?
WITH monthly_counts AS (
    SELECT
        DATE_TRUNC('month', job_posted_date) AS month,
        COUNT(*) AS job_count
    FROM job_postings_fact
    GROUP BY DATE_TRUNC('month', job_posted_date)
)
SELECT
    month,
    job_count,
    LEAD(job_count) OVER (ORDER BY month) AS next_month_count
FROM monthly_counts
ORDER BY month;
/*

┌────────────┬───────────┬──────────────────┐
│   month    │ job_count │ next_month_count │
│    date    │   int64   │      int64       │
├────────────┼───────────┼──────────────────┤
│ 2023-01-01 │     91872 │            64475 │
│ 2023-02-01 │     64475 │            64209 │
│ 2023-03-01 │     64209 │            62937 │
│ 2023-04-01 │     62937 │            52042 │
│ 2023-05-01 │     52042 │            61545 │
│ 2023-06-01 │     61545 │            63760 │
│ 2023-07-01 │     63760 │            75236 │
│ 2023-08-01 │     75236 │            62363 │
│ 2023-09-01 │     62363 │            66732 │
│ 2023-10-01 │     66732 │            64385 │
│ 2023-11-01 │     64385 │            57800 │
│ 2023-12-01 │     57800 │            53145 │
│ 2024-01-01 │     53145 │            55272 │
│ 2024-02-01 │     55272 │            48442 │
│ 2024-03-01 │     48442 │            43755 │
│ 2024-04-01 │     43755 │            45555 │
│ 2024-05-01 │     45555 │            41727 │
│ 2024-06-01 │     41727 │            51152 │
│ 2024-07-01 │     51152 │            47748 │
│ 2024-08-01 │     47748 │            30215 │
│ 2024-09-01 │     30215 │            19052 │
│ 2024-10-01 │     19052 │            13779 │
│ 2024-11-01 │     13779 │            34117 │
│ 2024-12-01 │     34117 │            67650 │
│ 2025-01-01 │     67650 │            84548 │
│ 2025-02-01 │     84548 │            73505 │
│ 2025-03-01 │     73505 │            44880 │
│ 2025-04-01 │     44880 │            40404 │
│ 2025-05-01 │     40404 │            33628 │
│ 2025-06-01 │     33628 │             NULL │
├────────────┴───────────┴──────────────────┤
│ 30 rows                         3 columns │
└───────────────────────────────────────────┘
*/


-- LAG/LEAD with offset > 1
-- Compare to 3 months ago:
WITH monthly_counts AS (
    SELECT
        DATE_TRUNC('month', job_posted_date) AS month,
        COUNT(*) AS job_count
    FROM job_postings_fact
    GROUP BY DATE_TRUNC('month', job_posted_date)
)
SELECT
    month,
    job_count,
    LAG(job_count, 3) OVER (ORDER BY month) AS three_months_ago,
    job_count - LAG(job_count, 3) OVER (ORDER BY month) AS qoq_change
FROM monthly_counts
ORDER BY month;
/*

┌────────────┬───────────┬──────────────────┬────────────┐
│   month    │ job_count │ three_months_ago │ qoq_change │
│    date    │   int64   │      int64       │   int64    │
├────────────┼───────────┼──────────────────┼────────────┤
│ 2023-01-01 │     91872 │             NULL │       NULL │
│ 2023-02-01 │     64475 │             NULL │       NULL │
│ 2023-03-01 │     64209 │             NULL │       NULL │
│ 2023-04-01 │     62937 │            91872 │     -28935 │
│ 2023-05-01 │     52042 │            64475 │     -12433 │
│ 2023-06-01 │     61545 │            64209 │      -2664 │
│ 2023-07-01 │     63760 │            62937 │        823 │
│ 2023-08-01 │     75236 │            52042 │      23194 │
│ 2023-09-01 │     62363 │            61545 │        818 │
│ 2023-10-01 │     66732 │            63760 │       2972 │
│ 2023-11-01 │     64385 │            75236 │     -10851 │
│ 2023-12-01 │     57800 │            62363 │      -4563 │
│ 2024-01-01 │     53145 │            66732 │     -13587 │
│ 2024-02-01 │     55272 │            64385 │      -9113 │
│ 2024-03-01 │     48442 │            57800 │      -9358 │
│ 2024-04-01 │     43755 │            53145 │      -9390 │
│ 2024-05-01 │     45555 │            55272 │      -9717 │
│ 2024-06-01 │     41727 │            48442 │      -6715 │
│ 2024-07-01 │     51152 │            43755 │       7397 │
│ 2024-08-01 │     47748 │            45555 │       2193 │
│ 2024-09-01 │     30215 │            41727 │     -11512 │
│ 2024-10-01 │     19052 │            51152 │     -32100 │
│ 2024-11-01 │     13779 │            47748 │     -33969 │
│ 2024-12-01 │     34117 │            30215 │       3902 │
│ 2025-01-01 │     67650 │            19052 │      48598 │
│ 2025-02-01 │     84548 │            13779 │      70769 │
│ 2025-03-01 │     73505 │            34117 │      39388 │
│ 2025-04-01 │     44880 │            67650 │     -22770 │
│ 2025-05-01 │     40404 │            84548 │     -44144 │
│ 2025-06-01 │     33628 │            73505 │     -39877 │
├────────────┴───────────┴──────────────────┴────────────┤
│ 30 rows                                      4 columns │
└────────────────────────────────────────────────────────┘
*/


-- ============================================================
-- Running Totals and Moving Averages
-- ============================================================

-- SUM() OVER — Running Total
WITH monthly_counts AS (
    SELECT
        DATE_TRUNC('month', job_posted_date) AS month,
        COUNT(*) AS job_count
    FROM job_postings_fact
    GROUP BY DATE_TRUNC('month', job_posted_date)
)
SELECT
    month,
    job_count,
    SUM(job_count) OVER (ORDER BY month) AS running_total,
    AVG(job_count) OVER (ORDER BY month) AS running_avg
FROM monthly_counts
ORDER BY month;
/*

┌────────────┬───────────┬───────────────┬────────────────────┐
│   month    │ job_count │ running_total │    running_avg     │
│    date    │   int64   │    int128     │       double       │
├────────────┼───────────┼───────────────┼────────────────────┤
│ 2023-01-01 │     91872 │         91872 │            91872.0 │
│ 2023-02-01 │     64475 │        156347 │            78173.5 │
│ 2023-03-01 │     64209 │        220556 │  73518.66666666667 │
│ 2023-04-01 │     62937 │        283493 │           70873.25 │
│ 2023-05-01 │     52042 │        335535 │            67107.0 │
│ 2023-06-01 │     61545 │        397080 │            66180.0 │
│ 2023-07-01 │     63760 │        460840 │  65834.28571428571 │
│ 2023-08-01 │     75236 │        536076 │            67009.5 │
│ 2023-09-01 │     62363 │        598439 │  66493.22222222222 │
│ 2023-10-01 │     66732 │        665171 │            66517.1 │
│ 2023-11-01 │     64385 │        729556 │  66323.27272727272 │
│ 2023-12-01 │     57800 │        787356 │            65613.0 │
│ 2024-01-01 │     53145 │        840501 │  64653.92307692308 │
│ 2024-02-01 │     55272 │        895773 │  63983.78571428572 │
│ 2024-03-01 │     48442 │        944215 │ 62947.666666666664 │
│ 2024-04-01 │     43755 │        987970 │          61748.125 │
│ 2024-05-01 │     45555 │       1033525 │  60795.58823529412 │
│ 2024-06-01 │     41727 │       1075252 │  59736.22222222222 │
│ 2024-07-01 │     51152 │       1126404 │  59284.42105263158 │
│ 2024-08-01 │     47748 │       1174152 │            58707.6 │
│ 2024-09-01 │     30215 │       1204367 │  57350.80952380953 │
│ 2024-10-01 │     19052 │       1223419 │ 55609.954545454544 │
│ 2024-11-01 │     13779 │       1237198 │ 53791.217391304344 │
│ 2024-12-01 │     34117 │       1271315 │ 52971.458333333336 │
│ 2025-01-01 │     67650 │       1338965 │            53558.6 │
│ 2025-02-01 │     84548 │       1423513 │            54750.5 │
│ 2025-03-01 │     73505 │       1497018 │  55445.11111111111 │
│ 2025-04-01 │     44880 │       1541898 │  55067.78571428572 │
│ 2025-05-01 │     40404 │       1582302 │ 54562.137931034486 │
│ 2025-06-01 │     33628 │       1615930 │ 53864.333333333336 │
├────────────┴───────────┴───────────────┴────────────────────┤
│ 30 rows                                           4 columns │
└─────────────────────────────────────────────────────────────┘
*/

-- Moving Average (3-month window)
-- This is huge in time-series analysis.
WITH monthly_counts AS (
    SELECT
        DATE_TRUNC('month', job_posted_date) AS month,
        COUNT(*) AS job_count
    FROM job_postings_fact
    GROUP BY DATE_TRUNC('month', job_posted_date)
)
SELECT
    month,
    job_count,
    AVG(job_count) OVER (
        ORDER BY month
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS moving_avg_3m
FROM monthly_counts
ORDER BY month;
/*

┌────────────┬───────────┬────────────────────┐
│   month    │ job_count │   moving_avg_3m    │
│    date    │   int64   │       double       │
├────────────┼───────────┼────────────────────┤
│ 2023-01-01 │     91872 │            91872.0 │
│ 2023-02-01 │     64475 │            78173.5 │
│ 2023-03-01 │     64209 │  73518.66666666667 │
│ 2023-04-01 │     62937 │ 63873.666666666664 │
│ 2023-05-01 │     52042 │ 59729.333333333336 │
│ 2023-06-01 │     61545 │ 58841.333333333336 │
│ 2023-07-01 │     63760 │ 59115.666666666664 │
│ 2023-08-01 │     75236 │            66847.0 │
│ 2023-09-01 │     62363 │  67119.66666666667 │
│ 2023-10-01 │     66732 │  68110.33333333333 │
│ 2023-11-01 │     64385 │ 64493.333333333336 │
│ 2023-12-01 │     57800 │ 62972.333333333336 │
│ 2024-01-01 │     53145 │ 58443.333333333336 │
│ 2024-02-01 │     55272 │ 55405.666666666664 │
│ 2024-03-01 │     48442 │ 52286.333333333336 │
│ 2024-04-01 │     43755 │ 49156.333333333336 │
│ 2024-05-01 │     45555 │ 45917.333333333336 │
│ 2024-06-01 │     41727 │            43679.0 │
│ 2024-07-01 │     51152 │ 46144.666666666664 │
│ 2024-08-01 │     47748 │ 46875.666666666664 │
│ 2024-09-01 │     30215 │ 43038.333333333336 │
│ 2024-10-01 │     19052 │ 32338.333333333332 │
│ 2024-11-01 │     13779 │ 21015.333333333332 │
│ 2024-12-01 │     34117 │            22316.0 │
│ 2025-01-01 │     67650 │ 38515.333333333336 │
│ 2025-02-01 │     84548 │            62105.0 │
│ 2025-03-01 │     73505 │  75234.33333333333 │
│ 2025-04-01 │     44880 │  67644.33333333333 │
│ 2025-05-01 │     40404 │ 52929.666666666664 │
│ 2025-06-01 │     33628 │ 39637.333333333336 │
├────────────┴───────────┴────────────────────┤
│ 30 rows                           3 columns │
└─────────────────────────────────────────────┘
*/

-- ROWS BETWEEN defines the "window frame."
-- "2 PRECEDING AND CURRENT ROW" means:
--   current row + 2 rows before it = 3 rows total.


-- ============================================================
-- Window Frame Clauses (ROWS vs RANGE)
-- ============================================================
-- By default, window functions use:
--   RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
--
-- You can control this:
--   ROWS BETWEEN ... — physical row count
--   RANGE BETWEEN ... — logical value range
--
-- Common frames:
--   UNBOUNDED PRECEDING AND CURRENT ROW  — everything up to here
--   2 PRECEDING AND CURRENT ROW          — last 3 rows
--   1 PRECEDING AND 1 FOLLOWING          — 3-row centered window
--   UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING  — entire partition


-- ============================================================
-- Aggregate Window Functions
-- ============================================================

-- Regular aggregates as window functions — they don't collapse rows.
SELECT
    job_title_short,
    salary_year_avg,
    COUNT(*) OVER (PARTITION BY job_title_short) AS role_count,
    AVG(salary_year_avg) OVER (PARTITION BY job_title_short) AS role_avg_salary,
    MIN(salary_year_avg) OVER (PARTITION BY job_title_short) AS role_min_salary,
    MAX(salary_year_avg) OVER (PARTITION BY job_title_short) AS role_max_salary
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
ORDER BY job_title_short, salary_year_avg DESC
LIMIT 20;
/*

┌──────────────────┬─────────────────┬────────────┬───────────────────┬─────────────────┬─────────────────┐
│ job_title_short  │ salary_year_avg │ role_count │  role_avg_salary  │ role_min_salary │ role_max_salary │
│     varchar      │     double      │   int64    │      double       │     double      │     double      │
├──────────────────┼─────────────────┼────────────┼───────────────────┼─────────────────┼─────────────────┤
│ Business Analyst │        390000.0 │       1962 │ 98660.39627134302 │         16500.0 │        390000.0 │
│ Business Analyst │        387460.0 │       1962 │ 98660.39627134302 │         16500.0 │        390000.0 │
│ Business Analyst │        286000.0 │       1962 │ 98660.39627134302 │         16500.0 │        390000.0 │
│ Business Analyst │        268500.0 │       1962 │ 98660.39627134302 │         16500.0 │        390000.0 │
│ Business Analyst │        264000.0 │       1962 │ 98660.39627134302 │         16500.0 │        390000.0 │
│ Business Analyst │        264000.0 │       1962 │ 98660.39627134302 │         16500.0 │        390000.0 │
│ Business Analyst │        264000.0 │       1962 │ 98660.39627134302 │         16500.0 │        390000.0 │
│ Business Analyst │        257937.0 │       1962 │ 98660.39627134302 │         16500.0 │        390000.0 │
│ Business Analyst │        257500.0 │       1962 │ 98660.39627134302 │         16500.0 │        390000.0 │
│ Business Analyst │        250000.0 │       1962 │ 98660.39627134302 │         16500.0 │        390000.0 │
│ Business Analyst │        250000.0 │       1962 │ 98660.39627134302 │         16500.0 │        390000.0 │
│ Business Analyst │        243500.0 │       1962 │ 98660.39627134302 │         16500.0 │        390000.0 │
│ Business Analyst │        230000.0 │       1962 │ 98660.39627134302 │         16500.0 │        390000.0 │
│ Business Analyst │        229000.0 │       1962 │ 98660.39627134302 │         16500.0 │        390000.0 │
│ Business Analyst │        226000.0 │       1962 │ 98660.39627134302 │         16500.0 │        390000.0 │
│ Business Analyst │        220000.0 │       1962 │ 98660.39627134302 │         16500.0 │        390000.0 │
│ Business Analyst │        220000.0 │       1962 │ 98660.39627134302 │         16500.0 │        390000.0 │
│ Business Analyst │        214500.0 │       1962 │ 98660.39627134302 │         16500.0 │        390000.0 │
│ Business Analyst │        214500.0 │       1962 │ 98660.39627134302 │         16500.0 │        390000.0 │
│ Business Analyst │        214000.0 │       1962 │ 98660.39627134302 │         16500.0 │        390000.0 │
├──────────────────┴─────────────────┴────────────┴───────────────────┴─────────────────┴─────────────────┤
│ 20 rows                                                                                       6 columns │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

-- How does each posting compare to its role average?
SELECT
    job_title_short,
    salary_year_avg,
    AVG(salary_year_avg) OVER (PARTITION BY job_title_short) AS role_avg,
    salary_year_avg - AVG(salary_year_avg) OVER (PARTITION BY job_title_short) AS diff_from_avg,
    ROUND(
        100.0 * salary_year_avg /
        AVG(salary_year_avg) OVER (PARTITION BY job_title_short),
        1
    ) AS pct_of_avg
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
ORDER BY pct_of_avg DESC
LIMIT 20;
/*

┌───────────────────────────┬─────────────────┬────────────────────┬────────────────────┬────────────┐
│      job_title_short      │ salary_year_avg │      role_avg      │   diff_from_avg    │ pct_of_avg │
│          varchar          │     double      │       double       │       double       │   double   │
├───────────────────────────┼─────────────────┼────────────────────┼────────────────────┼────────────┤
│ Data Scientist            │        960000.0 │ 134324.05013149753 │  825675.9498685024 │      714.7 │
│ Data Analyst              │        650000.0 │   93223.1844804113 │  556776.8155195887 │      697.3 │
│ Data Scientist            │        920000.0 │ 134324.05013149753 │  785675.9498685024 │      684.9 │
│ Data Scientist            │        870000.0 │ 134324.05013149753 │  735675.9498685024 │      647.7 │
│ Machine Learning Engineer │        875000.0 │  137331.7497598857 │  737668.2502401143 │      637.1 │
│ Data Scientist            │        850000.0 │ 134324.05013149753 │  715675.9498685024 │      632.8 │
│ Machine Learning Engineer │        800000.0 │  137331.7497598857 │  662668.2502401143 │      582.5 │
│ Senior Data Scientist     │        890000.0 │ 156390.76072875268 │  733609.2392712473 │      569.1 │
│ Senior Data Engineer      │        800000.0 │ 149222.25039026805 │   650777.749609732 │      536.1 │
│ Data Scientist            │        680000.0 │ 134324.05013149753 │  545675.9498685024 │      506.2 │
│ Data Analyst              │        445000.0 │   93223.1844804113 │  351776.8155195887 │      477.3 │
│ Data Analyst              │        445000.0 │   93223.1844804113 │  351776.8155195887 │      477.3 │
│ Data Analyst              │        445000.0 │   93223.1844804113 │  351776.8155195887 │      477.3 │
│ Data Scientist            │        640000.0 │ 134324.05013149753 │ 505675.94986850244 │      476.5 │
│ Data Engineer             │        640000.0 │ 134867.11449966236 │ 505132.88550033764 │      474.5 │
│ Data Scientist            │        585000.0 │ 134324.05013149753 │ 450675.94986850244 │      435.5 │
│ Data Analyst              │        400000.0 │   93223.1844804113 │  306776.8155195887 │      429.1 │
│ Data Analyst              │        385000.0 │   93223.1844804113 │  291776.8155195887 │      413.0 │
│ Data Scientist            │        550000.0 │ 134324.05013149753 │ 415675.94986850244 │      409.5 │
│ Data Analyst              │        375000.0 │   93223.1844804113 │  281776.8155195887 │      402.3 │
├───────────────────────────┴─────────────────┴────────────────────┴────────────────────┴────────────┤
│ 20 rows                                                                                  5 columns │
└────────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

-- ============================================================
-- NTILE — Split Into Buckets
-- ============================================================

-- Divide salaries into quartiles
SELECT
    job_title_short,
    salary_year_avg,
    NTILE(4) OVER (ORDER BY salary_year_avg) AS salary_quartile
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
LIMIT 20;
/*

┌───────────────────────────┬─────────────────┬─────────────────┐
│      job_title_short      │ salary_year_avg │ salary_quartile │
│          varchar          │     double      │      int64      │
├───────────────────────────┼─────────────────┼─────────────────┤
│ Cloud Engineer            │         15000.0 │               1 │
│ Data Engineer             │         15000.0 │               1 │
│ Data Engineer             │         15000.0 │               1 │
│ Business Analyst          │         16500.0 │               1 │
│ Data Scientist            │         16800.0 │               1 │
│ Data Scientist            │         17772.0 │               1 │
│ Data Analyst              │         18000.0 │               1 │
│ Data Engineer             │         18000.0 │               1 │
│ Data Analyst              │         19000.0 │               1 │
│ Cloud Engineer            │         19200.0 │               1 │
│ Data Analyst              │         20000.0 │               1 │
│ Data Engineer             │         20000.0 │               1 │
│ Data Scientist            │         20100.5 │               1 │
│ Data Scientist            │         20100.5 │               1 │
│ Data Analyst              │         21000.0 │               1 │
│ Data Analyst              │         21000.0 │               1 │
│ Business Analyst          │         21750.0 │               1 │
│ Software Engineer         │         21880.0 │               1 │
│ Software Engineer         │         22000.0 │               1 │
│ Machine Learning Engineer │         22000.0 │               1 │
├───────────────────────────┴─────────────────┴─────────────────┤
│ 20 rows                                             3 columns │
└───────────────────────────────────────────────────────────────┘
*/

-- Salary quartiles within each role
SELECT
    job_title_short,
    salary_year_avg,
    NTILE(4) OVER (
        PARTITION BY job_title_short
        ORDER BY salary_year_avg
    ) AS salary_quartile
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
ORDER BY job_title_short, salary_quartile
LIMIT 20;
/*

┌──────────────────┬─────────────────┬─────────────────┐
│ job_title_short  │ salary_year_avg │ salary_quartile │
│     varchar      │     double      │      int64      │
├──────────────────┼─────────────────┼─────────────────┤
│ Business Analyst │         24000.0 │               1 │
│ Business Analyst │         21750.0 │               1 │
│ Business Analyst │         25000.0 │               1 │
│ Business Analyst │         30000.0 │               1 │
│ Business Analyst │         25000.0 │               1 │
│ Business Analyst │         29900.0 │               1 │
│ Business Analyst │         23000.0 │               1 │
│ Business Analyst │         34560.0 │               1 │
│ Business Analyst │         34400.0 │               1 │
│ Business Analyst │         34400.0 │               1 │
│ Business Analyst │         31000.0 │               1 │
│ Business Analyst │         32000.0 │               1 │
│ Business Analyst │         30000.0 │               1 │
│ Business Analyst │         30000.0 │               1 │
│ Business Analyst │         34400.0 │               1 │
│ Business Analyst │         34400.0 │               1 │
│ Business Analyst │         32000.0 │               1 │
│ Business Analyst │         16500.0 │               1 │
│ Business Analyst │         34400.0 │               1 │
│ Business Analyst │         34400.0 │               1 │
├──────────────────┴─────────────────┴─────────────────┤
│ 20 rows                                    3 columns │
└──────────────────────────────────────────────────────┘    
*/


-- ============================================================
-- FIRST_VALUE / LAST_VALUE
-- ============================================================

-- What's the highest salary for each role?
-- (without collapsing rows)
SELECT
    job_title_short,
    salary_year_avg,
    FIRST_VALUE(salary_year_avg) OVER (
        PARTITION BY job_title_short
        ORDER BY salary_year_avg DESC
    ) AS highest_in_role,
    salary_year_avg / FIRST_VALUE(salary_year_avg) OVER (
        PARTITION BY job_title_short
        ORDER BY salary_year_avg DESC
    ) AS pct_of_highest
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
ORDER BY job_title_short, salary_year_avg DESC
LIMIT 20;
/*

┌──────────────────┬─────────────────┬─────────────────┬────────────────────┐
│ job_title_short  │ salary_year_avg │ highest_in_role │   pct_of_highest   │
│     varchar      │     double      │     double      │       double       │
├──────────────────┼─────────────────┼─────────────────┼────────────────────┤
│ Business Analyst │        390000.0 │        390000.0 │                1.0 │
│ Business Analyst │        387460.0 │        390000.0 │ 0.9934871794871795 │
│ Business Analyst │        286000.0 │        390000.0 │ 0.7333333333333333 │
│ Business Analyst │        268500.0 │        390000.0 │ 0.6884615384615385 │
│ Business Analyst │        264000.0 │        390000.0 │  0.676923076923077 │
│ Business Analyst │        264000.0 │        390000.0 │  0.676923076923077 │
│ Business Analyst │        264000.0 │        390000.0 │  0.676923076923077 │
│ Business Analyst │        257937.0 │        390000.0 │ 0.6613769230769231 │
│ Business Analyst │        257500.0 │        390000.0 │ 0.6602564102564102 │
│ Business Analyst │        250000.0 │        390000.0 │ 0.6410256410256411 │
│ Business Analyst │        250000.0 │        390000.0 │ 0.6410256410256411 │
│ Business Analyst │        243500.0 │        390000.0 │ 0.6243589743589744 │
│ Business Analyst │        230000.0 │        390000.0 │ 0.5897435897435898 │
│ Business Analyst │        229000.0 │        390000.0 │ 0.5871794871794872 │
│ Business Analyst │        226000.0 │        390000.0 │ 0.5794871794871795 │
│ Business Analyst │        220000.0 │        390000.0 │ 0.5641025641025641 │
│ Business Analyst │        220000.0 │        390000.0 │ 0.5641025641025641 │
│ Business Analyst │        214500.0 │        390000.0 │               0.55 │
│ Business Analyst │        214500.0 │        390000.0 │               0.55 │
│ Business Analyst │        214000.0 │        390000.0 │ 0.5487179487179488 │
├──────────────────┴─────────────────┴─────────────────┴────────────────────┤
│ 20 rows                                                         4 columns │
└───────────────────────────────────────────────────────────────────────────┘
*/

-- ============================================================
-- REAL PATTERN: De-duplication with Window Functions
-- ============================================================
-- This is probably the #1 use of window functions in data
-- engineering. You get duplicate records and need to keep
-- only the latest one.

-- Scenario: keep only the most recent posting per company per role
WITH deduped AS (
    SELECT
        company_id,
        job_title_short,
        job_title,
        salary_year_avg,
        job_posted_date,
        ROW_NUMBER() OVER (
            PARTITION BY company_id, job_title_short
            ORDER BY job_posted_date DESC
        ) AS rn
    FROM job_postings_fact
    WHERE salary_year_avg IS NOT NULL
)
SELECT
    company_id,
    job_title_short,
    job_title,
    salary_year_avg,
    job_posted_date
FROM deduped
WHERE rn = 1
ORDER BY salary_year_avg DESC
LIMIT 20;
/*

┌────────────┬───────────────────────────┬───────────────────────────────────────────────────────────┬─────────────────┬─────────────────────┐
│ company_id │      job_title_short      │                         job_title                         │ salary_year_avg │   job_posted_date   │
│   int32    │          varchar          │                          varchar                          │     double      │      timestamp      │
├────────────┼───────────────────────────┼───────────────────────────────────────────────────────────┼─────────────────┼─────────────────────┤
│     673003 │ Senior Data Scientist     │ Senior Data Scientist                                     │        890000.0 │ 2023-11-02 10:31:43 │
│     196988 │ Machine Learning Engineer │ Machine Learning Engineer                                 │        875000.0 │ 2025-05-22 16:01:12 │
│      16513 │ Data Scientist            │ Machine Learning Engineer/Data Scientist                  │        870000.0 │ 2024-05-10 12:41:47 │
│     856772 │ Data Scientist            │ Data Scientist                                            │        850000.0 │ 2024-02-07 07:02:57 │
│    1591743 │ Machine Learning Engineer │ AI/ML (Artificial Intelligence/Machine Learning) Engineer │        800000.0 │ 2025-06-04 13:10:10 │
│      13459 │ Senior Data Engineer      │ Senior Data Engineer (MDM team), DTG                      │        800000.0 │ 2025-03-08 07:08:29 │
│       8183 │ Data Scientist            │ Data Scientist , Games [Remote]                           │        680000.0 │ 2025-05-21 06:18:18 │
│     142665 │ Data Analyst              │ Data Analyst                                              │        650000.0 │ 2023-02-20 15:13:44 │
│     140291 │ Data Scientist            │ Geographic Information Systems Analyst - GIS Analyst      │        585000.0 │ 2023-12-27 18:00:12 │
│     596617 │ Senior Data Scientist     │ VP Data Science & Research                                │        463500.0 │ 2023-11-08 12:23:39 │
│       8183 │ Senior Data Scientist     │ Senior Data Scientist                                     │        445000.0 │ 2024-03-13 02:36:48 │
│       8183 │ Data Engineer             │ Data Engineer - Content Production & Promotion [Remote]   │        445000.0 │ 2025-06-21 06:05:38 │
│     313314 │ Senior Data Engineer      │ Senior Data Engineer, Security Master                     │        425000.0 │ 2023-05-26 10:41:16 │
│    1291078 │ Software Engineer         │ PhD Computer Scientist/Software Developer $1M+            │        425000.0 │ 2025-01-08 21:01:40 │
│      93390 │ Senior Data Analyst       │ Senior Data Analyst                                       │        420000.0 │ 2024-06-27 07:00:29 │
│     101348 │ Data Engineer             │ Data Engineer                                             │        400000.0 │ 2024-04-16 15:06:27 │
│     234407 │ Data Engineer             │ Data Engineer                                             │        400000.0 │ 2024-05-28 09:24:14 │
│     607936 │ Data Analyst              │ Data base administrator                                   │        400000.0 │ 2023-10-03 11:22:20 │
│    1017628 │ Machine Learning Engineer │ Principal Machine Learning Engineer                       │        400000.0 │ 2024-05-17 20:03:03 │
│     951196 │ Business Analyst          │ Старший продуктовый аналитик                              │        390000.0 │ 2024-04-02 12:16:44 │
├────────────┴───────────────────────────┴───────────────────────────────────────────────────────────┴─────────────────┴─────────────────────┤
│ 20 rows                                                                                                                          5 columns │
└────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

-- In real ETL pipelines, this pattern is everywhere:
--   1. Data arrives with duplicates
--   2. Use ROW_NUMBER() PARTITION BY the unique key
--      ORDER BY the "freshness" column (date, version, etc.)
--   3. Filter rn = 1


-- ============================================================
-- REAL PATTERN: Percentile Ranking
-- ============================================================

SELECT
    job_title_short,
    salary_year_avg,
    PERCENT_RANK() OVER (
        PARTITION BY job_title_short
        ORDER BY salary_year_avg
    ) AS percentile
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
ORDER BY job_title_short, percentile DESC
LIMIT 20;
/*

┌──────────────────┬─────────────────┬────────────────────┐
│ job_title_short  │ salary_year_avg │     percentile     │
│     varchar      │     double      │       double       │
├──────────────────┼─────────────────┼────────────────────┤
│ Business Analyst │        390000.0 │                1.0 │
│ Business Analyst │        387460.0 │ 0.9994900560938297 │
│ Business Analyst │        286000.0 │ 0.9989801121876594 │
│ Business Analyst │        268500.0 │  0.998470168281489 │
│ Business Analyst │        264000.0 │ 0.9969403365629781 │
│ Business Analyst │        264000.0 │ 0.9969403365629781 │
│ Business Analyst │        264000.0 │ 0.9969403365629781 │
│ Business Analyst │        257937.0 │ 0.9964303926568078 │
│ Business Analyst │        257500.0 │ 0.9959204487506375 │
│ Business Analyst │        250000.0 │ 0.9949005609382968 │
│ Business Analyst │        250000.0 │ 0.9949005609382968 │
│ Business Analyst │        243500.0 │ 0.9943906170321265 │
│ Business Analyst │        230000.0 │ 0.9938806731259562 │
│ Business Analyst │        229000.0 │ 0.9933707292197859 │
│ Business Analyst │        226000.0 │ 0.9928607853136155 │
│ Business Analyst │        220000.0 │ 0.9918408975012749 │
│ Business Analyst │        220000.0 │ 0.9918408975012749 │
│ Business Analyst │        214500.0 │ 0.9908210096889342 │
│ Business Analyst │        214500.0 │ 0.9908210096889342 │
│ Business Analyst │        214000.0 │ 0.9898011218765935 │
├──────────────────┴─────────────────┴────────────────────┤
│ 20 rows                                       3 columns │
└─────────────────────────────────────────────────────────┘
*/

-- Find the 90th percentile salary for each role
WITH ranked AS (
    SELECT
        job_title_short,
        salary_year_avg,
        PERCENT_RANK() OVER (
            PARTITION BY job_title_short
            ORDER BY salary_year_avg
        ) AS percentile
    FROM job_postings_fact
    WHERE salary_year_avg IS NOT NULL
)
SELECT
    job_title_short,
    MIN(salary_year_avg) AS p90_salary
FROM ranked
WHERE percentile >= 0.90
GROUP BY job_title_short
ORDER BY p90_salary DESC;
/*

┌───────────────────────────┬──────────────┐
│      job_title_short      │  p90_salary  │
│          varchar          │    double    │
├───────────────────────────┼──────────────┤
│ Machine Learning Engineer │     211000.0 │
│ Software Engineer         │     210000.0 │
│ Senior Data Scientist     │     206000.0 │
│ Data Scientist            │     200500.0 │
│ Cloud Engineer            │     197500.0 │
│ Senior Data Engineer      │     195708.0 │
│ Data Engineer             │     190226.0 │
│ Senior Data Analyst       │     156000.0 │
│ Business Analyst          │ 145485.59375 │
│ Data Analyst              │     130098.5 │
├───────────────────────────┴──────────────┤
│ 10 rows                        2 columns │
└──────────────────────────────────────────┘
*/


-- ============================================================
-- MULTIPLE WINDOW DEFINITIONS (WINDOW clause)
-- ============================================================
-- When you use the same OVER clause multiple times,
-- you can define it once with WINDOW.

SELECT
    job_title_short,
    salary_year_avg,
    ROW_NUMBER() OVER w AS row_num,
    RANK() OVER w AS rank,
    AVG(salary_year_avg) OVER w AS running_avg
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
WINDOW w AS (PARTITION BY job_title_short ORDER BY salary_year_avg DESC)
LIMIT 20;
/*

┌─────────────────────┬─────────────────┬─────────┬───────┬────────────────────┐
│   job_title_short   │ salary_year_avg │ row_num │ rank  │    running_avg     │
│       varchar       │     double      │  int64  │ int64 │       double       │
├─────────────────────┼─────────────────┼─────────┼───────┼────────────────────┤
│ Senior Data Analyst │         55000.0 │    2544 │  2543 │  117178.8782911648 │
│ Senior Data Analyst │         55000.0 │    2545 │  2543 │  117178.8782911648 │
│ Senior Data Analyst │         55000.0 │    2546 │  2543 │  117178.8782911648 │
│ Senior Data Analyst │         55000.0 │    2547 │  2543 │  117178.8782911648 │
│ Senior Data Analyst │         55000.0 │    2548 │  2543 │  117178.8782911648 │
│ Senior Data Analyst │         55000.0 │    2549 │  2543 │  117178.8782911648 │
│ Senior Data Analyst │         55000.0 │    2550 │  2543 │  117178.8782911648 │
│ Senior Data Analyst │         55000.0 │    2551 │  2543 │  117178.8782911648 │
│ Senior Data Analyst │         55000.0 │    2552 │  2543 │  117178.8782911648 │
│ Senior Data Analyst │         55000.0 │    2553 │  2543 │  117178.8782911648 │
│ Senior Data Analyst │         54373.0 │    2554 │  2554 │   117154.287109375 │
│ Senior Data Analyst │         53000.0 │    2555 │  2555 │ 117079.01809829635 │
│ Senior Data Analyst │         53000.0 │    2556 │  2555 │ 117079.01809829635 │
│ Senior Data Analyst │         53000.0 │    2557 │  2555 │ 117079.01809829635 │
│ Senior Data Analyst │         52250.0 │    2558 │  2558 │ 117053.67446338692 │
│ Senior Data Analyst │         52000.0 │    2559 │  2559 │    116952.10744627 │
│ Senior Data Analyst │         52000.0 │    2560 │  2559 │    116952.10744627 │
│ Senior Data Analyst │         52000.0 │    2561 │  2559 │    116952.10744627 │
│ Senior Data Analyst │         52000.0 │    2562 │  2559 │    116952.10744627 │
│ Senior Data Analyst │         51962.0 │    2563 │  2563 │ 116926.75040083642 │
├─────────────────────┴─────────────────┴─────────┴───────┴────────────────────┤
│ 20 rows                                                            5 columns │
└──────────────────────────────────────────────────────────────────────────────┘
*/

-- Cleaner than repeating the same OVER clause 3 times.


-- ============================================================
-- CHEAT SHEET
-- ============================================================
-- ROW_NUMBER()  — unique sequential number per partition
-- RANK()        — same rank for ties, gaps after
-- DENSE_RANK()  — same rank for ties, no gaps
-- NTILE(n)      — split into n equal buckets
-- LAG(col, n)   — value from n rows back (default 1)
-- LEAD(col, n)  — value from n rows ahead
-- FIRST_VALUE() — first value in window frame
-- LAST_VALUE()  — last value in window frame (careful with frame!)
-- SUM/AVG/etc.  — aggregate over window without collapsing
-- PERCENT_RANK()— percentile ranking (0 to 1)
--
-- Key patterns:
-- - Top N per group: ROW_NUMBER + CTE + WHERE rn <= N
-- - Dedup: ROW_NUMBER + CTE + WHERE rn = 1
-- - Period-over-period: LAG/LEAD
-- - Running totals: SUM() OVER (ORDER BY ...)
-- - Moving average: AVG() OVER (ROWS BETWEEN ... AND ...)


-- ============================================================
-- TRY THIS
-- ============================================================
-- 1. Find the top 3 highest-paying job postings for each role
--    (use ROW_NUMBER + CTE)
--
-- 2. Calculate the month-over-month percentage change in
--    Data Engineer postings specifically
--
-- 3. For each job posting, show the salary and what percentile
--    it falls in within its role. Filter to only show postings
--    that are in the top 10% (percentile >= 0.9)
--
-- 4. Calculate a 3-month moving average of average salary
--    for Data Analyst postings
