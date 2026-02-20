# Text Processing — awk, sed, cut, sort, uniq

These commands let you slice and dice text data right from the terminal. Before I knew these, I'd open every CSV in Excel or write a Python script for basic stuff. Now I reach for these first — they're faster and handle surprisingly complex tasks.

---

## cut — Pull Specific Columns

`cut` is the simplest one. Give it a delimiter and column numbers, and it extracts those columns.

```bash
# Get the 1st and 3rd columns from a comma-separated file
cut -d',' -f1,3 data.csv

# Get columns 2 through 5
cut -d',' -f2-5 data.csv

# Tab-delimited? That's the default
cut -f1,3 data.tsv
```

Limitations: `cut` can't handle quoted CSV fields well (commas inside quotes break it). For proper CSV parsing, you'd want `awk` or a real tool. But for quick looks at clean data, it's great.

---

## sort — Order the Output

```bash
sort data.csv                  # alphabetical sort
sort -n numbers.txt            # numeric sort
sort -r data.csv               # reverse sort
sort -t',' -k3 data.csv       # sort by 3rd column (comma-delimited)
sort -t',' -k3 -n data.csv    # sort by 3rd column, numerically
sort -u data.csv               # sort and remove duplicates
```

The `-k` flag specifies which column to sort by. `-t` sets the delimiter. I use these together a lot:

```bash
# Sort a CSV by salary (4th column), highest first
sort -t',' -k4 -n -r data.csv | head -20
```

---

## uniq — Find Duplicates

`uniq` only catches **adjacent** duplicates, so you almost always use it with `sort` first.

```bash
sort names.txt | uniq              # remove duplicates
sort names.txt | uniq -c           # count occurrences
sort names.txt | uniq -d           # only show duplicated lines
sort names.txt | uniq -c | sort -rn  # ranked frequency list
```

That last pattern — `sort | uniq -c | sort -rn` — is one of the most useful things I know. It gives you a frequency table of anything:

```bash
# What are the most common job titles?
cut -d',' -f3 jobs.csv | sort | uniq -c | sort -rn | head -10

# What are the most common error messages?
grep "ERROR" pipeline.log | sort | uniq -c | sort -rn
```

---

## awk — The Swiss Army Knife

`awk` is a mini programming language disguised as a command. I'm not an `awk` expert, but I know enough to be dangerous:

```bash
# Print the 3rd column (space-delimited by default)
awk '{print $3}' data.txt

# Print the 2nd column of a CSV
awk -F',' '{print $2}' data.csv

# Print multiple columns with custom formatting
awk -F',' '{print $1, "-", $3}' data.csv

# Print lines where column 4 is greater than 100000
awk -F',' '$4 > 100000' data.csv

# Sum up a column
awk -F',' '{sum += $4} END {print sum}' data.csv

# Count rows (like wc -l, but sometimes more convenient)
awk 'END {print NR}' data.csv
```

### Things that make `awk` click

- `$1`, `$2`, `$3`... = columns (fields)
- `$0` = the entire line
- `NR` = current row number
- `NF` = number of fields in current row
- `-F','` = set comma as delimiter
- `BEGIN {...}` = runs before processing starts
- `END {...}` = runs after all lines are processed

```bash
# Skip the header and print rows with salary > 150k
awk -F',' 'NR > 1 && $4 > 150000 {print $1, $3, $4}' jobs.csv

# Add a header to output
awk -F',' 'BEGIN {print "Name,Salary"} NR > 1 {print $2 "," $4}' jobs.csv
```

---

## sed — Find & Replace in Files

`sed` is a stream editor. I mainly use it for find-and-replace operations:

```bash
# Replace first occurrence on each line
sed 's/old/new/' file.txt

# Replace ALL occurrences on each line
sed 's/old/new/g' file.txt

# Replace in-place (actually modifies the file)
sed -i 's/old/new/g' file.txt
# On macOS, you need: sed -i '' 's/old/new/g' file.txt

# Delete lines matching a pattern
sed '/DEBUG/d' pipeline.log

# Delete blank lines
sed '/^$/d' file.txt

# Print only lines 5-10
sed -n '5,10p' file.txt
```

### Data cleaning with sed

This comes up more than you'd think:

```bash
# Fix Windows line endings (CRLF → LF)
sed -i 's/\r$//' data.csv

# Remove leading/trailing whitespace
sed 's/^[[:space:]]*//;s/[[:space:]]*$//' data.csv

# Replace tabs with commas (TSV → CSV)
sed 's/\t/,/g' data.tsv > data.csv

# Remove the header row
sed '1d' data.csv > data_no_header.csv
```

---

## Putting It All Together

Here's a realistic data engineering scenario — you've got a raw CSV and need to quickly understand what's in it:

```bash
# What columns are there?
head -n 1 jobs.csv
# job_id,company,title,salary,skills,location

# How many unique companies?
cut -d',' -f2 jobs.csv | sort -u | wc -l

# Top 10 most common job titles
cut -d',' -f3 jobs.csv | sort | uniq -c | sort -rn | head -10

# Average-ish salary check (quick look at the range)
awk -F',' 'NR > 1 && $4 != "" {print $4}' jobs.csv | sort -n | head -5
awk -F',' 'NR > 1 && $4 != "" {print $4}' jobs.csv | sort -n | tail -5

# Clean up and extract just what I need
awk -F',' 'NR > 1 && $4 > 100000 {print $2 "," $3 "," $4}' jobs.csv \
  | sort -t',' -k3 -n -r \
  | head -20
```

None of this replaces proper SQL analysis. But when you're on a server with a new data file and need to understand it in 60 seconds, these commands are unbeatable.
