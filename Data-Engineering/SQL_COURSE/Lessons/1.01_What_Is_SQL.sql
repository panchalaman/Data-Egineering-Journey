-- ============================================================
-- LESSON 1.01: What Is SQL & Why Data Engineers Need It
-- ============================================================
-- Before writing any code, let's understand what we're doing
-- and why. This lesson is all context — no queries to run yet.
-- ============================================================

/*
WHAT IS SQL?
============
SQL = Structured Query Language.

It's how you talk to databases. You write a SQL statement,
the database reads it, and gives you back data (or changes data).

That's it. Every database — PostgreSQL, MySQL, DuckDB, Snowflake,
BigQuery, SQL Server — speaks SQL. The syntax varies slightly
between them, but the core is the same everywhere.


WHY DO DATA ENGINEERS NEED SQL?
===============================
As a data engineer, SQL is your primary tool. Here's what you'll
use it for daily:

  1. QUERYING DATA
     - Pull data from tables
     - Join multiple tables together
     - Filter, sort, aggregate

  2. BUILDING PIPELINES (ETL)
     - Extract data from sources
     - Transform it (clean, reshape, aggregate)
     - Load it into warehouses and marts

  3. DATA MODELING
     - Design table structures (schemas)
     - Create star schemas (fact + dimension tables)
     - Define relationships between tables

  4. DATA QUALITY
     - Verify row counts
     - Check for NULLs, duplicates, referential integrity
     - Validate pipeline outputs


WHAT DATABASE ARE WE USING?
===========================
Throughout these lessons, we use DuckDB — a fast, file-based
OLAP database that runs right in your terminal. No server setup,
no configuration. Just:

    brew install duckdb    (macOS)
    apt install duckdb     (Ubuntu)

Then open it:

    duckdb                 (in-memory)
    duckdb my_database.db  (persistent file)


THE DATA WE'RE WORKING WITH
============================
Most examples use a job postings dataset with these tables:

  - job_postings_fact    → each row is a job posting
  - company_dim          → company details
  - skills_dim           → skill names (SQL, Python, AWS, etc.)
  - skills_job_dim       → bridge table linking jobs to skills

This is a "star schema" — you'll learn what that means in the
data modeling lessons. For now, just know that the data is about
real-world job postings for data roles.


HOW TO USE THESE LESSONS
=========================
Each lesson is a .sql file you can read through and run in DuckDB.
Comments explain everything. The queries build on each other, so
going in order is recommended.

Start with the basics (SELECT, WHERE, ORDER BY), then work up
through joins, aggregations, window functions, and finally into
data engineering-specific topics like DDL, DML, and star schemas.

Let's get started.
*/
