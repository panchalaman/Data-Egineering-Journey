
--LEFT JOIN
SELECT
    jpf.job_id,
    jpf.job_title_short,
    cd.company_id,
    cd.name AS company_name,
    jpf.job_location


FROM 
    job_postings_fact AS jpf

LEFT JOIN company_dim AS cd
    ON jpf.company_id = cd.company_id;

--RIGHT JOIN
SELECT
    jpf.job_id,
    jpf.job_title_short,
    cd.company_id,
    cd.name AS company_name,
    jpf.job_location


FROM 
    job_postings_fact AS jpf

RIGHT JOIN company_dim AS cd
    ON jpf.company_id = cd.company_id;

--INNER JOIN
SELECT
    jpf.job_id,
    jpf.job_title_short,
    cd.company_id,
    cd.name AS company_name,
    jpf.job_location


FROM 
    job_postings_fact AS jpf

INNER JOIN company_dim AS cd
    ON jpf.company_id = cd.company_id;

--FULL JOIN
SELECT
    jpf.job_id,
    jpf.job_title_short,
    cd.company_id,
    cd.name AS company_name,
    jpf.job_location


FROM 
    job_postings_fact AS jpf

FULL OUTER JOIN company_dim AS cd
    ON jpf.company_id = cd.company_id
LIMIT 10;


--MUtliple JOINS
SELECT
    jpf.job_id,
    jpf.job_title_short,
    sjd.skill_id,
    sd.skills

FROM job_postings_fact as jpf
LEFT JOIN skills_job_dim as sjd ON jpf.job_id = sjd.job_id
LEFT JOIN skills_dim AS sd ON sjd.skill_id = sd.skill_id;


--INNER JOIN

SELECT
    jpf.job_id,
    jpf.job_title_short,
    sjd.skill_id,
    sd.skills

FROM job_postings_fact as jpf
FULL JOIN skills_job_dim as sjd ON jpf.job_id = sjd.job_id
FULL JOIN skills_dim AS sd ON sjd.skill_id = sd.skill_id;
