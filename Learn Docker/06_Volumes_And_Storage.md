# Volumes and Data Storage

Here's the thing about containers that trips everyone up at first: **containers are ephemeral**. When a container stops and is removed, everything inside it is gone. Every file it created, every database record it stored — poof.

That's fine for stateless applications. But data engineering is literally about DATA. You need persistence. That's where volumes come in.

## The Problem

Try this:

```bash
# Run postgres, create a table
docker run -d --name test-db -e POSTGRES_PASSWORD=secret postgres:16
sleep 5
docker exec -it test-db psql -U postgres -c "CREATE TABLE test (id INT, name TEXT);"
docker exec -it test-db psql -U postgres -c "INSERT INTO test VALUES (1, 'hello');"
docker exec -it test-db psql -U postgres -c "SELECT * FROM test;"
# Output: 1 | hello

# Now remove and recreate the container
docker rm -f test-db
docker run -d --name test-db -e POSTGRES_PASSWORD=secret postgres:16
sleep 5
docker exec -it test-db psql -U postgres -c "SELECT * FROM test;"
# ERROR: relation "test" does not exist
```

Your data is gone. The new container started fresh from the image. This is by design — containers are disposable. But you obviously need data to survive container restarts.

## Three Types of Storage

Docker gives you three ways to persist data:

```
┌─────────────────────────────────────────────────────┐
│                    Host Machine                     │
│                                                     │
│  ┌──────────┐   ┌──────────┐   ┌──────────────────┐ │
│  │ Named    │   │ Bind     │   │ tmpfs mount      │ │
│  │ Volume   │   │ Mount    │   │ (in memory only) │ │
│  └────┬─────┘   └────┬─────┘   └────────┬─────────┘ │
│       │              │                  │           │
│       └──────────────┴──────────────────┘           │
│                      │                              │
│              ┌───────▼────────┐                     │
│              │   Container    │                     │
│              │                │                     │
│              │  /var/lib/data │                     │
│              └────────────────┘                     │
└─────────────────────────────────────────────────────┘
```

| Type | Where Data Lives | Managed By | Use Case |
|------|-----------------|-----------|----------|
| **Named Volume** | Docker's internal storage | Docker | Databases, persistent app data |
| **Bind Mount** | Specific path on your machine | You | Development, sharing config files |
| **tmpfs** | RAM (memory) | OS | Sensitive data, temp files (not persisted) |

## Named Volumes — The Standard for Databases

Named volumes are managed by Docker. You don't need to know where they are on disk (Docker handles that). They're the recommended way to persist database data.

### Create and Use a Volume

```bash
# Create a named volume
docker volume create postgres-data

# Run postgres using the volume
docker run -d \
    --name my-db \
    -e POSTGRES_PASSWORD=secret \
    -v postgres-data:/var/lib/postgresql/data \
    -p 5432:5432 \
    postgres:16
```

The key part is `-v postgres-data:/var/lib/postgresql/data`:
- `postgres-data` = the volume name on your machine
- `/var/lib/postgresql/data` = the path inside the container where Postgres stores data

Now test persistence:

```bash
# Create data
docker exec -it my-db psql -U postgres -c "CREATE TABLE jobs (id INT, title TEXT);"
docker exec -it my-db psql -U postgres -c "INSERT INTO jobs VALUES (1, 'Data Engineer');"

# Destroy the container
docker rm -f my-db

# Create a NEW container with the SAME volume
docker run -d \
    --name my-db \
    -e POSTGRES_PASSWORD=secret \
    -v postgres-data:/var/lib/postgresql/data \
    -p 5432:5432 \
    postgres:16

sleep 3

# Data survives!
docker exec -it my-db psql -U postgres -c "SELECT * FROM jobs;"
# Output: 1 | Data Engineer
```

The volume persists independently of the container. You can destroy and recreate containers all day — the data stays.

### Volume Commands

