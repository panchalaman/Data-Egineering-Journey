# Data Engineering Journey

> *"Data is the new oil, but only if you know how to refine it."*

Hi, I'm **Aman Panchal** — a data engineer who genuinely loves building things with data. This repository is a living record of my hands-on learning journey — from SQL-driven data engineering (analytical queries, star schemas, ETL pipelines, data marts) to Linux fundamentals and Git version control. Every script here was written by hand, debugged in the terminal, and iterated on until it worked cleanly.

I didn't build these projects to check a box. I built them because I wanted to deeply understand how data moves, transforms, and serves real business decisions. If you're a recruiter or hiring manager, I hope this gives you a clear picture of what I can do — and how I think.

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue?style=flat&logo=linkedin)](https://linkedin.com/in/amanpanchal83)
[![Email](https://img.shields.io/badge/Email-panchalaman%40hotmail.com-red?style=flat&logo=microsoft-outlook)](mailto:panchalaman@hotmail.com)

---

## What's Inside

This repo is organized into two main learning tracks:

### [Data Engineering](./Data-Engineering/)

**3 end-to-end SQL projects** that progressively demonstrate core data engineering competencies — starting from exploratory analysis and building up to full warehouse-and-mart architectures.

| # | Project | What It Proves |
|---|---------|----------------|
| 1 | [**Exploratory Data Analysis**](./Data-Engineering/SQL_COURSE/Projects/1_EDA/) | I can write production-quality analytical SQL, design multi-table joins, and extract actionable insights from raw data |
| 2 | [**Data Warehouse & Mart Build**](./Data-Engineering/SQL_COURSE/Projects/2_WH_Mart_Build/) | I can architect end-to-end ETL pipelines — from cloud-hosted CSVs to star schema warehouses to specialized data marts with incremental updates |
| 3 | [**Flat-to-Warehouse Transformation**](./Data-Engineering/SQL_COURSE/Projects/3_Flat_to_WH_Build/) | I can transform messy, denormalized flat files into clean star schemas through string parsing, normalization, and surrogate key generation |

Plus a [**SQL Lessons**](./Data-Engineering/SQL_COURSE/Lessons/) — a complete 15-lesson course covering SQL from scratch through advanced data engineering patterns (window functions, star schema design, ETL pipelines, query optimization).

### [Learn Linux](./Learn%20Linux/)

Linux fundamentals and command-line skills, including a dedicated [**Learn Git**](./Learn%20Linux/Learn%20Git/) section for version control.

---

## Repository Structure

```
Data-Engineering-Journey/
│
├── README.md                                    ← You are here
│
├── Data-Engineering/
│   ├── README.md
│   └── SQL_COURSE/
│       │
│       ├── Lessons/                             ← Complete SQL course (zero to advanced)
│       │   ├── README.md                        # Course overview & learning path
│       │   ├── 00_Setup.md                      # DuckDB install + MotherDuck connection
│       │   ├── 1.01_What_Is_SQL.sql             # Why SQL, DuckDB setup, the dataset
│       │   ├── 1.02_SELECT.sql                  # Reading data, aliases, DISTINCT, NULLs
│       │   ├── 1.03_WHERE.sql                   # Filtering — comparisons, IN, BETWEEN, LIKE
│       │   ├── 1.04_ORDER_BY.sql                # Sorting, LIMIT, OFFSET, NULLS handling
│       │   ├── 1.05_GROUP_BY.sql                # COUNT, AVG, SUM, HAVING, STRING_AGG
│       │   ├── 1.06_CASE_WHEN.sql               # Conditional logic, pivot-style aggregation
│       │   ├── 1.07_JOINS.sql                   # All join types across star schema
│       │   ├── 1.08_Subqueries_CTEs.sql         # CTEs, EXISTS, nested queries
│       │   ├── 1.09_Date_String_Functions.sql   # DATE_TRUNC, EXTRACT, string parsing
│       │   ├── 1.10_Window_Functions.sql        # ROW_NUMBER, RANK, LAG/LEAD, running totals
│       │   ├── 1.11_JOIN.sql                    # JOIN practice queries
│       │   ├── 1.12_Order_Execution.sql         # SQL execution order
│       │   ├── 2.01_DDL_Data_Modeling.sql       # CREATE TABLE, star schema, views
│       │   ├── 2.02_DML_ETL_Patterns.sql        # INSERT/UPDATE/DELETE, ETL workflows
│       │   └── 2.03_Advanced_SQL.sql            # UNION, recursive CTEs, EXPLAIN, optimization
│       │
│       └── Projects/
│           │
│           ├── 1_EDA/                           ← Project 1: Exploratory Data Analysis
│           │   ├── EDA_1_top_demanded_skills.sql # Top 10 in-demand skills (multi-table joins)
│           │   ├── EDA_2_highest_paying_skills.sql # Top 25 highest-paying skills (aggregations)
│           │   ├── EDA_3_optimal_skills.sql     # Optimal skills score (LN + median salary)
│           │   └── README.md
│           │
│           ├── 2_WH_Mart_Build/                 ← Project 2: Warehouse + Mart Pipeline
│           │   ├── 01_create_tables_dw.sql       # Star schema DDL
│           │   ├── 02_load_schema_dw.sql         # Extract & load from Google Cloud Storage
│           │   ├── 03_create_flat_mart.sql        # Denormalized flat mart
│           │   ├── 04_create_skills_mart.sql      # Skills demand time-series mart
│           │   ├── 05_create_priority_mart.sql    # Priority roles mart
│           │   ├── 06_update_priority_mart.sql    # Incremental MERGE upsert operations
│           │   ├── 07_create_company_mart.sql     # Company hiring trends mart
│           │   ├── build_dw_marts.sql             # Master orchestration script
│           │   └── README.md
│           │
│           ├── 3_Flat_to_WH_Build/              ← Project 3: Flat CSV → Star Schema
│           │   ├── 00_load_data.sql               # Import from Google Cloud Storage
│           │   ├── 01_create_tables.sql           # Star schema table creation
│           │   ├── 02_populate_company_dim.sql    # Company dimension (deduplication)
│           │   ├── 03_populate_skills_dim.sql     # Skills dimension (parsed from Python lists)
│           │   ├── 04_populate_fact_table.sql      # Fact table population
│           │   ├── 05_populate_bridge_table.sql   # Many-to-many bridge table
│           │   ├── 06_verify_schema.sql           # Data quality verification
│           │   ├── build_warehouse.sql            # Master SQL build script
│           │   ├── build_warehouse.sh             # Shell script with error handling
│           │   └── README.md
│           │
│           └── Resources/
│               └── images/                        # Architecture diagrams & schemas
│
└── Learn Linux/
    ├── README.md                                ← Linux fundamentals
    ├── 01_Basics/
    │   ├── navigation.md                        # File system navigation
    │   ├── file_operations.md                   # Copy, move, remove, symlinks
    │   └── viewing_files.md                     # cat, head, tail, wc, diff
    ├── 02_Working_with_Data/
    │   ├── grep_and_search.md                   # grep, find, pattern matching
    │   ├── text_processing.md                   # awk, sed, cut, sort, uniq
    │   └── piping_and_redirection.md            # Pipes, redirection, tee
    ├── 03_System/
    │   ├── permissions.md                       # chmod, chown, SSH, users
    │   └── processes_and_jobs.md                # ps, kill, cron, disk management
    ├── 04_Shell_Scripting/
    │   ├── basics.sh                            # Variables, loops, conditionals
    │   ├── pipeline_automation.sh               # ETL pipeline script template
    │   └── error_handling.sh                    # Logging, retries, traps
    ├── 05_Environment/
    │   └── setup.md                             # Packages, PATH, .zshrc, aliases
    └── Learn Git/
        └── README.md                            # Git basics & branching
```

---

## Project Deep Dives

### Project 1 — Exploratory Data Analysis

**The question:** *What skills should a data engineer learn to maximize career value?*

I queried a star schema data warehouse of real-world job postings to answer three business questions:

1. **Which skills are most in-demand?** — SQL and Python dominate with ~29,000 postings each, followed by AWS, Azure, and Spark
2. **Which skills pay the most?** — Infrastructure tools like Kubernetes, Terraform, and Docker command premium salaries
3. **What's the optimal skill to learn?** — Combined log-transformed demand with median salary to create a single "optimal score" — Terraform, Python, and AWS top the list

**Key technical highlights:**
- Multi-table `INNER JOIN` across fact, bridge, and dimension tables
- `MEDIAN()`, `LN()`, `ROUND()` for statistical analysis
- `HAVING` clause filtering on aggregated results
- Clean, commented, production-ready SQL

→ [**Explore Project 1**](./Data-Engineering/SQL_COURSE/Projects/1_EDA/)

---

### Project 2 — Data Warehouse & Mart Build

**The question:** *How do you turn raw CSV files into a queryable, business-ready data platform?*

Built a complete ETL pipeline that extracts job posting CSVs from Google Cloud Storage, loads them into a normalized star schema, and then creates **4 specialized data marts** optimized for different analytical use cases:

| Mart | Purpose | Grain |
|------|---------|-------|
| **Flat Mart** | Denormalized table for ad-hoc queries | One row per job posting |
| **Skills Mart** | Time-series skill demand analysis | skill + month + job title |
| **Priority Mart** | Priority role tracking with incremental updates | One row per job posting |
| **Company Mart** | Company hiring trends by role & location | company + title + location + month |

**Key technical highlights:**
- Cloud data extraction via DuckDB's `httpfs` extension from GCS
- Star schema design with fact, dimension, and bridge tables
- **MERGE operations** for production-ready incremental updates (INSERT/UPDATE/DELETE in one statement)
- Additive measures designed for safe re-aggregation at any level
- Master orchestration script for one-command pipeline execution
- Separate schemas per mart for logical data isolation

→ [**Explore Project 2**](./Data-Engineering/SQL_COURSE/Projects/2_WH_Mart_Build/)

---

### Project 3 — Flat-to-Warehouse Transformation

**The question:** *What do you do when your source data is a single messy CSV with skills jammed into Python list strings?*

This was a self-initiated bonus project. The raw data had skills stored as `['SQL', 'Python', 'AWS']` — a string, not an array. I built a pipeline to parse, normalize, and load it into the same star schema used in the other projects.

**Key technical highlights:**
- String parsing with `UNNEST`, `STRING_SPLIT`, and `REPLACE` to convert Python lists into relational rows
- Surrogate key generation via `ROW_NUMBER()` window functions
- Deduplication logic for company and skills dimensions
- Shell script with `set -e` for fail-fast execution
- End-to-end verification queries to validate row counts and referential integrity

→ [**Explore Project 3**](./Data-Engineering/SQL_COURSE/Projects/3_Flat_to_WH_Build/)

---

## Technical Skills Demonstrated

### Data Engineering Core

| Category | Skills |
|----------|--------|
| **Data Modeling** | Star schema design, dimensional modeling, fact/dimension/bridge tables, grain definition, additive measures |
| **ETL Development** | Extract from cloud storage (GCS), transform with SQL, load into warehouse, incremental updates with MERGE |
| **Data Marts** | Flat marts, time-series marts, priority tracking marts, company analytics marts |
| **Data Quality** | Idempotent scripts, verification queries, NULL handling, deduplication, type safety |
| **Pipeline Orchestration** | Master build scripts (SQL + Shell), error handling, sequential step execution |

### SQL Proficiency

| Category | Techniques |
|----------|------------|
| **DDL** | `CREATE TABLE`, `DROP TABLE IF EXISTS`, `CREATE SCHEMA`, schema isolation |
| **DML** | `INSERT INTO ... SELECT`, `UPDATE`, `DELETE`, `MERGE INTO` (upsert) |
| **Joins** | `INNER JOIN`, `LEFT JOIN`, `RIGHT JOIN`, `FULL JOIN` across multiple tables |
| **Aggregations** | `COUNT()`, `MEDIAN()`, `ROUND()`, `SUM()`, `STRING_AGG()` |
| **Window Functions** | `ROW_NUMBER()` for surrogate key generation |
| **Advanced** | CTEs, `UNNEST`, `LN()`, `DATE_TRUNC()`, `EXTRACT()`, `CASE WHEN`, `HAVING` |

### Tools & Infrastructure

| Tool | Usage |
|------|-------|
| **DuckDB** | OLAP query engine for all analytical workloads |
| **Google Cloud Storage** | Source data hosting and cloud extraction |
| **Git / GitHub** | Version-controlled pipeline scripts |
| **VS Code** | SQL development environment |
| **Shell (Bash/Zsh)** | Pipeline automation and orchestration |

---

## Why Data Engineering?

I didn't start here by accident. I'm drawn to the part of the data stack that most people overlook — the plumbing. The pipelines. The schemas. The quiet infrastructure that makes dashboards light up and models actually work.

What excites me most is the craft of it: taking chaotic, unstructured data and turning it into something clean, reliable, and useful. There's a satisfaction in writing an ETL pipeline that runs without errors, in designing a schema that makes complex queries simple, and in knowing that the data flowing through your system is trustworthy.

This repo is just the beginning. I'm continuously learning — expanding into orchestration tools, cloud-native architectures, and streaming pipelines. But the foundation is here: strong SQL, clean data modeling, and the discipline to build things properly.

---

## Get in Touch

I'm actively looking for opportunities in data engineering. If my work resonates with you, I'd love to connect.

- **Email:** [panchalaman@hotmail.com](mailto:panchalaman@hotmail.com)
- **LinkedIn:** [linkedin.com/in/amanpanchal83](https://linked.com/in/amanpanchal83)

---

<p align="center"><i>Built with curiosity, SQL, and a lot of terminal time.</i></p>
