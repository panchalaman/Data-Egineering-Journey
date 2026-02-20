# Viewing & Inspecting Files

Probably the most useful set of commands for data engineering. Before you load a CSV into a database, you should know what's in it — how many rows, what the headers look like, whether there's junk at the bottom. These commands let you peek at data without opening it in a full editor.

---

## Quick Look at a File

```bash
cat file.csv          # dump the whole thing to screen
```

`cat` is fine for small files — config files, short SQL scripts, a 20-row CSV. For anything big, it'll flood your terminal. Use `less` instead:

```bash
less big_data.csv     # scrollable viewer
```

Inside `less`:
- Arrow keys or `j`/`k` to scroll
- `/pattern` to search for something
- `q` to quit
- `G` to jump to the end, `g` to jump to the top

I use `less` when I want to browse around a file. For quick checks though, `head` and `tail` are faster.

---

## Peek at the Top or Bottom

```bash
head data.csv             # first 10 lines
head -n 5 data.csv        # first 5 lines
head -n 1 data.csv        # just the header row
```

```bash
tail data.csv             # last 10 lines
tail -n 20 data.csv       # last 20 lines
tail -f pipeline.log      # FOLLOW the file — live updates
```

That last one — `tail -f` — is gold for monitoring. Start a pipeline in one terminal, open another terminal and run `tail -f pipeline.log`, and you can watch the progress in real-time. I do this constantly.

### Checking What You Got

This is my go-to pattern before loading any data file:

```bash
head -n 1 data.csv        # what are the columns?
wc -l data.csv            # how many rows?
tail -n 3 data.csv        # any junk at the bottom?
```

Takes 5 seconds, saves you from loading garbage into your warehouse.

---

## Counting Things

```bash
wc data.csv               # lines, words, bytes
wc -l data.csv            # just line count
wc -w data.csv            # just word count
wc -c data.csv            # just byte count
```

I almost always use `wc -l`. Quick row count is probably the most common data quality check there is.

```bash
# How many rows in each CSV?
wc -l *.csv

# How many SQL files in the project?
find . -name "*.sql" | wc -l

# How many error lines in the log?
grep "ERROR" pipeline.log | wc -l
```

---

## Comparing Files

```bash
diff file1.csv file2.csv          # show differences line by line
diff -y file1.csv file2.csv       # side-by-side comparison
diff --brief dir1/ dir2/          # just tell me if files differ
```

I use `diff` to check pipeline outputs against expected results. If `diff` produces no output, the files are identical — which is exactly what you want to see after refactoring a query.

```bash
# Did my refactored query produce the same output?
duckdb -c ".read old_query.sql" > old_output.csv
duckdb -c ".read new_query.sql" > new_output.csv
diff old_output.csv new_output.csv
# (no output = identical = good)
```

---

## File Size & Type

```bash
ls -lh data.csv           # see the size in human-readable format
file data.csv             # what kind of file is this?
stat data.csv             # detailed info — size, timestamps, permissions
```

The `file` command is surprisingly useful. Sometimes a file has a `.csv` extension but it's actually gzipped, or it's UTF-16 encoded, or it has Windows line endings. `file` will tell you:

```bash
file data.csv
# data.csv: UTF-8 Unicode text, with CRLF line terminators

file archive.csv
# archive.csv: gzip compressed data
```

Knowing this early saves you from weird bugs later.

---

## Putting It Together

Here's what inspecting a new data file typically looks like for me:

```bash
# What kind of file is it?
file raw_data.csv
# raw_data.csv: UTF-8 Unicode text

# How big?
ls -lh raw_data.csv
# -rw-r--r--  1 aman  staff  147M  Mar 15 data.csv

# How many rows?
wc -l raw_data.csv
# 1,248,003  raw_data.csv

# What are the columns?
head -n 1 raw_data.csv
# job_id,company_name,job_title,salary_avg,skills,posted_date

# Does it look clean at the end?
tail -n 3 raw_data.csv

# Any null values I should worry about?
grep -c "NULL\|,," raw_data.csv
```

All of this happens in under a minute and tells me exactly what I'm dealing with before writing any SQL.
