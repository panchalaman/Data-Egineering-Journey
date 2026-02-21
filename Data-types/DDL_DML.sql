--.read Data-types/DDL_DML.sql
--creating and dropping a database
USE jobs_mart;

DROP DATABASE IF EXISTS jobs_mart;
CREATE DATABASE IF NOT EXISTS jobs_mart;

SHOW DATABASES;

DROP SCHEMA IF EXISTS staging CASCADE;

--creating schemas
SELECT *
FROM information_schema.schemata;

USE jobs_mart;

CREATE SCHEMA IF NOT EXISTS staging;


--creating/dropping tables
CREATE TABLE IF NOT EXISTS staging.preferred_roles (
    role_id INTEGER PRIMARY KEY,
    role_name VARCHAR
);

SELECT *
From information_schema.tables
WHERE table_catalog ='jobs_mart';


--INSERT
INSERT INTO staging.preferred_roles (role_id, role_name)
VALUES
    (1, 'Data Engineer'),
    (2, 'Senior Data Engineer'),
    (3, 'Software Engineer');

SELECT *
From staging.preferred_roles;

ALTER TABLE staging.preferred_roles
ADD COLUMN preferred_role BOOLEAN;

--Update table information
UPDATE staging.preferred_roles
SET preferred_role = TRUE
WHERE   role_id = 1 OR role_id=2;

UPDATE staging.preferred_roles
SET preferred_role = FALSE
WHERE role_id = 3;

SELECT *
From staging.preferred_roles;

--Changing name
ALTER TABLE staging.preferred_roles
RENAME TO priority_roles;

ALTER TABLE staging.priority_roles
RENAME COLUMN preferred_role TO priority_lvl;

SELECT *
From staging.priority_roles;

--change column info.
ALTER TABLE staging.priority_roles
ALTER COLUMN priority_lvl TYPE INTEGER;

--update specific row
UPDATE staging.priority_roles
SET priority_lvl = 3
WHERE role_id =3;

SELECT *
From staging.priority_roles;