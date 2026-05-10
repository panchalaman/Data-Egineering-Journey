"""
download_data.py — Download Olist Brazilian E-Commerce dataset from Kaggle.

Uses the Kaggle Public API to download the 'olistbr/brazilian-ecommerce' dataset
and extracts all CSV files into data/raw/.

Credential priority:
  1. KAGGLE_API_TOKEN env var (new KGAT_... bearer token format)
  2. KAGGLE_USERNAME + KAGGLE_KEY env vars (legacy basic auth format)
"""
from __future__ import annotations

import os
import zipfile
from pathlib import Path

import requests
from dotenv import load_dotenv

load_dotenv()

RAW_DIR = Path(__file__).resolve().parent.parent / "data" / "raw"

KAGGLE_DATASET = "olistbr/brazilian-ecommerce"
KAGGLE_API_BASE = "https://www.kaggle.com/api/v1"


def download_olist() -> None:
    RAW_DIR.mkdir(parents=True, exist_ok=True)

    token = os.environ.get("KAGGLE_API_TOKEN", "")
    username = os.environ.get("KAGGLE_USERNAME", "")
    key = os.environ.get("KAGGLE_KEY", "")

    if not token and not (username and key):
        raise EnvironmentError(
            "Kaggle credentials not found. Set KAGGLE_API_TOKEN (new format) "
            "or both KAGGLE_USERNAME and KAGGLE_KEY in your .env file."
        )

    owner, dataset_name = KAGGLE_DATASET.split("/")
    zip_path = RAW_DIR / f"{dataset_name}.zip"

    if not zip_path.exists():
        url = f"{KAGGLE_API_BASE}/datasets/{owner}/{dataset_name}/download"
        print(f"[download] Fetching {url}")

        if token:
            headers = {"Authorization": f"Bearer {token}"}
            auth = None
        else:
            headers = {}
            auth = (username, key)

        resp = requests.get(url, headers=headers, auth=auth, stream=True, timeout=300)

        if resp.status_code == 401:
            raise PermissionError(
                "Kaggle authentication failed. "
                "Check KAGGLE_API_TOKEN or KAGGLE_USERNAME/KAGGLE_KEY."
            )
        resp.raise_for_status()

        with open(zip_path, "wb") as f:
            for chunk in resp.iter_content(chunk_size=1024 * 1024):
                f.write(chunk)
        print(f"[download] Saved zip → {zip_path}  ({zip_path.stat().st_size / 1e6:.1f} MB)")
    else:
        print(f"[download] {zip_path.name} already exists, skipping download")

    print(f"[download] Extracting to {RAW_DIR}")
    with zipfile.ZipFile(zip_path, "r") as zf:
        zf.extractall(RAW_DIR)

    csv_files = sorted(RAW_DIR.glob("*.csv"))
    print(f"[download] Done. {len(csv_files)} CSV files extracted:")
    for f in csv_files:
        print(f"  {f.name}  ({f.stat().st_size / 1e6:.1f} MB)")


def main() -> None:
    download_olist()


if __name__ == "__main__":
    main()
