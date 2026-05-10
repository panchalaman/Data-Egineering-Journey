"""
upload_to_s3.py — Upload raw Olist CSV files from data/raw/ to S3 data lake.

Uploads each CSV to s3://<bucket>/raw/<filename>.
Skips files that already exist in S3.
"""
from __future__ import annotations

import os
from pathlib import Path

import boto3
from botocore.exceptions import ClientError
from dotenv import load_dotenv

load_dotenv()

RAW_DIR = Path(__file__).resolve().parent.parent / "data" / "raw"


def upload_to_s3() -> None:
    bucket_name = os.environ["S3_BUCKET"]
    region = os.getenv("AWS_REGION", "us-east-1")

    s3 = boto3.client("s3", region_name=region)

    csv_files = sorted(RAW_DIR.glob("*.csv"))
    if not csv_files:
        print(f"[upload] No CSV files found in {RAW_DIR}. Run download_data.py first.")
        return

    print(f"[upload] Uploading {len(csv_files)} files to s3://{bucket_name}/raw/")
    for csv_path in csv_files:
        key = f"raw/{csv_path.name}"

        try:
            s3.head_object(Bucket=bucket_name, Key=key)
            print(f"[upload] s3://{bucket_name}/{key} already exists, skipping")
            continue
        except ClientError as e:
            if e.response["Error"]["Code"] != "404":
                raise

        print(f"[upload] {csv_path.name} → s3://{bucket_name}/{key}")
        s3.upload_file(str(csv_path), bucket_name, key)
        print(f"[upload]   Done ({csv_path.stat().st_size / 1e6:.1f} MB)")

    print("[upload] All raw files uploaded.")


def main() -> None:
    upload_to_s3()


if __name__ == "__main__":
    main()
