# Data Engineering

SQL course and hands-on projects covering the full data engineering workflow — from writing your first query to building production data warehouses.

## SQL Course

The [SQL Lessons](SQL_COURSE/Lessons/) folder is a complete course that takes you from zero to data-engineer-ready SQL. 15 lessons split into two parts:

**Part 1 — Querying**: SELECT, WHERE, JOINs, GROUP BY, subqueries, CTEs, window functions, date/string functions  
**Part 2 — Building**: DDL, data modeling (star schema), DML, ETL patterns, query optimization, advanced SQL

Every lesson uses a real dataset of tech job postings and is designed to run in DuckDB. Follow the [Setup Guide](SQL_COURSE/Lessons/00_Setup.md) to install DuckDB and connect to the database.

→ [Start the course](SQL_COURSE/Lessons/README.md)
→ [Data 101 (University of California ): Notes](https://data101.org/notes/sql/review/)

## Projects

### [1_EDA/](SQL_COURSE/Projects/1_EDA) - Exploratory Data Analysis
![EDA Project Overview](SQL_COURSE/Projects/Resources/images/1_1_Project1_EDA.png)

> SQL-driven analysis of data engineer job market trends using advanced querying techniques.

**Skills**: Complex joins, aggregations, analytical functions, data quality validation

### [2_WH_Mart_Build/](SQL_COURSE/Projects/2_WH_Mart_Build) - Data Pipeline - Data Warehouse & Mart
![Data Pipeline Architecture](SQL_COURSE/Projects/Resources/images/1_2_Project2_Data_Pipeline.png)

> End-to-end ETL pipeline transforming raw CSV files into a star schema data warehouse and analytical data marts.

**Skills**: Dimensional modeling, ETL pipeline development, data mart architecture, production practices

### [3_Flat_to_WH_Build/](SQL_COURSE/Projects/3_Flat_to_WH_Build) - Flat to Warehouse Build

> SQL-driven transformation of flat job posting data into a normalized star schema using DuckDB.

**Skills**: Data transformation, star schema design, ETL pipeline development, production practices
