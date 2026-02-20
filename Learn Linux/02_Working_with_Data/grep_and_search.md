# grep — Searching Through Files

If I had to pick one Linux command that I use more than any other for data work, it's `grep`. It searches for patterns in files. That's it. But "searching for patterns" turns out to be useful for almost everything — finding errors in logs, filtering data, checking if a value exists.

---

## The Basics

```bash
grep "ERROR" pipeline.log           # find lines containing "ERROR"
grep "Python" skills.csv            # find all rows mentioning Python
grep "2024" data.csv                # find all 2024 records
```

By default, `grep` is case-sensitive. `grep "error"` won't find "ERROR". To ignore case:

```bash
grep -i "error" pipeline.log       # finds ERROR, Error, error, etc.
```

---

## Flags I Use All the Time

```bash
grep -c "ERROR" pipeline.log       # COUNT matching lines (don't show them)
grep -n "ERROR" pipeline.log       # show LINE NUMBERS
grep -v "DEBUG" pipeline.log       # INVERT — show lines that DON'T match
grep -r "TODO" ./scripts/          # RECURSIVE — search all files in a directory
grep -l "DROP TABLE" *.sql         # just show FILENAMES that match
```

The ones I reach for most:
- `-c` — quick count ("how many errors?")
- `-v` — filtering out noise ("give me everything except DEBUG lines")
- `-r` — searching across a whole project
- `-l` — when I just need to know which files contain something

---

## Combining Stuff with Pipes

This is where `grep` really shines — chaining it with other commands:

```bash
# How many errors in the log?
grep -c "ERROR" pipeline.log

# Show errors with context (2 lines before and after)
grep -B 2 -A 2 "ERROR" pipeline.log

# Find errors, but filter out ones I've already handled
grep "ERROR" pipeline.log | grep -v "KNOWN_ISSUE"

# Search pipeline output for specific job titles
cat results.csv | grep "Data Engineer"

# Count unique error types
grep "ERROR" pipeline.log | sort | uniq -c | sort -rn
```

That last one is a pattern I use constantly — it gives you a ranked list of how often each unique error appeared.

---

## Searching with Patterns (Regex)

`grep` supports regular expressions, which is a whole skill on its own. But a few patterns handle 90% of what I need:

```bash
# Lines that START with something
grep "^job_id" data.csv             # header row

# Lines that END with something
grep "\.csv$" filelist.txt          # lines ending in .csv

# Match either/or
grep "Python\|SQL\|AWS" skills.csv  # rows with any of these skills
# or use extended regex:
grep -E "Python|SQL|AWS" skills.csv

# Match a digit pattern
grep -E "[0-9]{4}-[0-9]{2}" data.csv  # dates like 2024-03
```

Don't worry about memorizing regex — I still look it up half the time. The important thing is knowing it's possible.

---

## The `find` + `grep` Combo

When you need to search for content across many files:

```bash
# Find all SQL files that reference a specific table
grep -r "job_postings_fact" --include="*.sql" .

# Find which scripts create tables
grep -rl "CREATE TABLE" --include="*.sql" .

# Search all log files for a specific error
find /logs/ -name "*.log" -exec grep -l "OutOfMemory" {} \;
```

That `--include` flag on `grep -r` is really handy — it limits the search to specific file types instead of searching through everything (including binary files, which produces garbage output).

---

## Real Data Engineering Examples

### Checking pipeline health

```bash
# Did anything fail last night?
grep -c "FAILED" /logs/pipeline_$(date +%Y%m%d)*.log

# Show the last 5 errors with timestamps
grep "ERROR" pipeline.log | tail -5

# Which steps failed?
grep "FAILED" pipeline.log | awk '{print $NF}'
```

### Data quality checks

```bash
# Any empty fields in the CSV?
grep ",," data.csv | head

# Check for NULL values
grep -ic "null" data.csv

# How many records per year?
grep -c "2024" data.csv
grep -c "2023" data.csv
```

### Finding things in your codebase

```bash
# Which SQL files use JOINs?
grep -rl "JOIN" --include="*.sql" .

# Where did I define that CTE?
grep -rn "WITH.*AS" --include="*.sql" .

# Find all MERGE operations across the project
grep -rn "MERGE INTO" --include="*.sql" .
```

---

## One More Thing: `grep` + `wc` Is Your Best Friend

I can't overstate how often I use this combo:

```bash
grep "something" file | wc -l
```

It answers "how many?" which is probably the most common question in data engineering. How many rows match? How many errors? How many files contain this table name? `grep | wc -l` every time.
