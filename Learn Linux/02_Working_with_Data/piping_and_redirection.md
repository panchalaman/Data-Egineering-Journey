# Piping & Redirection

This is where Linux goes from "a bunch of individual commands" to "a data processing engine." The idea is simple: take the output of one command and feed it into another. Once this clicks, you realize it's basically the same concept as building data pipelines — small, focused operations chained together.

---

## The Pipe: `|`

The pipe takes the output of the command on the left and sends it as input to the command on the right.

```bash
# Count how many CSV files are here
ls *.csv | wc -l

# Find the 5 largest files in a directory
ls -lhS | head -5

# Get unique values from a column
cut -d',' -f3 data.csv | sort -u

# Top 10 most common skills
cut -d',' -f5 jobs.csv | sort | uniq -c | sort -rn | head -10
```

You can chain as many pipes as you want. Each one takes the previous output and does something with it. That last example has four pipes — and it reads pretty naturally once you break it down:

1. `cut` — grab the 5th column
2. `sort` — sort alphabetically (required for `uniq`)
3. `uniq -c` — count duplicates
4. `sort -rn` — sort by count, descending
5. `head -10` — show the top 10

---

## Output Redirection: `>` and `>>`

Send output to a file instead of the screen.

```bash
# Write output to a file (overwrites if it exists)
grep "Data Engineer" jobs.csv > de_jobs.csv

# Append to a file (doesn't overwrite)
echo "Pipeline started at $(date)" >> pipeline.log

# Save query results
duckdb -c "SELECT * FROM skills_dim" > skills_export.csv
```

The key difference:
- `>` — overwrites the file. Gone. Whatever was there before is gone.
- `>>` — appends. Adds to the end. Existing content stays.

I've lost output by accidentally using `>` when I meant `>>`. It happens once, and then you never forget.

---

## Input Redirection: `<`

```bash
# Feed a SQL file into DuckDB
duckdb < build_warehouse.sql

# Same idea with other tools
psql -d mydb < schema.sql
mysql < import.sql
```

Less common than output redirection, but essential for running SQL scripts against database CLIs.

---

## Error Redirection: `2>` and `2>&1`

Every command has two output streams:
- **stdout** (standard output) — the normal output, file descriptor 1
- **stderr** (standard error) — error messages, file descriptor 2

By default, both go to your screen. You can separate them:

```bash
# Save errors to a file, normal output to screen
duckdb < query.sql 2> errors.log

# Save output to one file, errors to another
./run_pipeline.sh > output.log 2> errors.log

# Combine both into one file
./run_pipeline.sh > all_output.log 2>&1

# Throw away errors entirely (sometimes useful)
find / -name "*.csv" 2>/dev/null
```

That last pattern — `2>/dev/null` — sends errors to the void. I use it when `find` spits out a bunch of "Permission denied" messages for directories I don't care about.

### The `2>&1` thing

`2>&1` means "send stderr to the same place as stdout." The order matters:

```bash
# This works — both stdout and stderr go to output.log
./pipeline.sh > output.log 2>&1

# This does NOT do the same thing (order is wrong)
./pipeline.sh 2>&1 > output.log
```

It's confusing at first. In practice, I remember it as "redirect stdout first, then redirect stderr to join it."

---

## tee — Write to a File AND the Screen

`tee` is like a T-junction in plumbing. Output flows both to a file and to the screen.

```bash
# Watch pipeline progress AND log it
./run_pipeline.sh | tee pipeline.log

# Append mode
./run_pipeline.sh | tee -a pipeline.log
```

I use `tee` constantly for pipeline runs. I want to watch the output in real-time, but I also want it saved in case something fails and I need to review it later.

```bash
# Real pattern I use:
echo "=== Pipeline run $(date) ===" | tee -a pipeline.log
duckdb -c ".read build_warehouse.sql" 2>&1 | tee -a pipeline.log
echo "=== Completed $(date) ===" | tee -a pipeline.log
```

---

## Here Documents: `<<`

A way to pass multi-line input to a command. I use this mostly in scripts:

```bash
# Run multiple SQL commands
duckdb <<EOF
SELECT COUNT(*) FROM job_postings_fact;
SELECT COUNT(*) FROM skills_dim;
SELECT COUNT(*) FROM company_dim;
EOF
```

The `EOF` marker is just a convention — you can use any string. Everything between the two markers gets fed into the command as input.

---

## Practical Patterns for Data Engineering

### Pipeline run with full logging

```bash
./build_warehouse.sh 2>&1 | tee "pipeline_$(date +%Y%m%d_%H%M%S).log"
```

### Quick data inspection pipeline

```bash
# How many records per month?
cut -d',' -f6 jobs.csv | cut -d'-' -f1,2 | sort | uniq -c | sort -rn
```

### Extract, filter, and save

```bash
# Pull high-salary data engineer jobs and save
grep "Data Engineer" jobs.csv | awk -F',' '$4 > 150000' > high_salary_de.csv
```

### Sanity check after a pipeline run

```bash
# Count rows in each output file
wc -l output/*.csv | sort -n
```

---

The whole idea of pipes and redirection is: small tools, each doing one thing, chained together. That's also the philosophy behind building good data pipelines — keep each step focused and composable.
