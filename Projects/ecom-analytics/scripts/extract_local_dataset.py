"""
extract_local_dataset.py — Extract a local Olist dataset zip into data/raw/.

Expected zip location (default): data/source/olist.zip
You can override with --zip /path/to/your.zip
"""
from __future__ import annotations

import argparse
import zipfile
from pathlib import Path


def resolve_zip_path(zip_arg: str | None, source_dir: Path) -> Path:
    if zip_arg:
        return Path(zip_arg).expanduser().resolve()

    default_zip = source_dir / "olist.zip"
    if default_zip.exists():
        return default_zip

    zips = sorted(source_dir.glob("*.zip"))
    if zips:
        return zips[0]

    raise FileNotFoundError(
        "No dataset zip found. Place your Kaggle zip at data/source/olist.zip "
        "or pass --zip /path/to/file.zip"
    )


def extract_zip(zip_path: Path, raw_dir: Path) -> None:
    raw_dir.mkdir(parents=True, exist_ok=True)
    print(f"[extract] Using zip: {zip_path}")
    print(f"[extract] Extracting to: {raw_dir}")

    with zipfile.ZipFile(zip_path, "r") as zf:
        zf.extractall(raw_dir)

    csv_files = sorted(raw_dir.glob("*.csv"))
    print(f"[extract] Done. {len(csv_files)} CSV files ready.")


def main() -> None:
    base = Path(__file__).resolve().parent.parent
    source_dir = base / "data" / "source"
    raw_dir = base / "data" / "raw"

    parser = argparse.ArgumentParser(description="Extract local Olist dataset zip")
    parser.add_argument("--zip", dest="zip_path", help="Path to the dataset zip")
    args = parser.parse_args()

    zip_path = resolve_zip_path(args.zip_path, source_dir)
    extract_zip(zip_path, raw_dir)


if __name__ == "__main__":
    main()