```bash
# List all volumes
docker volume ls

# Inspect a volume (see where it's stored on disk)
docker volume inspect postgres-data

# Remove a volume (WARNING: deletes all data in it!)
docker volume rm postgres-data

# Remove all unused volumes
docker volume prune
```

### Inline Volume Creation

You don't have to create volumes in advance. Docker creates them automatically:

```bash
# This creates the volume "db-data" if it doesn't exist
docker run -d -v db-data:/var/lib/postgresql/data postgres:16
```

## Bind Mounts — Share Files Between Host and Container

Bind mounts map a specific directory on YOUR machine to a path inside the container. This is essential for development.

```bash
# Mount current directory into the container
docker run --rm \
    -v $(pwd):/app \
    -w /app \
    python:3.11-slim \
    python my_script.py
```

Changes you make to files on your machine are **immediately visible** inside the container, and vice versa. No rebuild needed.

### Real Example: Developing a Python Pipeline

```bash
mkdir pipeline && cd pipeline

# Create a script
cat > etl.py << 'EOF'
import pandas as pd
print("Running ETL...")
df = pd.DataFrame({'name': ['SQL', 'Python', 'Docker']})
df.to_csv('/app/output/result.csv', index=False)
print("Done! Check output/result.csv")
EOF

mkdir output

# Run with bind mounts — code AND output directory
docker run --rm \
    -v $(pwd):/app \
    -v $(pwd)/output:/app/output \
    -w /app \
    python:3.11-slim \
    bash -c "pip install pandas -q && python etl.py"

# Check the output — it's on YOUR machine!
cat output/result.csv
```

This is the development workflow:
1. Edit code on your machine (in VS Code or whatever)
2. Run it in a container (consistent environment)
3. Output goes to your machine (via bind mount)
4. No rebuilding the image every time you change code

### Bind Mount Gotchas

**File permissions:**
Files created by the container are often owned by root (since containers run as root by default). You might need to `chown` them afterwards, or run the container with your user ID:

```bash
docker run --rm \
    -v $(pwd):/app \
    -u $(id -u):$(id -g) \
    python:3.11-slim \
    python /app/script.py
```

**Path must be absolute:**
Bind mounts need absolute paths. `$(pwd)` gives you the current absolute path. Don't use relative paths.

**macOS performance:**
Bind mounts on macOS are slower than on Linux because Docker runs in a VM. For large directories (like `node_modules`), use named volumes instead.

## The `-v` Flag vs `--mount` Flag

Two ways to specify mounts. They do the same thing, but `--mount` is more explicit:

```bash
# -v syntax (shorter)
docker run -v postgres-data:/var/lib/postgresql/data postgres:16

# --mount syntax (more explicit)
docker run --mount type=volume,source=postgres-data,target=/var/lib/postgresql/data postgres:16

# Bind mount with --mount
docker run --mount type=bind,source=$(pwd),target=/app python:3.11
```

`--mount` fails loudly if something's wrong (like the source directory doesn't exist). `-v` silently creates missing directories. For scripts and production, prefer `--mount`. For quick CLI work, `-v` is fine.

## Read-Only Mounts

Sometimes you want the container to READ files but not MODIFY them (like config files):

```bash
docker run -v $(pwd)/config:/app/config:ro my-app
```

The `:ro` flag makes the mount read-only. If the container tries to write to `/app/config`, it gets an error.

Great for:
- Configuration files
- SSL certificates
- Reference data

## tmpfs Mounts — RAM-Only Storage

tmpfs mounts store data in memory. Fast, but gone when the container stops. Use for sensitive temp files.

```bash
docker run -d \
    --name secure-app \
    --tmpfs /app/temp:size=100m \
    my-app
```

Not common in data engineering, but useful when processing sensitive data that shouldn't touch disk.

## Volume Patterns for Data Engineering

### Pattern 1: Database with Persistent Storage

```bash
docker run -d \
    --name postgres \
    -e POSTGRES_PASSWORD=secret \
    -v pg-data:/var/lib/postgresql/data \
    -p 5432:5432 \
    postgres:16
```

### Pattern 2: ETL with Input/Output Mounts

