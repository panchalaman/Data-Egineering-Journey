# Permissions & Users

Permissions are one of those things you don't think about until something doesn't work. You write a script, try to run it, and get "Permission denied." Or you deploy a pipeline and it can't read the data directory. That's when you learn this stuff.

---

## How Permissions Work

Every file and directory in Linux has three sets of permissions:
- **Owner** (u) — the user who owns the file
- **Group** (g) — users in the file's group
- **Others** (o) — everyone else

And three types of permission:
- **r** (read) — can you see the contents?
- **w** (write) — can you modify it?
- **x** (execute) — can you run it (scripts) or enter it (directories)?

```bash
ls -l build_warehouse.sh
# -rw-r--r--  1 aman  staff  2048  Mar 15 10:30 build_warehouse.sh
#  ^^^^^^^^^
#  |owner|group|others
#  rw-   r--   r--
```

Reading that: owner can read+write, group can read, others can read. Nobody can execute it (no `x`).

---

## chmod — Changing Permissions

The command I use most often for permissions:

```bash
# Make a script executable
chmod +x build_warehouse.sh

# Now it has the x permission
ls -l build_warehouse.sh
# -rwxr-xr-x  1 aman  staff  2048  Mar 15 10:30 build_warehouse.sh
```

### Symbolic mode (readable)

```bash
chmod u+x file.sh          # add execute for owner
chmod g+w file.csv          # add write for group
chmod o-r file.csv          # remove read for others
chmod a+r file.csv          # add read for all (a = all)
chmod u+rwx,g+rx,o-rwx file.sh   # specific combination
```

### Numeric mode (faster once you learn it)

Each permission has a number: r=4, w=2, x=1. Add them up for each group.

```bash
chmod 755 script.sh         # rwxr-xr-x (owner: full, others: read+execute)
chmod 644 data.csv          # rw-r--r-- (owner: read+write, others: read only)
chmod 700 private.sh        # rwx------ (only owner has access)
chmod 666 shared_data.csv   # rw-rw-rw- (everyone can read and write)
```

The common ones I actually remember:
- `755` — scripts and executables (everyone can run, only you can edit)
- `644` — data files and configs (everyone can read, only you can edit)
- `700` — private stuff (only you)
- `600` — SSH keys, credentials (only you, no execute)

---

## chown — Changing Ownership

```bash
# Change owner
chown aman data.csv

# Change owner and group
chown aman:dataeng data.csv

# Recursive (everything in a directory)
chown -R aman:dataeng /data/warehouse/
```

This comes up when:
- A script running as a service account creates files you need to access
- You copy files from one server to another and ownership gets messed up
- Docker containers create files as root and you can't edit them afterward

---

## Who Am I?

```bash
whoami              # your username
id                  # your user ID, group ID, and all groups
groups              # which groups you belong to
```

I use `whoami` when I SSH into a server and need to verify I'm logged in as the right user (especially when dealing with service accounts).

---

## sudo — Do It As Root

```bash
sudo apt install duckdb          # install system packages
sudo chown aman /data/           # change ownership of protected directories
sudo chmod 755 /opt/scripts/     # fix permissions on system directories
```

`sudo` runs a command as the superuser (root). You'll need it for anything that touches system-level stuff — installing packages, modifying system directories, managing services.

One thing to be careful of: if you create files with `sudo`, they'll be owned by root, and you might have trouble accessing them later as your normal user. I've been bitten by this with `sudo mkdir` and `sudo touch`.

---

## SSH — Remote Access

This is how you connect to remote servers, which in data engineering means connecting to database hosts, cloud VMs, production machines, etc.

```bash
# Connect to a remote server
ssh aman@server.company.com

# Connect on a different port
ssh -p 2222 aman@server.company.com

# Run a command remotely without opening a session
ssh aman@server.company.com "df -h /data"
```

### SSH Keys (way better than passwords)

```bash
# Generate a key pair
ssh-keygen -t ed25519 -C "aman@workstation"

# Copy your public key to the server
ssh-copy-id aman@server.company.com

# Now you can connect without entering a password
ssh aman@server.company.com
```

### scp — Copy Files Between Machines

```bash
# Upload a file to a server
scp data.csv aman@server:/data/incoming/

# Download from a server
scp aman@server:/data/exports/output.csv ./

# Copy an entire directory
scp -r scripts/ aman@server:/opt/pipelines/
```

---

## Real Scenarios I've Run Into

### "Permission denied" when running a script

```bash
# Problem
./build_warehouse.sh
# zsh: permission denied: ./build_warehouse.sh

# Fix
chmod +x build_warehouse.sh
./build_warehouse.sh
# works!
```

### Pipeline can't read files created by another service

```bash
# Check who owns the files
ls -la /data/incoming/
# -rw-------  1 etl_service  etl  50M  Mar 15 data.csv
# Your user can't read this

# Fix — add group read permission
sudo chmod g+r /data/incoming/*.csv
# Or change ownership
sudo chown aman /data/incoming/*.csv
```

### Securing credential files

```bash
# .env files with database passwords should be locked down
chmod 600 .env
ls -l .env
# -rw-------  1 aman  staff  128  Mar 15 .env
# Only you can read it
```

---

## Quick Reference

| What I'm doing | Command |
|---|---|
| Make script runnable | `chmod +x script.sh` |
| Standard data file permissions | `chmod 644 data.csv` |
| Lock down credentials | `chmod 600 .env` |
| Check who owns a file | `ls -la file` |
| See my user/group info | `id` |
| Transfer files to/from servers | `scp` |
| Connect to remote servers | `ssh` |
