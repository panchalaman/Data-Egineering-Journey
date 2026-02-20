# Getting Around the File System

The first thing you learn in Linux, and honestly the thing you'll do thousands of times a day. It's simple, but worth getting comfortable with because everything else builds on this.

---

## Where Am I?

```bash
pwd
# /home/aman/projects/data-pipeline
```

That's it. `pwd` = "print working directory." I use it constantly when I'm jumping between folders and lose track of where I am.

---

## What's In This Folder?

```bash
ls              # just the names
ls -l           # long format — permissions, size, dates
ls -la          # same, but show hidden files too (dotfiles)
ls -lh          # human-readable sizes (KB, MB instead of bytes)
ls -lt          # sort by time — most recent first
```

The flags I actually use:
- `-l` — when I need to check file sizes or permissions
- `-a` — when I'm looking for `.env` files, `.gitignore`, config dotfiles
- `-h` — because I can never do byte math in my head
- `-t` — finding the most recently modified file (useful for logs)

You can combine them: `ls -lah` is my go-to.

---

## Moving Around

```bash
cd /home/aman/projects       # absolute path
cd projects                   # relative path (from current dir)
cd ..                         # go up one level
cd ../..                      # go up two levels
cd ~                          # go home
cd -                          # go back to the last directory you were in
```

That last one — `cd -` — is underrated. If you're jumping between two directories (say, your scripts folder and your data folder), it saves a lot of typing.

### Tab Completion

This isn't a command, but it's the #1 productivity thing I learned early. Start typing a path and hit `Tab` — the shell completes it for you. If there are multiple matches, hit `Tab` twice to see all options.

```bash
cd /home/aman/pro<Tab>    # autocompletes to /home/aman/projects/
```

---

## Creating Directories

```bash
mkdir data                     # create a folder
mkdir -p data/raw/2024/Q1     # create nested folders in one go
```

The `-p` flag is key — it creates parent directories if they don't exist. Without it, `mkdir data/raw/2024/Q1` fails unless `data/raw/2024/` already exists.

I typically set up project structures like this:

```bash
mkdir -p project/{data/{raw,processed},scripts,logs,output}
```

That one command creates:
```
project/
├── data/
│   ├── raw/
│   └── processed/
├── scripts/
├── logs/
└── output/
```

Brace expansion (`{}`) is one of those things that feels like a cheat code once you learn it.

---

## Finding Files

When you know what you're looking for but not where it is:

```bash
# Find all CSV files under current directory
find . -name "*.csv"

# Find files modified in the last 24 hours
find . -mtime -1

# Find files larger than 100MB (checking for bloated data dumps)
find . -size +100M

# Find all SQL files and list them with details
find . -name "*.sql" -ls

# Find and delete all .tmp files (careful with this one)
find . -name "*.tmp" -delete
```

The `find` command is incredibly powerful but the syntax is a bit weird at first. The pattern is always `find [where to look] [conditions]`.

### Quick Alternative: `which` and `type`

```bash
which duckdb      # where's the duckdb binary?
which python3     # which python am I actually running?
type ls           # is this a builtin, alias, or program?
```

I use `which` a lot when something isn't working and I suspect I'm running the wrong version of a tool.

---

## Getting a Bird's-Eye View

```bash
tree              # show full directory tree
tree -L 2         # only go 2 levels deep
tree -I "*.pyc"   # ignore certain patterns
```

`tree` isn't always installed by default, but it's worth installing (`brew install tree` on macOS, `apt install tree` on Ubuntu). I used it for all the repo structure diagrams in this project.

---

## Practical Example

Here's what a typical session looks like when I'm starting work on a data pipeline:

```bash
cd ~/projects/data-pipeline      # go to project
ls -la                            # see what's here
tree -L 2                         # get the lay of the land
find . -name "*.sql" | wc -l     # how many SQL files do I have?
mkdir -p output/$(date +%Y%m%d)  # create today's output folder
```

Nothing fancy — but this takes maybe 10 seconds and gives me a clear picture of what I'm working with.
