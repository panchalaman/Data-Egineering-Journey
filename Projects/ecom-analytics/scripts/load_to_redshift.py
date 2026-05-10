"""
load_to_redshift.py — Load processed Parquet from S3 into Redshift Serverless.

Creates olist_raw schema and orders_enriched table (if not exists), then loads
Parquet files from s3://<bucket>/processed/ via Redshift COPY command using
the IAM role attached to the Redshift namespace.

Table design:
  DISTKEY(customer_state)          — eliminates full-table scans by geography
  SORTKEY(order_purchase_date)     — efficient time-range queries (partition equivalent)
"""
from __future__ import annotations

import os

import psycopg2
from dotenv import load_dotenv

load_dotenv()

CREATE_SCHEMA_SQL = "CREATE SCHEMA IF NOT EXISTS olist_raw;"

CREATE_TABLE_SQL = """
CREATE TABLE IF NOT EXISTS olist_raw.orders_enriched (
    order_id                        VARCHAR(50),
    order_item_id                   INTEGER,
    order_status                    VARCHAR(30),
    order_purchase_timestamp        TIMESTAMP,
    order_purchase_date             DATE         ENCODE AZ64,
    order_purchase_year             INTEGER,
    order_purchase_month            INTEGER,
    order_delivered_customer_date   TIMESTAMP,
    order_estimated_delivery_date   TIMESTAMP,
    delivery_days                   FLOAT8,
    estimated_delivery_days         FLOAT8,
    is_on_time                      BOOLEAN,
    customer_id                     VARCHAR(50),
    customer_unique_id              VARCHAR(50),
    customer_city                   VARCHAR(100),
    customer_state                  VARCHAR(2),
    product_id                      VARCHAR(50),
    product_category_name           VARCHAR(100),
    product_category_name_english   VARCHAR(100),
    seller_id                       VARCHAR(50),
    seller_city                     VARCHAR(100),
    seller_state                    VARCHAR(2),
    price                           FLOAT8,
    freight_value                   FLOAT8,
    total_item_value                FLOAT8,
    payment_type                    VARCHAR(30),
    payment_value                   FLOAT8,
    review_score                    FLOAT8
)
DISTKEY(customer_state)
SORTKEY(order_purchase_date);
"""

TRUNCATE_SQL = "TRUNCATE TABLE olist_raw.orders_enriched;"

COPY_SQL = """
COPY olist_raw.orders_enriched
FROM 's3://{bucket}/processed/'
IAM_ROLE '{iam_role}'
FORMAT AS PARQUET;
"""


def load_to_redshift() -> None:
    host     = os.environ["REDSHIFT_HOST"]
    port     = int(os.getenv("REDSHIFT_PORT", "5439"))
    dbname   = os.getenv("REDSHIFT_DB", "olist")
    user     = os.environ["REDSHIFT_USER"]
    password = os.environ["REDSHIFT_PASSWORD"]
    bucket   = os.environ["S3_BUCKET"]
    iam_role = os.environ["IAM_ROLE_ARN"]

    print(f"[redshift] Connecting to {host}:{port}/{dbname}")
    conn = psycopg2.connect(
        host=host,
        port=port,
        dbname=dbname,
        user=user,
        password=password,
        connect_timeout=30,
        sslmode="require",
    )
    conn.autocommit = True

    with conn.cursor() as cur:
        print("[redshift] Creating schema olist_raw (if not exists)...")
        cur.execute(CREATE_SCHEMA_SQL)

        print("[redshift] Creating table orders_enriched (if not exists)...")
        cur.execute(CREATE_TABLE_SQL)

        print("[redshift] Truncating existing data...")
        cur.execute(TRUNCATE_SQL)

        copy_sql = COPY_SQL.format(bucket=bucket, iam_role=iam_role)
        print(f"[redshift] COPY from s3://{bucket}/processed/ ...")
        cur.execute(copy_sql)

        cur.execute("SELECT COUNT(*) FROM olist_raw.orders_enriched;")
        row_count = cur.fetchone()[0]
        print(f"[redshift] Loaded {row_count:,} rows into olist_raw.orders_enriched")
        print(f"[redshift] DISTKEY: customer_state | SORTKEY: order_purchase_date")

    conn.close()


def main() -> None:
    load_to_redshift()


if __name__ == "__main__":
    main()
