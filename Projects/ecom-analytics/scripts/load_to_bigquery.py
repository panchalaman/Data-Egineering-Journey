"""
load_to_bigquery.py — Load processed Parquet files from GCS into BigQuery.

Loads Spark output (gs://<bucket>/processed/*.parquet) into
olist_raw.orders_enriched, partitioned by order_purchase_date and
clustered by customer_state + product_category_name_english.
"""
from __future__ import annotations

import os

from dotenv import load_dotenv
from google.cloud import bigquery

load_dotenv()


def load_parquet_to_bigquery() -> None:
    project_id = os.environ["GCP_PROJECT_ID"]
    bucket_name = os.environ["GCS_BUCKET"]
    raw_dataset = os.getenv("BQ_RAW_DATASET", "olist_raw")

    table_id = f"{project_id}.{raw_dataset}.orders_enriched"
    source_uri = f"gs://{bucket_name}/processed/*.parquet"

    client = bigquery.Client(project=project_id)

    job_config = bigquery.LoadJobConfig(
        source_format=bigquery.SourceFormat.PARQUET,
        write_disposition=bigquery.WriteDisposition.WRITE_TRUNCATE,
        time_partitioning=bigquery.TimePartitioning(
            type_=bigquery.TimePartitioningType.DAY,
            field="order_purchase_date",
        ),
        clustering_fields=["customer_state", "product_category_name_english"],
    )

    print(f"[bigquery] Loading {source_uri} → {table_id}")

    load_job = client.load_table_from_uri(
        source_uri,
        table_id,
        job_config=job_config,
    )
    load_job.result()

    table = client.get_table(table_id)
    print(f"[bigquery] Loaded {table.num_rows:,} rows into {table_id}")
    print(f"[bigquery] Partition field: order_purchase_date")
    print(f"[bigquery] Cluster fields: customer_state, product_category_name_english")


def main() -> None:
    load_parquet_to_bigquery()


if __name__ == "__main__":
    main()
