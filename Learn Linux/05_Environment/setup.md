# Environment Setup

Getting your environment right is one of those things that looks boring but matters a lot. If your PATH is messed up, nothing works. If `duckdb` points to the wrong version, your queries break in mysterious ways. This covers the stuff I've learned about keeping a clean, reliable setup.

---

## Package Managers

The way you install software depends on your OS:

```bash
# macOS (Homebrew)
brew install duckdb
brew install python3
brew install git
brew upgrade duckdb          # update to latest version
brew list                    # see what's installed

# Ubuntu/Debian (apt)
sudo apt update              # refresh package list first
sudo apt install python3
sudo apt install git
sudo apt remove python3      # uninstall

# Check if something's already installed
which duckdb                 # shows path, or nothing
duckdb --version             # check version
python3 --version
```

### Homebrew Tips (macOS)

I use Homebrew for almost everything on my Mac. A few things I wish I'd known earlier:

```bash
brew doctor                  # check for problems
brew cleanup                 # remove old versions
brew search duckdb           # find packages
```

---

## Environment Variables

Environment variables are how you configure your shell and tools without hardcoding paths and credentials in scripts.

```bash
# Set a variable (only for this session)
export DB_PATH="/data/warehouse.duckdb"
export DATA_DIR="/data/raw"

# Use it
duckdb "$DB_PATH"
ls "$DATA_DIR"

# See all environment variables
env

# Check a specific one
echo $PATH
echo $HOME
```

### Important Variables

| Variable | What It Does |
|---|---|
| `PATH` | Where the shell looks for commands — if a command "isn't found," it's probably not in your PATH |
| `HOME` | Your home directory (`~`) |
| `USER` | Your username |
| `SHELL` | Which shell you're using (`/bin/zsh`, `/bin/bash`) |

### The PATH

This is the one that causes the most confusion. When you type `duckdb`, the shell searches through every directory in your `PATH` (in order) looking for a file called `duckdb`.

```bash
echo $PATH
# /usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin

# Directories are separated by colons
# Shell checks /usr/local/bin first, then /usr/bin, etc.
```

If you install something and the shell can't find it, you probably need to add its location to your PATH:

```bash
export PATH="/opt/homebrew/bin:$PATH"
```

That prepends `/opt/homebrew/bin` to the existing PATH. Order matters — directories listed first have priority.

---

## Shell Configuration Files

Setting variables with `export` only lasts for your current terminal session. To make things permanent, you add them to your shell config file.

```bash
# Which shell am I using?
echo $SHELL
# /bin/zsh

# Config files:
# Zsh  → ~/.zshrc
# Bash → ~/.bashrc (interactive) or ~/.bash_profile (login)
```

### What I Put in My `.zshrc`

```bash
# ~/.zshrc

# Path additions
export PATH="/opt/homebrew/bin:$PATH"

# Project shortcuts
export PROJECTS="$HOME/projects"
export DATA_DIR="$HOME/data"

# Aliases (shortcuts for commands I type a lot)
alias ll="ls -lah"
alias gs="git status"
alias gp="git push"
alias ddb="duckdb"

# Default editor
export EDITOR="code"        # VS Code
```

After editing, reload it:

```bash
source ~/.zshrc              # apply changes without opening a new terminal
```

---

## Aliases — Custom Shortcuts

Aliases save a lot of typing for commands you run constantly:

```bash
# Add these to ~/.zshrc

# Navigation
alias projects="cd ~/projects"
alias pipeline="cd ~/projects/data-pipeline"

# Common operations
alias ll="ls -lah"
alias cls="clear"

# Git shortcuts
alias gs="git status"
alias ga="git add ."
alias gc="git commit -m"
alias gp="git push"

# Data engineering
alias ddb="duckdb"
alias rowcount="wc -l"
alias csvhead="head -n 1"
```

Then `gs` instead of `git status`, `ll` instead of `ls -lah`, etc. Small thing, but it adds up over a day.

---

## Virtual Environments (Python)

If you're doing any Python work alongside your data engineering (and you probably are), virtual environments keep your project dependencies separate:

```bash
# Create a virtual environment
python3 -m venv .venv

# Activate it
source .venv/bin/activate

# Now pip installs go into .venv/ instead of globally
pip install pandas duckdb-engine

# Deactivate when done
deactivate
```

I always use virtual environments for Python projects. Global pip installs are a recipe for version conflicts.

---

## A Clean Setup Checklist

When I set up a new machine or server for data engineering work, here's roughly what I do:

```bash
# 1. Install package manager (macOS)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Install core tools
brew install git python3 duckdb

# 3. Set up shell config
cat >> ~/.zshrc << 'EOF'
export PATH="/opt/homebrew/bin:$PATH"
alias ll="ls -lah"
alias gs="git status"
alias ddb="duckdb"
EOF

source ~/.zshrc

# 4. Configure Git
git config --global user.name "Aman Panchal"
git config --global user.email "panchalaman@hotmail.com"
git config --global init.defaultBranch main

# 5. Generate SSH key (for GitHub, remote servers)
ssh-keygen -t ed25519 -C "aman@workstation"

# 6. Verify everything works
git --version
python3 --version
duckdb --version
```

Takes maybe 15 minutes and then your environment is solid. Way better than hitting random "command not found" errors for the next week.
