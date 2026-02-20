#!/bin/bash
# ============================================================
# Pipeline Automation — A Real-ish ETL Script
# ============================================================
# This is a template for how I structure pipeline scripts.
# It's based on the patterns I actually use in my SQL projects.
#
# The idea: run SQL files in order, log everything, fail fast
# if anything goes wrong.
# ============================================================

set -e          # exit immediately on error
set -o pipefail # catch errors in pipes too

# -----------------------------------------------------------
# CONFIG
# -----------------------------------------------------------
DB_FILE="warehouse.duckdb"
LOG_DIR="./logs"
LOG_FILE="${LOG_DIR}/pipeline_$(date +%Y%m%d_%H%M%S).log"

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# -----------------------------------------------------------
# HELPER FUNCTIONS
# -----------------------------------------------------------

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

run_step() {
    local step_file="$1"
    local description="$2"

    log "--- Running: $description ($step_file) ---"

    if duckdb "$DB_FILE" -c ".read $step_file" >> "$LOG_FILE" 2>&1; then
        log "DONE: $description"
    else
        log "FAILED: $description"
        log "Check $LOG_FILE for details"
        exit 1
    fi
}

check_file_exists() {
    if [[ ! -f "$1" ]]; then
        log "ERROR: Required file not found: $1"
        exit 1
    fi
}

# -----------------------------------------------------------
# PRE-FLIGHT CHECKS
# -----------------------------------------------------------
log "=== Pipeline started ==="

# Make sure duckdb is available
if ! command -v duckdb &>/dev/null; then
    log "ERROR: duckdb not found. Install it first."
    exit 1
fi

# Verify all SQL files exist before starting
# (better to fail immediately than halfway through)
for f in 01_create_tables.sql 02_load_data.sql 03_transform.sql 04_verify.sql; do
    check_file_exists "$f"
done

log "All pre-flight checks passed"

# -----------------------------------------------------------
# PIPELINE EXECUTION
# -----------------------------------------------------------
start_time=$(date +%s)

run_step "01_create_tables.sql"  "Create warehouse tables"
run_step "02_load_data.sql"      "Load data from source"
run_step "03_transform.sql"      "Transform and populate marts"
run_step "04_verify.sql"         "Verify data integrity"

end_time=$(date +%s)
duration=$((end_time - start_time))

log "=== Pipeline completed in ${duration}s ==="
log "Database: $DB_FILE"
log "Full log: $LOG_FILE"

# -----------------------------------------------------------
# POST-RUN CLEANUP (optional)
# -----------------------------------------------------------

# Remove temp files if any
# rm -f /tmp/pipeline_*.tmp

# Keep only last 7 days of logs
find "$LOG_DIR" -name "pipeline_*.log" -mtime +7 -delete 2>/dev/null

log "Cleanup done. All finished."
