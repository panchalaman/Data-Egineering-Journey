#!/bin/bash
# ============================================================
# Error Handling & Logging Patterns
# ============================================================
# These are patterns I've collected for handling errors
# properly in pipeline scripts. Mostly learned from things
# breaking in unhelpful ways.
# ============================================================

# -----------------------------------------------------------
# PATTERN 1: The basics — set -e
# -----------------------------------------------------------
# Put this at the top of every script. Without it, a failed
# command doesn't stop the script — it just keeps going,
# and you end up with half-loaded data.

set -e          # stop on first error
set -o pipefail # catch errors inside pipes too

# Without pipefail, this would "succeed" even if grep fails:
#   grep "pattern" file.csv | wc -l
# Because wc -l succeeds regardless. pipefail fixes that.


# -----------------------------------------------------------
# PATTERN 2: Trap — cleanup on exit
# -----------------------------------------------------------
# trap runs a command when the script exits (success or failure).
# Great for cleaning up temp files no matter what happens.

TEMP_FILE=$(mktemp)

cleanup() {
    rm -f "$TEMP_FILE"
    echo "Cleaned up temp files"
}

trap cleanup EXIT

# Now even if the script fails halfway through, temp files
# get cleaned up. I didn't know about trap for way too long.


# -----------------------------------------------------------
# PATTERN 3: Logging with timestamps
# -----------------------------------------------------------
# Every pipeline should log what it's doing and when.
# Makes debugging so much easier.

LOG_FILE="pipeline_$(date +%Y%m%d_%H%M%S).log"

log() {
    local level="${2:-INFO}"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $1" | tee -a "$LOG_FILE"
}

log "Pipeline starting"
log "Something went wrong" "ERROR"
log "Just so you know" "WARN"

# Output:
# [2024-03-15 10:30:45] [INFO] Pipeline starting
# [2024-03-15 10:30:45] [ERROR] Something went wrong
# [2024-03-15 10:30:45] [WARN] Just so you know


# -----------------------------------------------------------
# PATTERN 4: Retry logic
# -----------------------------------------------------------
# Network calls fail. APIs time out. Cloud storage has hiccups.
# Instead of failing immediately, retry a few times.

retry() {
    local max_attempts=$1
    local delay=$2
    shift 2
    local cmd="$@"

    for ((attempt=1; attempt<=max_attempts; attempt++)); do
        log "Attempt $attempt/$max_attempts: $cmd"
        if eval "$cmd"; then
            log "Succeeded on attempt $attempt"
            return 0
        fi

        if [[ $attempt -lt $max_attempts ]]; then
            log "Failed, retrying in ${delay}s..." "WARN"
            sleep "$delay"
        fi
    done

    log "All $max_attempts attempts failed" "ERROR"
    return 1
}

# Usage:
# retry 3 5 curl -f "https://storage.googleapis.com/data/file.csv" -o data.csv
# Tries 3 times with 5-second delays between attempts.


# -----------------------------------------------------------
# PATTERN 5: Validate before you start
# -----------------------------------------------------------
# Check everything you can BEFORE running the pipeline.
# Much better to fail in 2 seconds than 45 minutes in.

validate_environment() {
    local errors=0

    # Check required commands
    for cmd in duckdb curl gzip; do
        if ! command -v "$cmd" &>/dev/null; then
            log "Missing required command: $cmd" "ERROR"
            ((errors++))
        fi
    done

    # Check required files
    for f in config.env schema.sql; do
        if [[ ! -f "$f" ]]; then
            log "Missing required file: $f" "ERROR"
            ((errors++))
        fi
    done

    # Check disk space (at least 10GB free)
    local free_gb=$(df -BG . | awk 'NR==2 {gsub("G",""); print $4}')
    if [[ ${free_gb:-0} -lt 10 ]]; then
        log "Low disk space: ${free_gb}GB free (need 10GB)" "ERROR"
        ((errors++))
    fi

    if [[ $errors -gt 0 ]]; then
        log "$errors pre-flight check(s) failed. Aborting." "ERROR"
        exit 1
    fi

    log "All pre-flight checks passed"
}


# -----------------------------------------------------------
# PATTERN 6: Step runner with status tracking
# -----------------------------------------------------------
# Run pipeline steps and track which ones passed/failed.
# Gives you a summary at the end.

declare -a PASSED_STEPS=()
declare -a FAILED_STEPS=()

run_tracked_step() {
    local step_name="$1"
    local step_cmd="$2"

    log "Starting: $step_name"
    if eval "$step_cmd"; then
        PASSED_STEPS+=("$step_name")
        log "Passed: $step_name"
    else
        FAILED_STEPS+=("$step_name")
        log "Failed: $step_name" "ERROR"
        return 1
    fi
}

print_summary() {
    log "========== PIPELINE SUMMARY =========="
    log "Passed: ${#PASSED_STEPS[@]} steps"
    for step in "${PASSED_STEPS[@]}"; do
        log "  ✓ $step"
    done

    if [[ ${#FAILED_STEPS[@]} -gt 0 ]]; then
        log "Failed: ${#FAILED_STEPS[@]} steps" "ERROR"
        for step in "${FAILED_STEPS[@]}"; do
            log "  ✗ $step" "ERROR"
        done
    fi
    log "======================================"
}

# Usage:
# run_tracked_step "Create tables"  "duckdb -c '.read 01_create.sql'"
# run_tracked_step "Load data"      "duckdb -c '.read 02_load.sql'"
# print_summary


# -----------------------------------------------------------
# PUTTING IT ALL TOGETHER
# -----------------------------------------------------------
# A quick template combining the patterns above:

# main() {
#     trap cleanup EXIT
#     validate_environment
#
#     log "=== Pipeline started ==="
#     start_time=$(date +%s)
#
#     run_tracked_step "Extract"   "duckdb -c '.read 01_extract.sql'"
#     run_tracked_step "Transform" "duckdb -c '.read 02_transform.sql'"
#     run_tracked_step "Load"      "duckdb -c '.read 03_load.sql'"
#     run_tracked_step "Verify"    "duckdb -c '.read 04_verify.sql'"
#
#     end_time=$(date +%s)
#     log "Completed in $((end_time - start_time))s"
#     print_summary
# }
#
# main
