"""
load_local_to_postgres.py — Load processed Parquet from local disk into PostgreSQL.

Reads Parquet files from data/processed/ and bulk-inserts into
olist_raw.orders_enriched using psycopg2 COPY.
"""
from __future__ import annotations

import io
import os
from pathlib import Path

import psycopg2
import pyarrow.parquet as pq
import pandas as pd
from dotenv import load_dotenv

load_dotenv()

RAW_SCHEMA = os.getenv("PG_RAW_SCHEMA", "olist_raw")

CREATE_SCHEMA_SQL = f"CREATE SCHEMA IF NOT EXISTS {RAW_SCHEMA};"

CREATE_TABLE_SQL = f"""
CREATE TABLE IF NOT EXISTS {RAW_SCHEMA}.orders_enriched (
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

CREATE_DEFAULT_PARTITION_SQL = f"""
CREATE TABLE IF NOT EXISTS {RAW_SCHEMA}.orders_enriched_default
    PARTITION OF {RAW_SCHEMA}.orders_enriched DEFAULT;
"""

CREATE_INDEX_STATE_SQL = f"""
CREATE INDEX IF NOT EXISTS idx_orders_enriched_state
    ON {RAW_SCHEMA}.orders_enriched (customer_state);
"""

CREATE_INDEX_CATEGORY_SQL = f"""
CREATE INDEX IF NOT EXISTS idx_orders_enriched_category
    ON {RAW_SCHEMA}.orders_enriched (product_category_name_english);
"""

TRUNCATE_SQL = f"TRUNCATE TABLE {RAW_SCHEMA}.orders_enriched;"

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


def find_parquet_files(processed_dir: Path) -> list[Path]:
    if processed_dir.is_file() and processed_dir.suffix == ".parquet":
        return [processed_dir]

    return sorted(processed_dir.rglob("*.parquet"))


def load_to_postgres(processed_dir: Path) -> None:
    host = os.getenv("PG_HOST", "localhost")
    port = int(os.getenv("PG_PORT", "5432"))
    dbname = os.getenv("PG_DB", "olist")
    user = os.getenv("PG_USER", "olist")
    password = os.getenv("PG_PASSWORD", "olist")
    sslmode = os.getenv("PG_SSLMODE", "disable")

    print(f"[load] Connecting to {host}:{port}/{dbname}")
    conn = psycopg2.connect(
        host=host, port=port, dbname=dbname,
        user=user, password=password,
        connect_timeout=30, sslmode=sslmode,
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

    parquet_files = find_parquet_files(processed_dir)
    if not parquet_files:
        print("[load] No Parquet files found. Run the Spark transform first.")
        return

    total_rows = 0
    for pq_file in parquet_files:
        table = pq.read_table(pq_file)
        df = table.to_pandas()
        df = df[[c for c in COLUMNS if c in df.columns]]

        if "order_item_id" in df.columns:
            df["order_item_id"] = pd.to_numeric(df["order_item_id"], errors="coerce").astype("Int64")

        buf = io.StringIO()
        df.to_csv(buf, index=False, header=False, na_rep="\\N")
        buf.seek(0)

        with conn.cursor() as cur:
            cur.copy_expert(
                f"COPY {RAW_SCHEMA}.orders_enriched ({','.join(COLUMNS)}) "
                "FROM STDIN WITH (FORMAT csv, NULL '\\N')",
                buf,
            )
        total_rows += len(df)
        print(f"[load]   {pq_file.name}: {len(df):,} rows loaded")

    with conn.cursor() as cur:
        cur.execute(f"SELECT COUNT(*) FROM {RAW_SCHEMA}.orders_enriched;")
        row_count = cur.fetchone()[0]

    print(f"[load] Total: {row_count:,} rows in {RAW_SCHEMA}.orders_enriched")
    print("[load] PARTITION BY RANGE(order_purchase_date)")
    print("[load] INDEX on customer_state, product_category_name_english")
    conn.close()


def main() -> None:
    base = Path(__file__).resolve().parent.parent
    processed_dir = base / "data" / "processed"
    load_to_postgres(processed_dir)


if __name__ == "__main__":
    main()

