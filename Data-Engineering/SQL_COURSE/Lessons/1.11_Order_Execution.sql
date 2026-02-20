/*
Order of commands in SQL:
SELECT column1, column 2...
FROM table1
JOIN table2
    ON join_condition
WHERE condition
GROUP BY column             (ALIASES accepted only in DUCKDB)
HAVING condition            (ALIASES accepted only in DUCKDB)
ORDER BY column1            (ALIASES accepted only in DUCKDB)
LIMIT number
*/
/*
Find the top 10 companies for posting jobs
*/



SELECT
    cd.name AS company_name,
    COUNT(jpf.*) AS posting_count
FROM job_postings_fact AS jpf
LEFT JOIN company_dim AS cd
    ON jpf.company_id = cd.company_id
GROUP BY cd.name;

------limit it only to the US jobs
SELECT
    cd.name AS company_name,
    COUNT(jpf.*) AS posting_count
FROM job_postings_fact AS jpf
LEFT JOIN company_dim AS cd
    ON jpf.company_id = cd.company_id
WHERE jpf.job_country = 'United States'
GROUP BY cd.name;

--they must have >3000 postings

SELECT
    cd.name AS company_name,
    COUNT(jpf.*) AS posting_count
FROM job_postings_fact AS jpf
LEFT JOIN company_dim AS cd
    ON jpf.company_id = cd.company_id
WHERE jpf.job_country = 'United States'
GROUP BY cd.name
HAVING COUNT(jpf.job_id)> 3000
ORDER BY posting_count DESC;

--EXPLAIN: shows execution plan without executing

EXPLAIN SELECT
    cd.name AS company_name,
    COUNT(jpf.*) AS posting_count
FROM job_postings_fact AS jpf
LEFT JOIN company_dim AS cd
    ON jpf.company_id = cd.company_id
WHERE jpf.job_country = 'United States'
GROUP BY cd.name;

--EXPLAIN ANALYSE: shows execution plan with executing (!CAUTION)

EXPLAIN ANALYSE SELECT
    cd.name AS company_name,
    COUNT(jpf.*) AS posting_count
FROM job_postings_fact AS jpf
LEFT JOIN company_dim AS cd
    ON jpf.company_id = cd.company_id
WHERE jpf.job_country = 'United States'
GROUP BY cd.name;