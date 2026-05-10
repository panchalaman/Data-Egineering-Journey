"""
upload_processed_to_s3.py — Upload Spark-processed Parquet files to S3.

Uploads data/processed/*.parquet to s3://<bucket>/processed/.
Always overwrites (processed output is deterministic).
"""
from __future__ import annotations

import os
from pathlib import Path

import boto3
from dotenv import load_dotenv

load_dotenv()

PROCESSED_DIR = Path(__file__).resolve().parent.parent / "data" / "processed"


def upload_processed_to_s3() -> None:
    bucket_name = os.environ["S3_BUCKET"]
    region = os.getenv("AWS_REGION", "us-east-1")

    s3 = boto3.client("s3", region_name=region)

    parquet_files = sorted(PROCESSED_DIR.glob("*.parquet"))
    if not parquet_files:
        print(f"[upload] No Parquet files found in {PROCESSED_DIR}. Run spark transform first.")
        return

    print(f"[upload] Uploading {len(parquet_files)} Parquet files to s3://{bucket_name}/processed/")
    for pq_path in parquet_files:
        key = f"processed/{pq_path.name}"
        print(f"[upload] {pq_path.name} → s3://{bucket_name}/{key}")
        s3.upload_file(str(pq_path), bucket_name, key)
        print(f"[upload]   Done ({pq_path.stat().st_size / 1e6:.1f} MB)")

    print("[upload] All processed files uploaded.")


def main() -> None:
    upload_processed_to_s3()


if __name__ == "__main__":
    main()