```bash
docker run --rm \
    -v $(pwd)/data/raw:/app/input:ro \
    -v $(pwd)/data/processed:/app/output \
    my-etl:v1
```

Input is read-only (raw data shouldn't be modified by the pipeline). Output goes to your machine.

### Pattern 3: Development with Live Code + Volume for Dependencies

```bash
docker run --rm \
    -v $(pwd):/app \
    -v etl-deps:/app/.venv \
    -w /app \
    python:3.11-slim \
    bash -c "pip install -r requirements.txt && python main.py"
```

A named volume for `.venv` means dependencies persist between runs (no reinstalling every time), while your code is bind-mounted for live editing.

### Pattern 4: Sharing Data Between Containers

```bash
# Create a shared volume
docker volume create shared-data

# Producer writes data
docker run --rm -v shared-data:/data alpine sh -c "echo 'hello from producer' > /data/message.txt"

# Consumer reads it
docker run --rm -v shared-data:/data alpine cat /data/message.txt
# Output: hello from producer
```

This pattern shows up when one container generates data and another processes it.

## Backup and Restore Volumes

### Backup a Volume to a Tar File

```bash
docker run --rm \
    -v postgres-data:/source:ro \
    -v $(pwd):/backup \
    alpine \
    tar czf /backup/postgres-backup.tar.gz -C /source .
```

This starts a temporary Alpine container with the source volume mounted read-only, and creates a compressed tar of the data.

### Restore from Backup

```bash
docker volume create postgres-data-restored

docker run --rm \
    -v postgres-data-restored:/target \
    -v $(pwd):/backup:ro \
    alpine \
    tar xzf /backup/postgres-backup.tar.gz -C /target
```

These backup patterns are important for data engineering. Your database volume contains valuable data — have a backup strategy.

## Cleanup

```bash
# Remove specific volume
docker volume rm postgres-data

# Remove all unused volumes (not attached to any container)
docker volume prune

# Nuclear: remove everything (containers, images, volumes, networks)
docker system prune --volumes
```

**Warning:** `docker volume prune` is permanent. There's no undo. Always make sure you don't need the data before pruning.

---

## Practice Problems

### Beginner

1. Create a named volume called `my-data`. Run an Alpine container that writes "hello world" to a file inside the volume. Remove the container. Run a NEW container with the same volume and verify the file is still there.

2. Use a bind mount to share your current directory with a Python container. Create a Python script that writes a file. Verify the file appears on your host machine.

3. Run `docker volume ls` and `docker system df` to see how much space your volumes are using.

### Intermediate

4. Set up a PostgreSQL container with a named volume. Create a database and some tables. Stop the container, remove it, and recreate it with the same volume. Verify your data survived.

5. Create an ETL container that:
   - Reads a CSV from a read-only bind mount (`/input:ro`)
   - Processes it with Python/pandas
   - Writes results to an output bind mount (`/output`)
   - Run it and verify the output on your machine

6. Use the volume backup technique to back up a PostgreSQL data volume to a tar file. Restore it to a new volume and verify the data is intact.

### Advanced

7. Create two containers sharing a volume:
   - Container A: writes a new timestamp to a file every 5 seconds
   - Container B: tails the file and prints new entries
   (Hint: use `sh -c "while true; do date >> /shared/log.txt; sleep 5; done"`)

8. Compare performance: run a Python script that writes 10,000 small files using:
   a. No volume (container filesystem)
   b. Named volume
   c. Bind mount
   Time each with `time docker run ...`. Is there a difference on your OS?

---

**Up next:** [Docker Networking](07_Networking.md) — how containers talk to each other and the outside world.

## Resources

- [Docker Volumes Documentation](https://docs.docker.com/engine/storage/volumes/) — Complete volumes guide
- [Bind Mounts Documentation](https://docs.docker.com/engine/storage/bind-mounts/) — Bind mount details
- [Storage Best Practices](https://docs.docker.com/get-started/docker-concepts/running-containers/persisting-container-data/) — When to use what
