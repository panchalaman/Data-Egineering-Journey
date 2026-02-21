SELECT 
job_id,
job_work_from_home,
job_posted_date,
salary_year_avg
FROM
    job_postings_fact
LIMIT 10; 

SELECT 
job_id,
CAST(job_work_from_home AS INT) AS work_from_home,
CAST(job_posted_date AS DATE) AS job_posted_date,
(salary_year_avg::DECIMAL(10,0) ||'-'|| salary_year_avg::DECIMAL(10,0)) AS salary_year_avg,
FROM
    job_postings_fact
WHERE salary_year_avg IS NOT NULL
LIMIT 10; 