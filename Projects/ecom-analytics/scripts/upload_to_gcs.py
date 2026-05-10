"""
upload_to_gcs.py — Upload raw Olist CSV files from data/raw/ to GCS data lake.

Uploads each CSV file to gs://<bucket>/raw/<filename>.
Skips files that already exist in GCS.
"""
from __future__ import annotations

import os
from pathlib import Path

from dotenv import load_dotenv
from google.cloud import storage

load_dotenv()

RAW_DIR = Path(__file__).resolve().parent.parent / "data" / "raw"


def upload_to_gcs() -> None:
    bucket_name = os.environ["GCS_BUCKET"]

    client = storage.Client()
    bucket = client.bucket(bucket_name)

    csv_files = sorted(RAW_DIR.glob("*.csv"))
    if not csv_files:
        print(f"[upload] No CSV files found in {RAW_DIR}. Run download_data.py first.")
        return

    print(f"[upload] Uploading {len(csv_files)} files to gs://{bucket_name}/raw/")
    for csv_path in csv_files:
        blob_name = f"raw/{csv_path.name}"
        blob = bucket.blob(blob_name)

        if blob.exists():
            print(f"[upload] gs://{bucket_name}/{blob_name} already exists, skipping")
            continue

        print(f"[upload] {csv_path.name} → gs://{bucket_name}/{blob_name}")
        blob.upload_from_filename(str(csv_path), timeout=300)
        print(f"[upload]   Done ({csv_path.stat().st_size / 1e6:.1f} MB)")

    print("[upload] All files uploaded.")


def main() -> None:
    upload_to_gcs()


if __name__ == "__main__":
    main()
