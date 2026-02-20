# Learn Git

I started using Git because I got tired of files named `pipeline_v2_final_FINAL.sql`. Now I use it for everything — all my SQL scripts, pipeline code, and documentation live in Git. It's one of those skills where the learning curve is steep at first, but then you wonder how you ever worked without it.

---

## Why Git for Data Engineering?

- **Track every change** — who changed what SQL, when, and why
- **Experiment safely** — try a new approach on a branch without breaking what already works
- **Undo mistakes** — broke something? Roll back to the last working version in seconds
- **Collaborate** — code reviews for ETL scripts, pull requests for schema changes
- **Deploy confidently** — CI/CD pipelines that test and deploy your data pipeline code automatically

---

## The Basics I Use Daily

### Starting a project

```bash
# Initialize a new repo
git init
git add .
git commit -m "Initial commit"

# Or clone an existing one
git clone https://github.com/username/repo.git
```

### The core workflow

This is probably 90% of what I do with Git:

```bash
# 1. Check what's changed
git status

# 2. Stage changes
git add filename.sql         # specific file
git add .                    # everything

# 3. Commit with a message
git commit -m "Add skills dimension population script"

# 4. Push to remote
git push
```

### Looking at history

```bash
git log                      # full history
git log --oneline            # compact view
git log --oneline -10        # last 10 commits
git log -- path/to/file.sql  # history of one specific file
git diff                     # what's changed but not staged
git diff --staged            # what's staged but not committed
```

---

## Branching

This is where Git gets really useful. Work on a new feature without touching the main code:

```bash
# Create and switch to a new branch
git checkout -b feature/add-skills-mart

# Do your work, commit as usual
git add .
git commit -m "Add skills mart with time-series aggregation"

# Switch back to main
git checkout main

# Merge your branch in
git merge feature/add-skills-mart

# Delete the branch (it's merged, don't need it anymore)
git branch -d feature/add-skills-mart
```

### When I use branches

- Building a new data mart
- Refactoring an existing pipeline
- Trying a different approach to a query
- Anything I'm not sure about yet

The point is: `main` always works. If my experiment on a branch is a disaster, I just delete the branch and nothing is broken.

---

## Useful Commands

```bash
# Undo the last commit (keep the changes)
git reset --soft HEAD~1

# Discard all uncommitted changes (careful!)
git checkout -- .

# Stash changes temporarily
git stash                    # save current changes aside
git stash pop                # bring them back

# See who changed what line in a file
git blame schema.sql

# Check remote info
git remote -v
```

---

## .gitignore

Tell Git to ignore files that shouldn't be tracked. I always set this up at the start of a project:

```gitignore
# Data files (too big for Git, and often sensitive)
*.csv
*.parquet
*.duckdb

# Credentials
.env
*.key

# OS junk
.DS_Store
Thumbs.db

# Logs and temp files
logs/
*.log
*.tmp
```

---

## My Commit Message Style

I try to write commit messages that tell me what I'll want to know in 6 months:

```bash
# Good
git commit -m "Add MERGE upsert to priority mart for incremental updates"
git commit -m "Fix NULL handling in salary aggregation query"
git commit -m "Refactor build script to use functions for each step"

# Bad
git commit -m "updates"
git commit -m "fix"
git commit -m "stuff"
```

The format I've settled on: start with a verb, describe what changed and why in one line.

---

## Resources

- [Pro Git Book](https://git-scm.com/book/en/v2) — free, comprehensive, and well-written
- [Git cheat sheet](https://education.github.com/git-cheat-sheet-education.pdf) — PDF I keep bookmarked
- `git help <command>` — built-in docs, surprisingly useful
