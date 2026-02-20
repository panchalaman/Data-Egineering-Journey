# Processes, Jobs & Scheduling

When you run a data pipeline, it becomes a process. When it hangs, you need to find and kill it. When you need it to run every morning at 6am, you need cron. This stuff isn't glamorous, but it's essential for keeping pipelines running reliably.

---

## Seeing What's Running

### ps — Process Snapshot

```bash
ps                    # just your processes in this terminal
ps aux                # ALL processes on the system
ps aux | grep duckdb  # find a specific process
```

The output columns that matter:
```
USER       PID  %CPU  %MEM   COMMAND
aman     12345   85.2  12.3   duckdb warehouse.duckdb
```

- **PID** — the process ID (you need this to kill it)
- **%CPU** and **%MEM** — is this thing eating all your resources?
- **COMMAND** — what's actually running

### top / htop — Live Monitoring

```bash
top                   # built-in, always available
htop                  # prettier, easier to use (might need to install)
```

Inside `top`:
- `q` to quit
- `M` to sort by memory
- `P` to sort by CPU
- `k` then enter a PID to kill a process

I use `htop` when I want to watch resource usage during a big data load — see if CPU or memory is the bottleneck.

---

## Killing Processes

When something's stuck:

```bash
# Graceful shutdown
kill 12345            # sends SIGTERM — "please stop"

# Forceful kill (when it won't listen)
kill -9 12345         # sends SIGKILL — "stop NOW"

# Kill by name instead of PID
pkill duckdb          # kill all duckdb processes
killall python3       # same idea, different command
```

My usual flow when a query hangs:

```bash
# 1. Find it
ps aux | grep duckdb
# aman  12345  85.2  12.3  duckdb warehouse.duckdb

# 2. Try graceful first
kill 12345

# 3. If it's still there after a few seconds
kill -9 12345
```

---

## Background & Foreground Jobs

### Running Things in the Background

```bash
# Start a long job in the background
./load_big_data.sh &
# [1] 12345  (job number and PID)

# You get your terminal back immediately
```

### Job Control

```bash
jobs                  # list background jobs
fg                    # bring background job to foreground
fg %2                 # bring job #2 to foreground
bg                    # resume a stopped job in background

# Ctrl+Z — pause (stop) the current job
# Then: bg to resume it in the background
```

The typical workflow:
1. Start a long-running command
2. Realize you forgot to put it in the background
3. Press `Ctrl+Z` to pause it
4. Type `bg` to resume it in the background
5. Keep working in the same terminal

### nohup — Survive SSH Disconnects

This one's important for data engineers. If you're SSH'd into a server and running a 3-hour data load, you don't want it to die if your connection drops.

```bash
# Run something that survives logout
nohup ./overnight_load.sh &
# output goes to nohup.out by default

# Better — specify your own log file
nohup ./overnight_load.sh > load.log 2>&1 &

# Now you can safely disconnect from SSH
```

---

## cron — Scheduling Recurring Jobs

Cron is how you schedule things to run automatically. Every data engineer needs to know this.

### Editing Your Crontab

```bash
crontab -e            # edit your scheduled jobs
crontab -l            # list your scheduled jobs
```

### Cron Syntax

```
┌───────── minute (0-59)
│ ┌─────── hour (0-23)
│ │ ┌───── day of month (1-31)
│ │ │ ┌─── month (1-12)
│ │ │ │ ┌─ day of week (0-6, 0=Sunday)
│ │ │ │ │
* * * * *  command
```

### Examples I've Actually Used

```bash
# Run ETL pipeline every morning at 6:00 AM
0 6 * * * /opt/pipelines/run_daily_etl.sh >> /var/log/etl.log 2>&1

# Run data quality checks every hour
0 * * * * /opt/pipelines/check_data_quality.sh >> /var/log/dq.log 2>&1

# Weekly full refresh on Sunday at midnight
0 0 * * 0 /opt/pipelines/full_refresh.sh >> /var/log/refresh.log 2>&1

# Every 15 minutes during business hours (Mon-Fri, 9am-5pm)
*/15 9-17 * * 1-5 /opt/pipelines/check_incoming.sh
```

### A couple things I learned the hard way:

1. **Always redirect output in cron.** If you don't, cron tries to email it, which usually doesn't work and silently fails.

2. **Use absolute paths.** Cron doesn't load your shell profile, so it doesn't know your PATH. `/usr/local/bin/duckdb` not just `duckdb`.

3. **Test your script manually first.** Never set up a cron job without running the script by hand at least once.

```bash
# Bad (might not find duckdb)
0 6 * * * ./run_pipeline.sh

# Good
0 6 * * * /home/aman/pipelines/run_pipeline.sh >> /home/aman/logs/pipeline.log 2>&1
```

---

## Disk & Storage

Not exactly processes, but I'm including this here because running out of disk space is one of the most common reasons processes fail.

```bash
# How much disk space is left?
df -h
# Filesystem      Size  Used  Avail  Use%  Mounted on
# /dev/sda1       100G   72G    28G   72%  /

# What's using all the space in this directory?
du -sh *
# 4.2G   data/
# 150M   logs/
# 12K    scripts/

# Find the biggest files
du -sh * | sort -rh | head -10

# Find files larger than 1GB
find / -size +1G 2>/dev/null
```

Before any big data load, I check `df -h`. It takes 2 seconds and saves you from that "No space left on device" error in the middle of a 4-hour pipeline run.

### Compressing & Archiving

```bash
# Create a tar.gz archive
tar -czf archive_20240315.tar.gz /data/output/

# Extract
tar -xzf archive_20240315.tar.gz

# Compress a single file
gzip big_export.csv          # creates big_export.csv.gz
gunzip big_export.csv.gz     # decompress

# Check what's in an archive without extracting
tar -tzf archive.tar.gz
```

The flag mnemonics that helped me remember:
- `-c` = create
- `-x` = extract
- `-z` = gzip compression
- `-f` = filename (always comes last)
- `-t` = list contents (test)
- `-v` = verbose (show files as they're processed)

---

## Quick Reference

| What I'm doing | Command |
|---|---|
| Find a running process | `ps aux \| grep name` |
| Watch resource usage | `htop` (or `top`) |
| Kill a stuck process | `kill PID` (or `kill -9 PID`) |
| Run in background | `command &` |
| Survive SSH disconnect | `nohup command > log 2>&1 &` |
| Schedule a daily job | `crontab -e` then add `0 6 * * * ...` |
| Check disk space | `df -h` |
| Find big directories | `du -sh * \| sort -rh` |
| Compress files | `tar -czf archive.tar.gz files/` |
