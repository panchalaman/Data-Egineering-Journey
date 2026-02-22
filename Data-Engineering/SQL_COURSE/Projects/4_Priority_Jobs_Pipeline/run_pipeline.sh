#!/bin/bash
# ============================================================
# run_pipeline.sh — Execute the full pipeline in order
# ============================================================
# Usage:
#   cd Data-Engineering-Journey
#   bash Data-types/4_Priority_Jobs_Pipeline/run_pipeline.sh
#
# This connects to MotherDuck, runs each script in sequence,
# and stops on the first error.
# ============================================================

set -e  # Stop on first error

PIPELINE_DIR="Data-types/4_Priority_Jobs_Pipeline"

echo "=== Priority Jobs Pipeline ==="
echo ""

echo "[1/4] setting up database and schemas..."
duckdb md:data_jobs < "${PIPELINE_DIR}/01_setup_database.sql"

echo "[2/4] creating priority roles config..."
duckdb md:data_jobs < "${PIPELINE_DIR}/02_create_priority_roles.sql"

echo "[3/4] running initial load..."
duckdb md:data_jobs < "${PIPELINE_DIR}/04_initial_load.sql"

echo "[4/5] running incremental refresh (UPDATE+INSERT pattern)..."
duckdb md:data_jobs < "${PIPELINE_DIR}/05_incremental_refresh.sql"

echo "[5/5] running MERGE refresh (single-statement upsert)..."
duckdb md:data_jobs < "${PIPELINE_DIR}/06_merge_refresh.sql"

echo ""
echo "=== Pipeline complete (5 steps) ==="
