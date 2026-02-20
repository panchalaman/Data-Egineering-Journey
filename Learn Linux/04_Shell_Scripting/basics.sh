#!/bin/bash
# ============================================================
# Shell Scripting Basics
# ============================================================
# This script isn't meant to be "run" — it's a walkthrough
# of the building blocks I use in my pipeline scripts.
# Think of it as a reference/cheat sheet with real examples.
# ============================================================

# -----------------------------------------------------------
# VARIABLES
# -----------------------------------------------------------
# No spaces around the = sign. That tripped me up early on.

name="Aman"
db_path="/data/warehouse.duckdb"
today=$(date +%Y%m%d)        # command substitution — runs the command and stores result
row_count=$(wc -l < data.csv) # store line count of a file

echo "Running pipeline for $name on $today"
echo "Database: $db_path"
echo "Input rows: $row_count"

# Use curly braces when variable is next to other text
echo "Log file: pipeline_${today}.log"    # without {}, it'd look for $today.log variable


# -----------------------------------------------------------
# CONDITIONALS
# -----------------------------------------------------------
# [[ ]] is the modern way to write conditions in bash.
# Always use double brackets — they handle edge cases better.

file="data.csv"

if [[ -f "$file" ]]; then
    echo "$file exists, proceeding"
elif [[ -d "$file" ]]; then
    echo "$file is a directory, not a file"
else
    echo "$file not found, aborting"
    exit 1
fi

# Useful file checks:
# -f  → is it a regular file?
# -d  → is it a directory?
# -e  → does it exist (file or directory)?
# -s  → does it exist AND is non-empty?
# -r  → is it readable?
# -w  → is it writable?
# -x  → is it executable?

# String comparisons
status="success"
if [[ "$status" == "success" ]]; then
    echo "Pipeline passed"
fi

if [[ -z "$SOME_VAR" ]]; then
    echo "Variable is empty or unset"
fi

# Number comparisons (use -eq, -ne, -gt, -lt, -ge, -le)
count=42
if [[ $count -gt 0 ]]; then
    echo "Got $count rows"
fi


# -----------------------------------------------------------
# LOOPS
# -----------------------------------------------------------

# Loop through files
for file in *.sql; do
    echo "Running: $file"
    duckdb -c ".read $file"
done

# Loop through a list
for step in extract transform load verify; do
    echo "Step: $step"
done

# Loop with numbers
for i in {1..5}; do
    echo "Iteration $i"
done

# While loop — read a file line by line
while IFS= read -r line; do
    echo "Processing: $line"
done < files_to_process.txt

# While loop — retry logic
max_retries=3
attempt=1
while [[ $attempt -le $max_retries ]]; do
    echo "Attempt $attempt of $max_retries"
    if ./run_pipeline.sh; then
        echo "Success on attempt $attempt"
        break
    fi
    ((attempt++))
    sleep 5
done


# -----------------------------------------------------------
# FUNCTIONS
# -----------------------------------------------------------
# Keep your scripts DRY. If you're copy-pasting the same block
# of code, it should probably be a function.

run_sql() {
    local sql_file="$1"
    echo "[$(date)] Running: $sql_file"
    duckdb -c ".read $sql_file"
}

# Use it
run_sql "01_create_tables.sql"
run_sql "02_load_data.sql"

# Function with return value (via echo)
count_rows() {
    local file="$1"
    wc -l < "$file"
}

rows=$(count_rows "data.csv")
echo "File has $rows rows"


# -----------------------------------------------------------
# EXIT CODES
# -----------------------------------------------------------
# Every command returns an exit code: 0 = success, anything else = failure.
# $? holds the exit code of the last command.

duckdb -c "SELECT 1"
if [[ $? -eq 0 ]]; then
    echo "Query ran fine"
else
    echo "Query failed"
fi

# set -e makes the script stop on ANY non-zero exit code.
# I put this at the top of every pipeline script.
# set -e

# set -o pipefail makes pipe failures caught too.
# Without it, only the last command in a pipe determines success/failure.
# set -o pipefail


# -----------------------------------------------------------
# PRACTICAL PATTERNS
# -----------------------------------------------------------

# Timestamp logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "Starting pipeline"
log "Step 1 complete"

# Check if a command exists before using it
if command -v duckdb &>/dev/null; then
    echo "DuckDB is installed"
else
    echo "DuckDB not found — install it first"
    exit 1
fi

# Default values for variables
output_dir="${OUTPUT_DIR:-./output}"   # use ./output if OUTPUT_DIR isn't set
log_level="${LOG_LEVEL:-INFO}"

echo "Output: $output_dir, Log level: $log_level"
