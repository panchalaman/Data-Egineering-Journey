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
| 1 | [**Job Market EDA**](./Data-Engineering/SQL_COURSE/Projects/1_EDA/) | I can write analytical SQL that answers real questions — multi-table joins, MEDIAN aggregations, and a custom demand-salary scoring formula |
| 2 | [**Data Warehouse & Mart Build**](./Data-Engineering/SQL_COURSE/Projects/2_WH_Mart_Build/) | I can build a full ETL pipeline — extract CSVs from cloud storage, normalize into a star schema, create four specialized marts, and maintain them with MERGE |
| 3 | [**Flat-to-Warehouse Transformation**](./Data-Engineering/SQL_COURSE/Projects/3_Flat_to_WH_Build/) | I can take genuinely messy source data (Python list strings in a CSV) and transform it into a clean star schema with parsed dimensions and bridge tables |
| 4 | [**Priority Jobs Pipeline**](./Data-types/4_Priority_Jobs_Pipeline/) | I can build incremental ETL pipelines with staging, upsert patterns, schema evolution, and proper data type handling |

Plus a [**SQL Lessons**](./Data-Engineering/SQL_COURSE/Lessons/) — a complete 15-lesson course covering SQL from scratch through advanced data engineering patterns (window functions, star schema design, ETL pipelines, query optimization).

### [Learn Linux](./Learn%20Linux/)

Linux fundamentals and command-line skills, including a dedicated [**Learn Git**](./Learn%20Linux/Learn%20Git/) section for version control.

### [Learn Docker](./Learn%20Docker/)

A comprehensive Docker course built specifically for data engineering — 15 lessons covering containers, images, Compose, networking, volumes, databases, Airflow, CI/CD, production best practices, and security. Includes 3 hands-on projects and practice problems at every level.

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
│       ├── Lessons/                             ← Complete SQL Lessons
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
├── Learn Linux/
│   ├── README.md                                ← Linux fundamentals
│   ├── 01_Basics/
│   │   ├── navigation.md                        # File system navigation
│   │   ├── file_operations.md                   # Copy, move, remove, symlinks
│   │   └── viewing_files.md                     # cat, head, tail, wc, diff
│   ├── 02_Working_with_Data/
│   │   ├── grep_and_search.md                   # grep, find, pattern matching
│   │   ├── text_processing.md                   # awk, sed, cut, sort, uniq
│   │   └── piping_and_redirection.md            # Pipes, redirection, tee
│   ├── 03_System/
│   │   ├── permissions.md                       # chmod, chown, SSH, users
│   │   └── processes_and_jobs.md                # ps, kill, cron, disk management
│   ├── 04_Shell_Scripting/
│   │   ├── basics.sh                            # Variables, loops, conditionals
│   │   ├── pipeline_automation.sh               # ETL pipeline script template
│   │   └── error_handling.sh                    # Logging, retries, traps
│   ├── 05_Environment/
│   │   └── setup.md                             # Packages, PATH, .zshrc, aliases
│   └── Learn Git/
│       └── README.md                            # Git basics & branching
│
└── Learn Docker/
    ├── README.md                                ← Docker for Data Engineering
    ├── 01_What_Is_Docker.md                     # Why Docker, containers vs VMs
    ├── 02_Installation_And_Setup.md             # Install on macOS/Linux/Windows
    ├── 03_Your_First_Container.md               # docker run, stop, rm, exec, logs
    ├── 04_Docker_Images.md                      # Layers, tags, registries, variants
    ├── 05_Building_Images.md                    # Dockerfile, multi-stage builds
    ├── 06_Volumes_And_Storage.md                # Named volumes, bind mounts, persistence
    ├── 07_Networking.md                         # Bridge networks, DNS, port mapping
    ├── 08_Docker_Compose.md                     # Multi-container apps, services
    ├── 09_Environment_And_Secrets.md            # ENV, ARG, .env files, secrets
    ├── 10_Data_Engineering_Pipelines.md         # Containerized ETL, project structure
    ├── 11_Databases_In_Docker.md                # PostgreSQL, DuckDB, Redis, backups
    ├── 12_Airflow_With_Docker.md                # Airflow setup, DAGs, scheduling
    ├── 13_CI_CD_And_Registry.md                 # Docker Hub, GHCR, GitHub Actions
    ├── 14_Production_Best_Practices.md          # Multi-stage, health checks, logging
    ├── 15_Security.md                           # Non-root, scanning, network isolation
    ├── Docker_Command_Reference.md              # Every Docker command for data engineers
    ├── Docker_Practice_And_Interview_Prep.md    # Hands-on exercises & interview questions
    └── projects/
        ├── 01_python_etl_pipeline/              # CSV → Python → PostgreSQL
        ├── 02_multi_service_pipeline/           # Source DB → ETL → Warehouse
        └── 03_airflow_pipeline/                 # Full Airflow orchestration
