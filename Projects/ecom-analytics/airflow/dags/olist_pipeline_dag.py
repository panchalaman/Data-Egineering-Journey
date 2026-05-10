"""
olist_pipeline_dag.py — Airflow DAG for the Olist E-Commerce Analytics pipeline.

Workflow (7 tasks):
    1. download_from_kaggle     — Download Olist CSVs from Kaggle API to data/raw/
    2. upload_raw_to_s3         — Push raw CSV files to S3 data lake (raw/ prefix)
    3. spark_transform          — PySpark: join all Olist CSVs → denormalized Parquet in data/processed/
    4. upload_processed_to_s3   — Push Parquet files to S3 data lake (processed/ prefix)
    5. load_to_postgres         — Download Parquet from S3, bulk-load into RDS PostgreSQL
    6. dbt_run                  — Run dbt models: staging → dimensions → facts → aggregations
    7. dbt_test                 — Run dbt data quality tests
"""
from __future__ import annotations

from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.bash import BashOperator

PROJECT_DIR = "/opt/airflow/project"

ENV_EXPORT = (
    'export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" && '
    'export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" && '
    'export AWS_DEFAULT_REGION="${AWS_REGION:-us-east-1}" && '
    'export S3_BUCKET="${S3_BUCKET}" && '
    'export PG_HOST="${PG_HOST}" && '
    'export PG_USER="${PG_USER}" && '
    'export PG_PASSWORD="${PG_PASSWORD}" && '
    'export PG_DB="${PG_DB:-olist}" && '
    'export PG_RAW_SCHEMA="${PG_RAW_SCHEMA:-olist_raw}" && '
    'export PG_PROD_SCHEMA="${PG_PROD_SCHEMA:-olist_prod}" && '
    'export KAGGLE_API_TOKEN="${KAGGLE_API_TOKEN}" && '
)

default_args = {
    "owner": "data-engineering",
    "depends_on_past": False,
    "email_on_failure": False,
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

with DAG(
    dag_id="olist_ecommerce_analytics_pipeline",
    default_args=default_args,
    description="Batch pipeline: Kaggle Olist → S3 → Spark → PostgreSQL → dbt",
    schedule_interval="@once",
    start_date=datetime(2024, 1, 1),
    catchup=False,
    tags=["olist", "ecommerce", "batch", "warehouse"],
) as dag:

    download_from_kaggle = BashOperator(
        task_id="download_from_kaggle",
        bash_command=(
            f"{ENV_EXPORT} cd {PROJECT_DIR} && "
            "python scripts/download_data.py"
        ),
    )

    upload_raw_to_s3 = BashOperator(
        task_id="upload_raw_to_s3",
        bash_command=(
            f"{ENV_EXPORT} cd {PROJECT_DIR} && "
            "python scripts/upload_to_s3.py"
        ),
    )

    spark_transform = BashOperator(
        task_id="spark_transform",
        bash_command=(
            f"{ENV_EXPORT} cd {PROJECT_DIR} && "
            "python spark/transform_events.py"
        ),
        execution_timeout=timedelta(minutes=30),
    )

    upload_processed_to_s3 = BashOperator(
        task_id="upload_processed_to_s3",
        bash_command=(
            f"{ENV_EXPORT} cd {PROJECT_DIR} && "
            "python scripts/upload_processed_to_s3.py"
        ),
    )

    load_to_postgres = BashOperator(
        task_id="load_to_postgres",
        bash_command=(
            f"{ENV_EXPORT} cd {PROJECT_DIR} && "
            "python scripts/load_to_postgres.py"
        ),
    )

    dbt_run = BashOperator(
        task_id="dbt_run",
        bash_command=(
            f"{ENV_EXPORT} cd {PROJECT_DIR}/dbt && "
            "dbt deps --project-dir . --profiles-dir . && "
            "dbt run --project-dir . --profiles-dir ."
        ),
    )

    dbt_test = BashOperator(
        task_id="dbt_test",
        bash_command=(
            f"{ENV_EXPORT} cd {PROJECT_DIR}/dbt && "
            "dbt test --project-dir . --profiles-dir ."
        ),
    )

    (
        download_from_kaggle
        >> upload_raw_to_s3
        >> spark_transform
        >> upload_processed_to_s3
        >> load_to_postgres
        >> dbt_run
        >> dbt_test
    )
