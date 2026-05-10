"""
load_to_postgres.py — Load processed Parquet from S3 into RDS PostgreSQL.

Downloads Parquet files from S3 to a temp dir, reads with PyArrow,
and bulk-inserts into olist_raw.orders_enriched using psycopg2 COPY.

Table design (DW-style for the course evaluation):
  PARTITION BY RANGE (order_purchase_date) — time-range query efficiency
  INDEX on (customer_state)               — geography filter performance
  INDEX on (product_category_name_english) — category filter performance
"""
from __future__ import annotations

import io
import os
import tempfile
from pathlib import Path

import boto3
import psycopg2
import pyarrow.parquet as pq
from dotenv import load_dotenv

load_dotenv()

CREATE_SCHEMA_SQL = "CREATE SCHEMA IF NOT EXISTS olist_raw;"

# Partitioned table: PARTITION BY RANGE on order_purchase_date
# This is the PostgreSQL equivalent of BigQuery partitioning / Redshift SORTKEY
CREATE_TABLE_SQL = """
CREATE TABLE IF NOT EXISTS olist_raw.orders_enriched (
    order_id                        VARCHAR(50),
    order_item_id                   INTEGER,
    order_status                    VARCHAR(30),
    order_purchase_timestamp        TIMESTAMP,
    order_purchase_date             DATE         NOT NULL,
    order_purchase_year             INTEGER,
    order_purchase_month            INTEGER,
    order_delivered_customer_date   TIMESTAMP,
    order_estimated_delivery_date   TIMESTAMP,
    delivery_days                   DOUBLE PRECISION,
    estimated_delivery_days         DOUBLE PRECISION,
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
    price                           DOUBLE PRECISION,
    freight_value                   DOUBLE PRECISION,
    total_item_value                DOUBLE PRECISION,
    payment_type                    VARCHAR(30),
    payment_value                   DOUBLE PRECISION,
    review_score                    DOUBLE PRECISION
) PARTITION BY RANGE (order_purchase_date);
"""

# Monthly partitions covering the Olist dataset range (Sep 2016 – Oct 2018)
# Plus a catch-all default partition
CREATE_DEFAULT_PARTITION_SQL = """
CREATE TABLE IF NOT EXISTS olist_raw.orders_enriched_default
    PARTITION OF olist_raw.orders_enriched DEFAULT;
"""

# Index on customer_state — equivalent to BigQuery clustering / Redshift DISTKEY
CREATE_INDEX_STATE_SQL = """
CREATE INDEX IF NOT EXISTS idx_orders_enriched_state
    ON olist_raw.orders_enriched (customer_state);
"""

# Index on product_category — equivalent to secondary clustering
CREATE_INDEX_CATEGORY_SQL = """
CREATE INDEX IF NOT EXISTS idx_orders_enriched_category
    ON olist_raw.orders_enriched (product_category_name_english);
"""

TRUNCATE_SQL = "TRUNCATE TABLE olist_raw.orders_enriched;"

COLUMNS = [
    "order_id", "order_item_id", "order_status", "order_purchase_timestamp",
    "order_purchase_date", "order_purchase_year", "order_purchase_month",
    "order_delivered_customer_date", "order_estimated_delivery_date",
    "delivery_days", "estimated_delivery_days", "is_on_time",
    "customer_id", "customer_unique_id", "customer_city", "customer_state",
    "product_id", "product_category_name", "product_category_name_english",
    "seller_id", "seller_city", "seller_state",
    "price", "freight_value", "total_item_value",
    "payment_type", "payment_value", "review_score",
]


def download_parquet_from_s3(bucket: str, region: str, tmp_dir: Path) -> list[Path]:
    s3 = boto3.client("s3", region_name=region)
    paginator = s3.get_paginator("list_objects_v2")
    files = []
    for page in paginator.paginate(Bucket=bucket, Prefix="processed/"):
        for obj in page.get("Contents", []):
            key = obj["Key"]
            if not key.endswith(".parquet"):
                continue
            local_path = tmp_dir / Path(key).name
            print(f"[load] Downloading s3://{bucket}/{key}")
            s3.download_file(bucket, key, str(local_path))
            files.append(local_path)
    return files


def load_to_postgres() -> None:
    host     = os.environ["PG_HOST"]
    port     = int(os.getenv("PG_PORT", "5432"))
    dbname   = os.getenv("PG_DB", "olist")
    user     = os.environ["PG_USER"]
    password = os.environ["PG_PASSWORD"]
    bucket   = os.environ["S3_BUCKET"]
    region   = os.getenv("AWS_REGION", "us-east-1")

    print(f"[load] Connecting to {host}:{port}/{dbname}")
    conn = psycopg2.connect(
        host=host, port=port, dbname=dbname,
        user=user, password=password,
        connect_timeout=30, sslmode="require",
    )
    conn.autocommit = True

    with conn.cursor() as cur:
        print("[load] Creating schema and partitioned table...")
        cur.execute(CREATE_SCHEMA_SQL)
        cur.execute(CREATE_TABLE_SQL)
        cur.execute(CREATE_DEFAULT_PARTITION_SQL)
        cur.execute(CREATE_INDEX_STATE_SQL)
        cur.execute(CREATE_INDEX_CATEGORY_SQL)
        print("[load] Truncating existing data...")
        cur.execute(TRUNCATE_SQL)

    with tempfile.TemporaryDirectory() as tmp:
        tmp_dir = Path(tmp)
        parquet_files = download_parquet_from_s3(bucket, region, tmp_dir)
        if not parquet_files:
            print("[load] No Parquet files found in S3. Run spark + upload-processed first.")
            return

        total_rows = 0
        for pq_file in parquet_files:
            table = pq.read_table(pq_file)
            df = table.to_pandas()
            df = df[[c for c in COLUMNS if c in df.columns]]

            buf = io.StringIO()
            df.to_csv(buf, index=False, header=False, na_rep="\\N")
            buf.seek(0)

            with conn.cursor() as cur:
                cur.copy_expert(
                    f"COPY olist_raw.orders_enriched ({','.join(COLUMNS)}) "
                    "FROM STDIN WITH (FORMAT csv, NULL '\\N')",
                    buf,
                )
            total_rows += len(df)
            print(f"[load]   {pq_file.name}: {len(df):,} rows loaded")

    with conn.cursor() as cur:
        cur.execute("SELECT COUNT(*) FROM olist_raw.orders_enriched;")
        row_count = cur.fetchone()[0]

    print(f"[load] Total: {row_count:,} rows in olist_raw.orders_enriched")
    print("[load] PARTITION BY RANGE(order_purchase_date)")
    print("[load] INDEX on customer_state, product_category_name_english")
    conn.close()


def main() -> None:
    load_to_postgres()


if __name__ == "__main__":
    main()