│
├── Data-types/
│   └── 4_Priority_Jobs_Pipeline/                ← Project 4: Incremental ETL Pipeline
│       ├── 01_setup_database.sql                # Database & schema creation
│       ├── 02_create_priority_roles.sql         # Config table with priority levels
│       ├── 02b_schema_evolution.sql             # ALTER TABLE journey (learning ref)
│       ├── 03_data_type_exploration.sql         # CAST, type analysis, source inspection
│       ├── 04_initial_load.sql                  # Full load — CREATE + INSERT INTO
│       ├── 05_incremental_refresh.sql           # Upsert — UPDATE changed + INSERT new
│       ├── 06_merge_refresh.sql                 # MERGE INTO — atomic upsert + deletes
│       ├── run_pipeline.sh                      # One-command pipeline execution
│       └── README.md
```

---

## Project Deep Dives

### Project 1 — Job Market EDA

**The question I wanted to answer:** *If I'm going to invest months learning skills, which ones actually matter?*

I wrote three queries against a star schema of real job postings, each building on the last:

1. **Demand analysis** — SQL and Python each appear in ~29K remote DE postings, nearly double the next skill. They're not optional.
2. **Salary analysis** — Used MEDIAN (not AVG) to avoid outlier skew. Rust pays $210K but has only 232 postings. Terraform ($184K, 3,248 postings) is the real sweet spot.
3. **Combined scoring** — Built a formula: `MEDIAN(salary) × LN(demand_count) / 1,000,000`. The log transform compresses the demand range so niche high-paying skills can compete fairly with high-volume ones.

**What makes this interesting technically:**
- Three-table INNER JOINs across fact → bridge → dimension tables
- MEDIAN over AVG for honest salary reporting
- LN() transformation to normalize wildly different demand counts
- HAVING >= 100 to filter out statistically meaningless skills

→ [**Explore Project 1**](./Data-Engineering/SQL_COURSE/Projects/1_EDA/)

---

### Project 2 — Data Warehouse & Mart Build

**What I wanted to build:** *A real pipeline, not just queries. Something that takes raw files and turns them into a system.*

This pipeline extracts CSVs from Google Cloud Storage, loads them into a star schema warehouse, then builds four purpose-built marts on top:

| Mart | Why it exists | Grain |
|------|--------------|-------|
| **Flat Mart** | Analysts want one table for Excel — no joins needed | One row per posting |
| **Skills Mart** | Time-series trend analysis with additive measures | skill + month + role |
| **Priority Mart** | Track specific roles with incremental MERGE updates | One row per posting |
| **Company Mart** | Hiring intelligence by company, location, and month | company + title + location + month |

**What makes this interesting technically:**
- Direct CSV extraction from GCS using DuckDB's `httpfs` — no download step
- Full MERGE upsert: INSERT new, UPDATE changed, DELETE removed — in one statement
- Additive fact measures (counts, not ratios) that can safely roll up to any grain
- Bridge tables for many-to-many relationships (jobs↔skills, companies↔locations)
- Separate schemas per mart so you can rebuild one without touching others
- One-command execution via master build script

→ [**Explore Project 2**](./Data-Engineering/SQL_COURSE/Projects/2_WH_Mart_Build/)

---

### Project 3 — Flat CSV to Star Schema

**Why I built this on my own:** *The course gave us pre-formatted CSVs. Real data isn't that clean.*

This was a self-directed bonus project. The source file had skills crammed into Python-style list strings: `['SQL', 'Python', 'AWS']`. That's not JSON (single quotes), it's not an array (it's a VARCHAR), and you can't join on it. I built a pipeline to parse it, normalize it, and load it into the same star schema as the other projects.

**What makes this interesting technically:**
- The main challenge: REPLACE → STRING_SPLIT → UNNEST → TRIM → DISTINCT to extract individual skills from embedded list strings
- Surrogate key generation with `ROW_NUMBER() OVER (ORDER BY ...)` for deterministic, repeatable IDs
- Bridge table population without a shared natural key (had to join on title + date, then re-parse skills)
- Shell script with `set -e` so any failure stops everything immediately
- Verification queries that test record counts AND cross-table joins

→ [**Explore Project 3**](./Data-Engineering/SQL_COURSE/Projects/3_Flat_to_WH_Build/)

### Project 4 — Priority Jobs Pipeline

**The question:** *How do you build an ETL pipeline that loads data correctly and updates incrementally?*

This one started as practice with DDL/DML commands and turned into a proper pipeline. I built a priority roles config table, joined it against the full job postings warehouse, and implemented an upsert pattern for incremental refreshes.

**Key technical highlights:**
- INSERT INTO vs bare SELECT — learned the hard way that SELECT alone doesn't load data
- Upsert pattern: UPDATE changed rows + INSERT new rows using temp staging tables
- `IS DISTINCT FROM` for NULL-safe comparisons in UPDATE conditions
- Schema evolution: table went through 3 phases (boolean → integer priority levels) using ALTER TABLE
- Data type exploration: CAST, DOUBLE vs DECIMAL, TIMESTAMP vs DATE
- Idempotent scripts with CREATE OR REPLACE and IF EXISTS

→ [**Explore Project 4**](./Data-types/4_Priority_Jobs_Pipeline/)

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
| **Docker / Docker Compose** | Containerized pipelines, multi-service setups, CI/CD |
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
