--.read Data-types/DDL_DML.sql
--creating and dropping a database
DROP DATABASE IF EXISTS jobs_mart;
USE jobs_mart;
CREATE DATABASE IF NOT EXISTS jobs_mart;
SHOW DATABASES;


--creating schemas
SELECT *
FROM information_schema.schemata;

CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA jobs_mart.staging;

--DROP SCHEMA staging;

--creating/dropping tables
CREATE TABLE IF NOT EXISTS staging.preferred_roles (
    role_id INTEGER PRIMARY KEY,
    role_name VARCHAR
);

SELECT *
From information_schema.tables
WHERE table_catalog ='jobs_mart';

--DROP TABLE IF EXISTS main.preferred_roles;.rea

--INSERT
INSERT INTO staging.preferred_roles (role_id, role_name)
VALUES
    (1, 'Data Engineer'),
    (2, 'Senior Data Engineer');

SELECT *
From staging.preferred_roles;

INSERT INTO staging.preferred_roles (role_id, role_name)
VALUES
    (3, 'Software Engineer');