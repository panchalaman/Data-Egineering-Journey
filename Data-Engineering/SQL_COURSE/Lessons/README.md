# SQL Lessons — From Zero to Data Engineer

This is a complete SQL course built around a real dataset of job postings. Every query here runs against DuckDB with a star schema of job postings, companies, and skills data.

I designed these lessons so someone starting from scratch can follow along in order and end up with the SQL chops needed for a data engineering role. Each lesson builds on the previous one, and every concept ties back to real use cases from the projects in this repo.

## Getting Started

**First time?** Follow the [Setup Guide](00_Setup.md) to install DuckDB and connect to the database. Takes about 5 minutes.

## How to Use These Lessons

1. Read the comments — they explain not just *what* the SQL does but *why* you'd use it
2. Run each query yourself in DuckDB
3. Try the exercises at the end of each lesson
4. When you feel comfortable, move to the [Projects](../Projects/) folder and apply what you learned

## The Dataset

Everything uses a star schema of tech job postings:

- **job_postings_fact** — The main table. Each row is a job posting with title, salary, location, date, etc.
- **company_dim** — Company details (name, link). Joined to facts via `company_id`.
- **skills_dim** — Skill names and categories. Joined through the bridge table.
- **skills_job_dim** — Bridge table connecting jobs to skills (many-to-many).

## Course Outline

### Part 1 — Querying Data

Start here. This covers everything you need to pull data out of a database.

| # | Lesson | What You'll Learn |
|---|--------|-------------------|
| 0 | [Setup Guide](00_Setup.md) | Install DuckDB, connect MotherDuck, verify the dataset |
| 1.01 | [What Is SQL](1.01_What_Is_SQL.sql) | Why SQL matters for data engineering, DuckDB setup, the dataset |
| 1.02 | [SELECT](1.02_SELECT.sql) | Reading data, aliases, DISTINCT, expressions, NULLs |
| 1.03 | [WHERE](1.03_WHERE.sql) | Filtering rows — comparisons, AND/OR, IN, BETWEEN, LIKE, IS NULL |
| 1.04 | [ORDER BY](1.04_ORDER_BY.sql) | Sorting results, LIMIT, OFFSET, NULLS FIRST/LAST |
| 1.05 | [GROUP BY](1.05_GROUP_BY.sql) | Aggregations — COUNT, AVG, SUM, MIN, MAX, HAVING, STRING_AGG |
| 1.06 | [CASE WHEN](1.06_CASE_WHEN.sql) | Conditional logic, salary bands, pivot-style aggregation |
| 1.07 | [JOINS](1.07_JOINS.sql) | INNER, LEFT, RIGHT, FULL, CROSS, SELF joins across the star schema |
| 1.08 | [Subqueries & CTEs](1.08_Subqueries_CTEs.sql) | Nested queries, WITH clauses, EXISTS, building complex pipelines |
| 1.09 | [Date & String Functions](1.09_Date_String_Functions.sql) | DATE_TRUNC, EXTRACT, string parsing, type casting, data cleaning |
| 1.10 | [Window Functions](1.10_Window_Functions.sql) | ROW_NUMBER, RANK, LAG/LEAD, running totals, deduplication |
| 1.11 | [JOINs (Practice)](1.11_JOIN.sql) | Additional JOIN practice queries |
| 1.12 | [Order of Execution](1.12_Order_Execution.sql) | How SQL actually processes your query (FROM → WHERE → GROUP BY → SELECT → ORDER BY) |

### Part 2 — Building Things

Once you can query data, this part teaches you to build the tables, pipelines, and systems around it.

| # | Lesson | What You'll Learn |
|---|--------|-------------------|
| 2.01 | [DDL & Data Modeling](2.01_DDL_Data_Modeling.sql) | CREATE TABLE, data types, constraints, star schema design, views, schemas |
| 2.02 | [DML & ETL Patterns](2.02_DML_ETL_Patterns.sql) | INSERT, UPDATE, DELETE, UPSERT, full refresh vs incremental, staging patterns |
| 2.03 | [Advanced SQL](2.03_Advanced_SQL.sql) | UNION/INTERSECT/EXCEPT, recursive CTEs, PIVOT, EXPLAIN, query optimization |

## Suggested Learning Path

If you're starting from zero, go in order — 1.01 through 2.03. Each lesson is 15-30 minutes.

If you already know basic SQL and want to level up for data engineering:
- Start at **1.08 Subqueries & CTEs**
- **1.10 Window Functions** is probably the highest-value single lesson
- **2.01 DDL** and **2.02 DML/ETL** are what separate analysts from engineers

After the lessons, work through the projects:
1. [EDA Project](../Projects/1_EDA/) — Apply querying skills to answer real questions
2. [Warehouse & Mart Build](../Projects/2_WH_Mart_Build/) — Build a full data warehouse with marts
3. [Flat to Warehouse Pipeline](../Projects/3_Flat_to_WH_Build/) — Design a normalized schema from flat files

## Tools

- **DuckDB** — An in-process OLAP database. Think SQLite but built for analytics. No server needed, runs locally.
- Any SQL client that supports DuckDB (I use the CLI and VS Code extensions)

## Why These Lessons Exist

I built these while learning SQL for data engineering. The tutorials I found online were either too basic ("here's how SELECT works") or assumed you already knew everything. I wanted something that starts from scratch but actually gets to the stuff you need on the job — window functions, ETL patterns, data modeling.

Every example uses real data so you're not learning on toy `employees` tables with 5 rows. The job postings dataset has hundreds of thousands of records, which is closer to what you'll see in production.
