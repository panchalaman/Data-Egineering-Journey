# File Operations — Copy, Move, Remove, and All That

This is the stuff that replaces dragging and dropping files in a GUI. Once you get used to it, it's actually faster — especially when you're dealing with hundreds of data files.

---

## Copying Files

```bash
cp data.csv backup_data.csv             # simple copy
cp data.csv /backups/                   # copy to another directory
cp -r project/ project_backup/          # copy entire directory (-r = recursive)
cp *.csv /data/raw/                     # copy all CSVs to a folder
```

The `-r` flag matters. Without it, `cp` won't copy directories — it'll just complain.

### Flags I Use

- `-r` — recursive, needed for directories
- `-v` — verbose, shows what's being copied (nice for big operations)
- `-i` — interactive, asks before overwriting (safety net)

```bash
cp -rv /data/exports/ /backups/exports_20240315/
# copies everything and shows each file as it goes
```

---

## Moving & Renaming

`mv` does double duty — it moves files AND renames them. Same command.

```bash
# Renaming
mv old_name.csv new_name.csv
mv pipeline_v1.sh pipeline_v2.sh

# Moving to a different directory
mv data.csv /data/processed/
mv *.log /logs/archive/

# Both at once — move AND rename
mv /data/raw/dump.csv /data/processed/cleaned_dump.csv
```

One thing that tripped me up early: `mv` doesn't have a `-r` flag because it doesn't need one. Moving a directory just changes its path — it doesn't copy-then-delete like `cp -r` would.

---

## Removing Files

```bash
rm file.csv                   # delete a file
rm -r directory/             # delete a directory and everything in it
rm -f file.csv               # force delete (no "are you sure?" prompt)
rm -rf old_project/          # the classic "nuke it from orbit"
```

**Be careful with `rm`.** There's no trash can in Linux. Once it's gone, it's gone.

I've developed a habit of doing a dry run first:

```bash
# First, see what would be deleted
ls *.tmp

# Then delete
rm *.tmp
```

Or using `-i` for interactive confirmation:

```bash
rm -i *.csv
# rm: remove 'data1.csv'? y
# rm: remove 'data2.csv'? n
```

### Cleaning Up After Pipeline Runs

This comes up a lot in data work — you run a pipeline, it generates temp files, and you need to clean up:

```bash
# Remove all temp files
rm -f /tmp/pipeline_*.csv

# Remove output older than 7 days
find /output/ -name "*.csv" -mtime +7 -delete

# Remove empty directories
find /data/processed/ -type d -empty -delete
```

---

## Creating Empty Files

```bash
touch notes.txt               # create an empty file (or update its timestamp)
touch log_{01..05}.txt        # create log_01.txt through log_05.txt
```

Honestly, I use `touch` more for updating timestamps than creating files. But it's handy for quickly creating placeholder files.

---

## Symbolic Links

Think of these as shortcuts. I use them when I want one file to be accessible from multiple places without duplicating it.

```bash
# Create a symlink
ln -s /data/warehouse/main.duckdb ./db

# Now I can do:
duckdb ./db
# instead of:
duckdb /data/warehouse/main.duckdb
```

Useful for:
- Linking to a shared config file across projects
- Creating a shortcut to a deeply nested directory
- Pointing "current" at the latest version of something

```bash
ln -s /data/exports/export_20240315/ /data/exports/latest
# now /data/exports/latest always points to the most recent export
```

---

## Wildcards & Patterns

This isn't a separate command, but it's everywhere in file operations:

```bash
*           # matches anything
?           # matches exactly one character
[abc]       # matches a, b, or c
{a,b,c}     # expands to a b c (brace expansion)

# Examples
ls *.csv                    # all CSV files
ls data_202?.csv            # data_2020.csv through data_2029.csv
cp pipeline_{01,02,03}.sql /scripts/
rm output_[0-9]*.tmp        # remove numbered temp files
```

---

## Real-World Scenario

Here's something I actually do — archiving a day's output before starting a fresh pipeline run:

```bash
# Create archive directory with today's date
mkdir -p /data/archive/$(date +%Y%m%d)

# Move yesterday's output there
mv /data/output/*.csv /data/archive/$(date +%Y%m%d)/

# Verify
ls -lh /data/archive/$(date +%Y%m%d)/

# Now the output directory is clean for today's run
ls /data/output/
# (empty — ready to go)
```

This kind of file hygiene sounds boring, but it's the difference between a pipeline that works reliably and one that blows up because yesterday's files confuse today's run.
