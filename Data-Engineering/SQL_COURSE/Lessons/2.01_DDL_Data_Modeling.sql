-- ============================================================
-- LESSON 2.01: DDL & Data Modeling
-- ============================================================
-- DDL = Data Definition Language. This is how you CREATE, ALTER,
-- and DROP tables. If you want to be a Data Engineer and not
-- just an analyst, you NEED to know this stuff. Analysts query
-- tables. Engineers build them.
--
-- This lesson covers:
--   - Creating tables
--   - Data types
--   - Constraints
--   - Star schema design
--   - Building dimension and fact tables
-- ============================================================


-- ============================================================
-- DATA TYPES
-- ============================================================
-- Every column needs a data type. Pick the right one or you'll
-- regret it later (bloated storage, broken queries, etc.)

-- Common types in DuckDB / PostgreSQL:
--
-- INTEGERS:
--   TINYINT     -128 to 127
--   SMALLINT    -32,768 to 32,767
--   INTEGER     -2 billion to 2 billion (most common)
--   BIGINT      -9 quintillion to 9 quintillion (for IDs)
--
-- DECIMALS:
--   FLOAT       approximate decimal (don't use for money!)
--   DOUBLE      more precision, still approximate
--   DECIMAL(p,s) exact decimal — p total digits, s after decimal
--   NUMERIC     same as DECIMAL
--   -- Use DECIMAL for money. Always. Floats have rounding errors.
--
-- TEXT:
--   VARCHAR     variable-length text (most common)
--   VARCHAR(n)  text with max length n
--   TEXT        same as VARCHAR in most databases
--   CHAR(n)     fixed-length text (rarely used)
--
-- DATE/TIME:
--   DATE        just the date: 2024-03-15
--   TIME        just the time: 14:30:00
--   TIMESTAMP   date + time: 2024-03-15 14:30:00
--   INTERVAL    a duration: '3 days', '2 hours'
--
-- OTHER:
--   BOOLEAN     true/false
--   UUID        universally unique ID
--   JSON        JSON data (DuckDB has great JSON support)

-- See what types exist in our tables:
DESCRIBE job_postings_fact;
DESCRIBE company_dim;
DESCRIBE skills_dim;
DESCRIBE skills_job_dim;
/*

D DESCRIBE job_postings_fact;
┌───────────────────────┬─────────────┬─────────┬─────────┬─────────┬─────────┐
│      column_name      │ column_type │  null   │   key   │ default │  extra  │
│        varchar        │   varchar   │ varchar │ varchar │ varchar │ varchar │
├───────────────────────┼─────────────┼─────────┼─────────┼─────────┼─────────┤
│ job_id                │ INTEGER     │ NO      │ PRI     │ NULL    │ NULL    │
│ company_id            │ INTEGER     │ YES     │ NULL    │ NULL    │ NULL    │
│ job_title_short       │ VARCHAR     │ YES     │ NULL    │ NULL    │ NULL    │
│ job_title             │ VARCHAR     │ YES     │ NULL    │ NULL    │ NULL    │
│ job_location          │ VARCHAR     │ YES     │ NULL    │ NULL    │ NULL    │
│ job_via               │ VARCHAR     │ YES     │ NULL    │ NULL    │ NULL    │
│ job_schedule_type     │ VARCHAR     │ YES     │ NULL    │ NULL    │ NULL    │
│ job_work_from_home    │ BOOLEAN     │ YES     │ NULL    │ NULL    │ NULL    │
│ search_location       │ VARCHAR     │ YES     │ NULL    │ NULL    │ NULL    │
│ job_posted_date       │ TIMESTAMP   │ YES     │ NULL    │ NULL    │ NULL    │
│ job_no_degree_mention │ BOOLEAN     │ YES     │ NULL    │ NULL    │ NULL    │
│ job_health_insurance  │ BOOLEAN     │ YES     │ NULL    │ NULL    │ NULL    │
│ job_country           │ VARCHAR     │ YES     │ NULL    │ NULL    │ NULL    │
│ salary_rate           │ VARCHAR     │ YES     │ NULL    │ NULL    │ NULL    │
│ salary_year_avg       │ DOUBLE      │ YES     │ NULL    │ NULL    │ NULL    │
│ salary_hour_avg       │ DOUBLE      │ YES     │ NULL    │ NULL    │ NULL    │
├───────────────────────┴─────────────┴─────────┴─────────┴─────────┴─────────┤
│ 16 rows                                                           6 columns │
└─────────────────────────────────────────────────────────────────────────────┘
D DESCRIBE company_dim;
┌─────────────┬─────────────┬─────────┬─────────┬─────────┬─────────┐
│ column_name │ column_type │  null   │   key   │ default │  extra  │
│   varchar   │   varchar   │ varchar │ varchar │ varchar │ varchar │
├─────────────┼─────────────┼─────────┼─────────┼─────────┼─────────┤
│ company_id  │ INTEGER     │ NO      │ PRI     │ NULL    │ NULL    │
│ name        │ VARCHAR     │ YES     │ NULL    │ NULL    │ NULL    │
│ link        │ VARCHAR     │ YES     │ NULL    │ NULL    │ NULL    │
│ link_google │ VARCHAR     │ YES     │ NULL    │ NULL    │ NULL    │
│ thumbnail   │ VARCHAR     │ YES     │ NULL    │ NULL    │ NULL    │
└─────────────┴─────────────┴─────────┴─────────┴─────────┴─────────┘
D DESCRIBE skills_dim;
┌─────────────┬─────────────┬─────────┬─────────┬─────────┬─────────┐
│ column_name │ column_type │  null   │   key   │ default │  extra  │
│   varchar   │   varchar   │ varchar │ varchar │ varchar │ varchar │
├─────────────┼─────────────┼─────────┼─────────┼─────────┼─────────┤
│ skill_id    │ INTEGER     │ NO      │ PRI     │ NULL    │ NULL    │
│ skills      │ VARCHAR     │ YES     │ NULL    │ NULL    │ NULL    │
│ type        │ VARCHAR     │ YES     │ NULL    │ NULL    │ NULL    │
└─────────────┴─────────────┴─────────┴─────────┴─────────┴─────────┘
D DESCRIBE skills_job_dim;
┌─────────────┬─────────────┬─────────┬─────────┬─────────┬─────────┐
│ column_name │ column_type │  null   │   key   │ default │  extra  │
│   varchar   │   varchar   │ varchar │ varchar │ varchar │ varchar │
├─────────────┼─────────────┼─────────┼─────────┼─────────┼─────────┤
│ skill_id    │ INTEGER     │ NO      │ PRI     │ NULL    │ NULL    │
│ job_id      │ INTEGER     │ NO      │ PRI     │ NULL    │ NULL    │
└─────────────┴─────────────┴─────────┴─────────┴─────────┴─────────┘
*/


-- ============================================================
-- CREATE TABLE
-- ============================================================

-- Basic syntax:
CREATE TABLE demo_employees (
    employee_id INTEGER PRIMARY KEY,
    name VARCHAR NOT NULL,
    department VARCHAR,
    salary DECIMAL(10, 2),
    hire_date DATE,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- INSERT some data to test
INSERT INTO demo_employees (employee_id, name, department, salary, hire_date)
VALUES
    (1, 'Alice', 'Engineering', 125000.00, '2022-01-15'),
    (2, 'Bob', 'Data', 115000.00, '2022-06-01'),
    (3, 'Charlie', 'Data', 105000.00, '2023-03-10'),
    (4, 'Diana', 'Engineering', 135000.00, '2021-11-20'),
    (5, 'Eve', 'Marketing', 95000.00, '2023-08-05');

SELECT * FROM demo_employees;

-- Clean up
DROP TABLE IF EXISTS demo_employees;


-- ============================================================
-- CONSTRAINTS
-- ============================================================
-- Constraints enforce data quality. This is where you prevent
-- garbage from getting into your tables.

CREATE TABLE demo_constrained (
    id INTEGER PRIMARY KEY,                     -- unique, not null
    email VARCHAR UNIQUE NOT NULL,              -- no duplicates
    age INTEGER CHECK (age >= 18 AND age <= 120), -- range check
    department_id INTEGER NOT NULL,
    salary DECIMAL(10, 2) DEFAULT 0.00,
    status VARCHAR DEFAULT 'active'
);

-- PRIMARY KEY: uniquely identifies each row. Every table needs one.
-- UNIQUE: no duplicate values allowed in this column.
-- NOT NULL: this column can't be empty.
-- CHECK: custom validation rule.
-- DEFAULT: value to use if none is provided.
-- FOREIGN KEY: references another table (covered below).

DROP TABLE IF EXISTS demo_constrained;


-- ============================================================
-- CREATE TABLE AS (CTAS)
-- ============================================================
-- This is the workhorse of data engineering. You don't manually
-- define columns — you let the query define the schema.

CREATE TABLE high_paying_data_jobs AS
SELECT
    job_id,
    job_title,
    job_title_short,
    job_location,
    salary_year_avg,
    job_posted_date
FROM job_postings_fact
WHERE
    job_title_short = 'Data Engineer'
    AND salary_year_avg > 150000;

SELECT COUNT(*) FROM high_paying_data_jobs;
SELECT * FROM high_paying_data_jobs LIMIT 5;

-- CTAS is everywhere in ETL:
--   - Staging tables
--   - Transformed tables
--   - Data marts
-- It's way faster than INSERT INTO ... SELECT and
-- the schema comes from the query itself.

DROP TABLE IF EXISTS high_paying_data_jobs;


-- ============================================================
-- ALTER TABLE
-- ============================================================

CREATE TABLE demo_alter (
    id INTEGER PRIMARY KEY,
    name VARCHAR
);

-- Add a column
ALTER TABLE demo_alter ADD COLUMN email VARCHAR;

-- Drop a column
ALTER TABLE demo_alter DROP COLUMN email;

-- Rename a column
ALTER TABLE demo_alter RENAME COLUMN name TO full_name;

-- Rename the table
ALTER TABLE demo_alter RENAME TO demo_renamed;

DROP TABLE IF EXISTS demo_renamed;


-- ============================================================
-- DROP TABLE
-- ============================================================

-- Careful with this one. There's no undo.
DROP TABLE IF EXISTS some_table;

-- IF EXISTS prevents errors when the table doesn't exist.
-- Always use IF EXISTS in scripts so they're idempotent
-- (you can run them multiple times without errors).


-- ============================================================
-- VIEWS
-- ============================================================
-- A view is a saved query. It doesn't store data — it's just
-- a named SELECT that runs whenever you query the view.

CREATE OR REPLACE VIEW v_data_engineer_salaries AS
SELECT
    jpf.job_id,
    jpf.job_title,
    cd.name AS company_name,
    jpf.job_location,
    jpf.salary_year_avg,
    jpf.job_posted_date
FROM job_postings_fact jpf
LEFT JOIN company_dim cd ON jpf.company_id = cd.company_id
WHERE
    jpf.job_title_short = 'Data Engineer'
    AND jpf.salary_year_avg IS NOT NULL;

-- Now query it like a table
SELECT * FROM v_data_engineer_salaries LIMIT 10;

-- Views are great for:
-- - Hiding complex joins behind simple names
-- - Access control (expose only certain columns)
-- - Standardizing business logic

DROP VIEW IF EXISTS v_data_engineer_salaries;


-- ============================================================
-- TEMPORARY TABLES
-- ============================================================
-- Temp tables exist only for your session. They disappear when
-- you disconnect. Perfect for intermediate pipeline steps.

CREATE TEMP TABLE temp_skills_summary AS
SELECT
    sd.skills AS skill_name,
    COUNT(*) AS demand_count,
    ROUND(AVG(jpf.salary_year_avg), 0) AS avg_salary
FROM skills_job_dim sjd
JOIN job_postings_fact jpf ON sjd.job_id = jpf.job_id
JOIN skills_dim sd ON sjd.skill_id = sd.skill_id
WHERE jpf.salary_year_avg IS NOT NULL
GROUP BY sd.skills;

SELECT * FROM temp_skills_summary
ORDER BY demand_count DESC
LIMIT 10;

DROP TABLE IF EXISTS temp_skills_summary;


-- ============================================================
-- SCHEMAS
-- ============================================================
-- Schemas are like folders for your tables. They organize
-- a database into logical sections.
--
-- Common schema layouts:
--   raw.        — original source data, untouched
--   staging.    — cleaned, typed, deduplicated
--   warehouse.  — star/snowflake schema, modeled data
--   marts.      — business-specific aggregations
--
-- In DuckDB:
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS warehouse;

CREATE TABLE staging.raw_jobs AS
SELECT * FROM job_postings_fact LIMIT 100;

SELECT * FROM staging.raw_jobs LIMIT 5;

DROP TABLE IF EXISTS staging.raw_jobs;
DROP SCHEMA IF EXISTS staging;
DROP SCHEMA IF EXISTS warehouse;


-- ============================================================
-- STAR SCHEMA DESIGN
-- ============================================================
-- This is THE data modeling pattern for analytics.
-- Our dataset already uses it, so let's understand why.
--
-- FACT TABLE (job_postings_fact):
--   - Contains the "events" or "measurements"
--   - Each row is a THING THAT HAPPENED (a job was posted)
--   - Stores foreign keys to dimension tables
--   - Stores measurable values (salary)
--   - Usually the BIGGEST table
--
-- DIMENSION TABLES (company_dim, skills_dim):
--   - Contain the "context" or "attributes"
--   - WHO posted the job? (company_dim)
--   - WHAT skills are needed? (skills_dim)
--   - Usually SMALLER tables
--   - Rarely change (slowly changing dimensions)
--
-- BRIDGE TABLE (skills_job_dim):
--   - Handles many-to-many relationships
--   - One job can have many skills
--   - One skill can appear in many jobs
--   - Bridge table connects them
--
-- Why star schema?
--   1. Simple to understand (fact in center, dims around it)
--   2. Fast queries (fewer joins than normalized)
--   3. Standard pattern every tool supports
--
-- Our schema looks like:
--
--   company_dim ──── job_postings_fact ──── skills_job_dim ──── skills_dim
--   (who)             (what happened)        (bridge)          (what skills)


-- ============================================================
-- BUILDING A STAR SCHEMA FROM SCRATCH
-- ============================================================
-- Let's build a mini version of our schema to understand
-- how fact/dimension tables are designed.

-- 1. Dimension tables first (they have no dependencies)

CREATE TABLE mini_company_dim (
    company_id INTEGER PRIMARY KEY,
    company_name VARCHAR NOT NULL,
    industry VARCHAR,
    company_size VARCHAR
);

CREATE TABLE mini_skills_dim (
    skill_id INTEGER PRIMARY KEY,
    skill_name VARCHAR NOT NULL,
    skill_category VARCHAR  -- 'Programming', 'Cloud', 'Database', etc.
);

-- 2. Fact table (references dimension tables)

CREATE TABLE mini_job_fact (
    job_id INTEGER PRIMARY KEY,
    company_id INTEGER REFERENCES mini_company_dim(company_id),
    job_title VARCHAR NOT NULL,
    salary DECIMAL(10, 2),
    job_location VARCHAR,
    posted_date DATE,
    is_remote BOOLEAN
);

-- 3. Bridge table (many-to-many between jobs and skills)

CREATE TABLE mini_skills_bridge (
    job_id INTEGER REFERENCES mini_job_fact(job_id),
    skill_id INTEGER REFERENCES mini_skills_dim(skill_id),
    PRIMARY KEY (job_id, skill_id)  -- composite key
);

-- Load some test data
INSERT INTO mini_company_dim VALUES
    (1, 'Google', 'Tech', 'Large'),
    (2, 'Stripe', 'Fintech', 'Medium');

INSERT INTO mini_skills_dim VALUES
    (1, 'SQL', 'Database'),
    (2, 'Python', 'Programming'),
    (3, 'AWS', 'Cloud');

INSERT INTO mini_job_fact VALUES
    (101, 1, 'Data Engineer', 165000, 'Mountain View, CA', '2024-01-15', false),
    (102, 2, 'Data Engineer', 175000, 'Remote', '2024-02-01', true);

INSERT INTO mini_skills_bridge VALUES
    (101, 1), (101, 2), (101, 3),  -- Google job needs SQL, Python, AWS
    (102, 1), (102, 2);             -- Stripe job needs SQL, Python

-- Query it like the real dataset
SELECT
    f.job_title,
    c.company_name,
    f.salary,
    s.skill_name
FROM mini_job_fact f
JOIN mini_company_dim c ON f.company_id = c.company_id
JOIN mini_skills_bridge b ON f.job_id = b.job_id
JOIN mini_skills_dim s ON b.skill_id = s.skill_id;

-- Clean up
DROP TABLE IF EXISTS mini_skills_bridge;
DROP TABLE IF EXISTS mini_job_fact;
DROP TABLE IF EXISTS mini_skills_dim;
DROP TABLE IF EXISTS mini_company_dim;


-- ============================================================
-- DATA MODELING BEST PRACTICES
-- ============================================================
-- Things I've learned from building the warehouse projects:
--
-- 1. ALWAYS have a primary key. No exceptions.
--
-- 2. Use INTEGER for IDs, not VARCHAR. Joins are faster.
--
-- 3. CTAS for initial loads, INSERT for incremental.
--
-- 4. Use IF EXISTS / IF NOT EXISTS everywhere.
--    Makes scripts re-runnable (idempotent).
--
-- 5. Name tables clearly:
--    _fact = fact tables
--    _dim  = dimension tables
--    _bridge or _link = bridge tables
--    v_    = views
--    stg_  = staging tables
--
-- 6. Document your schema. Future you will thank present you.
--
-- 7. Start simple. You can always add columns later
--    with ALTER TABLE. You can't easily remove them
--    if data depends on them.


-- ============================================================
-- TRY THIS
-- ============================================================
-- 1. Create a table called "skill_demand_mart" using CTAS that
--    has: skill_name, demand_count, avg_salary, min_salary,
--    max_salary — grouped by skill
--
-- 2. Create a view that joins job_postings_fact with company_dim
--    and shows only remote Data Engineer jobs with salaries
--
-- 3. Design a star schema for a different domain (e.g., an
--    e-commerce store). What would the fact table be?
--    What dimensions would surround it?
