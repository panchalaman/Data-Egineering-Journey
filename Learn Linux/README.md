# Learn Linux

I started learning Linux because I kept running into it everywhere — SSH into a server, debug a cron job, figure out why a pipeline died at 3am. You can't do data engineering seriously without being comfortable in a terminal.

I picked up the basics through the [NDG Linux Unhatched](https://www.netacad.com/courses/os-it/ndg-linux-unhatched) course from Cisco, and then just kept going — writing shell scripts, automating SQL pipelines, breaking things and fixing them.

---

## Why I'm Learning This

Pretty simple — production data pipelines don't run in GUIs. They run on Linux servers, inside containers, on cloud VMs. If something breaks, you need to SSH in, read logs, check disk space, kill a hung process. That's all terminal work.

Here's what I've noticed maps directly to data engineering:

- **Shell scripting** — automating ETL runs, scheduling with cron
- **File operations** — inspecting CSVs, counting rows, parsing columns with `awk` and `grep`
- **Process management** — monitoring long-running jobs, killing stuff that's stuck
- **Permissions** — making scripts executable, managing access on shared servers
- **SSH & file transfers** — working with remote data servers
- **Environment setup** — installing tools, managing PATH, setting credentials

---

## What's Here

```
Learn Linux/
├── README.md                              ← You are here
│
├── 01_Basics/                             ← Start here
│   ├── navigation.md                      # Getting around the file system
│   ├── file_operations.md                 # Copy, move, remove, symlinks
│   └── viewing_files.md                   # cat, head, tail, wc, diff
│
├── 02_Working_with_Data/                  ← The data engineering bread and butter
│   ├── grep_and_search.md                 # Searching files and finding patterns
│   ├── text_processing.md                 # awk, sed, cut, sort, uniq
│   └── piping_and_redirection.md          # Pipes, >, >>, 2>, tee
│
├── 03_System/                             ← Managing the machine
│   ├── permissions.md                     # chmod, chown, SSH, users
│   └── processes_and_jobs.md              # ps, kill, cron, disk, background jobs
│
├── 04_Shell_Scripting/                    ← Automating everything
│   ├── basics.sh                          # Variables, loops, conditionals, functions
│   ├── pipeline_automation.sh             # Full ETL pipeline script template
│   └── error_handling.sh                  # Logging, retries, traps, validation
│
├── 05_Environment/                        ← Setting things up properly
│   └── setup.md                           # Packages, PATH, .zshrc, aliases, venvs
│
└── Learn Git/                             ← Version control
    └── README.md                          # Git basics, branching, .gitignore
```

If you're new to Linux and here for data engineering, I'd suggest going through the folders in order — each one builds on the last.

---

## Commands I Actually Use

I'm not going to list every Linux command ever. These are the ones I keep coming back to, organized by what I'm usually trying to do. Each section has its own detailed file with examples — links below.

### [Getting Around & Managing Files](./01_Basics/navigation.md)

`ls`, `cd`, `pwd` — the basics, but I use them hundreds of times a day. `find` is great when I'm looking for a log file somewhere deep in a directory. `tree` gives me a quick picture of a project layout.

`mkdir`, `rm`, `cp`, `mv` — setting up project folders, moving data files around, cleaning up temp outputs. More on this in [file operations](./01_Basics/file_operations.md).

### [Looking at Data](./01_Basics/viewing_files.md)

This is where Linux really shines for data work:

- `head -n 5 data.csv` — check the headers before loading anything
- `tail -f pipeline.log` — watch a pipeline run in real-time
- `wc -l data.csv` — quick row count (saved me so many times)
- `grep "ERROR" pipeline.log` — find what went wrong ([more on grep](./02_Working_with_Data/grep_and_search.md))
- `cat data.csv | sort | uniq -c | sort -rn` — quick duplicate check
- `cut -d',' -f2,5 data.csv` — pull specific columns from a CSV
- `awk -F',' '{print $3}' data.csv` — same idea, more flexible ([more on text processing](./02_Working_with_Data/text_processing.md))
- `diff expected.csv actual.csv` — did my pipeline produce the right output?

### [Piping & Redirection](./02_Working_with_Data/piping_and_redirection.md)

This clicked for me pretty quickly — it's basically chaining transformations, which is what data engineering is:

```bash
# Count how many 2024 records are in a file
cat data.csv | grep "2024" | wc -l

# Run a query and save output + errors separately
duckdb < query.sql > results.csv 2> errors.log

# Watch output and save it at the same time
./run_pipeline.sh | tee pipeline.log
```

### [Processes & Jobs](./03_System/processes_and_jobs.md)

- `ps aux | grep duckdb` — is my query still running?
- `top` / `htop` — how much memory is this thing eating?
- `kill` — stop a runaway process
- `nohup ./long_job.sh &` — run something overnight without worrying about SSH dropping
- `crontab -e` — schedule a pipeline to run every morning

### [Permissions](./03_System/permissions.md)

Mostly comes up when a script won't run:

```bash
chmod +x build_warehouse.sh    # make it executable
chown user:group data/         # fix ownership issues
```

Or when I need to SSH into a server: `ssh`, `scp` for moving files between machines.

### Disk & Storage

`df -h` and `du -sh *` — I check these before any big data load. Nothing worse than a pipeline failing halfway through because you ran out of disk. More in [processes & jobs](./03_System/processes_and_jobs.md).

`tar`, `gzip` — compressing data exports and archived files.

### [Setting Up Environments](./05_Environment/setup.md)

```bash
# Install tools
brew install duckdb    # macOS
apt install python3    # Ubuntu

# Check what's installed
which duckdb
python3 --version

# Set environment variables
export DB_PATH="/data/warehouse.duckdb"
```

---

## [Shell Scripting](./04_Shell_Scripting/)

This is where everything comes together. I started writing shell scripts to automate my SQL pipelines instead of running each file manually. I've got detailed scripts in the [04_Shell_Scripting](./04_Shell_Scripting/) folder — [basics](./04_Shell_Scripting/basics.sh), [pipeline automation](./04_Shell_Scripting/pipeline_automation.sh), and [error handling patterns](./04_Shell_Scripting/error_handling.sh).

Here's the basic pattern I use:

```bash
#!/bin/bash
set -e  # stop immediately if anything fails

echo "Starting pipeline..."
duckdb -c ".read 01_extract.sql"
duckdb -c ".read 02_transform.sql"
duckdb -c ".read 03_load.sql"
echo "Done."
```

And when I need logging (which is most of the time):

```bash
#!/bin/bash
set -e
LOG="pipeline_$(date +%Y%m%d_%H%M%S).log"

run_step() {
    echo "[$(date)] Running: $1" | tee -a "$LOG"
    if duckdb -c ".read $1" >> "$LOG" 2>&1; then
        echo "[$(date)] Done: $1" | tee -a "$LOG"
    else
        echo "[$(date)] FAILED: $1" | tee -a "$LOG"
        exit 1
    fi
}

run_step "01_create_tables.sql"
run_step "02_load_data.sql"
run_step "03_verify_schema.sql"
```

I actually used this pattern for real in my SQL projects — check out [build_warehouse.sh](../Data-Engineering/SQL_COURSE/Projects/3_Flat_to_WH_Build/build_warehouse.sh) if you want to see it in action.

---

## Learn Git

Version control is one of those things that feels tedious until it saves you. I use Git for all my SQL scripts and pipeline code — it's how I track changes, experiment on branches without breaking things, and keep a clean history of what changed and why.

→ [**Explore Learn Git**](./Learn%20Git/)

---

## What I'm Working On Next

- [x] File system basics
- [x] Permissions & users
- [x] Piping & redirection
- [x] Process management
- [x] Shell scripting basics
- [x] Git fundamentals
- [ ] Advanced shell scripting (functions, arrays, error traps)
- [ ] Networking (`curl`, `wget`, `netstat`)
- [ ] Docker from the command line
- [ ] Deeper `awk`/`sed`/`jq` for log parsing

---

## Resources That Helped

- [NDG Linux Unhatched](https://www.netacad.com/courses/os-it/ndg-linux-unhatched) — where I started, solid for the fundamentals
- [linuxcommand.org](https://linuxcommand.org/) — good reference when I forget syntax
- [shellscript.sh](https://www.shellscript.sh/) — helped me level up my scripting
- [Pro Git Book](https://git-scm.com/book/en/v2) — the definitive Git reference