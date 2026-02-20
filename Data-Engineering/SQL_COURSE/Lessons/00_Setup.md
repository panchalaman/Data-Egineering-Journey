# Setting Up DuckDB + MotherDuck

Before you can run any of the lessons, you need DuckDB installed and the job postings database connected. This takes about 5 minutes.

## Step 1 — Install DuckDB

### macOS (Homebrew)

```bash
brew install duckdb
```

### macOS / Linux (Manual)

```bash
# Download the latest release
curl -LO https://github.com/duckdb/duckdb/releases/latest/download/duckdb_cli-osx-universal.tar.gz

# Extract it
tar -xzf duckdb_cli-osx-universal.tar.gz

# Move to your PATH
sudo mv duckdb /usr/local/bin/

# Verify
duckdb --version
```

For Linux, replace the download URL with the Linux build:
```bash
curl -LO https://github.com/duckdb/duckdb/releases/latest/download/duckdb_cli-linux-amd64.zip
unzip duckdb_cli-linux-amd64.zip
sudo mv duckdb /usr/local/bin/
```

### Windows

Download the CLI from [duckdb.org/docs/installation](https://duckdb.org/docs/installation/) and add it to your PATH. Or use `winget`:
```
winget install DuckDB.cli
```

### Verify Installation

```bash
duckdb --version
```

You should see something like `v1.x.x`. Any recent version works fine.

---

## Step 2 — Connect to the Database

The dataset lives on [MotherDuck](https://motherduck.com/) — a cloud service for DuckDB. You don't need an account to attach a shared database.

### Option A: In-Memory Session (Quickest)

Just launch DuckDB and attach the shared database:

```bash
duckdb
```

Then inside the DuckDB prompt:

```sql
INSTALL motherduck;
LOAD motherduck;

ATTACH 'md:_share/data_jobs/87603155-cdc7-4c80-85ad-3a6b0d760d93' AS data_jobs;

USE data_jobs;
```

That's it. You now have access to all four tables.

### Option B: Persistent Local Database

If you want a local `.duckdb` file so you don't re-attach every time:

```bash
duckdb jobs.duckdb
```

Then:

```sql
INSTALL motherduck;
LOAD motherduck;

ATTACH 'md:_share/data_jobs/87603155-cdc7-4c80-85ad-3a6b0d760d93' AS data_jobs;

-- Copy the tables locally (one-time, takes ~30 seconds)
CREATE TABLE job_postings_fact AS SELECT * FROM data_jobs.job_postings_fact;
CREATE TABLE company_dim AS SELECT * FROM data_jobs.company_dim;
CREATE TABLE skills_dim AS SELECT * FROM data_jobs.skills_dim;
CREATE TABLE skills_job_dim AS SELECT * FROM data_jobs.skills_job_dim;

-- Detach MotherDuck — now everything is local
DETACH data_jobs;
```

Now you can open `jobs.duckdb` anytime without an internet connection:

```bash
duckdb jobs.duckdb
```

I'd recommend Option B if you're working through the full course. Queries run faster on local data and you don't need wifi.

---

## Step 3 — Verify the Tables

Run these to make sure everything loaded correctly:

```sql
-- List all tables
SHOW TABLES;

-- Quick row counts
SELECT 'job_postings_fact' AS table_name, COUNT(*) AS rows FROM job_postings_fact
UNION ALL
SELECT 'company_dim', COUNT(*) FROM company_dim
UNION ALL
SELECT 'skills_dim', COUNT(*) FROM skills_dim
UNION ALL
SELECT 'skills_job_dim', COUNT(*) FROM skills_job_dim;

-- Peek at the data
SELECT * FROM job_postings_fact LIMIT 5;
SELECT * FROM company_dim LIMIT 5;
SELECT * FROM skills_dim LIMIT 5;
SELECT * FROM skills_job_dim LIMIT 5;
```

You should see:
- **job_postings_fact** — hundreds of thousands of rows (job postings with salary, location, dates)
- **company_dim** — company names and links
- **skills_dim** — skill names and categories
- **skills_job_dim** — bridge table linking jobs to skills

---

## Step 4 — Run the Lessons

### From the CLI

```bash
# Run a specific lesson file
duckdb jobs.duckdb < 1.02_SELECT.sql

# Or open interactive mode and copy-paste queries
duckdb jobs.duckdb
```

### From VS Code

Install the [DuckDB extension for VS Code](https://marketplace.visualstudio.com/items?itemName=DuckDB.duckdb) and point it at your `jobs.duckdb` file. Then you can run queries directly from `.sql` files.

---

## The Schema

Here's how the tables connect — this is a classic star schema:

```
                        ┌──────────────┐
                        │  company_dim │
                        │──────────────│
                        │ company_id   │ ◄──┐
                        │ name         │    │
                        │ link         │    │
                        └──────────────┘    │
                                            │
┌──────────────┐    ┌───────────────────┐   │
│  skills_dim  │    │ job_postings_fact  │   │
│──────────────│    │───────────────────│   │
│ skill_id     │◄─┐ │ job_id            │   │
│ skills       │  │ │ company_id ───────│───┘
│ type         │  │ │ job_title         │
└──────────────┘  │ │ job_title_short   │
                  │ │ salary_year_avg   │
┌──────────────┐  │ │ job_location      │
│skills_job_dim│  │ │ job_posted_date   │
│──────────────│  │ │ job_work_from_home│
│ job_id ──────│──┤ └───────────────────┘
│ skill_id ────│──┘
└──────────────┘
```

- **job_postings_fact** → **company_dim**: via `company_id` (many jobs per company)
- **job_postings_fact** → **skills_job_dim** → **skills_dim**: via bridge table (many-to-many)

---

## Troubleshooting

**"motherduck extension not found"**
```sql
INSTALL motherduck;
LOAD motherduck;
```
Run both lines. The first downloads it, the second activates it.

**"unable to connect" or timeout errors**
Check your internet connection. MotherDuck requires network access for the initial attach. If you're behind a VPN or firewall, try Option B (copy tables locally) and work offline after that.

**"table not found" errors when running lessons**
Make sure you either `USE data_jobs;` (Option A) or copied the tables locally (Option B). The lessons assume the tables are in your default schema.

**Queries are slow**
You're probably querying directly from MotherDuck over the network. Copy the tables locally (Option B) for much faster performance.
