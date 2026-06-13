USE ROLE accountadmin;
CREATE DATABASE course_repo;
USE SCHEMA public;

-- Create credentials
CREATE OR REPLACE SECRET course_repo.public.github_pat
  TYPE = password
  USERNAME = ''
  PASSWORD = '';

-- Create the API integration
CREATE OR REPLACE API INTEGRATION
  API_PROVIDER = git_https_api
  API_ALLOWED_PREFIXES = ('') -- URL to your GitHub profile
  ALLOWED_AUTHENTICATION_SECRETS = ()
  ENABLED = TRUE;

-- Create the git repository object
CREATE OR REPLACE GIT REPOSITORY course_repo.public.advanced_data_engineering_snowflake
  API_INTEGRATION =  -- Name of the API integration defined above
  ORIGIN = '' -- Insert URL of forked repo
  GIT_CREDENTIALS = ;

-- List the git repositories
SHOW GIT REPOSITORIES;